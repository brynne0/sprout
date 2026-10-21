<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { ChevronDown, CalendarCheck, MoreHorizontal, X } from '@lucide/vue'
import { today, getLocalTimeZone } from '@internationalized/date'
import type { DateValue } from 'reka-ui'
import { toast } from 'vue-sonner'
import type { Plant, Reminder } from '@/types'
import { supabase } from '@/lib/supabase'
import { localToday } from '@/lib/utils'
import { TASKS } from '@/lib/tasks'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Card, CardAction, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Checkbox } from '@/components/ui/checkbox'
import {
  Item,
  ItemActions,
  ItemContent,
  ItemGroup,
  ItemMedia,
  ItemSeparator,
  ItemTitle,
} from '@/components/ui/item'
import PlantIcon from '@/components/PlantIcon.vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

// Pass plants to show which plant each reminder is for (the home page)
const props = defineProps<{
  reminders: Reminder[]
  plants?: Plant[]
  limit?: number
}>()

const emit = defineEmits<{ changed: [] }>()

const MS_DAY = 24 * 60 * 60 * 1000
const todayStart = parseISO(localToday())

function parseISO(s: string): Date {
  const p = s.substring(0, 10).split('-').map(Number)
  return new Date(p[0] ?? 0, (p[1] ?? 1) - 1, p[2] ?? 1)
}

function daysFromToday(r: Reminder): number {
  return Math.round((parseISO(r.due_date).getTime() - todayStart.getTime()) / MS_DAY)
}

function fmtRelative(r: Reminder): string {
  const diff = daysFromToday(r)
  if (diff === 0) return 'Today'
  if (diff === 1) return 'Tomorrow'
  if (diff === -1) return 'Yesterday'
  if (diff > 1 && diff < 7) return `In ${diff} days`
  if (diff < 0) return `${-diff} days ago`
  return parseISO(r.due_date).toLocaleDateString('en-AU', { month: 'short', day: 'numeric' })
}

const plantById = computed(() => new Map((props.plants ?? []).map((p) => [p.id, p])))

const visibleReminders = computed(() =>
  props.plants ? props.reminders.filter((r) => plantById.value.has(r.plant_id)) : props.reminders,
)

const groups = computed(() => {
  const sorted = [...visibleReminders.value].sort((a, b) => a.due_date.localeCompare(b.due_date))
  const result = [
    { label: 'Overdue', reminders: sorted.filter((r) => daysFromToday(r) < 0) },
    {
      label: 'This week',
      reminders: sorted.filter((r) => daysFromToday(r) >= 0 && daysFromToday(r) <= 6),
    },
    {
      label: 'Next week',
      reminders: sorted.filter((r) => daysFromToday(r) > 6 && daysFromToday(r) <= 13),
    },
    { label: 'Later', reminders: sorted.filter((r) => daysFromToday(r) > 13) },
  ]
  return result.filter((g) => g.reminders.length)
})

const expanded = ref(false)

const visibleGroups = computed(() => {
  if (!props.limit || expanded.value) return groups.value
  let remaining = props.limit
  const result = []
  for (const group of groups.value) {
    if (remaining <= 0) break
    result.push({ ...group, reminders: group.reminders.slice(0, remaining) })
    remaining -= group.reminders.length
  }
  return result
})

const busy = ref(new Set<string>())

function title(r: Reminder): string {
  const plant = plantById.value.get(r.plant_id)
  return plant ? `${TASKS[r.type].label} ${plant.name}` : TASKS[r.type].label
}

async function complete(r: Reminder, doneOn: string) {
  busy.value.add(r.id)
  try {
    await supabase.rpc('complete_reminder', { reminder_id: r.id, done_on: doneOn }).throwOnError()
    toast.success(`${title(r)} logged`)
    emit('changed')
  } catch {
    toast.error('Failed to update reminder')
  }
  busy.value.delete(r.id)
}

async function skip(r: Reminder) {
  busy.value.add(r.id)
  try {
    await supabase.from('reminders').delete().eq('id', r.id).throwOnError()
    emit('changed')
  } catch {
    toast.error('Failed to skip reminder')
  }
  busy.value.delete(r.id)
}

const otherDayFor = ref<Reminder | null>(null)
const now = today(getLocalTimeZone())

