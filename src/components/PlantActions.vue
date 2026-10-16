<script setup lang="ts">
import { useRouter } from 'vue-router'
import { Archive, MoreHorizontal, Pencil, Trash2 } from '@lucide/vue'
import { supabase } from '@/lib/supabase'
import type { Plant } from '@/types'
import { toast } from 'vue-sonner'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const props = defineProps<{ plant: Plant }>()
const emit = defineEmits<{
  archived: [id: string]
  deleted: [id: string]
}>()

const router = useRouter()

async function archive() {
  try {
    await supabase
      .from('plants')
      .update({ archived_at: new Date().toISOString() })
      .eq('id', props.plant.id)
      .throwOnError()
    toast.success(`${props.plant.name} archived`)
    emit('archived', props.plant.id)
  } catch {
    toast.error('Failed to archive plant')
  }
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
        <button class="p-1 rounded-md hover:bg-muted transition-colors" @click.stop>
          <MoreHorizontal class="w-4 h-4 text-muted-foreground" />
        </button>
      </slot>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end">
      <DropdownMenuItem @click="router.push(`/plants/${plant.id}/edit`)">
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
