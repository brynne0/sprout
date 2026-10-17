<script setup lang="ts">
import { computed } from 'vue'
import type { TaskType, Window } from '@/types'
import { formatDate } from '@/lib/utils'
import { TASKS, TASK_ORDER } from '@/lib/tasks'
import TaskDatePicker from '@/components/TaskDatePicker.vue'
import {
  TagsInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from '@/components/ui/tags-input'

// Everything done to a plant in one list, with an add button per task type.
const sow = defineModel<string[]>('sow', { required: true })
const repot = defineModel<string[]>('repot', { required: true })
const transplant = defineModel<string[]>('transplant', { required: true })
const harvest = defineModel<string[]>('harvest', { required: true })

defineProps<{
  windows?: { sow?: Window[]; transplant?: Window[]; harvest?: Window[] }
  year?: number | null
}>()

const models = { sow, repot, transplant, harvest }

const entries = computed(() =>
  TASK_ORDER.flatMap((type) =>
    models[type].value.map((date, index) => ({ type, ...TASKS[type], date, index })),
  ).sort((a, b) => a.date.localeCompare(b.date)),
)

function add(t: TaskType, date: string) {
  models[t].value = [...models[t].value, date]
}

type Entry = (typeof entries.value)[number]

const entryTags = computed({
  get: () => entries.value,
  set: (remaining) => {
    for (const t of TASK_ORDER) {
      models[t].value = (remaining as Entry[]).filter((e) => e.type === t).map((e) => e.date)
    }
  },
})

const displayEntry = (v: unknown) => {
  const e = v as Entry
  return `${e.done} · ${formatDate(e.date)}`
}
</script>

<template>
  <div class="flex flex-col gap-3">
    <div v-if="entries.length" class="flex flex-wrap gap-2">
      <TagsInput v-model="entryTags" :display-value="displayEntry">
        <TagsInputItem v-for="e in entries" :key="`${e.type}-${e.index}`" :value="e">
          <span class="size-1.5 rounded-full" :class="e.dot" />
          <TagsInputItemText />
          <TagsInputItemDelete tabindex="0" />
        </TagsInputItem>
      </TagsInput>
    </div>
    <p v-else class="text-sm text-muted-foreground">Nothing logged yet.</p>

    <TaskDatePicker when="past" :windows="windows" :year="year" @pick="add" />
  </div>
</template>
