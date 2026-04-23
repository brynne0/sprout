<script setup lang="ts">
defineOptions({ name: 'PlantDetailView' })

import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useElementSize } from '@vueuse/core'
import {
  ArrowLeft,
  Check,
  ChevronDown,
  Clock,
  Leaf,
  MoreHorizontal,
  Pencil,
  Plus,
  Repeat2,
  Ruler,
  Scissors,
  Sprout,
  Sun,
  Thermometer,
} from 'lucide-vue-next'
import { getApiPlantsById, getApiCatalogueById, putApiPlantsById } from '@/client'
import type { Plant, CataloguePlant } from '@/client'
import { handleApiError, formatDate } from '@/lib/utils'
import { computeTracksForPlant, dateToX } from '@/lib/trackUtils'
import type { TrackType } from '@/lib/trackUtils'
import LoadingSprout from '@/components/LoadingSprout.vue'
import PlantRow from '@/components/PlantRow.vue'
import PlantActions from '@/components/PlantActions.vue'
import PlantDatesDialogue from '@/components/PlantDatesDialogue.vue'
import { Textarea } from '@/components/ui/textarea'
import { toast } from 'vue-sonner'

const route = useRoute()
const router = useRouter()

const isCatalogue = computed(() => route.meta.cataloguePlant === true)

const plant = ref<Plant | CataloguePlant | null>(null)
const loading = ref(true)
const editingNotes = ref(false)
const savingNotes = ref(false)
const notes = ref('')

async function fetchPlant(id: string) {
  loading.value = true
  plant.value = null
  editingNotes.value = false
  try {
    if (isCatalogue.value) {
      const res = await getApiCatalogueById({ path: { id }, throwOnError: true })
      plant.value = res.data ?? null
    } else {
      const res = await getApiPlantsById({ path: { id }, throwOnError: true })
      plant.value = res.data ?? null
      notes.value = (plant.value as Plant)?.notes ?? ''
    }
  } catch (err) {
    handleApiError(err, 'Failed to load plant')
  }
  loading.value = false
}

watch(
  () => route.params.id as string | undefined,
  (id) => {
    if (id) fetchPlant(id)
  },
  { immediate: true },
)

const gardenPlant = computed(() => (isCatalogue.value ? null : (plant.value as Plant | null)))

type StatusEntry = { label: string; type: TrackType }

const activeStatuses = computed<StatusEntry[]>(() => {
  if (!plant.value) return []
  const now = new Date()
  const todayNum = (now.getMonth() + 1) * 100 + now.getDate()
  const inWindow = (w: { start: string; end: string }) => {
    const [sm, sd] = w.start.split('-').map(Number)
    const [em, ed] = w.end.split('-').map(Number)
    const sn = sm! * 100 + sd!
    const en = em! * 100 + ed!
    return sn > en ? todayNum >= sn || todayNum <= en : todayNum >= sn && todayNum <= en
  }
  const result: StatusEntry[] = []
  if ((plant.value.sowing_windows ?? []).some(inWindow))
    result.push({ label: 'Sow now', type: 'sowing' })
  if ((plant.value.transplant_windows ?? []).some(inWindow))
    result.push({ label: 'Transplant now', type: 'transplant' })
  if ((plant.value.harvest_windows ?? []).some(inWindow))
    result.push({ label: 'Harvest now', type: 'harvest' })
  return result
})

type TaskEntry = { type: 'sow' | 'transplant' | 'repot'; date: string; label: string; key: string }

const allTasks = computed<TaskEntry[]>(() => {
  if (!gardenPlant.value) return []
  return [
    ...(gardenPlant.value.sow_dates ?? []).map((d) => ({
      type: 'sow' as const,
      date: d,
      label: 'Sow',
      key: `${d}-sow`,
    })),
    ...(gardenPlant.value.transplant_dates ?? []).map((d) => ({
      type: 'transplant' as const,
      date: d,
      label: 'Transplant',
      key: `${d}-transplant`,
    })),
    ...(gardenPlant.value.repot_dates ?? []).map((d) => ({
      type: 'repot' as const,
      date: d,
      label: 'Repot',
      key: `${d}-repot`,
    })),
  ].sort((a, b) => a.date.localeCompare(b.date))
})

