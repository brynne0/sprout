<script setup lang="ts">
defineOptions({ name: 'PlantDetailView' })

import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useElementSize } from '@vueuse/core'
import {
  ArrowLeft,
  Bug,
  Check,
  Clock,
  HandHeart,
  Leaf,
  MoreHorizontal,
  Pencil,
  Plus,
  Ruler,
  Scissors,
  Sprout,
  Sun,
  Thermometer,
} from '@lucide/vue'
import { supabase } from '@/lib/supabase'
import type { Plant, CataloguePlant, Reminder, TaskType, Window } from '@/types'
import { handleApiError, formatDate } from '@/lib/utils'
import { TASKS, TASK_ORDER } from '@/lib/tasks'
import { computeTracksForPlant, dateToX, inWindow, todayMonthDay } from '@/lib/trackUtils'
import type { TrackType } from '@/lib/trackUtils'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import { Skeleton } from '@/components/ui/skeleton'
import PlantRow from '@/components/PlantRow.vue'
import PlantActions from '@/components/PlantActions.vue'
import PlantIcon from '@/components/PlantIcon.vue'
import PlantDatesField from '@/components/PlantDatesField.vue'
import RemindersCard from '@/components/RemindersCard.vue'
import TaskDatePicker from '@/components/TaskDatePicker.vue'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardAction, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { toast } from 'vue-sonner'

const route = useRoute()
const router = useRouter()

const isCatalogue = computed(() => route.meta.cataloguePlant === true)

const plant = ref<Plant | CataloguePlant | null>(null)
const loading = ref(true)
const editingNotes = ref(false)
const savingNotes = ref(false)
const notes = ref('')
const reminders = ref<Reminder[]>([])

async function fetchReminders(id: string) {
  const { data } = await supabase
    .from('reminders')
    .select('id, plant_id, type, due_date')
    .eq('plant_id', id)
    .throwOnError()
  reminders.value = data
}

