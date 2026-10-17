import { toast } from 'vue-sonner'
import type { Plant } from '@/types'
import { supabase } from '@/lib/supabase'

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