function completeOnOtherDay(v: DateValue | undefined) {
  if (!v || !otherDayFor.value) return
  complete(otherDayFor.value, v.toString())
  otherDayFor.value = null
}
</script>

<template>
  <Card>
    <CardHeader>
      <CardTitle>
        To do
        <span
          v-if="visibleReminders.length"
          class="ml-1.5 text-xs font-medium text-muted-foreground"
          >{{ visibleReminders.length }}</span
        >
      </CardTitle>
      <CardAction v-if="limit && visibleReminders.length > limit">
        <Button
          variant="ghost-muted"
          size="xs"
          :aria-expanded="expanded"
          @click="expanded = !expanded"
        >
          {{ expanded ? 'Show less' : 'Show all' }}
          <ChevronDown
            class="size-3 transition-transform duration-200"
            :class="{ 'rotate-180': expanded }"
          />
        </Button>
      </CardAction>
    </CardHeader>
    <CardContent class="pt-0">
      <p v-if="!visibleReminders.length" class="text-sm italic text-muted-foreground opacity-70">
        Nothing planned.
      </p>
      <template v-for="group in visibleGroups" :key="group.label">
        <p
          class="text-2xs font-semibold uppercase tracking-wider px-1 pt-2.5 pb-0.5 first:pt-1"
          :class="group.label === 'Overdue' ? 'text-destructive' : 'text-muted-foreground'"
        >
          {{ group.label }}
        </p>
        <ItemGroup>
          <template v-for="(r, i) in group.reminders" :key="r.id">
            <ItemSeparator v-if="i > 0" />
            <Item size="xs">
              <Checkbox
                :model-value="busy.has(r.id)"
                :disabled="busy.has(r.id)"
                :aria-label="`Mark ${title(r)} as done today`"
                @update:model-value="complete(r, localToday())"
              />
              <ItemMedia>
                <PlantIcon
                  v-if="plantById.get(r.plant_id)"
                  :name="plantById.get(r.plant_id)!.name"
                  :icon="plantById.get(r.plant_id)!.icon"
                  :colour="plantById.get(r.plant_id)!.colour"
                />
                <component
                  :is="TASKS[r.type].icon"
                  v-else
                  :size="15"
                  :style="{ color: TASKS[r.type].soft }"
                />
              </ItemMedia>
              <ItemContent>
                <component
                  :is="plants ? RouterLink : 'div'"
                  :to="plants ? `/plants/${r.plant_id}` : undefined"
                  class="flex items-baseline gap-1.5"
                >
                  <ItemTitle>{{ title(r) }}</ItemTitle>
                  <span
                    v-if="plantById.get(r.plant_id)?.variety"
                    class="text-xs truncate text-muted-foreground"
                  >
                    {{ plantById.get(r.plant_id)?.variety }}
                  </span>
                </component>
              </ItemContent>
              <ItemActions>
                <span
                  class="text-xs font-medium tabular-nums"
                  :class="daysFromToday(r) < 0 ? 'text-destructive' : 'text-muted-foreground'"
                >
                  {{ fmtRelative(r) }}
                </span>
                <DropdownMenu>
                  <DropdownMenuTrigger as-child>
                    <Button variant="ghost-muted" size="icon-sm" aria-label="Reminder actions">
                      <MoreHorizontal />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem @click="otherDayFor = r">
                      <CalendarCheck class="w-4 h-4" />
                      Done on another day
                    </DropdownMenuItem>
                    <DropdownMenuItem @click="skip(r)">
                      <X class="w-4 h-4" />
                      Skip
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </ItemActions>
            </Item>
          </template>
        </ItemGroup>
      </template>
      <slot />
    </CardContent>
  </Card>

  <Dialog :open="!!otherDayFor" @update:open="(o: boolean) => !o && (otherDayFor = null)">
    <DialogContent class="w-auto">
      <DialogHeader>
        <DialogTitle
          >When did you
          {{ otherDayFor && TASKS[otherDayFor.type].label.toLowerCase() }}?</DialogTitle
        >
      </DialogHeader>
      <Calendar :max-value="now" layout="month-and-year" @update:model-value="completeOnOtherDay" />
    </DialogContent>
  </Dialog>
</template>
