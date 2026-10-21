<script setup lang="ts">
import { Archive } from '@lucide/vue'
import { Button } from '@/components/ui/button'
import { Item, ItemActions, ItemContent, ItemMedia } from '@/components/ui/item'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip'
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
  <Item variant="outline" size="sm" :class="{ 'opacity-60': plant.archived_at }">
    <RouterLink
      :to="`/plants/${plant.id}`"
      class="flex flex-1 min-w-0 items-center gap-3 rounded-xl outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
    >
      <ItemMedia>
        <PlantIcon
          :name="plant.name"
          :icon="plant.icon"
          :colour="plant.colour"
          :task="hint?.task"
          :task-label="hint?.label"
        />
      </ItemMedia>
      <ItemContent>
        <div class="font-medium line-clamp-2">
          {{ plant.name
          }}<span v-if="plant.variety" class="font-normal text-muted-foreground">
            · {{ plant.variety }}</span
          >
        </div>
      </ItemContent>
    </RouterLink>
    <!-- Sibling of the link, not inside it, so the menu button is valid HTML -->
    <ItemActions>
      <Tooltip v-if="quickArchive">
        <TooltipTrigger as-child>
          <Button variant="ghost-muted" size="icon-sm" aria-label="Archive" @click="archive">
            <Archive />
          </Button>
        </TooltipTrigger>
        <TooltipContent>Archive</TooltipContent>
      </Tooltip>
      <PlantActions
        :plant="plant"
        :hide-archive="quickArchive"
        @archived="emit('changed')"
        @restored="emit('changed')"
        @deleted="emit('changed')"
      />
    </ItemActions>
  </Item>
</template>
