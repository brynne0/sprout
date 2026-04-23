<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Track, TrackType } from '@/lib/trackUtils'
import { TRACK_HEIGHT, TRACK_GAP, ROW_PADDING, rowHeightForTrackCount } from '@/lib/trackUtils'
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

const trackCount = computed(() => resolvedTracks.value.length)
const height = computed(() => rowHeightForTrackCount(trackCount.value))

function trackTop(index: number): number {
  return ROW_PADDING + index * (TRACK_HEIGHT + TRACK_GAP)
}

function isHidden(type: TrackType): boolean {
  return props.hiddenTracks?.has(type) ?? false
}

function dotLabel(type: TrackType, variant?: string): string {
  if (variant === 'repot') return 'Repotted on'
  if (type === 'sowing') return 'Sown on'
  return 'Transplanted on'
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
      <Popover
        v-for="(dot, di) in showDots ? (track.dots ?? []) : []"
        :key="`dot-${ti}-${di}`"
        :open="openDotKey === `${ti}-${di}`"
        @update:open="(v) => (openDotKey = v ? `${ti}-${di}` : null)"
      >
        <PopoverTrigger as-child>
          <button
            v-show="!isHidden(track.type)"
            class="absolute w-2.5 h-2.5 rounded-full cursor-pointer border border-border"
            :class="dot.variant === 'repot' ? 'track-repot-dot' : `track-${track.type}-dot`"
            :style="{ left: dot.x - 5 + 'px', top: trackTop(ti) + TRACK_HEIGHT / 2 - 5 + 'px' }"
            @mouseenter="openDotKey = `${ti}-${di}`"
            @mouseleave="openDotKey = null"
          />
        </PopoverTrigger>
        <PopoverContent
          class="w-auto px-2 py-1 text-xs rounded-sm bg-popover border"
          side="top"
          :side-offset="4"
        >
          {{ dotLabel(track.type, dot.variant) }} {{ formatDate(dot.date) }}
        </PopoverContent>
      </Popover>
    </template>
  </div>
</template>
