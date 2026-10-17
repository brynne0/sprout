<script setup lang="ts">
import { computed, ref } from 'vue'

import { today, getLocalTimeZone } from '@internationalized/date'
import type { BasePlant, Plant, Reminder } from '@/types'
import { toLocalDateStr } from '@/lib/utils'
import { TASKS, TASK_ORDER } from '@/lib/tasks'
import { useElementSize } from '@vueuse/core'
import { ChevronLeft, ChevronRight, ArrowUpDown, Rows3 } from '@lucide/vue'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { Toggle } from '@/components/ui/toggle'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import {
  dateToX,
  computeTracksForPlant,
  parseDateMonthDay,
  rowHeightForTracks,
} from '@/lib/trackUtils'
import type { Track, TrackType } from '@/lib/trackUtils'
import PlantRow from '@/components/PlantRow.vue'

const props = withDefaults(
  defineProps<{
    plants: BasePlant[]
    reminders?: Reminder[]
    showDots?: boolean
    showYearNav?: boolean
    groupByName?: boolean
    clickable?: boolean
  }>(),
  {
    showDots: false,
    showYearNav: false,
    groupByName: false,
    clickable: false,
  },
)

const emit = defineEmits<{
  plantClick: [plant: BasePlant]
}>()

const selectedYear = ref(today(getLocalTimeZone()).year)
const NAME_COL_WIDTH = 112

const scrollContainer = ref<HTMLElement | null>(null)
const { width: containerWidth } = useElementSize(scrollContainer)
const monthWidth = computed(() => Math.max(40, (containerWidth.value - NAME_COL_WIDTH) / 12))

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

const timelineMonths = Array.from({ length: 12 }, (_, i) => ({ month: i + 1 }))

const showGrid = ref(true)

const legendTracks: { type: TrackType; label: string }[] = [
  { type: 'sowing', label: 'Sow' },
  { type: 'transplant', label: 'Transplant' },
  { type: 'harvest', label: 'Harvest' },
]

const hiddenTracks = ref<Set<TrackType>>(new Set())

const visibleTracks = computed({
  get: () => legendTracks.map((t) => t.type).filter((t) => !hiddenTracks.value.has(t)),
  set: (visible: TrackType[]) => {
    hiddenTracks.value = new Set(
      legendTracks.map((t) => t.type).filter((t) => !visible.includes(t)),
    )
  },
})

type SortMode = 'sow-date' | 'transplant-date' | 'harvest-date' | 'alphabetical'
const sortMode = ref<SortMode>('alphabetical')

const sortLabels: Record<SortMode, string> = {
  alphabetical: 'A-Z',
  'sow-date': 'Sow date',
  'transplant-date': 'Transplant date',
  'harvest-date': 'Harvest date',
}

const expandedGroups = ref(new Set<string>())

function toggleGroup(name: string) {
  if (expandedGroups.value.has(name)) {
    expandedGroups.value.delete(name)
  } else {
    expandedGroups.value.add(name)
  }
}

function getSowAnchor(plant: BasePlant): { month: number; day: number } {
  if ('sow_dates' in plant && Array.isArray(plant.sow_dates) && plant.sow_dates.length > 0) {
    return parseDateMonthDay(plant.sow_dates[0] as string)
  }
  const firstWindow = plant.sowing_windows?.[0]
  if (firstWindow) {
    const [m, d] = firstWindow.start.split('-').map(Number)
    return { month: m!, day: d! }
  }
  const t = today(getLocalTimeZone())
  return { month: t.month, day: t.day }
}

function getTransplantAnchor(plant: BasePlant): { month: number; day: number } {
  if (
    'transplant_dates' in plant &&
    Array.isArray(plant.transplant_dates) &&
    plant.transplant_dates.length > 0
  ) {
    return parseDateMonthDay(plant.transplant_dates[0] as string)
  }
  const firstWindow = plant.transplant_windows?.[0]
  if (firstWindow) {
    const [m, d] = firstWindow.start.split('-').map(Number)
    return { month: m!, day: d! }
  }
  return { month: 12, day: 31 }
}

function getHarvestAnchor(plant: BasePlant): { month: number; day: number } {
  const firstWindow = plant.harvest_windows?.[0]
  if (firstWindow) {
    const [m, d] = firstWindow.start.split('-').map(Number)
    return { month: m!, day: d! }
  }
  return { month: 12, day: 31 }
}

function compareMD(a: { month: number; day: number }, b: { month: number; day: number }): number {
  return a.month !== b.month ? a.month - b.month : a.day - b.day
}

type PlantRowData = {
  key: string
  plant: BasePlant
  tracks: Track[]
}

type PlantGroup = {
  name: string
  rows: PlantRowData[]
}

