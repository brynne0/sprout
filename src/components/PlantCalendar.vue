<script setup lang="ts">
import { computed, ref } from 'vue'

import { today, getLocalTimeZone } from '@internationalized/date'
import type { BasePlant } from '@/client'
import { useElementSize } from '@vueuse/core'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { ChevronRight, ArrowUpDown, Rows3 } from 'lucide-vue-next'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const props = withDefaults(defineProps<{ plants: BasePlant[]; showDots?: boolean }>(), {
  showDots: false,
})
const timelineContainer = ref<HTMLElement | null>(null)
const { width: containerWidth } = useElementSize(timelineContainer)
const monthWidth = computed(() => Math.max(40, containerWidth.value / 12))

const NAME_COL_WIDTH = 112
const TRACK_HEIGHT = 10
const TRACK_GAP = 3
const ROW_PADDING = 8

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

// Use a fixed leap year so all month/day values are valid
const DUMMY_YEAR = 2000

const timelineMonths = Array.from({ length: 12 }, (_, i) => ({ month: i + 1 }))

function daysInMonth(month: number): number {
  return new Date(DUMMY_YEAR, month, 0).getDate()
}

function dateToX(month: number, day: number): number {
  const idx = month - 1
  const dayFraction = (day - 1) / daysInMonth(month)
  return (idx + dayFraction) * monthWidth.value
}

type Bar = { x: number; width: number; start: string; end: string }
type WindowData = { start: string; end: string; label?: string }
// Returns 1 bar normally, or 2 bars if the window wraps past December into January
function windowBars(mmddStart: string, mmddEnd: string): Bar[] {
  const sp = mmddStart.split('-').map(Number)
  const ep = mmddEnd.split('-').map(Number)
  const sm = sp[0]!,
    sd = sp[1]!,
    em = ep[0]!,
    ed = ep[1]!
  const startX = dateToX(sm, sd)
  const endX = dateToX(em, ed)
  const wraps = em < sm || (em === sm && ed < sd)
  if (!wraps)
    return endX > startX
      ? [{ x: startX, width: endX - startX, start: mmddStart, end: mmddEnd }]
      : []
  return [
    { x: startX, width: 12 * monthWidth.value - startX, start: mmddStart, end: '12-31' },
    { x: 0, width: endX, start: '01-01', end: mmddEnd },
  ]
}

type Track = {
  type: 'sowing' | 'transplant' | 'harvest'
  label?: string
  bars: Bar[]
  dotXs?: number[]
}

type PlantGroup = {
  name: string
  rows: PlantRow[]
}

type PlantRow = {
  key: string
  plant: BasePlant
  tracks: Track[]
}

const showGrid = ref(false)

const hiddenTracks = ref<Set<'sowing' | 'transplant' | 'harvest'>>(new Set())

