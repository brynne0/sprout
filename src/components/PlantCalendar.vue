<script setup lang="ts">
import { computed } from 'vue'
import { CalendarDate, today, getLocalTimeZone } from '@internationalized/date'
import type { CataloguePlant } from '@/client'

const props = withDefaults(defineProps<{ plants: CataloguePlant[]; showSowDot?: boolean }>(), {
  showSowDot: false,
})

const MONTH_WIDTH = 40
const NAME_COL_WIDTH = 112
const TRACK_HEIGHT = 10
const TRACK_GAP = 3
const ROW_PADDING = 8
const ROW_HEIGHT = ROW_PADDING * 2 + TRACK_HEIGHT * 3 + TRACK_GAP * 2

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
const currentYear = today(getLocalTimeZone()).year

function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate()
}

function addMonths(year: number, month: number, delta: number): { year: number; month: number } {
  let m = month + delta
  let y = year
  while (m > 12) {
    m -= 12
    y++
  }
  while (m < 1) {
    m += 12
    y--
  }
  return { year: y, month: m }
}

const timelineMonths = computed(() => {
  const nowDate = today(getLocalTimeZone())
  let startYear = nowDate.year
  let startMonth = 1
  let endYear = nowDate.year
  let endMonth = 12

  for (const plant of props.plants) {
    const sow = getAnchorDate(plant)
    if (sow.year < startYear || (sow.year === startYear && sow.month < startMonth)) {
      startYear = sow.year
      startMonth = sow.month
    }
    if (sow.year > endYear || (sow.year === endYear && sow.month > endMonth)) {
      endYear = sow.year
      endMonth = sow.month
    }
  }

  const months: { year: number; month: number }[] = []
  let y = startYear
  let m = startMonth
  while (y < endYear || (y === endYear && m <= endMonth)) {
    months.push({ year: y, month: m })
    const next = addMonths(y, m, 1)
    y = next.year
    m = next.month
  }
  return months
})

function monthIndexOf(year: number, month: number): number {
  const first = timelineMonths.value[0]!
  return (year - first.year) * 12 + (month - first.month)
}

function dateToX(date: CalendarDate): number {
  const idx = monthIndexOf(date.year, date.month)
  const dayFraction = (date.day - 1) / daysInMonth(date.year, date.month)
  return idx * MONTH_WIDTH + dayFraction * MONTH_WIDTH
}

function windowBar(
  mmddStart: string,
  mmddEnd: string,
  baseYear: number,
): { x: number; width: number } | null {
  const sp = mmddStart.split('-').map(Number)
  const ep = mmddEnd.split('-').map(Number)
  const sm = sp[0]!
  const sd = sp[1]!
  const em = ep[0]!
  const ed = ep[1]!
  const startDate = new CalendarDate(baseYear, sm, sd)
  const endYear = em < sm || (em === sm && ed < sd) ? baseYear + 1 : baseYear
  const endDate = new CalendarDate(endYear, em, ed)
  const x = dateToX(startDate)
  const endX = dateToX(endDate)
  return endX > x ? { x, width: endX - x } : null
}

const plantRows = computed(() =>
  props.plants
    .slice()
    .sort((a, b) => getAnchorDate(a).toString().localeCompare(getAnchorDate(b).toString()))
    .map((plant) => {
      const sow = getAnchorDate(plant)
      const sowX = dateToX(sow)
      const baseYear = sow.year
      return {
        plant,
        sowX,
        sowingBars: (plant.sowing_windows ?? [])
          .map((w) => windowBar(w.start, w.end, baseYear))
          .filter(Boolean) as { x: number; width: number }[],
        transplantBars: (plant.transplant_windows ?? [])
          .map((w) => windowBar(w.start, w.end, baseYear))
          .filter(Boolean) as { x: number; width: number }[],
        harvestBars: (plant.harvest_windows ?? [])
          .map((w) => windowBar(w.start, w.end, baseYear))
          .filter(Boolean) as { x: number; width: number }[],
      }
    }),
)