// quiet keeps the page on screen while refreshing after a change
async function fetchPlant(id: string, quiet = false) {
  if (!quiet) {
    loading.value = true
    plant.value = null
    editingNotes.value = false
  }
  try {
    if (isCatalogue.value) {
      const { data } = await supabase
        .from('catalogue_with_details')
        .select('*')
        .eq('id', id)
        .maybeSingle()
        .throwOnError()
      plant.value = data as unknown as CataloguePlant | null
    } else {
      const { data } = await supabase
        .from('plants_with_details')
        .select('*')
        .eq('id', id)
        .maybeSingle()
        .throwOnError()
      plant.value = data as unknown as Plant | null
      notes.value = (plant.value as Plant)?.notes ?? ''
      await fetchReminders(id)
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
  const today = todayMonthDay()
  const open = (ws: Window[] | undefined) => (ws ?? []).some((w) => inWindow(today, w))
  const result: StatusEntry[] = []
  if (open(plant.value.sowing_windows)) result.push({ label: 'Sow now', type: 'sowing' })
  if (open(plant.value.transplant_windows))
    result.push({ label: 'Transplant now', type: 'transplant' })
  if (open(plant.value.harvest_windows)) result.push({ label: 'Harvest now', type: 'harvest' })
  return result
})

const logEntries = computed(() => {
  if (!gardenPlant.value) return []
  const p = gardenPlant.value
  return TASK_ORDER.flatMap((type) =>
    (p[TASKS[type].column] ?? []).map((date) => ({ type, date, key: `${date}-${type}` })),
  ).sort((a, b) => b.date.localeCompare(a.date))
})

const editingLog = ref(false)
const addingReminder = ref(false)

const dateWindows = computed(() => ({
  sow: plant.value?.sowing_windows ?? [],
  transplant: plant.value?.transplant_windows ?? [],
  harvest: plant.value?.harvest_windows ?? [],
}))

type DateColumn = 'sow_dates' | 'repot_dates' | 'transplant_dates' | 'harvest_dates'

async function saveDates(column: DateColumn, dates: string[]) {
  if (!gardenPlant.value) return
  const update: Partial<Record<DateColumn, string[]>> = { [column]: dates }
  try {
    await supabase.from('plants').update(update).eq('id', gardenPlant.value.id).throwOnError()
    plant.value = { ...gardenPlant.value, [column]: dates }
  } catch {
    toast.error('Failed to save dates')
  }
}

async function addReminder(type: TaskType, dueDate: string) {
  if (!gardenPlant.value) return
  try {
    await supabase
      .from('reminders')
      .insert({ plant_id: gardenPlant.value.id, type, due_date: dueDate })
      .throwOnError()
    await fetchReminders(gardenPlant.value.id)
    addingReminder.value = false
  } catch {
    toast.error('Failed to add reminder')
  }
}

async function saveNotes() {
  if (!gardenPlant.value) return
  savingNotes.value = true
  try {
    await supabase
      .from('plants')
      .update({ notes: notes.value })
      .eq('id', gardenPlant.value.id)
      .throwOnError()
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
  plant.value
    ? computeTracksForPlant(plant.value, monthWidth.value, undefined, reminders.value)
    : [],
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
  const p = plant.value
  return [
    { icon: Sun, label: 'Position', value: p.position },
    { icon: Thermometer, label: 'Hardiness', value: p.hardiness },
    { icon: Sprout, label: 'Germination', value: p.germination },
    { icon: Leaf, label: 'Sow to transplant', value: p.sowing_to_transplant },
    { icon: Ruler, label: 'Spacing', value: p.spacing },
    { icon: Clock, label: 'Seed to harvest', value: p.seed_to_harvest },
    { icon: HandHeart, label: 'Care', value: p.care },
    { icon: Bug, label: 'Pests', value: p.pests },
    { icon: Scissors, label: 'Harvest', value: p.harvest },
  ].filter((r) => r.value)
})
</script>

<template>
  <div
    v-if="!loading && !plant"
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
        <Button
          variant="ghost"
          size="icon-sm"
          class="bg-background/70"
          aria-label="Back"
          @click="router.back()"
        >
          <ArrowLeft class="size-4.5" />
        </Button>

        <PlantActions
          v-if="plant && !isCatalogue"
          :plant="plant as Plant"
          @archived="router.back()"
          @restored="router.back()"
          @deleted="router.back()"
        >
          <Button
            variant="ghost"
            size="icon-sm"
            class="bg-background/70"
            aria-label="Plant actions"
          >
            <MoreHorizontal />
          </Button>
        </PlantActions>
        <div v-else class="w-7" />
      </div>

      <!-- Plant identity -->
      <div v-if="loading" class="flex gap-3.5 sm:gap-5 items-center">
        <Skeleton class="w-16 h-16 rounded-xl sm:w-20 sm:h-20 sm:rounded-2xl" />
        <div class="flex-1 flex flex-col gap-1.5">
          <Skeleton class="h-2.5 w-16" />
          <Skeleton class="h-5.5 sm:h-7 w-40" />
          <Skeleton class="h-4 w-24" />
        </div>
      </div>

      <template v-else-if="plant">
        <div class="flex gap-3.5 sm:gap-5 items-center">
          <PlantIcon
            :name="plant.name"
            :icon="(plant as Plant).icon"
            :colour="(plant as Plant).colour"
            class="w-16 h-16 rounded-xl sm:w-20 sm:h-20 sm:rounded-2xl text-2xl sm:text-3xl border [--icon-base:var(--background)]"
          />
          <div class="min-w-0 flex-1">
            <div
              v-if="(plant as Plant).category_name"
              class="text-2xs font-semibold text-muted-foreground uppercase tracking-wider mb-0.5"
            >
              {{ (plant as Plant).category_name }}
            </div>
            <h1 class="text-2xl sm:text-3xl font-bold tracking-tight text-primary leading-none">
              {{ plant.name }}
            </h1>
            <p
              v-if="plant.variety"
              class="text-sm sm:text-base italic text-muted-foreground mt-0.5"
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
          <Badge v-for="s in activeStatuses" :key="s.type" :variant="s.type">
            {{ s.label }}
          </Badge>
          <Badge v-for="s in plant.suitability ?? []" :key="s" variant="outline" class="capitalize">
            {{ s }}
          </Badge>
        </div>
      </template>
    </div>

    <LoadingLeaves v-if="loading" />

    <!-- BODY -->
    <div
      v-else-if="plant"
      class="grid grid-cols-1 sm:grid-cols-[1.25fr_1fr] gap-3 sm:gap-4 p-4 sm:p-8 items-start"
    >
      <!-- LEFT COL -->
      <div class="flex flex-col gap-3 sm:gap-4">
        <Card>
          <CardHeader class="border-b border-border/40">
            <CardTitle>Timeline</CardTitle>
          </CardHeader>
          <CardContent class="flex flex-col gap-0.5">
            <div class="flex">
              <div class="w-15 shrink-0" />
              <div
                ref="timelineRef"
                class="flex flex-1 text-2xs tracking-[0.02em] text-muted-foreground"
              >
                <div v-for="m in MONTH_LABELS" :key="m" class="flex-1 text-center">{{ m[0] }}</div>
              </div>
            </div>
            <div v-for="row in labelledRows" :key="row.type" class="flex">
              <div
                class="w-15 shrink-0 text-xs font-medium text-muted-foreground flex items-center"
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
          </CardContent>
        </Card>

        <Card v-if="infoRows.length">
          <CardHeader class="border-b border-border/40">
            <CardTitle>Growing</CardTitle>
          </CardHeader>
          <CardContent class="p-0">
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
          </CardContent>
        </Card>
      </div>

      <!-- RIGHT COL: garden-specific only -->
      <div v-if="!isCatalogue" class="flex flex-col gap-3 sm:gap-4">
        <RemindersCard :reminders="reminders" @changed="fetchPlant(gardenPlant!.id, true)">
          <div v-if="addingReminder" class="pt-3">
            <TaskDatePicker
              when="future"
              :windows="dateWindows"
              :year="gardenPlant!.year"
              @pick="addReminder"
            />
          </div>
          <Button
            variant="ghost-muted"
            size="xs"
            class="mt-2 w-full"
            @click="addingReminder = !addingReminder"
          >
            <component :is="addingReminder ? Check : Plus" class="size-3.5" />
            {{ addingReminder ? 'Done' : 'Remind me' }}
          </Button>
        </RemindersCard>

        <Card>
          <CardHeader class="border-b border-border/40">
            <CardTitle>Log</CardTitle>
            <CardAction>
              <Button variant="ghost-muted" size="xs" @click="editingLog = !editingLog">
                <component :is="editingLog ? Check : Pencil" class="size-3.5" />
                {{ editingLog ? 'Done' : 'Edit' }}
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent :class="editingLog ? '' : 'p-0'">
            <PlantDatesField
              v-if="editingLog"
              :sow="gardenPlant!.sow_dates ?? []"
              :repot="gardenPlant!.repot_dates ?? []"
              :transplant="gardenPlant!.transplant_dates ?? []"
              :harvest="gardenPlant!.harvest_dates ?? []"
              :windows="dateWindows"
              :year="gardenPlant!.year"
              @update:sow="(v: string[]) => saveDates('sow_dates', v)"
              @update:repot="(v: string[]) => saveDates('repot_dates', v)"
              @update:transplant="(v: string[]) => saveDates('transplant_dates', v)"
              @update:harvest="(v: string[]) => saveDates('harvest_dates', v)"
            />
            <template v-else>
              <p
                v-if="logEntries.length === 0"
                class="px-3.5 py-3 text-sm italic text-muted-foreground opacity-70"
              >
                Nothing logged yet.
              </p>
              <div
                v-for="(entry, i) in logEntries"
                :key="entry.key"
                class="flex items-center gap-2.5 px-3.5 py-2.5 text-sm"
                :class="i > 0 ? 'border-t border-border/40' : ''"
              >
                <component
                  :is="TASKS[entry.type].icon"
                  class="w-3.5 h-3.5 shrink-0"
                  :style="{ color: TASKS[entry.type].soft }"
                />
                <span class="flex-1"
                  >{{ TASKS[entry.type].done }} · {{ formatDate(entry.date) }}</span
                >
              </div>
            </template>
          </CardContent>
        </Card>

        <!-- Notes card -->
        <Card>
          <CardHeader class="border-b border-border/40">
            <CardTitle>Notes</CardTitle>
            <CardAction>
              <Button
                variant="ghost-muted"
                size="xs"
                :disabled="savingNotes"
                @click="editingNotes ? saveNotes() : (editingNotes = true)"
              >
                <component :is="editingNotes ? Check : Pencil" class="size-3.5" />
                {{ editingNotes ? (savingNotes ? 'Saving…' : 'Done') : 'Edit' }}
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent>
            <Textarea v-if="editingNotes" v-model="notes" />
            <p
              v-else-if="notes"
              class="text-sm text-muted-foreground leading-relaxed whitespace-pre-wrap"
            >
              {{ notes }}
            </p>
            <p v-else class="text-sm italic text-muted-foreground opacity-70">No notes yet.</p>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>
