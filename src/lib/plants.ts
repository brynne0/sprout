import { toast } from 'vue-sonner'
import type { Plant } from '@/types'
import { supabase } from '@/lib/supabase'

export const PRODUCE_COLOURS = [
  'red',
  'orange',
  'yellow',
  'leaf',
  'deep',
  'sage',
  'blue',
  'purple',
  'pink',
  'beet',
  'earth',
] as const

export async function archivePlant(plant: Plant): Promise<boolean> {
  try {
    await supabase
      .from('plants')
      .update({ archived_at: new Date().toISOString() })
      .eq('id', plant.id)
      .throwOnError()
    toast.success(`${plant.name} archived`)
    return true
  } catch {
    toast.error('Failed to archive plant')
    return false
  }
}

export async function restorePlant(plant: Plant): Promise<boolean> {
  try {
    await supabase.from('plants').update({ archived_at: null }).eq('id', plant.id).throwOnError()
    toast.success(`${plant.name} restored`)
    return true
  } catch {
    toast.error('Failed to restore plant')
    return false
  }
}
