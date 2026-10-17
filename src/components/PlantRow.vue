<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Bar, Dot, Track, TrackType } from '@/lib/trackUtils'
import { TRACK_HEIGHT, LABEL_HEIGHT, trackTops, rowHeightForTracks } from '@/lib/trackUtils'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { formatDate } from '@/lib/utils'

const props = withDefaults(
  defineProps<{
    tracks?: Track[]
    monthWidth?: number
    showDots?: boolean
    hiddenTracks?: Set<TrackType>
    todayX?: number | null
  }>(),
  { showDots: false, hiddenTracks: () => new Set() },
)

const resolvedTracks = computed(() => props.tracks ?? [])
const resolvedMonthWidth = computed(() => props.monthWidth ?? 0)
const resolvedTodayX = computed<number | null>(() => props.todayX ?? null)

const height = computed(() => rowHeightForTracks(resolvedTracks.value))
const tops = computed(() => trackTops(resolvedTracks.value))

function trackTop(index: number): number {
  return tops.value[index]!
}

const LABEL_CHAR_WIDTH = 6

function labelStyle(bar: Bar, label: string, trackIndex: number) {
  const total = 12 * resolvedMonthWidth.value
  const top = trackTop(trackIndex) - LABEL_HEIGHT + 'px'
  const end = bar.x + bar.width
  if (total - bar.x >= label.length * LABEL_CHAR_WIDTH) {
    return { left: bar.x + 'px', top, maxWidth: total - bar.x + 'px' }
  }
  return { right: total - end + 'px', top, maxWidth: end + 'px' }
}

function isHidden(type: TrackType): boolean {
  return props.hiddenTracks?.has(type) ?? false
}

function dotLabel(type: TrackType, dot: Dot): string {
  const upcoming = !!dot.planned
  if (dot.variant === 'repot') return upcoming ? 'Repot on' : 'Repotted on'
  if (type === 'sowing') return upcoming ? 'Sow on' : 'Sown on'
  if (type === 'harvest') return upcoming ? 'Harvest on' : 'Harvested on'
  return upcoming ? 'Transplant on' : 'Transplanted on'
}

const openDotKey = ref<string | null>(null)
</script>

<template>
  <div
    class="relative"
    :style="{ width: 12 * resolvedMonthWidth + 'px', minHeight: height + 'px' }"
  >
    <div
      v-if="resolvedTodayX !== null"
      class="pointer-events-none absolute top-0 bottom-0 z-10 border-l-2 border-dashed border-primary/60"
      :style="{ left: resolvedTodayX + 'px' }"
    />
    <template v-for="(track, ti) in resolvedTracks" :key="`track-${ti}`">
      <template v-for="(b, bi) in track.bars" :key="`bar-${ti}-${bi}`">
        <div
          v-show="!isHidden(track.type)"
          class="absolute h-2 border rounded-[4px]"
          :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
          :style="{ left: b.x + 'px', width: b.width + 'px', top: trackTop(ti) + 'px' }"
        />
        <span
          v-if="track.label"
          v-show="!isHidden(track.type)"
          class="absolute h-2.5 text-[8.5px] font-bold uppercase tracking-[0.08em] leading-2.5 truncate"
          :class="`track-${track.type}-text`"
          :style="labelStyle(b, track.label, ti)"
          :title="track.label"
          >{{ track.label }}</span
        >
      </template>
      <Popover
        v-for="(dot, di) in showDots ? (track.dots ?? []) : []"
        :key="`dot-${ti}-${di}`"
        :open="openDotKey === `${ti}-${di}`"
        @update:open="
          (v) => {
            if (v) openDotKey = `${ti}-${di}`
            else if (openDotKey === `${ti}-${di}`) openDotKey = null
          }
        "
      >
        <PopoverTrigger as-child>
          <button
            v-show="!isHidden(track.type)"
            class="absolute z-20 w-2.5 h-2.5 rounded-full cursor-pointer ring-1 ring-background dark:ring-card"
            :class="[
              dot.variant === 'repot' ? 'track-repot-dot' : `track-${track.type}-dot`,
              { 'opacity-40': dot.planned },
            ]"
            :style="{ left: dot.x - 5 + 'px', top: trackTop(ti) + TRACK_HEIGHT / 2 - 5 + 'px' }"
            @pointerenter="
              (e: PointerEvent) => {
                if (e.pointerType === 'mouse') openDotKey = `${ti}-${di}`
              }
            "
            @pointerleave="
              (e: PointerEvent) => {
                if (e.pointerType === 'mouse') openDotKey = null
              }
            "
          />
        </PopoverTrigger>
        <PopoverContent
          class="w-auto px-2 py-1 text-xs rounded-sm bg-popover border"
          side="top"
          :side-offset="4"
        >
          {{ dotLabel(track.type, dot) }} {{ formatDate(dot.date) }}
        </PopoverContent>
      </Popover>
    </template>
  </div>
</template>