function toggleTrack(type: 'sowing' | 'transplant' | 'harvest') {
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

function extractTracks(windows: WindowData[]): {
  unlabelledBars: Bar[]
  labelGroups: Map<string, Bar[]>
} {
  const unlabelledBars: Bar[] = []
  const labelGroups = new Map<string, Bar[]>()
  for (const w of windows) {
    const bars = windowBars(w.start, w.end)
    if (!bars.length) continue
    if (w.label) {
      if (!labelGroups.has(w.label)) labelGroups.set(w.label, [])
      labelGroups.get(w.label)!.push(...bars)
    } else {
      unlabelledBars.push(...bars)
    }
  }
  return { unlabelledBars, labelGroups }
}

function parseDateMonthDay(dateStr: string): { month: number; day: number } {
  const parts = dateStr.substring(0, 10).split('-').map(Number)
  return { month: parts[1]!, day: parts[2]! }
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

  const groupMap = new Map<string, PlantRow[]>()
  for (const plant of sorted) {
    const tracks: Track[] = []

    const rawSowDates =
      'sow_dates' in plant && Array.isArray(plant.sow_dates) ? (plant.sow_dates as string[]) : []
    const rawTransplantDates =
      'transplant_dates' in plant && Array.isArray(plant.transplant_dates)
        ? (plant.transplant_dates as string[])
        : []
    const sowXs = rawSowDates.map((d) => {
      const md = parseDateMonthDay(d)
      return dateToX(md.month, md.day)
    })
    const transplantXs = rawTransplantDates.map((d) => {
      const md = parseDateMonthDay(d)
      return dateToX(md.month, md.day)
    })

    const sowing = extractTracks((plant.sowing_windows ?? []) as WindowData[])
    const transplant = extractTracks((plant.transplant_windows ?? []) as WindowData[])
    const harvest = extractTracks((plant.harvest_windows ?? []) as WindowData[])

    // Sowing tracks
    if (sowing.unlabelledBars.length || sowXs.length) {
      tracks.push({ type: 'sowing', bars: sowing.unlabelledBars, dotXs: sowXs })
    }
    for (const [label, bars] of sowing.labelGroups) {
      tracks.push({ type: 'sowing', label, bars })
    }

    // Transplant tracks
    if (transplant.unlabelledBars.length || transplantXs.length) {
      tracks.push({ type: 'transplant', bars: transplant.unlabelledBars, dotXs: transplantXs })
    }
    for (const [label, bars] of transplant.labelGroups) {
      tracks.push({ type: 'transplant', label, bars })
    }

    // Harvest tracks
    if (harvest.unlabelledBars.length) {
      tracks.push({ type: 'harvest', bars: harvest.unlabelledBars })
    }
    for (const [label, bars] of harvest.labelGroups) {
      tracks.push({ type: 'harvest', label, bars })
    }

    const row: PlantRow = { key: String(plant.id ?? plant.name), plant, tracks }

    if (!groupMap.has(plant.name)) groupMap.set(plant.name, [])
    groupMap.get(plant.name)!.push(row)
  }

  return Array.from(groupMap, ([name, rows]) => ({ name, rows }))
})

type VisibleItem =
  | { kind: 'plant'; row: PlantRow; expandable: boolean; groupName: string }
  | { kind: 'variety'; row: PlantRow }

const visibleRows = computed<VisibleItem[]>(() => {
  const result: VisibleItem[] = []
  for (const group of displayGroups.value) {
    // First row is always visible as the main plant row
    const [first, ...rest] = group.rows
    if (!first) continue
    result.push({ kind: 'plant', row: first, expandable: rest.length > 0, groupName: group.name })
    // Remaining varieties only shown when expanded
    if (rest.length > 0 && expandedGroups.value.has(group.name)) {
      for (const row of rest) {
        result.push({ kind: 'variety', row })
      }
    }
  }
  return result
})

const dotClasses: Record<string, string> = {
  sowing: 'bg-primary border',
  transplant: 'bg-amber-500/70 border',
}

function rowHeight(row: PlantRow): number {
  const count = Math.max(row.tracks.length, 1)
  return ROW_PADDING * 2 + count * TRACK_HEIGHT + (count - 1) * TRACK_GAP
}

function trackTop(index: number): number {
  return ROW_PADDING + index * (TRACK_HEIGHT + TRACK_GAP)
}

const trackBarClasses: Record<'sowing' | 'transplant' | 'harvest', string> = {
  sowing: 'bg-emerald-500/20 border border-emerald-500/40',
  transplant: 'bg-amber-500/20 border border-amber-500/40',
  harvest: 'bg-rose-500/20 border border-rose-500/40',
}

const todayX = computed(() => {
  const t = today(getLocalTimeZone())
  return dateToX(t.month, t.day)
})
</script>

