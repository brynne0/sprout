import type { BasePlant } from '@/client'

export type TrackType = 'sowing' | 'transplant' | 'harvest'

export const TRACK_HEIGHT = 10
export const TRACK_GAP = 3
export const ROW_PADDING = 8

const DUMMY_YEAR = 2000

export type Bar = { x: number; width: number; start: string; end: string }
export type Dot = { x: number; date: string; variant?: 'repot' }

export type Track = {
  type: TrackType
  label?: string
  bars: Bar[]
  dots?: Dot[]
}

export type WindowData = { start: string; end: string; label?: string }

export function rowHeightForTrackCount(count: number): number {
  const c = Math.max(count, 1)
  return ROW_PADDING * 2 + c * TRACK_HEIGHT + (c - 1) * TRACK_GAP
}

export function daysInMonth(month: number): number {
  return new Date(DUMMY_YEAR, month, 0).getDate()
}

export function parseDateMonthDay(dateStr: string): { month: number; day: number } {
  const parts = dateStr.substring(0, 10).split('-').map(Number)
  return { month: parts[1]!, day: parts[2]! }
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
): Track[] {
  const tracks: Track[] = []

  const rawSowDates = (
    'sow_dates' in plant && Array.isArray(plant.sow_dates) ? (plant.sow_dates as string[]) : []
  ).filter((d) => selectedYear === undefined || new Date(d).getFullYear() === selectedYear)

  const rawTransplantDates = (
    'transplant_dates' in plant && Array.isArray(plant.transplant_dates)
      ? (plant.transplant_dates as string[])
      : []
  ).filter((d) => selectedYear === undefined || new Date(d).getFullYear() === selectedYear)

  const rawRepotDates = (
    'repot_dates' in plant && Array.isArray(plant.repot_dates)
      ? (plant.repot_dates as string[])
      : []
  ).filter((d) => selectedYear === undefined || new Date(d).getFullYear() === selectedYear)

  const rawHarvestDates = (
    'harvest_dates' in plant && Array.isArray(plant.harvest_dates)
      ? (plant.harvest_dates as string[])
      : []
  ).filter((d) => selectedYear === undefined || new Date(d).getFullYear() === selectedYear)

  const harvestDots: Dot[] = rawHarvestDates.map((d) => {
    const md = parseDateMonthDay(d)
    return { x: dateToX(md.month, md.day, monthWidth), date: d.substring(0, 10) }
  })

  const sowDots: Dot[] = rawSowDates.map((d) => {
    const md = parseDateMonthDay(d)
    return { x: dateToX(md.month, md.day, monthWidth), date: d.substring(0, 10) }
  })
  const transplantDots: Dot[] = [
    ...rawTransplantDates.map((d) => {
      const md = parseDateMonthDay(d)
      return { x: dateToX(md.month, md.day, monthWidth), date: d.substring(0, 10) }
    }),
    ...rawRepotDates.map((d) => {
      const md = parseDateMonthDay(d)
      return {
        x: dateToX(md.month, md.day, monthWidth),
        date: d.substring(0, 10),
        variant: 'repot' as const,
      }
    }),
  ]

  const sowing = extractTracks((plant.sowing_windows ?? []) as WindowData[], monthWidth)
  const transplant = extractTracks((plant.transplant_windows ?? []) as WindowData[], monthWidth)
  const harvest = extractTracks((plant.harvest_windows ?? []) as WindowData[], monthWidth)

  // Sowing tracks
  const sowLabelEntries = [...sowing.labelGroups]
  if (sowing.unlabelledBars.length || (sowDots.length && sowLabelEntries.length === 0)) {
    tracks.push({ type: 'sowing', bars: sowing.unlabelledBars, dots: sowDots })
    for (const [label, bars] of sowLabelEntries) {
      tracks.push({ type: 'sowing', label, bars })
    }
  } else {
    const firstSowEntry = sowLabelEntries[0]
    if (firstSowEntry) {
      tracks.push({
        type: 'sowing',
        label: firstSowEntry[0],
        bars: firstSowEntry[1],
        dots: sowDots.length ? sowDots : undefined,
      })
    }
    for (const [label, bars] of sowLabelEntries.slice(1)) {
      tracks.push({ type: 'sowing', label, bars })
    }
  }

  // Transplant tracks
  if (transplant.unlabelledBars.length || transplantDots.length) {
    tracks.push({ type: 'transplant', bars: transplant.unlabelledBars, dots: transplantDots })
  }
  for (const [label, bars] of transplant.labelGroups) {
    tracks.push({ type: 'transplant', label, bars })
  }

  // Harvest tracks
  if (harvest.unlabelledBars.length || harvestDots.length) {
    tracks.push({ type: 'harvest', bars: harvest.unlabelledBars, dots: harvestDots.length ? harvestDots : undefined })
  }
  for (const [label, bars] of harvest.labelGroups) {
    tracks.push({ type: 'harvest', label, bars })
  }

  return tracks
}
