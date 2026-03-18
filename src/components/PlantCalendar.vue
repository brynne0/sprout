<script setup lang="ts">
import { computed, ref } from 'vue'

import { today, getLocalTimeZone } from '@internationalized/date'
import type { CataloguePlant } from '@/client'
import { useElementSize } from '@vueuse/core'

const props = withDefaults(defineProps<{ plants: CataloguePlant[]; showSowDot?: boolean }>(), {
  showSowDot: false,
})
const timelineContainer = ref<HTMLElement | null>(null)
const { width: containerWidth } = useElementSize(timelineContainer)
const monthWidth = computed(() => Math.max(40, containerWidth.value / 12))

const NAME_COL_WIDTH = 112
const TRACK_HEIGHT = 10
const TRACK_GAP = 3
const ROW_PADDING = 8
const ROW_HEIGHT = ROW_PADDING * 2 + TRACK_HEIGHT * 3 + TRACK_GAP * 2
const LABEL_ROW_HEIGHT = ROW_PADDING * 2 + TRACK_HEIGHT

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

type Bar = { x: number; width: number }
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
  if (!wraps) return endX > startX ? [{ x: startX, width: endX - startX }] : []
  return [
    { x: startX, width: 12 * monthWidth.value - startX },
    { x: 0, width: endX },
  ]
}

