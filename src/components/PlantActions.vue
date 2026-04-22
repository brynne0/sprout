<script setup lang="ts">
import { ref } from 'vue'
import { Archive, MoreHorizontal, Pencil, Trash2 } from 'lucide-vue-next'
import { deleteApiPlantsById, patchApiPlantsByIdArchive } from '@/client'
import type { Plant } from '@/client'
import { toast } from 'vue-sonner'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import PlantDialogue from '@/components/PlantDialogue.vue'

const props = defineProps<{ plant: Plant }>()
const emit = defineEmits<{
  updated: []
  archived: [id: string]
  deleted: [id: string]
}>()

const editOpen = ref(false)

async function archive() {
  try {
    await patchApiPlantsByIdArchive({ path: { id: props.plant.id }, throwOnError: true })
    toast.success(`${props.plant.name} archived`)
    emit('archived', props.plant.id)
  } catch {
    toast.error('Failed to archive plant')
  }
}

async function remove() {
  try {
    await deleteApiPlantsById({ path: { id: props.plant.id }, throwOnError: true })
    toast.success(`${props.plant.name} removed from your garden`)
    emit('deleted', props.plant.id)
  } catch {
    toast.error('Failed to delete plant')
  }
}
</script>

<template>
  <PlantDialogue v-model:open="editOpen" :plant="plant" @plant-added="emit('updated')" />
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <slot>
        <button class="p-1 rounded-md hover:bg-muted transition-colors" @click.stop>
          <MoreHorizontal class="w-4 h-4 text-muted-foreground" />
        </button>
      </slot>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end">
      <DropdownMenuItem @click="editOpen = true">
        <Pencil class="w-4 h-4" />
        Edit
      </DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem @click="archive">
        <Archive class="w-4 h-4" />
        Archive
      </DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem variant="destructive" @click="remove">
        <Trash2 class="w-4 h-4" />
        Delete
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
