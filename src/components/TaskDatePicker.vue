<script setup lang="ts">
import { ref } from 'vue'
import { Plus } from '@lucide/vue'
import { CalendarDate, today, getLocalTimeZone } from '@internationalized/date'
import type { DateValue } from 'reka-ui'
import type { TaskType, Window } from '@/types'
import { Button } from '@/components/ui/button'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Calendar } from '@/components/ui/calendar'
import { inWindow } from '@/lib/trackUtils'
import { TASKS, TASK_ORDER } from '@/lib/tasks'

// One button per task type, each opening a calendar limited to past or future days
const props = defineProps<{
  when: 'past' | 'future'
  windows?: { sow?: Window[]; transplant?: Window[]; harvest?: Window[] }
  year?: number | null
}>()

const emit = defineEmits<{ pick: [type: TaskType, date: string] }>()

const openType = ref<TaskType | null>(null)
const staging = ref<DateValue>()
const now = today(getLocalTimeZone())

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function windowsFor(t: TaskType): Window[] {
  return t === 'repot' ? [] : (props.windows?.[t] ?? [])
}

function formatWindow(w: Window): string {
  const [sm = 1, sd = 1] = w.start.split('-').map(Number)
  const [em = 1, ed = 1] = w.end.split('-').map(Number)
  return `${sd} ${MONTHS[sm - 1]} → ${ed} ${MONTHS[em - 1]}`
}

// Open on the window in the plant's year (or today, if today is inside it), kept within the allowed range
function placeholderFor(t: TaskType): DateValue {
  const windows = windowsFor(t)
  const year = props.year ?? now.year
  let date: DateValue = year === now.year ? now : new CalendarDate(year, now.month, 1)
  if (windows.length && !(year === now.year && windows.some((w) => inWindow(now, w)))) {
    date = windows
      .map((w) => {
        const [m = 1, d = 1] = w.start.split('-').map(Number)
        return new CalendarDate(year, m, d)
      })
      .reduce((a, b) => (b.compare(a) < 0 ? b : a))
  }
  const outOfRange = props.when === 'past' ? date.compare(now) > 0 : date.compare(now) < 0
  return outOfRange ? now : date
}

function pick(t: TaskType, v: DateValue | undefined) {
  if (!v) return
  emit('pick', t, v.toString())
  staging.value = undefined
  openType.value = null
}

function highlight(t: TaskType, day: DateValue): string | false {
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
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
    <Popover
      v-for="t in TASK_ORDER"
      :key="t"
      :open="openType === t"
      @update:open="(o: boolean) => (openType = o ? t : null)"
    >
      <PopoverTrigger as-child>
        <Button type="button" variant="outline" size="sm"> <Plus /> {{ TASKS[t].label }} </Button>
      </PopoverTrigger>
      <PopoverContent class="w-auto p-0">
        <div class="px-3 pt-3 text-xs">
          <div class="font-medium flex items-center gap-1.5">
            <span class="size-1.5 rounded-full" :class="TASKS[t].dot" />
            {{ TASKS[t].label }} {{ when === 'past' ? 'date' : 'reminder' }}
          </div>
          <div v-if="windowsFor(t).length" class="text-muted-foreground mt-0.5">
            Window: {{ windowsFor(t).map(formatWindow).join(', ') }}
          </div>
        </div>
        <Calendar
          v-model="staging"
          :initial-focus="true"
          :default-placeholder="placeholderFor(t)"
          :min-value="when === 'future' ? now : undefined"
          :max-value="when === 'past' ? now : undefined"
          layout="month-and-year"
          :highlight-date="(day: DateValue) => highlight(t, day)"
          @update:model-value="(v: DateValue | undefined) => pick(t, v)"
        />
      </PopoverContent>
    </Popover>
  </div>
</template>
