// App-facing shapes for rows from the Supabase views. Generated view types
// (see ./database.ts) mark every column nullable, so queries cast to these.

export type SuitabilityTag = 'multisow' | 'interplant' | 'follow-on'

export type PlantKind = 'vegetable' | 'herb' | 'fruit' | 'flower'

export type Window = {
  /** Start of window as MM-DD (e.g. "01-15") */
  start: string
  /** End of window as MM-DD (e.g. "03-31") */
  end: string
  /** Optional label for this window (e.g. "salad leaves") */
  label?: string
}

export type BasePlant = {
  id: string
  name: string
  variety?: string
  position?: string
  hardiness?: string
  spacing?: string
  germination?: string
  care?: string
  pests?: string
  seed_to_harvest?: string
  sowing_to_transplant?: string
  harvest?: string
  sowing_windows?: Window[]
  harvest_windows?: Window[]
  transplant_windows?: Window[]
  flowering_windows?: Window[]
  height?: string
  icon?: string
  colour?: string
  category_name?: string
}

export type Plant = BasePlant & {
  plant_type_id?: string
  catalogue_id?: string
  custom_variety?: string
  suitability?: SuitabilityTag[]
  sow_dates?: string[]
  repot_dates?: string[]
  transplant_dates?: string[]
  harvest_dates?: string[]
  notes?: string
  year?: number
  archived_at?: string
}

export type TaskType = 'sow' | 'repot' | 'transplant' | 'harvest'

export type Reminder = {
  id: string
  plant_id: string
  type: TaskType
  due_date: string
}

export type PlantType = {
  id: string
  name: string
  category_id?: number
  perennial?: boolean
  icon?: string
  colour?: string
}

export type CataloguePlant = BasePlant & {
  plant_type_id?: string
  suitability?: SuitabilityTag[]
  source?: string
  kind?: PlantKind
}
