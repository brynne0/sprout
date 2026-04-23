<script setup lang="ts">
import { computed, ref } from 'vue'
import type { BasePlant } from '@/client'
import { useElementSize } from '@vueuse/core'
import {
  TRACK_HEIGHT,
  TRACK_GAP,
  ROW_PADDING,
  computeTracksForPlant,
  dateToX,
  rowHeightForTrackCount,
} from '@/lib/trackUtils'
import type { Track, TrackType } from '@/lib/trackUtils'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { formatDate } from '@/lib/utils'

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
const TRACK_LABELS: Record<TrackType, string> = {
  sowing: 'Sow',
  transplant: 'Transplant',
  harvest: 'Harvest',
}

const props = withDefaults(
  defineProps<{
    plant?: BasePlant
    tracks?: Track[]
    monthWidth?: number
    showDots?: boolean
    hiddenTracks?: Set<TrackType>
    todayX?: number | null
  }>(),
  { showDots: false, hiddenTracks: () => new Set() },
)

const containerRef = ref<HTMLElement | null>(null)
const { width: containerWidth } = useElementSize(containerRef)

const resolvedMonthWidth = computed(
  () => props.monthWidth ?? (containerWidth.value > 0 ? containerWidth.value / 12 : 0),
)

const resolvedTracks = computed(
  () =>
    props.tracks ??
    (props.plant ? computeTracksForPlant(props.plant, resolvedMonthWidth.value) : []),
)

const resolvedTodayX = computed<number | null>(() => {
  if (props.todayX !== undefined) return props.todayX
  return dateToX(new Date().getMonth() + 1, new Date().getDate(), resolvedMonthWidth.value)
})

const labelledRows = computed(() =>
  (['sowing', 'transplant', 'harvest'] as TrackType[])
    .map((type) => ({
      type,
      label: TRACK_LABELS[type],
      tracks: resolvedTracks.value.filter((t) => t.type === type),
    }))
    .filter((r) => r.tracks.length > 0),
)

const trackCount = computed(() => resolvedTracks.value.length)
const height = computed(() => rowHeightForTrackCount(trackCount.value))

function rowHeightForTracks(tracks: Track[]): number {
  return rowHeightForTrackCount(tracks.length)
}

function trackTop(index: number): number {
  return ROW_PADDING + index * (TRACK_HEIGHT + TRACK_GAP)
}

function isHidden(type: TrackType): boolean {
  return props.hiddenTracks?.has(type) ?? false
}
</script>

