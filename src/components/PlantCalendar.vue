<script setup lang="ts">
import { computed, ref } from 'vue'

import { today, getLocalTimeZone } from '@internationalized/date'
import type { BasePlant } from '@/client'
import { useElementSize } from '@vueuse/core'
import { ChevronLeft, ChevronRight, ArrowUpDown, Rows3 } from 'lucide-vue-next'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  dateToX,
  computeTracksForPlant,
  parseDateMonthDay,
  rowHeightForTrackCount,
} from '@/lib/trackUtils'
import type { Track, TrackType } from '@/lib/trackUtils'
import PlantRow from '@/components/PlantRow.vue'

const props = withDefaults(
  defineProps<{
    plants: BasePlant[]
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
const timelineContainer = ref<HTMLElement | null>(null)
const { width: containerWidth } = useElementSize(timelineContainer)
const monthWidth = computed(() => Math.max(40, containerWidth.value / 12))

const NAME_COL_WIDTH = 112

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

const showGrid = ref(false)

const hiddenTracks = ref<Set<TrackType>>(new Set())

function toggleTrack(type: TrackType) {
  if (hiddenTracks.value.has(type)) hiddenTracks.value.delete(type)
  else hiddenTracks.value.add(type)
}

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
    ? sorted.filter((p) => {
        if ('year' in p && p.year != null) {
          return (p.year as number) === selectedYear.value
        }
        return true
      })
    : sorted

  const groupMap = new Map<string, PlantRowData[]>()
  for (const plant of filtered) {
    const tracks = computeTracksForPlant(
      plant,
      monthWidth.value,
      props.showYearNav ? selectedYear.value : undefined,
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
  return rowHeightForTrackCount(row.tracks.length)
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
    <div class="flex flex-wrap gap-4 text-xs text-muted-foreground">
      <button @click="toggleTrack('sowing')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border track-sowing-border"
          :class="{ 'track-sowing-bg': !hiddenTracks.has('sowing') }"
        />
        Sow
      </button>
      <button @click="toggleTrack('transplant')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border track-transplant-border"
          :class="{ 'track-transplant-bg': !hiddenTracks.has('transplant') }"
        />
        Transplant
      </button>
      <button @click="toggleTrack('harvest')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border track-harvest-border"
          :class="{ 'track-harvest-bg': !hiddenTracks.has('harvest') }"
        />
        Harvest
      </button>
      <span v-if="showDots" class="flex items-center gap-1.5">
        <span class="inline-block w-3 h-3 border rounded-sm track-sowing-dot" />
        Sow date
      </span>
      <span v-if="showDots" class="flex items-center gap-1.5">
        <span class="inline-block w-3 h-3 border rounded-sm track-transplant-dot" />
        Transplant date
      </span>
    </div>
    <div v-if="showYearNav" class="flex items-center gap-2 text-sm ml-auto">
      <button
        v-if="selectedYear !== today(getLocalTimeZone()).year"
        class="text-xs text-muted-foreground hover:text-foreground transition-colors"
        @click="selectedYear = today(getLocalTimeZone()).year"
      >
        {{ today(getLocalTimeZone()).year }}
      </button>
      <button class="p-0.5 rounded hover:bg-muted transition-colors" @click="selectedYear--">
        <ChevronLeft class="w-4 h-4 text-muted-foreground" />
      </button>
      <span class="font-medium tabular-nums">{{ selectedYear }}</span>
      <button class="p-0.5 rounded hover:bg-muted transition-colors" @click="selectedYear++">
        <ChevronRight class="w-4 h-4 text-muted-foreground" />
      </button>
    </div>
  </div>

  <div v-if="plants.length === 0" class="px-4 py-8 text-sm text-muted-foreground text-center">
    No plants found.
  </div>

  <div v-else class="flex mt-2">
    <!-- Fixed name column -->
    <div
      class="shrink-0 border-y border-border relative z-10 bg-background"
      :style="{ width: NAME_COL_WIDTH + 'px' }"
    >
      <!-- Header with sort -->
      <div class="px-3 py-2 flex items-center justify-between">
        <span class="text-xs font-medium text-muted-foreground">Plant</span>
        <div class="flex items-center gap-1">
          <button
            class="p-0.5 rounded hover:bg-muted transition-colors"
            :class="{ 'bg-accent': showGrid }"
            @click="showGrid = !showGrid"
          >
            <Rows3 class="w-3 h-3 text-muted-foreground" />
          </button>
          <DropdownMenu>
            <DropdownMenuTrigger class="p-0.5 rounded hover:bg-muted transition-colors">
              <ArrowUpDown class="w-3 h-3 text-muted-foreground" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="start">
              <DropdownMenuItem
                v-for="mode in [
                  'sow-date',
                  'transplant-date',
                  'harvest-date',
                  'alphabetical',
                ] as SortMode[]"
                :key="mode"
                :class="{ 'font-medium bg-accent': sortMode === mode }"
                @click="sortMode = mode"
              >
                {{ sortLabels[mode] }}
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
      <!-- Rows -->
      <div
        v-for="(item, index) in visibleRows"
        :key="item.row.key"
        class="px-3 flex items-center gap-1 border-t border-border/40 first:border-t-0 justify-between"
        :style="{ minHeight: rowHeight(item.row) + 'px' }"
        :class="{
          'cursor-pointer select-none': item.kind === 'plant' && item.expandable,
          'bg-muted/50': showGrid && index % 2 === 0,
        }"
        @click="item.kind === 'plant' && item.expandable ? toggleGroup(item.groupName) : undefined"
      >
        <template v-if="item.kind === 'plant'">
          <div class="flex flex-col min-w-0">
            <span
              class="text-xs font-medium leading-tight transition-colors"
              :class="clickable ? 'cursor-pointer hover:text-primary' : ''"
              @click.stop="clickable && emit('plantClick', item.row.plant)"
              >{{ item.row.plant.name }}</span
            >
            <span
              v-if="'variety' in item.row.plant && (item.row.plant as { variety?: string }).variety"
              class="text-[10px] text-muted-foreground leading-tight"
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
    </div>

    <!-- Scrollable timeline -->
    <div ref="timelineContainer" class="overflow-x-auto flex-1 border-y border-l border-border">
      <div
        :class="showGrid ? 'divide-y divide-border/40' : ''"
        :style="{ minWidth: timelineMonths.length * monthWidth + 'px' }"
      >
        <!-- Month header -->
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

        <!-- Timeline rows -->
        <template v-for="(item, index) in visibleRows" :key="item.row.key">
          <div
            class="relative flex divide-x divide-border/40 shrink-0"
            :class="{ 'bg-muted/50': showGrid && index % 2 === 0 }"
            :style="{
              width: timelineMonths.length * monthWidth + 'px',
              minHeight: rowHeight(item.row) + 'px',
            }"
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
        </template>
      </div>
    </div>
  </div>
</template>