const upcomingTasks = computed(() => {
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  return allTasks.value.filter((t) => new Date(t.date) >= now)
})

const pastTasks = computed(() => {
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  return allTasks.value.filter((t) => new Date(t.date) < now).reverse()
})

const showHistory = ref(false)

async function saveNotes() {
  if (!gardenPlant.value) return
  savingNotes.value = true
  try {
    await putApiPlantsById({
      path: { id: gardenPlant.value.id },
      body: {
        plant_type_id: gardenPlant.value.plant_type_id ?? '',
        catalogue_id: gardenPlant.value.catalogue_id,
        custom_variety: gardenPlant.value.custom_variety,
        sow_dates: gardenPlant.value.sow_dates,
        transplant_dates: gardenPlant.value.transplant_dates,
        notes: notes.value,
        year: gardenPlant.value.year,
      },
      throwOnError: true,
    })
    plant.value = { ...gardenPlant.value, notes: notes.value }
    toast.success('Notes saved')
  } catch {
    toast.error('Failed to save notes')
  }
  savingNotes.value = false
  editingNotes.value = false
}

const MONTH_LABELS = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
]
const TRACK_LABELS: Record<TrackType, string> = {
  sowing: 'Sow',
  transplant: 'Transplant',
  harvest: 'Harvest',
}

const timelineRef = ref<HTMLElement | null>(null)
const { width: timelineWidth } = useElementSize(timelineRef)
const monthWidth = computed(() => (timelineWidth.value > 0 ? timelineWidth.value / 12 : 0))
const todayX = computed(() =>
  monthWidth.value > 0
    ? dateToX(new Date().getMonth() + 1, new Date().getDate(), monthWidth.value)
    : null,
)

const plantTracks = computed(() =>
  plant.value ? computeTracksForPlant(plant.value, monthWidth.value) : [],
)

const labelledRows = computed(() =>
  (['sowing', 'transplant', 'harvest'] as TrackType[])
    .map((type) => ({
      type,
      label: TRACK_LABELS[type],
      tracks: plantTracks.value.filter((t) => t.type === type),
    }))
    .filter((r) => r.tracks.length > 0),
)

const infoRows = computed(() => {
  if (!plant.value) return []
  return [
    { icon: Sun, label: 'Position', value: plant.value.position },
    { icon: Thermometer, label: 'Hardiness', value: plant.value.hardiness },
    { icon: Ruler, label: 'Spacing', value: plant.value.spacing },
    { icon: Clock, label: 'Seed to harvest', value: plant.value.seed_to_harvest },
    { icon: Leaf, label: 'Sow to transplant', value: plant.value.sowing_to_transplant },
    { icon: Scissors, label: 'Harvest', value: plant.value.harvest },
  ].filter((r) => r.value)
})
</script>