<template>
  <!-- Standalone mode: month header + labelled rows -->
  <div v-if="plant" class="flex flex-col gap-0.5">
    <div class="flex">
      <div class="w-19.5 shrink-0" />
      <div
        ref="containerRef"
        class="flex flex-1 text-[10px] tracking-[0.02em] text-muted-foreground"
      >
        <div v-for="m in MONTH_LABELS" :key="m" class="flex-1 text-center">{{ m[0] }}</div>
      </div>
    </div>
    <div v-for="row in labelledRows" :key="row.type" class="flex">
      <div class="w-19.5 shrink-0 text-[11px] font-medium text-muted-foreground flex items-center">
        {{ row.label }}
      </div>
      <div
        class="relative"
        :style="{
          width: 12 * resolvedMonthWidth + 'px',
          minHeight: rowHeightForTracks(row.tracks) + 'px',
        }"
      >
        <div
          v-if="resolvedTodayX !== null"
          class="absolute top-0 bottom-0 border-l-2 border-dashed border-primary/60"
          :style="{ left: resolvedTodayX + 'px' }"
        />
        <template v-for="(track, ti) in row.tracks" :key="`track-${ti}`">
          <template v-if="track.label && !isHidden(track.type)">
            <Popover v-for="(b, bi) in track.bars" :key="`bar-${ti}-${bi}`">
              <PopoverTrigger as-child>
                <button
                  class="absolute h-2.5 overflow-hidden flex items-center cursor-pointer border rounded-sm"
                  :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
                  :style="{ left: b.x + 'px', width: b.width + 'px', top: trackTop(ti) + 'px' }"
                >
                  <span
                    v-if="b.width > 30"
                    class="text-[8px] leading-none truncate px-1 text-muted-foreground"
                    >{{ track.label }}</span
                  >
                </button>
              </PopoverTrigger>
              <PopoverContent
                class="w-auto px-2 py-1 text-xs rounded-sm z-1 border"
                :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
                side="top"
                :side-offset="4"
              >
                {{ track.label }}
              </PopoverContent>
            </Popover>
          </template>
          <template v-else>
            <div
              v-for="(b, bi) in track.bars"
              v-show="!isHidden(track.type)"
              :key="`bar-${ti}-${bi}`"
              class="absolute h-2.5 border rounded-sm"
              :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
              :style="{ left: b.x + 'px', width: b.width + 'px', top: trackTop(ti) + 'px' }"
            />
          </template>
          <Popover v-for="(dot, di) in showDots ? (track.dots ?? []) : []" :key="`dot-${ti}-${di}`">
            <PopoverTrigger as-child>
              <button
                v-show="!isHidden(track.type)"
                class="absolute w-2.5 h-2.5 rounded-full z-10 cursor-pointer border border-border"
                :class="dot.variant === 'repot' ? 'track-repot-dot' : `track-${track.type}-dot`"
                :style="{ left: dot.x - 5 + 'px', top: trackTop(ti) + TRACK_HEIGHT / 2 - 5 + 'px' }"
              />
            </PopoverTrigger>
            <PopoverContent
              class="w-auto px-2 py-1 text-xs rounded-sm z-1"
              side="top"
              :side-offset="4"
            >
              {{ formatDate(dot.date) }}
            </PopoverContent>
          </Popover>
        </template>
      </div>
    </div>
  </div>

  <!-- Embedded mode: bare bars, used inside PlantCalendar -->
  <div
    v-else
    class="relative"
    :style="{ width: 12 * resolvedMonthWidth + 'px', minHeight: height + 'px' }"
  >
    <div
      v-if="resolvedTodayX !== null"
      class="absolute top-0 bottom-0 border-l-2 border-dashed border-primary/60"
      :style="{ left: resolvedTodayX + 'px' }"
    />
    <template v-for="(track, ti) in resolvedTracks" :key="`track-${ti}`">
      <template v-if="track.label && !isHidden(track.type)">
        <Popover v-for="(b, bi) in track.bars" :key="`bar-${ti}-${bi}`">
          <PopoverTrigger as-child>
            <button
              class="absolute h-2.5 overflow-hidden flex items-center cursor-pointer border rounded-sm"
              :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
              :style="{ left: b.x + 'px', width: b.width + 'px', top: trackTop(ti) + 'px' }"
            >
              <span
                v-if="b.width > 30"
                class="text-[8px] leading-none truncate px-1 text-muted-foreground"
                >{{ track.label }}</span
              >
            </button>
          </PopoverTrigger>
          <PopoverContent
            class="w-auto px-2 py-1 text-xs rounded-sm z-1 border"
            :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
            side="top"
            :side-offset="4"
          >
            {{ track.label }}
          </PopoverContent>
        </Popover>
      </template>
      <template v-else>
        <div
          v-for="(b, bi) in track.bars"
          v-show="!isHidden(track.type)"
          :key="`bar-${ti}-${bi}`"
          class="absolute h-2.5 border rounded-sm"
          :class="[`track-${track.type}-bg`, `track-${track.type}-border`]"
          :style="{ left: b.x + 'px', width: b.width + 'px', top: trackTop(ti) + 'px' }"
        />
      </template>
      <Popover v-for="(dot, di) in showDots ? (track.dots ?? []) : []" :key="`dot-${ti}-${di}`">
        <PopoverTrigger as-child>
          <button
            v-show="!isHidden(track.type)"
            class="absolute w-2.5 h-2.5 rounded-full z-10 cursor-pointer border border-border"
            :class="dot.variant === 'repot' ? 'track-repot-dot' : `track-${track.type}-dot`"
            :style="{ left: dot.x - 5 + 'px', top: trackTop(ti) + TRACK_HEIGHT / 2 - 5 + 'px' }"
          />
        </PopoverTrigger>
        <PopoverContent class="w-auto px-2 py-1 text-xs rounded-sm z-1" side="top" :side-offset="4">
          {{ formatDate(dot.date) }}
        </PopoverContent>
      </Popover>
    </template>
  </div>
</template>