const yearOf = (d: string) => Number(toLocalDateStr(d).substring(0, 4))

function showsInYear(p: Plant, year: number): boolean {
  if (p.archived_at && yearOf(p.archived_at) < year) return false
  if (p.year == null || p.year === year) return true
  const dates = [
    ...TASK_ORDER.flatMap((t) => p[TASKS[t].column] ?? []),
    ...(props.reminders ?? []).filter((r) => r.plant_id === p.id).map((r) => r.due_date),
  ]
  return dates.some((d) => yearOf(d) === year)
}

const displayGroups = computed<PlantGroup[]>(() => {
  const sorted = props.plants.slice().sort((a, b) => {
    switch (sortMode.value) {
      case 'alphabetical':
        return a.name.localeCompare(b.name)
      case 'transplant-date':
        return compareMD(getTransplantAnchor(a), getTransplantAnchor(b))
      case 'harvest-date':
        return compareMD(getHarvestAnchor(a), getHarvestAnchor(b))
      case 'sow-date':
      default:
        return compareMD(getSowAnchor(a), getSowAnchor(b))
    }
  })

  const filtered = props.showYearNav
    ? sorted.filter((p) => showsInYear(p as Plant, selectedYear.value))
    : sorted

  const groupMap = new Map<string, PlantRowData[]>()
  for (const plant of filtered) {
    const tracks = computeTracksForPlant(
      plant,
      monthWidth.value,
      props.showYearNav ? selectedYear.value : undefined,
      props.reminders?.filter((r) => r.plant_id === plant.id),
    )
    const row: PlantRowData = { key: String(plant.id ?? plant.name), plant, tracks }
    const groupKey = props.groupByName ? plant.name : String(plant.id ?? plant.name)
    if (!groupMap.has(groupKey)) groupMap.set(groupKey, [])
    groupMap.get(groupKey)!.push(row)
  }

  return Array.from(groupMap, ([name, rows]) => ({ name, rows }))
})

type VisibleItem =
  | { kind: 'plant'; row: PlantRowData; expandable: boolean; groupName: string }
  | { kind: 'variety'; row: PlantRowData }

const visibleRows = computed<VisibleItem[]>(() => {
  const result: VisibleItem[] = []
  for (const group of displayGroups.value) {
    const [first, ...rest] = group.rows
    if (!first) continue
    result.push({ kind: 'plant', row: first, expandable: rest.length > 0, groupName: group.name })
    if (rest.length > 0 && expandedGroups.value.has(group.name)) {
      for (const row of rest) {
        result.push({ kind: 'variety', row })
      }
    }
  }
  return result
})

function rowHeight(row: PlantRowData): number {
  return rowHeightForTracks(row.tracks)
}

const todayX = computed(() => {
  const t = today(getLocalTimeZone())
  return dateToX(t.month, t.day, monthWidth.value)
})
</script>