<template>
  <div v-if="loading" class="flex items-center justify-center min-h-[70vh]">
    <LoadingSprout />
  </div>

  <div
    v-else-if="!plant"
    class="flex items-center justify-center min-h-[70vh] text-sm text-muted-foreground"
  >
    Plant not found.
  </div>

  <div v-else>
    <div
      class="px-4 pt-[calc(env(safe-area-inset-top)+0.875rem)] pb-3.5 sm:px-8 sm:pb-5"
      style="
        background: color-mix(in oklab, var(--primary) 12%, var(--background));
        border-bottom: 1px solid color-mix(in oklab, var(--foreground) 8%, transparent);
      "
    >
      <!-- Nav row -->
      <div class="flex items-center justify-between mb-3.5 sm:mb-5">
        <button
          class="p-1.5 rounded-lg"
          style="background: color-mix(in oklab, var(--background) 70%, transparent)"
          @click="router.back()"
        >
          <ArrowLeft class="w-4.5 h-4.5" />
        </button>

        <PlantActions
          v-if="!isCatalogue"
          :plant="plant as Plant"
          @archived="router.back()"
          @deleted="router.back()"
          @updated="fetchPlant(route.params.id as string)"
        >
          <button
            class="p-1.5 rounded-lg"
            style="background: color-mix(in oklab, var(--background) 70%, transparent)"
          >
            <MoreHorizontal class="w-4 h-4" />
          </button>
        </PlantActions>
        <div v-else class="w-7" />
      </div>

      <!-- Plant identity -->
      <div class="flex gap-3.5 sm:gap-5 items-center">
        <div
          class="shrink-0 flex items-center justify-center w-16 h-16 rounded-xl sm:w-20 sm:h-20 sm:rounded-2xl overflow-hidden"
          style="background: color-mix(in oklab, var(--background) 75%, transparent)"
        >
          <img
            v-if="(plant as Plant).icon"
            :src="`/icons/${(plant as Plant).icon}`"
            :alt="plant.name"
            class="w-[82%] h-[82%] object-contain"
          />
          <Sprout v-else class="w-8 h-8 sm:w-10 sm:h-10 text-primary" />
        </div>
        <div class="min-w-0 flex-1">
          <div
            v-if="(plant as Plant).category_name"
            class="text-[10px] text-muted-foreground uppercase mb-0.5"
            style="letter-spacing: 0.12em"
          >
            {{ (plant as Plant).category_name }}
          </div>
          <h1 class="text-[22px] sm:text-[28px] font-bold tracking-tight text-primary leading-none">
            {{ plant.name }}
          </h1>
          <p
            v-if="plant.variety"
            class="text-sm sm:text-[15px] italic text-muted-foreground mt-0.5"
          >
            '{{ plant.variety }}'
          </p>
        </div>
      </div>

      <!-- Chips row -->
      <div
        v-if="activeStatuses.length || (plant.suitability ?? []).length"
        class="mt-3.5 flex flex-wrap gap-1.5"
      >
        <span
          v-for="s in activeStatuses"
          :key="s.type"
          class="text-[11px] px-2.5 py-1 rounded-full border"
          :class="[`track-${s.type}-bg`, `track-${s.type}-border`, `track-${s.type}-text`]"
        >
          {{ s.label }}
        </span>
        <span
          v-for="s in plant.suitability ?? []"
          :key="s"
          class="text-[11px] px-2.5 py-1 rounded-full capitalize"
          style="
            background: color-mix(in oklab, var(--background) 65%, transparent);
            border: 1px solid color-mix(in oklab, var(--foreground) 10%, transparent);
            color: var(--muted-foreground);
          "
        >
          {{ s }}
        </span>
      </div>
    </div>

    <!-- BODY -->
    <div class="grid grid-cols-1 sm:grid-cols-[1.25fr_1fr] gap-3 sm:gap-4 p-4 sm:p-8 items-start">
      <!-- LEFT COL -->
      <div class="flex flex-col gap-3 sm:gap-4">
        <div class="rounded-xl border bg-card">
          <div class="px-3.5 pt-3.5 pb-2.5 border-b border-border/40">
            <h3 class="text-sm font-semibold">Timeline</h3>
          </div>
          <div class="p-3.5 flex flex-col gap-0.5">
            <div class="flex">
              <div class="w-19.5 shrink-0" />
              <div
                ref="timelineRef"
                class="flex flex-1 text-[10px] tracking-[0.02em] text-muted-foreground"
              >
                <div v-for="m in MONTH_LABELS" :key="m" class="flex-1 text-center">{{ m[0] }}</div>
              </div>
            </div>
            <div v-for="row in labelledRows" :key="row.type" class="flex">
              <div
                class="w-19.5 shrink-0 text-[11px] font-medium text-muted-foreground flex items-center"
              >
                {{ row.label }}
              </div>
              <PlantRow
                :tracks="row.tracks"
                :month-width="monthWidth"
                :show-dots="true"
                :today-x="todayX"
              />
            </div>
          </div>
        </div>

        <div v-if="infoRows.length" class="rounded-xl border bg-card">
          <div class="px-3.5 pt-3.5 pb-2.5 border-b border-border/40">
            <h3 class="text-sm font-semibold">Growing</h3>
          </div>
          <div
            v-for="(row, i) in infoRows"
            :key="row.label"
            class="flex items-start gap-3 px-3.5 py-2.5 text-sm"
            :class="i > 0 ? 'border-t border-border/40' : ''"
          >
            <component :is="row.icon" class="w-3.5 h-3.5 mt-0.5 shrink-0 text-muted-foreground" />
            <span class="w-27.5 shrink-0 text-muted-foreground">{{ row.label }}</span>
            <span class="text-foreground leading-snug">{{ row.value }}</span>
          </div>
        </div>
      </div>

      <!-- RIGHT COL: garden-specific only -->
      <div v-if="!isCatalogue" class="flex flex-col gap-3 sm:gap-4">
        <!-- Tasks card -->
        <div class="rounded-xl border bg-card">
          <div
            class="flex items-center justify-between px-3.5 pt-3.5 pb-2.5 border-b border-border/40"
          >
            <h3 class="text-sm font-semibold">Tasks</h3>
            <span v-if="upcomingTasks.length" class="text-xs text-muted-foreground">
              {{ upcomingTasks.length }} upcoming
            </span>
          </div>
          <div>
            <p
              v-if="upcomingTasks.length === 0"
              class="px-3.5 py-3 text-sm italic text-muted-foreground opacity-70"
            >
              No upcoming tasks.
            </p>
            <div
              v-for="(task, i) in upcomingTasks"
              :key="task.key"
              class="flex items-center gap-2.5 px-3.5 py-2.5 text-sm"
              :class="i > 0 ? 'border-t border-border/40' : ''"
            >
              <Sprout v-if="task.type === 'sow'" class="w-4 h-4 text-primary opacity-60 shrink-0" />
              <Leaf
                v-else-if="task.type === 'transplant'"
                class="w-3.5 h-3.5 shrink-0 opacity-75 text-yellow-600"
              />
              <Repeat2 v-else class="w-3.5 h-3.5 shrink-0 opacity-75 text-yellow-500" />
              <span class="flex-1 font-medium">{{ task.label }} - {{ formatDate(task.date) }}</span>
            </div>

            <button
              v-if="pastTasks.length"
              class="flex items-center gap-1.5 w-full px-3.5 py-2.5 border-t border-border/40 text-xs text-muted-foreground"
              @click="showHistory = !showHistory"
            >
              <ChevronDown
                class="w-3.5 h-3.5 transition-transform duration-200"
                :class="{ 'rotate-180': showHistory }"
              />
              {{ pastTasks.length }} past {{ pastTasks.length === 1 ? 'task' : 'tasks' }}
            </button>
            <template v-if="showHistory">
              <div
                v-for="task in pastTasks"
                :key="task.key"
                class="flex items-center gap-2.5 px-3.5 py-2.5 text-sm border-t border-border/40 opacity-50"
              >
                <Sprout v-if="task.type === 'sow'" class="w-4 h-4 text-primary shrink-0" />
                <Leaf
                  v-else-if="task.type === 'transplant'"
                  class="w-3.5 h-3.5 shrink-0 text-yellow-600"
                />
                <Repeat2 v-else class="w-3.5 h-3.5 shrink-0 text-yellow-500" />
                <span class="flex-1">{{ task.label }} - {{ formatDate(task.date) }}</span>
              </div>
            </template>

            <PlantDatesDialogue
              :plant="gardenPlant!"
              @saved="fetchPlant(route.params.id as string)"
            >
              <button
                class="flex items-center justify-center gap-1.5 w-full px-3.5 py-2.5 border-t border-border/40 bg-transparent text-xs text-muted-foreground"
              >
                <Plus class="w-3.5 h-3.5" />
                Add date
              </button>
            </PlantDatesDialogue>
          </div>
        </div>

        <!-- Notes card -->
        <div class="rounded-xl border bg-card">
          <div
            class="flex items-center justify-between px-3.5 pt-3.5 pb-2.5 border-b border-border/40"
          >
            <h3 class="text-sm font-semibold">Notes</h3>
            <button
              class="flex items-center gap-1 text-xs text-muted-foreground disabled:opacity-50"
              :disabled="savingNotes"
              @click="editingNotes ? saveNotes() : (editingNotes = true)"
            >
              <component :is="editingNotes ? Check : Pencil" class="w-3.5 h-3.5" />
              {{ editingNotes ? (savingNotes ? 'Saving…' : 'Done') : 'Edit' }}
            </button>
          </div>
          <div class="px-3.5 py-3">
            <Textarea v-if="editingNotes" v-model="notes" />
            <p
              v-else-if="notes"
              class="text-sm text-muted-foreground leading-relaxed whitespace-pre-wrap"
            >
              {{ notes }}
            </p>
            <p v-else class="text-sm italic text-muted-foreground opacity-70">No notes yet.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
