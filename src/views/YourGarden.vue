<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Sprout, Shovel, Scissors, Replace, ChevronDown, ChevronRight } from 'lucide-vue-next'
import PlantCalendar from '@/components/PlantCalendar.vue'
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import type { Plant, Window as PlantWindow } from '@/client'
import { getApiPlants } from '@/client'
import PlantDialogue from '@/components/PlantDialogue.vue'
import PlantActions from '@/components/PlantActions.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import PageHeader from '@/components/layout/PageHeader.vue'
import { handleApiError } from '@/lib/utils'

const router = useRouter()
const plants = ref<Plant[]>([])
const dialogOpen = ref(false)
const loading = ref(true)

// Window status utils
function monthDay(d: Date): number {
  return (d.getMonth() + 1) * 100 + d.getDate()
}

function inWindow(today: Date, w: PlantWindow): boolean {
  const ps = w.start.split('-').map(Number)
  const pe = w.end.split('-').map(Number)
  const t = monthDay(today)
  const s = (ps[0] ?? 0) * 100 + (ps[1] ?? 0)
  const e = (pe[0] ?? 0) * 100 + (pe[1] ?? 0)
  return s <= e ? t >= s && t <= e : t >= s || t <= e
}

function windowStatus(plant: Plant, today: Date) {
  const sowNow = (plant.sowing_windows ?? []).some((w) => inWindow(today, w))
  const transplantNow = (plant.transplant_windows ?? []).some((w) => inWindow(today, w))
  const harvestNow = (plant.harvest_windows ?? []).some((w) => inWindow(today, w))
  const hasSowed = (plant.sow_dates ?? []).length > 0
  const hasTransplanted = (plant.transplant_dates ?? []).length > 0
  return { sowNow, transplantNow, harvestNow, hasSowed, hasTransplanted }
}

function currentBucket(plant: Plant, today: Date): BucketKey {
  const s = windowStatus(plant, today)
  if (s.harvestNow && (s.hasSowed || s.hasTransplanted)) return 'harvest'
  if (s.transplantNow && s.hasSowed && !s.hasTransplanted) return 'transplant'
  if (s.sowNow && !s.hasSowed) return 'sow'
  if (s.harvestNow) return 'harvest'
  if (s.transplantNow) return 'transplant'
  if (s.sowNow) return 'sow'
  if (s.hasSowed || s.hasTransplanted) return 'growing'
  return 'resting'
}

function plantHint(plant: Plant, today: Date): { label: string; color: string } | null {
  const s = windowStatus(plant, today)
  if (s.harvestNow) return null
  if (s.transplantNow) {
    if (s.hasTransplanted) return { label: 'Transplanted', color: 'var(--color-muted-foreground)' }
    if (s.hasSowed) return { label: 'Transplant', color: 'var(--color-transplant)' }
  }
  if (s.sowNow) {
    if (s.hasSowed) return { label: 'Sown', color: 'var(--color-muted-foreground)' }
    return { label: 'Sow', color: 'var(--color-primary)' }
  }
  return null
}

const today = new Date()
const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate())

// Task reminders
const MS_DAY = 24 * 60 * 60 * 1000

function parseISO(s: string): Date {
  const p = s.substring(0, 10).split('-').map(Number)
  return new Date(p[0] ?? 0, (p[1] ?? 1) - 1, p[2] ?? 1)
}

function fmtRelative(date: Date): string {
  const diff = Math.round((date.getTime() - todayStart.getTime()) / MS_DAY)
  if (diff === 0) return 'Today'
  if (diff === 1) return 'Tomorrow'
  if (diff > 1 && diff < 7) return `In ${diff} days`
  if (diff < 0 && diff > -7) return `${-diff}d ago`
  return date.toLocaleDateString('en-AU', { month: 'short', day: 'numeric' })
}

type TaskType = 'sow' | 'transplant' | 'repot' | 'harvest'

interface Task {
  key: string
  type: TaskType
  plant: Plant
  date: Date
}

