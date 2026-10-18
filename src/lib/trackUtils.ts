import type { BasePlant, Reminder, TaskType, Window } from '@/types'
import { toLocalDateStr } from '@/lib/utils'

export type TrackType = 'sowing' | 'transplant' | 'harvest'

export const TRACK_HEIGHT = 8
export const TRACK_GAP = 3
export const ROW_PADDING = 8
export const LABEL_HEIGHT = 11

const DUMMY_YEAR = 2000

export type Bar = { x: number; width: number; start: string; end: string }
export type Dot = { x: number; date: string; variant?: 'repot'; planned?: boolean }

export type Track = {
  type: TrackType
  label?: string
  bars: Bar[]
  dots?: Dot[]
}

export type WindowData = { start: string; end: string; label?: string }

export function trackTops(tracks: Track[]): number[] {
  let y = ROW_PADDING
  return tracks.map((t) => {
    if (t.label) y += LABEL_HEIGHT
    const top = y
    y += TRACK_HEIGHT + TRACK_GAP
    return top
  })
}

export function rowHeightForTracks(tracks: Track[]): number {
  const tops = trackTops(tracks)
  const lastTop = tops[tops.length - 1] ?? ROW_PADDING
  return lastTop + TRACK_HEIGHT + ROW_PADDING
}

export function daysInMonth(month: number): number {
  return new Date(DUMMY_YEAR, month, 0).getDate()
}

export function parseDateMonthDay(dateStr: string): { month: number; day: number } {
  const parts = toLocalDateStr(dateStr).split('-').map(Number)
  return { month: parts[1]!, day: parts[2]! }
}

export function inWindow(day: { month: number; day: number }, w: Window): boolean {
  const [sm = 0, sd = 0] = w.start.split('-').map(Number)
  const [em = 0, ed = 0] = w.end.split('-').map(Number)
  const d = day.month * 100 + day.day
  const start = sm * 100 + sd
  const end = em * 100 + ed
  return start <= end ? d >= start && d <= end : d >= start || d <= end
}

export function todayMonthDay(): { month: number; day: number } {
  const now = new Date()
  return { month: now.getMonth() + 1, day: now.getDate() }
}

export function dateToX(month: number, day: number, monthWidth: number): number {
  const idx = month - 1
  const dayFraction = (day - 1) / daysInMonth(month)
  return (idx + dayFraction) * monthWidth
}

export function windowBars(mmddStart: string, mmddEnd: string, monthWidth: number): Bar[] {
  const sp = mmddStart.split('-').map(Number)
  const ep = mmddEnd.split('-').map(Number)
  const sm = sp[0]!,
    sd = sp[1]!,
    em = ep[0]!,
    ed = ep[1]!
  const startX = dateToX(sm, sd, monthWidth)
  const endX = dateToX(em, ed, monthWidth)
  const wraps = em < sm || (em === sm && ed < sd)
  if (!wraps)
    return endX > startX
      ? [{ x: startX, width: endX - startX, start: mmddStart, end: mmddEnd }]
      : []
  return [
    { x: startX, width: 12 * monthWidth - startX, start: mmddStart, end: '12-31' },
    { x: 0, width: endX, start: '01-01', end: mmddEnd },
  ]
}

