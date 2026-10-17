<script setup lang="ts">
import { ref, computed, onMounted, onActivated } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Sprout, Shovel, Scissors, Replace, ChevronDown } from '@lucide/vue'
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
import { Card, CardAction, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import type { Plant, Window as PlantWindow } from '@/types'
import { handleApiError, localToday, toLocalDateStr } from '@/lib/utils'
import { inWindow, todayMonthDay } from '@/lib/trackUtils'
import { supabase } from '@/lib/supabase'
import PlantActions from '@/components/PlantActions.vue'
import PlantIcon from '@/components/PlantIcon.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import PageHeader from '@/components/layout/PageHeader.vue'

const router = useRouter()
const plants = ref<Plant[]>([])
const loading = ref(true)

type Stage = 'planned' | 'sown' | 'growing' | 'harvesting'

// Later columns win same-day ties
const STAGE_BY_COLUMN = [
  ['sow_dates', 'sown'],
  ['repot_dates', 'growing'],
  ['transplant_dates', 'growing'],
  ['harvest_dates', 'harvesting'],
] as const

function currentStage(plant: Plant): Stage {
  const todayStr = localToday()
  let latest = ''
  let stage: Stage = 'planned'
  for (const [column, s] of STAGE_BY_COLUMN) {
    for (const d of plant[column] ?? []) {
      const day = toLocalDateStr(d)
      if (day <= todayStr && day >= latest) {
        latest = day
        stage = s
      }
    }
  }
  return stage
}

function windowHint(plant: Plant, stage: Stage): string | null {
  const now = todayMonthDay()
  const open = (ws: PlantWindow[] | undefined) => (ws ?? []).some((w) => inWindow(now, w))
  if (stage === 'planned') return open(plant.sowing_windows) ? 'Sow window open' : null
  if (stage === 'sown' && open(plant.transplant_windows)) return 'Transplant window open'
  if (stage !== 'harvesting' && open(plant.harvest_windows)) return 'Harvest window open'
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
  sow: { verb: 'Sow', color: 'var(--sow)', bg: 'var(--sow-bg)' },
  transplant: { verb: 'Transplant', color: 'var(--transplant)', bg: 'var(--transplant-bg)' },
  repot: { verb: 'Repot', color: 'var(--repot)', bg: 'var(--repot-bg)' },
  harvest: { verb: 'Harvest', color: 'var(--harvest)', bg: 'var(--harvest-bg)' },
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

// Plants grouped by stage
const STAGE_ORDER: Stage[] = ['planned', 'sown', 'growing', 'harvesting']

const STAGE_META: Record<Stage, { label: string; color: string }> = {
  planned: { label: 'Planned', color: 'var(--color-muted-foreground)' },
  sown: { label: 'Sown', color: 'var(--sow-dot)' },
  growing: { label: 'Growing', color: 'var(--color-secondary)' },
  harvesting: { label: 'Harvesting', color: 'var(--harvest-dot)' },
}

const groupedByStage = computed(() => {
  const buckets: Record<Stage, Plant[]> = {
    planned: [],
    sown: [],
    growing: [],
    harvesting: [],
  }
  for (const p of plants.value) {
    buckets[currentStage(p)].push(p)
  }
  return STAGE_ORDER.filter((k) => buckets[k].length > 0).map((k) => ({
    key: k,
    meta: STAGE_META[k],
    plants: [...buckets[k]].sort((a, b) => a.name.localeCompare(b.name)),
  }))
})

// Data fetching
async function fetchPlants() {
  try {
    const { data } = await supabase
      .from('plants_with_details')
      .select('*')
      .is('archived_at', null)
      .order('name')
      .throwOnError()
    plants.value = data as unknown as Plant[]
  } catch (error) {
    handleApiError(error, 'Failed to load plants')
  }
}

onMounted(async () => {
  await fetchPlants()
  loading.value = false
})

// The page is kept alive, so refresh when coming back from adding or editing a plant
onActivated(() => {
  if (!loading.value) fetchPlants()
})
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
      <RouterLink
        v-if="!loading && plants.length > 0"
        to="/plants/new"
        class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
        aria-label="Add plant"
      >
        <Plus :size="18" />
      </RouterLink>
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
          <Card v-if="tasks.length > 0">
            <CardHeader>
              <CardTitle>
                Reminders
                <span class="ml-1.5 text-[11.5px] font-normal text-muted-foreground">{{
                  tasks.length
                }}</span>
              </CardTitle>
              <CardAction v-if="tasks.length > TASKS_MAX">
                <Button
                  variant="ghost-muted"
                  size="xs"
                  :aria-expanded="tasksExpanded"
                  @click="tasksExpanded = !tasksExpanded"
                >
                  {{ tasksExpanded ? 'Show less' : 'Show all' }}
                  <ChevronDown
                    class="size-3 transition-transform duration-200"
                    :class="{ 'rotate-180': tasksExpanded }"
                  />
                </Button>
              </CardAction>
            </CardHeader>
            <CardContent class="pt-0">
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
            </CardContent>
          </Card>

          <!-- Plants grouped by stage -->
          <div class="flex flex-col gap-5">
            <section v-for="group in groupedByStage" :key="group.key">
              <header class="flex items-center gap-2 mb-2 px-0.5">
                <span
                  class="w-2 h-2 rounded-full shrink-0"
                  :style="{ background: group.meta.color }"
                />
                <h3 class="text-[14px] font-semibold">{{ group.meta.label }}</h3>
              </header>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-1.5">
                <div
                  v-for="plant in group.plants"
                  :key="plant.id"
                  class="flex items-center gap-1 pr-2 rounded-xl border bg-card border-border transition-colors hover:bg-[color-mix(in_oklab,var(--color-foreground)_3%,transparent)]"
                >
                  <RouterLink
                    :to="`/plants/${plant.id}`"
                    class="flex flex-1 min-w-0 items-center gap-3 pl-3 py-2 rounded-xl outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
                  >
                    <PlantIcon
                      :name="plant.name"
                      :icon="plant.icon"
                      :colour="plant.colour"
                      class="w-8 h-8 rounded-full text-sm"
                    />
                    <!-- Name + variety -->
                    <div class="min-w-0 flex-1">
                      <div class="text-[13.5px] font-medium line-clamp-2">
                        {{ plant.name
                        }}<span v-if="plant.variety" class="font-normal text-muted-foreground">
                          · {{ plant.variety }}</span
                        >
                      </div>
                    </div>
                    <!-- Window hint -->
                    <span
                      v-if="windowHint(plant, group.key)"
                      class="text-[11px] font-medium shrink-0 text-muted-foreground"
                    >
                      {{ windowHint(plant, group.key) }}
                    </span>
                  </RouterLink>
                  <!-- Sibling of the link, not inside it, so the menu button is valid HTML -->
                  <PlantActions
                    :plant="plant"
                    @archived="plants = plants.filter((p) => p.id !== $event)"
                    @deleted="fetchPlants"
                  />
                </div>
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
          <Button as-child>
            <RouterLink to="/plants/new">Add Plant</RouterLink>
          </Button>
        </EmptyContent>
      </Empty>
    </div>
  </main>
</template>