const TASK_META: Record<TaskType, { verb: string; color: string; bg: string }> = {
  sow: {
    verb: 'Sow',
    color: 'var(--color-primary)',
    bg: 'color-mix(in oklab, var(--color-primary) 18%, transparent)',
  },
  transplant: {
    verb: 'Transplant',
    color: 'var(--color-transplant)',
    bg: 'color-mix(in oklab, var(--color-transplant) 18%, transparent)',
  },
  repot: {
    verb: 'Repot',
    color: 'var(--color-repot)',
    bg: 'color-mix(in oklab, var(--color-repot) 15%, transparent)',
  },
  harvest: {
    verb: 'Harvest',
    color: 'var(--color-harvest)',
    bg: 'color-mix(in oklab, var(--color-harvest) 15%, transparent)',
  },
}

const tasks = computed((): Task[] => {
  const result: Task[] = []

  for (const plant of plants.value) {
    for (const ds of plant.sow_dates ?? []) {
      const date = parseISO(ds)
      if (date >= todayStart)
        result.push({ type: 'sow', plant, date, key: `sow-${plant.id}-${ds}` })
    }
    for (const ds of plant.transplant_dates ?? []) {
      const date = parseISO(ds)
      if (date >= todayStart)
        result.push({ type: 'transplant', plant, date, key: `tp-${plant.id}-${ds}` })
    }
    for (const ds of plant.repot_dates ?? []) {
      const date = parseISO(ds)
      if (date >= todayStart)
        result.push({ type: 'repot', plant, date, key: `rp-${plant.id}-${ds}` })
    }
    for (const ds of plant.harvest_dates ?? []) {
      const date = parseISO(ds)
      if (date >= todayStart)
        result.push({ type: 'harvest', plant, date, key: `hv-${plant.id}-${ds}` })
    }
  }

  result.sort((a, b) => a.date.getTime() - b.date.getTime())

  return result
})

const tasksExpanded = ref(false)
const TASKS_MAX = 6

interface TaskGroup {
  label: string
  tasks: Task[]
}

const groupedTasks = computed((): TaskGroup[] => {
  const thisWeek: Task[] = []
  const nextWeek: Task[] = []
  const later: Task[] = []

  for (const task of tasks.value) {
    const diff = Math.round((task.date.getTime() - todayStart.getTime()) / MS_DAY)
    if (diff <= 6) thisWeek.push(task)
    else if (diff <= 13) nextWeek.push(task)
    else later.push(task)
  }

  const groups: TaskGroup[] = []
  if (thisWeek.length) groups.push({ label: 'This week', tasks: thisWeek })
  if (nextWeek.length) groups.push({ label: 'Next week', tasks: nextWeek })
  if (later.length) groups.push({ label: 'Later', tasks: later })
  return groups
})

const visibleGroups = computed((): TaskGroup[] => {
  if (tasksExpanded.value) return groupedTasks.value

  let remaining = TASKS_MAX
  const result: TaskGroup[] = []
  for (const group of groupedTasks.value) {
    if (remaining <= 0) break
    result.push({ label: group.label, tasks: group.tasks.slice(0, remaining) })
    remaining -= group.tasks.length
  }
  return result
})

// Plants grouped by current window status
type BucketKey = 'sow' | 'transplant' | 'harvest' | 'growing' | 'resting'

const BUCKET_ORDER: BucketKey[] = ['sow', 'transplant', 'growing', 'harvest', 'resting']

const BUCKET_META: Record<BucketKey, { label: string; color: string }> = {
  sow: { label: 'Sow now', color: 'var(--color-primary)' },
  transplant: { label: 'Transplant now', color: 'var(--color-transplant)' },
  growing: { label: 'Growing', color: 'var(--color-secondary)' },
  harvest: { label: 'Harvest now', color: 'var(--color-harvest)' },
  resting: { label: 'Off season', color: 'oklch(0.50 0.01 50)' },
}