export function extractTracks(
  windows: WindowData[],
  monthWidth: number,
): { unlabelledBars: Bar[]; labelGroups: Map<string, Bar[]> } {
  const unlabelledBars: Bar[] = []
  const labelGroups = new Map<string, Bar[]>()
  for (const w of windows) {
    const bars = windowBars(w.start, w.end, monthWidth)
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

export function computeTracksForPlant(
  plant: BasePlant,
  monthWidth: number,
  selectedYear?: number,
  reminders: Reminder[] = [],
): Track[] {
  const tracks: Track[] = []

  const rawSowDates = (
    'sow_dates' in plant && Array.isArray(plant.sow_dates) ? (plant.sow_dates as string[]) : []
  ).filter(
    (d) => selectedYear === undefined || Number(toLocalDateStr(d).substring(0, 4)) === selectedYear,
  )

  const rawTransplantDates = (
    'transplant_dates' in plant && Array.isArray(plant.transplant_dates)
      ? (plant.transplant_dates as string[])
      : []
  ).filter(
    (d) => selectedYear === undefined || Number(toLocalDateStr(d).substring(0, 4)) === selectedYear,
  )

  const rawRepotDates = (
    'repot_dates' in plant && Array.isArray(plant.repot_dates)
      ? (plant.repot_dates as string[])
      : []
  ).filter(
    (d) => selectedYear === undefined || Number(toLocalDateStr(d).substring(0, 4)) === selectedYear,
  )

  const rawHarvestDates = (
    'harvest_dates' in plant && Array.isArray(plant.harvest_dates)
      ? (plant.harvest_dates as string[])
      : []
  ).filter(
    (d) => selectedYear === undefined || Number(toLocalDateStr(d).substring(0, 4)) === selectedYear,
  )

  const harvestDots: Dot[] = rawHarvestDates.map((d) => {
    const md = parseDateMonthDay(d)
    return { x: dateToX(md.month, md.day, monthWidth), date: toLocalDateStr(d) }
  })

  const sowDots: Dot[] = rawSowDates.map((d) => {
    const md = parseDateMonthDay(d)
    return { x: dateToX(md.month, md.day, monthWidth), date: toLocalDateStr(d) }
  })
  const transplantDots: Dot[] = [
    ...rawTransplantDates.map((d) => {
      const md = parseDateMonthDay(d)
      return { x: dateToX(md.month, md.day, monthWidth), date: toLocalDateStr(d) }
    }),
    ...rawRepotDates.map((d) => {
      const md = parseDateMonthDay(d)
      return {
        x: dateToX(md.month, md.day, monthWidth),
        date: toLocalDateStr(d),
        variant: 'repot' as const,
      }
    }),
  ]

  // Reminders show as faded dots alongside what has been done
  const plannedDots = (type: TaskType): Dot[] =>
    reminders
      .filter((r) => r.type === type)
      .filter(
        (r) => selectedYear === undefined || Number(r.due_date.substring(0, 4)) === selectedYear,
      )
      .map((r) => {
        const md = parseDateMonthDay(r.due_date)
        return { x: dateToX(md.month, md.day, monthWidth), date: r.due_date, planned: true }
      })
  sowDots.push(...plannedDots('sow'))
  transplantDots.push(
    ...plannedDots('transplant'),
    ...plannedDots('repot').map((d) => ({ ...d, variant: 'repot' as const })),
  )
  harvestDots.push(...plannedDots('harvest'))

  const sowing = extractTracks((plant.sowing_windows ?? []) as WindowData[], monthWidth)
  const transplant = extractTracks((plant.transplant_windows ?? []) as WindowData[], monthWidth)
  const harvest = extractTracks((plant.harvest_windows ?? []) as WindowData[], monthWidth)

  pushTracks(tracks, 'sowing', sowing, sowDots)
  pushTracks(tracks, 'transplant', transplant, transplantDots)
  pushTracks(tracks, 'harvest', harvest, harvestDots)

  return tracks
}

// When every window is labelled, dots go on the labelled track whose window contains them
function pushTracks(
  tracks: Track[],
  type: TrackType,
  { unlabelledBars, labelGroups }: ReturnType<typeof extractTracks>,
  dots: Dot[],
) {
  const labelled = [...labelGroups].map(([label, bars]) => ({
    type,
    label,
    bars,
    dots: [] as Dot[],
  }))
  if (unlabelledBars.length || (dots.length && !labelled.length)) {
    tracks.push({ type, bars: unlabelledBars, dots }, ...labelled)
    return
  }
  for (const dot of dots) {
    const target =
      labelled.find((t) => t.bars.some((b) => dot.x >= b.x && dot.x <= b.x + b.width)) ??
      labelled[0]!
    target.dots.push(dot)
  }
  tracks.push(...labelled)
}
