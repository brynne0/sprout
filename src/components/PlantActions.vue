<script setup lang="ts">
import { useRouter } from 'vue-router'
import { Archive, ArchiveRestore, MoreHorizontal, Pencil, Trash2 } from '@lucide/vue'
import { supabase } from '@/lib/supabase'
import { archivePlant, restorePlant } from '@/lib/plants'
import type { Plant } from '@/types'
import { toast } from 'vue-sonner'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const props = defineProps<{ plant: Plant; hideArchive?: boolean }>()
const emit = defineEmits<{
  archived: [id: string]
  restored: [id: string]
  deleted: [id: string]
}>()

const router = useRouter()

async function archive() {
  if (await archivePlant(props.plant)) emit('archived', props.plant.id)
}

async function restore() {
  if (await restorePlant(props.plant)) emit('restored', props.plant.id)
}

async function remove() {
  try {
    await supabase.from('plants').delete().eq('id', props.plant.id).throwOnError()
    toast.success(`${props.plant.name} removed from your garden`)
    emit('deleted', props.plant.id)
  } catch {
    toast.error('Failed to delete plant')
  }
}
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <slot>
        <Button variant="ghost-muted" size="icon-sm" aria-label="Plant actions" @click.stop>
          <MoreHorizontal />
        </Button>
      </slot>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end">
      <DropdownMenuItem @click="router.push(`/plants/${plant.id}/edit`)">
        <Pencil class="w-4 h-4" />
        Edit
      </DropdownMenuItem>
      <template v-if="plant.archived_at">
        <DropdownMenuSeparator />
        <DropdownMenuItem @click="restore">
          <ArchiveRestore class="w-4 h-4" />
          Restore
        </DropdownMenuItem>
      </template>
      <template v-else-if="!hideArchive">
        <DropdownMenuSeparator />
        <DropdownMenuItem @click="archive">
          <Archive class="w-4 h-4" />
          Archive
        </DropdownMenuItem>
      </template>
      <DropdownMenuSeparator />
      <DropdownMenuItem variant="destructive" @click="remove">
        <Trash2 class="w-4 h-4" />
        Delete
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
