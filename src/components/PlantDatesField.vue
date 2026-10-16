<script setup lang="ts">
import { computed, ref } from 'vue'
import { Plus, X } from '@lucide/vue'
import { CalendarDate, today, getLocalTimeZone } from '@internationalized/date'
import type { DateValue } from 'reka-ui'
import type { Window } from '@/types'
import { Button } from '@/components/ui/button'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Calendar } from '@/components/ui/calendar'
import { formatDate } from '@/lib/utils'

// All of a plant's task dates in one list, with an add button per task type.
const sow = defineModel<string[]>('sow', { required: true })
const repot = defineModel<string[]>('repot', { required: true })
const transplant = defineModel<string[]>('transplant', { required: true })
const harvest = defineModel<string[]>('harvest', { required: true })

const props = defineProps<{
  windows?: { sow?: Window[]; transplant?: Window[]; harvest?: Window[] }
  year?: number | null
}>()

type DateType = 'sow' | 'repot' | 'transplant' | 'harvest'

const types: { value: DateType; label: string; dot: string }[] = [
  { value: 'sow', label: 'Sow', dot: 'track-sowing-dot' },
  { value: 'repot', label: 'Repot', dot: 'track-repot-dot' },
  { value: 'transplant', label: 'Transplant', dot: 'track-transplant-dot' },
  { value: 'harvest', label: 'Harvest', dot: 'track-harvest-dot' },
]

const models = { sow, repot, transplant, harvest }

const entries = computed(() =>
  types
    .flatMap((t) => models[t.value].value.map((date, index) => ({ ...t, date, index })))
    .sort((a, b) => a.date.localeCompare(b.date)),
)

const openType = ref<DateType | null>(null)
const staging = ref<DateValue>()
const now = today(getLocalTimeZone())

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function windowsFor(t: DateType): Window[] {
  return t === 'repot' ? [] : (props.windows?.[t] ?? [])
}

function formatWindow(w: Window): string {
  const [sm = 1, sd = 1] = w.start.split('-').map(Number)
  const [em = 1, ed = 1] = w.end.split('-').map(Number)
  return `${sd} ${MONTHS[sm - 1]} → ${ed} ${MONTHS[em - 1]}`
}

function inWindow(day: DateValue, w: Window): boolean {
  const [sm, sd] = w.start.split('-').map(Number)
  const [em, ed] = w.end.split('-').map(Number)
  const d = day.month * 100 + day.day
  const start = sm! * 100 + sd!
  const end = em! * 100 + ed!
  return start > end ? d >= start || d <= end : d >= start && d <= end
}

// Open the calendar on the window in the plant's year (or today, if today is inside it),
// so the highlighted window is visible straight away
function placeholderFor(t: DateType): DateValue {
  const windows = windowsFor(t)
  const year = props.year ?? now.year
  if (!windows.length || (year === now.year && windows.some((w) => inWindow(now, w)))) {
    return year === now.year ? now : new CalendarDate(year, now.month, 1)
  }
  const starts = windows.map((w) => {
    const [m = 1, d = 1] = w.start.split('-').map(Number)
    return new CalendarDate(year, m, d)
  })
  return starts.reduce((a, b) => (b.compare(a) < 0 ? b : a))
}

function add(t: DateType, v: DateValue | undefined) {
  if (!v) return
  const model = models[t]
  model.value = [...model.value, v.toString()]
  staging.value = undefined
  openType.value = null
}

function remove(t: DateType, index: number) {
  const model = models[t]
  model.value = model.value.filter((_, i) => i !== index)
}

function highlight(t: DateType, day: DateValue): string | false {
  const d = day.month * 100 + day.day
  for (const w of windowsFor(t)) {
    if (!inWindow(day, w)) continue
    const [sm, sd] = w.start.split('-').map(Number)
    const [em, ed] = w.end.split('-').map(Number)
    const start = sm! * 100 + sd!
    const end = em! * 100 + ed!
    if (d === start && d === end) return 'bg-primary/15 rounded-md'
    if (d === start) return 'bg-primary/15 rounded-l-md rounded-r-none'
    if (d === end) return 'bg-primary/15 rounded-r-md rounded-l-none'
    return 'bg-primary/15 rounded-none'
  }
  return false
}
</script>

<template>
  <div class="flex flex-col gap-3">
    <div v-if="entries.length" class="flex flex-wrap gap-2">
      <span
        v-for="e in entries"
        :key="`${e.value}-${e.index}`"
        class="flex items-center gap-1.5 rounded-md border px-2 py-1 text-sm"
      >
        <span class="size-1.5 rounded-full" :class="e.dot" />
        {{ e.label }} · {{ formatDate(e.date) }}
        <button
          type="button"
          class="text-muted-foreground hover:text-foreground"
          :aria-label="`Remove ${e.label} ${formatDate(e.date)}`"
          @click="remove(e.value, e.index)"
        >
          <X class="h-3 w-3" />
        </button>
      </span>
    </div>
    <p v-else class="text-sm text-muted-foreground">No dates yet.</p>

    <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
      <Popover
        v-for="t in types"
        :key="t.value"
        :open="openType === t.value"
        @update:open="(o: boolean) => (openType = o ? t.value : null)"
      >
        <PopoverTrigger as-child>
          <Button type="button" variant="outline" size="sm"> <Plus /> {{ t.label }} </Button>
        </PopoverTrigger>
        <PopoverContent class="w-auto p-0">
          <div class="px-3 pt-3 text-xs">
            <div class="font-medium flex items-center gap-1.5">
              <span class="size-1.5 rounded-full" :class="t.dot" />
              {{ t.label }} date
            </div>
            <div v-if="windowsFor(t.value).length" class="text-muted-foreground mt-0.5">
              Window: {{ windowsFor(t.value).map(formatWindow).join(', ') }}
            </div>
          </div>
          <Calendar
            v-model="staging"
            :initial-focus="true"
            :default-placeholder="placeholderFor(t.value)"
            layout="month-and-year"
            :highlight-date="(day: DateValue) => highlight(t.value, day)"
            @update:model-value="(v: DateValue | undefined) => add(t.value, v)"
          />
        </PopoverContent>
      </Popover>
    </div>
  </div>
</template>
