<script setup lang="ts">
import { Archive } from '@lucide/vue'
import { Button } from '@/components/ui/button'
import type { Plant, TaskType } from '@/types'
import { archivePlant } from '@/lib/plants'
import PlantActions from '@/components/PlantActions.vue'
import PlantIcon from '@/components/PlantIcon.vue'

const props = defineProps<{
  plant: Plant
  hint?: { label: string; task: TaskType } | null
  quickArchive?: boolean
}>()
const emit = defineEmits<{ changed: [] }>()

async function archive() {
  if (await archivePlant(props.plant)) emit('changed')
}
</script>

<template>
  <div
    class="flex items-center gap-1 pr-2 rounded-xl border bg-card border-border transition-colors hover:bg-[color-mix(in_oklab,var(--color-foreground)_3%,transparent)]"
    :class="{ 'opacity-60': plant.archived_at }"
  >
    <RouterLink
      :to="`/plants/${plant.id}`"
      class="flex flex-1 min-w-0 items-center gap-3 pl-3 py-2 rounded-xl outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
    >
      <PlantIcon
        :name="plant.name"
        :icon="plant.icon"
        :colour="plant.colour"
        :task="hint?.task"
        :task-label="hint?.label"
        class="w-8 h-8 rounded-full text-sm"
      />
      <div class="min-w-0 flex-1">
        <div class="text-sm font-medium line-clamp-2">
          {{ plant.name
          }}<span v-if="plant.variety" class="font-normal text-muted-foreground">
            · {{ plant.variety }}</span
          >
        </div>
      </div>
    </RouterLink>
    <Button
      v-if="quickArchive"
      variant="ghost-muted"
      size="icon-sm"
      aria-label="Archive"
      title="Archive"
      @click="archive"
    >
      <Archive />
    </Button>
    <!-- Sibling of the link, not inside it, so the menu button is valid HTML -->
    <PlantActions
      :plant="plant"
      :hide-archive="quickArchive"
      @archived="emit('changed')"
      @restored="emit('changed')"
      @deleted="emit('changed')"
    />
  </div>
</template>