<template>
  <div v-if="$slots.header" class="mb-4 px-4">
    <slot name="header" />
  </div>
  <!-- Legend + year nav -->
  <div class="flex items-center gap-4 mb-4 px-4">
    <ToggleGroup
      v-model="visibleTracks"
      type="multiple"
      :spacing="4"
      class="flex-wrap text-muted-foreground"
    >
      <ToggleGroupItem
        v-for="t in legendTracks"
        :key="t.type"
        :value="t.type"
        class="h-auto px-1 py-0.5 text-xs font-normal hover:bg-transparent data-[state=on]:bg-transparent data-[state=on]:text-muted-foreground"
      >
        <span
          class="inline-block w-3 h-3 rounded-sm border"
          :class="[`track-${t.type}-border`, { [`track-${t.type}-bg`]: !hiddenTracks.has(t.type) }]"
        />
        {{ t.label }}
      </ToggleGroupItem>
    </ToggleGroup>
    <div v-if="showYearNav" class="flex items-center gap-1 text-sm ml-auto">
      <Button
        v-if="selectedYear !== today(getLocalTimeZone()).year"
        variant="ghost-muted"
        size="xs"
        @click="selectedYear = today(getLocalTimeZone()).year"
      >
        {{ today(getLocalTimeZone()).year }}
      </Button>
      <Button
        variant="ghost-muted"
        size="icon-xs"
        aria-label="Previous year"
        @click="selectedYear--"
      >
        <ChevronLeft />
      </Button>
      <span class="font-medium tabular-nums">{{ selectedYear }}</span>
      <Button variant="ghost-muted" size="icon-xs" aria-label="Next year" @click="selectedYear++">
        <ChevronRight />
      </Button>
    </div>
  </div>

  <div v-if="plants.length === 0" class="px-4 py-8 text-sm text-muted-foreground text-center">
    No plants found.
  </div>

  <div
    v-else
    ref="scrollContainer"
    class="mt-2 overflow-x-auto border-y border-border dark:bg-card"
  >
    <div class="w-max min-w-full">
      <!-- Header row -->
      <div class="flex">
        <div
          class="sticky left-0 z-30 shrink-0 px-3 py-1 flex items-center justify-between border-r border-border bg-background dark:bg-card"
          :style="{ width: NAME_COL_WIDTH + 'px' }"
        >
          <span class="text-xs font-medium text-muted-foreground">Plant</span>
          <div class="flex items-center gap-1">
            <Toggle
              v-model="showGrid"
              size="sm"
              class="h-6 min-w-6 px-0.5 text-muted-foreground"
              aria-label="Show row stripes"
            >
              <Rows3 class="size-3" />
            </Toggle>
            <DropdownMenu>
              <DropdownMenuTrigger as-child>
                <Button variant="ghost-muted" size="icon-xs" aria-label="Sort plants">
                  <ArrowUpDown class="size-3" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="start">
                <DropdownMenuRadioGroup v-model="sortMode">
                  <DropdownMenuRadioItem
                    v-for="mode in [
                      'sow-date',
                      'transplant-date',
                      'harvest-date',
                      'alphabetical',
                    ] as SortMode[]"
                    :key="mode"
                    :value="mode"
                  >
                    {{ sortLabels[mode] }}
                  </DropdownMenuRadioItem>
                </DropdownMenuRadioGroup>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
        <div class="flex divide-x border-b border-border/40 divide-border/40">
          <div
            v-for="m in timelineMonths"
            :key="m.month"
            class="shrink-0 text-xs text-muted-foreground py-2 text-center w-auto"
            :style="{ width: monthWidth + 'px' }"
          >
            {{ MONTH_LABELS[m.month - 1] }}
          </div>
        </div>
      </div>

      <!-- Rows -->
      <div v-for="(item, index) in visibleRows" :key="item.row.key" class="flex">
        <div
          class="sticky left-0 z-30 shrink-0 px-3 flex items-center gap-1 justify-between border-r border-border bg-background dark:bg-card"
          :class="{
            'border-t border-t-border/40': index > 0,
            'bg-linear-to-r from-muted/50 to-muted/50 dark:from-muted/25 dark:to-muted/25':
              showGrid && index % 2 === 0,
            'cursor-pointer select-none': item.kind === 'plant' && item.expandable,
          }"
          :style="{ width: NAME_COL_WIDTH + 'px' }"
          @click="
            item.kind === 'plant' && item.expandable ? toggleGroup(item.groupName) : undefined
          "
        >
          <template v-if="item.kind === 'plant'">
            <div
              class="flex flex-col min-w-0"
              :class="{ 'opacity-60': (item.row.plant as Plant).archived_at }"
            >
              <span
                class="text-xs font-medium leading-tight transition-colors"
                :class="clickable ? 'cursor-pointer hover:text-primary' : ''"
                @click.stop="clickable && emit('plantClick', item.row.plant)"
                >{{ item.row.plant.name }}</span
              >
              <span
                v-if="
                  'variety' in item.row.plant && (item.row.plant as { variety?: string }).variety
                "
                class="text-2xs text-muted-foreground leading-tight"
              >
                {{ (item.row.plant as { variety?: string }).variety }}
              </span>
            </div>
            <ChevronRight
              v-if="item.expandable"
              class="w-3 h-3 shrink-0 text-muted-foreground transition-transform duration-200"
              :class="{ 'rotate-90': expandedGroups.has(item.groupName) }"
            />
          </template>
          <template v-else>
            <span class="text-xs text-muted-foreground leading-tight">
              {{
                'variety' in item.row.plant && (item.row.plant as { variety?: string }).variety
                  ? (item.row.plant as { variety?: string }).variety
                  : '(default)'
              }}
            </span>
          </template>
        </div>
        <div
          class="relative flex divide-x divide-border/40 shrink-0"
          :class="{
            'bg-muted/50 dark:bg-muted/25': showGrid && index % 2 === 0,
            'border-t border-border/40': showGrid && index > 0,
          }"
          :style="{ width: 12 * monthWidth + 'px', minHeight: rowHeight(item.row) + 'px' }"
        >
          <div
            v-for="(_, i) in timelineMonths"
            :key="`col-${i}`"
            class="shrink-0"
            :style="{ width: monthWidth + 'px' }"
          />
          <div class="absolute inset-0">
            <PlantRow
              :tracks="item.row.tracks"
              :month-width="monthWidth"
              :show-dots="showDots"
              :hidden-tracks="hiddenTracks"
              :today-x="selectedYear === today(getLocalTimeZone()).year ? todayX : null"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