type DisplayRow =
  | {
      kind: 'base'
      key: string
      plant: CataloguePlant
      sowX: number
      sowingBars: Bar[]
      transplantBars: Bar[]
      harvestBars: Bar[]
    }
  | {
      kind: 'label'
      key: string
      plant: CataloguePlant
      label: string
      trackType: 'sowing' | 'transplant' | 'harvest'
      bars: Bar[]
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

function getAnchorMonthDay(plant: {
  sow_date?: string
  sowing_windows?: Array<{ start: string }>
}): { month: number; day: number } {
  if (plant.sow_date) {
    const parts = plant.sow_date.substring(0, 10).split('-').map(Number)
    return { month: parts[1]!, day: parts[2]! }
  }
  const firstWindow = plant.sowing_windows?.[0]
  if (firstWindow) {
    const [m, d] = firstWindow.start.split('-').map(Number)
    return { month: m!, day: d! }
  }
  const t = today(getLocalTimeZone())
  return { month: t.month, day: t.day }
}

const displayRows = computed<DisplayRow[]>(() => {
  const sorted = props.plants.slice().sort((a, b) => {
    const am = getAnchorMonthDay(a)
    const bm = getAnchorMonthDay(b)
    return am.month !== bm.month ? am.month - bm.month : am.day - bm.day
  })

  const rows: DisplayRow[] = []

  for (const plant of sorted) {
    const anchor = getAnchorMonthDay(plant)
    const sowX = dateToX(anchor.month, anchor.day)

    const sowing = extractTracks((plant.sowing_windows ?? []) as WindowData[])
    const transplant = extractTracks((plant.transplant_windows ?? []) as WindowData[])
    const harvest = extractTracks((plant.harvest_windows ?? []) as WindowData[])

    rows.push({
      kind: 'base',
      key: String(plant.id ?? plant.name),
      plant,
      sowX,
      sowingBars: sowing.unlabelledBars,
      transplantBars: transplant.unlabelledBars,
      harvestBars: harvest.unlabelledBars,
    })

    for (const [label, bars] of sowing.labelGroups) {
      rows.push({
        kind: 'label',
        key: `${plant.id}-sow-${label}`,
        plant,
        label,
        trackType: 'sowing',
        bars,
      })
    }
    for (const [label, bars] of transplant.labelGroups) {
      rows.push({
        kind: 'label',
        key: `${plant.id}-transplant-${label}`,
        plant,
        label,
        trackType: 'transplant',
        bars,
      })
    }
    for (const [label, bars] of harvest.labelGroups) {
      rows.push({
        kind: 'label',
        key: `${plant.id}-harvest-${label}`,
        plant,
        label,
        trackType: 'harvest',
        bars,
      })
    }
  }

  return rows
})

function rowHeight(row: DisplayRow): number {
  return row.kind === 'base' ? ROW_HEIGHT : LABEL_ROW_HEIGHT
}

const sowingTop = ROW_PADDING
const transplantTop = ROW_PADDING + TRACK_HEIGHT + TRACK_GAP
const harvestTop = ROW_PADDING + (TRACK_HEIGHT + TRACK_GAP) * 2

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
  <div class="flex mt-2">
    <!-- Fixed name column -->
    <div class="shrink-0 border-y border-border" :style="{ width: NAME_COL_WIDTH + 'px' }">
      <!-- Header -->
      <div class="px-3 py-2 text-xs font-medium text-muted-foreground">Plant</div>
      <!-- Rows -->
      <div
        v-for="row in displayRows"
        :key="row.key"
        class="px-3 flex flex-col justify-center border-t border-border/40 first:border-t-0"
        :style="{ minHeight: rowHeight(row) + 'px' }"
      >
        <template v-if="row.kind === 'base'">
          <span class="text-xs font-medium leading-tight">{{ row.plant.name }}</span>
          <span
            v-if="'variety' in row.plant && (row.plant as { variety?: string }).variety"
            class="text-[10px] text-muted-foreground leading-tight"
          >
            {{ (row.plant as { variety?: string }).variety }}
          </span>
        </template>
        <template v-else>
          <span class="text-[10px] text-muted-foreground leading-tight pl-1">{{ row.label }}</span>
        </template>
      </div>
    </div>

    <!-- Scrollable timeline -->
    <div ref="timelineContainer" class="overflow-x-auto flex-1 border-y border-l border-border">
      <div :style="{ minWidth: timelineMonths.length * monthWidth + 'px' }">
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
        <div v-for="row in displayRows" :key="row.key">
          <div
            class="relative flex divide-x divide-border/40 shrink-0"
            :style="{
              width: timelineMonths.length * monthWidth + 'px',
              minHeight: rowHeight(row) + 'px',
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

              <!-- Base row: unlabelled sowing, transplant, harvest tracks -->
              <template v-if="row.kind === 'base'">
                <div
                  v-for="(b, i) in row.sowingBars"
                  :key="`sow-${i}`"
                  class="absolute rounded-sm bg-emerald-500/20 border border-emerald-500/40"
                  :style="{
                    left: b.x + 'px',
                    width: b.width + 'px',
                    top: sowingTop + 'px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
                <div
                  v-for="(b, i) in row.transplantBars"
                  :key="`transplant-${i}`"
                  class="absolute rounded-sm bg-amber-500/20 border border-amber-500/40"
                  :style="{
                    left: b.x + 'px',
                    width: b.width + 'px',
                    top: transplantTop + 'px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
                <div
                  v-for="(b, i) in row.harvestBars"
                  :key="`harvest-${i}`"
                  class="absolute rounded-sm bg-rose-500/20 border border-rose-500/40"
                  :style="{
                    left: b.x + 'px',
                    width: b.width + 'px',
                    top: harvestTop + 'px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
                <div
                  v-if="showSowDot"
                  class="absolute rounded-full bg-primary border z-10"
                  :style="{
                    left: row.sowX - 5 + 'px',
                    top: transplantTop + TRACK_HEIGHT / 2 - 5 + 'px',
                    width: '10px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
              </template>

              <!-- Label row: single track centred vertically -->
              <template v-else>
                <div
                  v-for="(b, i) in row.bars"
                  :key="`label-bar-${i}`"
                  class="absolute rounded-sm"
                  :class="trackBarClasses[row.trackType]"
                  :style="{
                    left: b.x + 'px',
                    width: b.width + 'px',
                    top: ROW_PADDING + 'px',
                    height: TRACK_HEIGHT + 'px',
                  }"
                />
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Legend -->
  <div class="flex flex-row gap-8 mt-2 px-4 text-xs text-muted-foreground">
    <span class="flex items-center gap-1.5">
      <span class="inline-block w-3 h-3 rounded-sm bg-green-500/20 border border-green-500/40" />
      Sow
    </span>
    <span class="flex items-center gap-1.5">
      <span class="inline-block w-3 h-3 rounded-sm bg-amber-500/20 border border-amber-500/40" />
      Transplant
    </span>
    <span class="flex items-center gap-1.5">
      <span class="inline-block w-3 h-3 rounded-sm bg-rose-500/20 border border-rose-500/40" />
      Harvest
    </span>
    <span v-if="showSowDot" class="flex items-center gap-1.5">
      <span class="inline-block w-3 h-3 border rounded-sm bg-primary" />
      Sow date
    </span>
  </div>
</template>