<template>
  <!-- Header: slot + legend -->
  <div class="flex flex-wrap items-center gap-4 mb-4 px-4">
    <slot name="header" />
    <div class="flex flex-wrap gap-4 text-xs text-muted-foreground">
      <button @click="toggleTrack('sowing')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border border-green-500/40"
          :class="hiddenTracks.has('sowing') ? '' : 'bg-green-500/20'"
        />
        Sow
      </button>
      <button @click="toggleTrack('transplant')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border border-amber-500/40"
          :class="hiddenTracks.has('transplant') ? '' : 'bg-amber-500/20'"
        />
        Transplant
      </button>
      <button @click="toggleTrack('harvest')" class="flex items-center gap-1.5">
        <span
          class="inline-block w-3 h-3 rounded-sm border border-rose-500/40"
          :class="hiddenTracks.has('harvest') ? '' : 'bg-rose-500/20'"
        />
        Harvest
      </button>
      <span v-if="showDots" class="flex items-center gap-1.5">
        <span class="inline-block w-3 h-3 border rounded-sm bg-primary" />
        Sow date
      </span>
      <span v-if="showDots" class="flex items-center gap-1.5">
        <span class="inline-block w-3 h-3 border rounded-sm bg-amber-500/70" />
        Transplant date
      </span>
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
        <!-- Main plant row -->
        <template v-if="item.kind === 'plant'">
          <div class="flex flex-col min-w-0">
            <span class="text-xs font-medium leading-tight">{{ item.row.plant.name }}</span>
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
        <!-- Variety sub-row -->
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
              <!-- Today line -->
              <div
                class="absolute top-0 bottom-0 border-l border-primary/40"
                :style="{ left: todayX + 'px' }"
              />

              <!-- Render each track -->
              <template v-for="(track, ti) in item.row.tracks" :key="`track-${ti}`">
                <!-- Window bars with label: clickable with popover -->
                <template v-if="track.label && !hiddenTracks.has(track.type)">
                  <Popover v-for="(b, bi) in track.bars" :key="`bar-${ti}-${bi}`">
                    <PopoverTrigger as-child>
                      <button
                        class="absolute rounded-sm overflow-hidden flex items-center cursor-pointer"
                        :class="trackBarClasses[track.type]"
                        :style="{
                          left: b.x + 'px',
                          width: b.width + 'px',
                          top: trackTop(ti) + 'px',
                          height: TRACK_HEIGHT + 'px',
                        }"
                      >
                        <span
                          v-if="b.width > 30"
                          class="text-[8px] leading-none truncate px-1 text-muted-foreground"
                        >
                          {{ track.label }}
                        </span>
                      </button>
                    </PopoverTrigger>
                    <PopoverContent
                      class="w-auto px-2 py-1 text-xs rounded-sm z-1"
                      :class="trackBarClasses[track.type]"
                      side="top"
                      :side-offset="4"
                    >
                      {{ track.label }}
                    </PopoverContent>
                  </Popover>
                </template>

                <!-- Window bars without label: plain div -->
                <template v-else>
                  <div
                    v-for="(b, bi) in track.bars"
                    v-show="!hiddenTracks.has(track.type)"
                    :key="`bar-${ti}-${bi}`"
                    class="absolute rounded-sm"
                    :class="trackBarClasses[track.type]"
                    :style="{
                      left: b.x + 'px',
                      width: b.width + 'px',
                      top: trackTop(ti) + 'px',
                      height: TRACK_HEIGHT + 'px',
                    }"
                  />
                </template>

                <!-- Dots (sow/transplant dates) -->
                <div
                  v-for="(dx, di) in showDots ? (track.dotXs ?? []) : []"
                  v-show="!hiddenTracks.has(track.type)"
                  :key="`dot-${ti}-${di}`"
                  class="absolute rounded-full z-10"
                  :class="dotClasses[track.type]"
                  :style="{
                    left: dx - 5 + 'px',
                    top: trackTop(ti) + TRACK_HEIGHT / 2 - 5 + 'px',
                    width: '10px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
              </template>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>