function parseDate(s: string): CalendarDate {
  const parts = s.substring(0, 10).split('-').map(Number)
  return new CalendarDate(parts[0]!, parts[1]!, parts[2]!)
}

function getAnchorDate(plant: {
  sow_date?: string
  sowing_windows?: Array<{ start: string }>
}): CalendarDate {
  if (plant.sow_date) return parseDate(plant.sow_date)
  const firstWindow = plant.sowing_windows?.[0]
  if (firstWindow) {
    const [m, d] = firstWindow.start.split('-').map(Number)
    return new CalendarDate(today(getLocalTimeZone()).year, m!, d!)
  }
  return today(getLocalTimeZone())
}

const sowingTop = ROW_PADDING
const transplantTop = ROW_PADDING + TRACK_HEIGHT + TRACK_GAP
const harvestTop = ROW_PADDING + (TRACK_HEIGHT + TRACK_GAP) * 2

const totalWidth = computed(() => NAME_COL_WIDTH + timelineMonths.value.length * MONTH_WIDTH)

const todayX = computed(() => {
  const t = today(getLocalTimeZone())
  return dateToX(new CalendarDate(t.year, t.month, t.day))
})
</script>

<template>
  <div class="overflow-x-auto mt-2">
    <div :style="{ minWidth: totalWidth + 'px' }">
      <!-- Bordered chart -->
      <div class="border-y border-border">
        <!-- Month header -->
        <div class="flex divide-x border-b border-border/40 divide-border/40">
          <div
            class="sticky bg-background left-0 z-10 shrink-0 px-3 py-2 text-xs font-medium text-muted-foreground"
            :style="{ width: NAME_COL_WIDTH + 'px' }"
          >
            Plant
          </div>
          <div class="flex divide-border/40">
            <div
              v-for="m in timelineMonths"
              :key="`${m.year}-${m.month}`"
              class="shrink-0 text-xs text-muted-foreground py-2 text-center"
              :style="{ width: MONTH_WIDTH + 'px' }"
            >
              {{ MONTH_LABELS[m.month - 1] }}
              <span v-if="m.year !== currentYear" class="text-[10px]"
                >'{{ String(m.year).slice(2) }}</span
              >
            </div>
          </div>
        </div>

        <!-- Plant rows -->
        <div v-for="row in plantRows" :key="row.plant.id" class="flex divide-x divide-border/40">
          <!-- Sticky name -->
          <div
            class="sticky left-0 z-11 bg-background shrink-0 px-3 flex flex-col justify-center"
            :style="{ width: NAME_COL_WIDTH + 'px' }"
          >
            <span class="text-xs font-medium leading-tight">{{ row.plant.name }}</span>
            <span
              v-if="'variety' in row.plant && (row.plant as { variety?: string }).variety"
              class="text-[10px] text-muted-foreground leading-tight"
            >
              {{ (row.plant as { variety?: string }).variety }}
            </span>
          </div>

          <!-- Timeline: month columns provide grid lines via divide-x -->
          <div
            class="relative flex divide-x divide-border/40 shrink-0"
            :style="{
              width: timelineMonths.length * MONTH_WIDTH + 'px',
              minHeight: ROW_HEIGHT + 'px',
            }"
          >
            <div
              v-for="(_, i) in timelineMonths"
              :key="`col-${i}`"
              class="shrink-0"
              :style="{ width: MONTH_WIDTH + 'px' }"
            />

            <!-- Gantt content overlay -->
            <div class="absolute inset-0">
              <!-- Today line -->
              <div
                class="absolute top-0 bottom-0 border-l border-primary/40"
                :style="{ left: todayX + 'px' }"
              />

              <!-- Sowing window bands (green, top track) -->
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

              <!-- Transplant window bands (rose, middle track) -->
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

              <!-- Harvest window bands (amber, bottom track) -->
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

              <!-- Sow date dot -->
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
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Legend -->
  <div
    :class="[
      'grid justify-items-center gap-2 mt-2 px-4 text-xs text-muted-foreground',
      showSowDot ? 'grid-cols-4' : 'grid-cols-3',
    ]"
  >
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
      Sown on
    </span>
  </div>
</template>