const groupedByWindow = computed(() => {
  const buckets: Record<BucketKey, Plant[]> = {
    sow: [],
    transplant: [],
    harvest: [],
    growing: [],
    resting: [],
  }
  for (const p of plants.value) {
    const b = currentBucket(p, today)
    buckets[b].push(p)
  }
  return BUCKET_ORDER.filter((k) => buckets[k].length > 0).map((k) => ({
    key: k,
    meta: BUCKET_META[k],
    plants: [...buckets[k]].sort((a, b) => a.name.localeCompare(b.name)),
  }))
})

// Data fetching
async function fetchPlants() {
  try {
    const res = await getApiPlants({ throwOnError: true })
    plants.value = res.data ?? []
  } catch (error) {
    handleApiError(error, 'Failed to load plants')
  }
}

onMounted(async () => {
  await fetchPlants()
  loading.value = false
})

async function onPlantAdded() {
  await fetchPlants()
}
</script>

<template>
  <main>
    <PageHeader class="flex items-start justify-between">
      <div>
        <p class="text-[11.5px] font-medium uppercase tracking-widest text-muted-foreground">
          {{
            today.toLocaleDateString('en-AU', { weekday: 'long', day: 'numeric', month: 'long' })
          }}
        </p>
        <h1 class="text-3xl font-bold tracking-tight text-primary mt-0.5">Your Garden</h1>
      </div>
      <PlantDialogue
        v-if="!loading && plants.length > 0"
        v-model:open="dialogOpen"
        @plant-added="onPlantAdded"
      >
        <button
          class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
        >
          <Plus :size="18" />
        </button>
      </PlantDialogue>
    </PageHeader>

    <LoadingLeaves v-if="loading" />

    <div v-else-if="!loading && plants.length > 0">
      <Tabs default-value="gardenList">
        <TabsList class="mx-4">
          <TabsTrigger value="gardenList">Plants</TabsTrigger>
          <TabsTrigger value="gardenCalendar">Calendar</TabsTrigger>
        </TabsList>

        <TabsContent value="gardenList" class="px-4 flex flex-col gap-4">
          <!-- Task reminders -->
          <section
            v-if="tasks.length > 0"
            class="rounded-2xl border px-3 py-2 bg-card border-border"
          >
            <header class="flex items-center justify-between pt-1 pb-0.5">
              <h2 class="text-[13px] font-semibold">
                Reminders
                <span class="ml-1.5 text-[11.5px] font-normal text-muted-foreground">{{
                  tasks.length
                }}</span>
              </h2>
              <button
                v-if="tasks.length > TASKS_MAX"
                class="flex items-center gap-0.5 text-[11.5px] font-medium text-muted-foreground"
                @click="tasksExpanded = !tasksExpanded"
              >
                {{ tasksExpanded ? 'Show less' : 'Show all' }}
                <ChevronDown
                  :size="12"
                  class="transition-transform duration-200"
                  :class="{ 'rotate-180': tasksExpanded }"
                />
              </button>
            </header>
            <div>
              <template v-for="group in visibleGroups" :key="group.label">
                <p
                  class="text-[10.5px] font-medium uppercase tracking-widest text-muted-foreground px-1 pt-2.5 pb-0.5 first:pt-1"
                >
                  {{ group.label }}
                </p>
                <div
                  class="flex flex-col divide-y divide-[color-mix(in_oklab,var(--color-foreground)_6%,transparent)]"
                >
                  <button
                    v-for="task in group.tasks"
                    :key="task.key"
                    class="-mx-1 px-1 rounded-md text-left transition-colors hover:bg-[color-mix(in_oklab,var(--color-foreground)_3%,transparent)]"
                    @click="router.push(`/plants/${task.plant.id}`)"
                  >
                    <div class="flex items-center gap-2.5 py-1.5">
                      <span
                        class="grid place-items-center w-7 h-7 rounded-lg shrink-0"
                        :style="{
                          background: TASK_META[task.type].bg,
                          color: TASK_META[task.type].color,
                        }"
                      >
                        <Sprout v-if="task.type === 'sow'" :size="14" />
                        <Replace v-else-if="task.type === 'repot'" :size="14" />
                        <Scissors v-else-if="task.type === 'harvest'" :size="14" />
                        <Shovel v-else :size="14" />
                      </span>
                      <div class="min-w-0 flex-1 flex items-baseline gap-1.5">
                        <span class="text-[13.5px] font-medium">
                          {{ TASK_META[task.type].verb }} {{ task.plant.name }}
                        </span>
                        <span
                          v-if="task.plant.variety"
                          class="text-[11.5px] truncate text-muted-foreground"
                        >
                          {{ task.plant.variety }}
                        </span>
                      </div>
                      <span
                        class="text-[11.5px] font-medium tabular-nums shrink-0 text-muted-foreground"
                      >
                        {{ fmtRelative(task.date) }}
                      </span>
                    </div>
                  </button>
                </div>
              </template>
            </div>
          </section>

          <!-- Plants grouped by window status -->
          <div class="flex flex-col gap-5">
            <section v-for="group in groupedByWindow" :key="group.key">
              <header class="flex items-center gap-2 mb-2 px-0.5">
                <span
                  class="w-2 h-2 rounded-full shrink-0"
                  :style="{ background: group.meta.color }"
                />
                <h3 class="text-[14px] font-semibold">{{ group.meta.label }}</h3>
              </header>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-1.5">
                <button
                  v-for="plant in group.plants"
                  :key="plant.id"
                  class="flex items-center gap-3 px-3 py-2 rounded-xl border bg-card border-border text-left cursor-pointer transition-colors hover:bg-[color-mix(in_oklab,var(--color-foreground)_3%,transparent)]"
                  @click="router.push(`/plants/${plant.id}`)"
                >
                  <!-- Plant icon -->
                  <img
                    v-if="plant.icon"
                    :src="`/icons/${plant.icon}`"
                    :alt="plant.name"
                    class="shrink-0 w-8 h-8 object-contain"
                    style="filter: brightness(0.95)"
                  />
                  <div
                    v-else
                    class="shrink-0 w-8 h-8 rounded-full grid place-items-center"
                    style="background: color-mix(in oklab, var(--color-primary) 10%, transparent)"
                  >
                    <Sprout :size="16" class="text-primary" />
                  </div>
                  <!-- Name + variety -->
                  <div class="min-w-0 flex-1">
                    <div class="text-[13.5px] font-medium truncate">
                      {{ plant.name
                      }}<span v-if="plant.variety" class="font-normal text-muted-foreground">
                        · {{ plant.variety }}</span
                      >
                    </div>
                  </div>
                  <!-- Status hint -->
                  <span
                    v-if="plantHint(plant, today)"
                    class="text-[11px] font-medium shrink-0"
                    :style="{ color: plantHint(plant, today)?.color }"
                  >
                    {{ plantHint(plant, today)?.label }}
                  </span>
                  <!-- Also keep plant actions accessible -->
                  <PlantActions
                    :plant="plant"
                    @updated="fetchPlants"
                    @archived="plants = plants.filter((p) => p.id !== $event)"
                    @deleted="fetchPlants"
                    @click.stop
                  />
                  <ChevronRight :size="14" class="text-muted-foreground opacity-50 shrink-0" />
                </button>
              </div>
            </section>
          </div>
        </TabsContent>

        <TabsContent value="gardenCalendar">
          <PlantCalendar
            :plants="plants"
            :show-dots="true"
            :show-year-nav="true"
            :clickable="true"
            @plant-click="(p) => router.push(`/plants/${p.id}`)"
          />
        </TabsContent>
      </Tabs>
    </div>

    <div v-else-if="!loading" class="flex items-center justify-center min-h-[70vh]">
      <Empty>
        <EmptyHeader>
          <EmptyMedia>
            <Sprout />
          </EmptyMedia>
          <EmptyTitle>No Plants Yet</EmptyTitle>
          <EmptyDescription>
            You haven't added any plants yet. Get started by adding your first plant.
          </EmptyDescription>
        </EmptyHeader>
        <EmptyContent>
          <PlantDialogue v-model:open="dialogOpen" @plant-added="onPlantAdded">
            <Button>Add Plant</Button>
          </PlantDialogue>
        </EmptyContent>
      </Empty>
    </div>
  </main>
</template>
