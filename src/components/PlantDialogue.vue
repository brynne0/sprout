<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { ChevronDown, ChevronsUpDown, Check, Plus, X } from 'lucide-vue-next'
import {
  Dialog,
  DialogClose,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogScrollContent,
  DialogDescription,
} from '@/components/ui/dialog'
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Spinner } from '@/components/ui/spinner'
import { RangeCalendar } from '@/components/ui/range-calendar'
import type { DateRange } from 'reka-ui'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import { Field, FieldGroup, FieldLabel } from '@/components/ui/field'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { PlantType, CataloguePlant, Plant } from '@/client'
import {
  postApiPlants,
  putApiPlantsById,
  getApiPlantTypes,
  getApiPlantTypesByIdCatalogue,
} from '@/client'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { cn } from '@/lib/utils'
import { getLocalTimeZone, today } from '@internationalized/date'
import type { DateValue } from 'reka-ui'
import { toast } from 'vue-sonner'
import { Textarea } from '@/components/ui/textarea'
import { Checkbox } from '@/components/ui/checkbox'
import { CheckboxGroupRoot } from 'reka-ui'
import { formatDate } from '@/lib/utils'

const props = defineProps<{ open: boolean; plant?: Plant | null }>()
const emit = defineEmits<{ 'update:open': [boolean]; plantAdded: [] }>()

const isEditMode = computed(() => !!props.plant)

const dialogOpen = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
})

const plantTypeComboOpen = ref(false)
const catalogueComboOpen = ref(false)
const showOverrides = ref(false)

const defaultPlaceholder = today(getLocalTimeZone())

// Plant type + catalogue entry selection
const plantTypes = ref<PlantType[]>([])
const catalogueEntries = ref<CataloguePlant[]>([])
const selectedPlantTypeId = ref('')
const selectedCatalogueId = ref('')
const customVariety = ref('')
const isCustomVariety = ref(false)

const sowDates = ref<string[]>([])
const transplantDates = ref<string[]>([])
const stagingSowDate = ref<DateValue>()
const stagingTransplantDate = ref<DateValue>()
const notes = ref('')
const year = ref<number | null>(null)

const SUITABILITY_OPTIONS = ['multisow', 'interplant', 'follow-on'] as const

const overrides = ref({
  description: '',
  position: '',
  hardiness: '',
  spacing: '',
  seed_to_harvest: '',
  sowing_to_transplant: '',
  harvest: '',
  suitability: [] as string[],
})

// Window arrays (confirmed selections)
type Window = { start: string; end: string }
const sowingWindows = ref<Window[]>([])
const harvestWindows = ref<Window[]>([])
const transplantWindows = ref<Window[]>([])

// Staging — one calendar open at a time per type
const stagingSowing = ref<DateRange | undefined>()
const stagingHarvest = ref<DateRange | undefined>()
const stagingTransplant = ref<DateRange | undefined>()
const showSowingPicker = ref(false)
const showHarvestPicker = ref(false)
const showTransplantPicker = ref(false)
const showSowDatePicker = ref(false)
const showTransplantDatePicker = ref(false)

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function toMonthDay(d: DateValue): string {
  return `${String(d.month).padStart(2, '0')}-${String(d.day).padStart(2, '0')}`
}

function highlightWindow(day: DateValue, windows: Window[]): string | false {
  const d = day.month * 100 + day.day
  for (const w of windows) {
    const [sm, sd] = w.start.split('-').map(Number)
    const [em, ed] = w.end.split('-').map(Number)
    const start = sm! * 100 + sd!
    const end = em! * 100 + ed!
    const wraps = start > end
    const inRange = wraps ? d >= start || d <= end : d >= start && d <= end
    if (!inRange) continue
    const isStart = d === start
    const isEnd = d === end
    if (isStart && isEnd) return 'bg-primary/15 rounded-md'
    if (isStart) return 'bg-primary/15 rounded-l-md rounded-r-none'
    if (isEnd) return 'bg-primary/15 rounded-r-md rounded-l-none'
    return 'bg-primary/15 rounded-none'
  }
  return false
}

function isInSowWindow(day: DateValue): string | false {
  return highlightWindow(day, selectedCatalogueEntry.value?.sowing_windows ?? [])
}

function isInTransplantWindow(day: DateValue): string | false {
  return highlightWindow(day, selectedCatalogueEntry.value?.transplant_windows ?? [])
}

function formatWindow(w: Window): string {
  const [sm = 1, sd = 1] = w.start.split('-').map(Number)
  const [em = 1, ed = 1] = w.end.split('-').map(Number)
  return `${sd} ${MONTHS[sm - 1]} → ${ed} ${MONTHS[em - 1]}`
}

function confirmSowingWindow() {
  if (stagingSowing.value?.start && stagingSowing.value?.end) {
    sowingWindows.value.push({
      start: toMonthDay(stagingSowing.value.start),
      end: toMonthDay(stagingSowing.value.end),
    })
    stagingSowing.value = undefined
    showSowingPicker.value = false
  }
}
function confirmHarvestWindow() {
  if (stagingHarvest.value?.start && stagingHarvest.value?.end) {
    harvestWindows.value.push({
      start: toMonthDay(stagingHarvest.value.start),
      end: toMonthDay(stagingHarvest.value.end),
    })
    stagingHarvest.value = undefined
    showHarvestPicker.value = false
  }
}
function confirmTransplantWindow() {
  if (stagingTransplant.value?.start && stagingTransplant.value?.end) {
    transplantWindows.value.push({
      start: toMonthDay(stagingTransplant.value.start),
      end: toMonthDay(stagingTransplant.value.end),
    })
    stagingTransplant.value = undefined
    showTransplantPicker.value = false
  }
}

const selectedPlantTypeName = computed(
  () => plantTypes.value.find((p) => p.id === selectedPlantTypeId.value)?.name ?? 'Select plant...',
)

// Catalogue entries that have a named variety
const namedVarieties = computed(() => catalogueEntries.value.filter((e) => e.variety))

const hasVarieties = computed(() => namedVarieties.value.length > 0)

const selectedVarietyLabel = computed(() => {
  if (isCustomVariety.value) return 'Custom'
  const entry = catalogueEntries.value.find((e) => e.id === selectedCatalogueId.value)
  return entry?.variety ?? 'Select variety...'
})

const selectedCatalogueEntry = computed(() =>
  catalogueEntries.value.find((e) => e.id === selectedCatalogueId.value),
)

const canSubmit = computed(() => {
  if (!selectedPlantTypeId.value) return false
  if (hasVarieties.value && !selectedCatalogueId.value && !isCustomVariety.value) return false
  if (isCustomVariety.value && !customVariety.value) return false
  return true
})

const yearOptions = computed(() => {
  const current = today(getLocalTimeZone()).year
  return Array.from({ length: 11 }, (_, i) => current - 5 + i)
})

const cleanedOverrides = computed(() => {
  const result: Record<string, unknown> = Object.fromEntries(
    Object.entries(overrides.value).filter(([, v]) => v !== '' && v != null),
  )
  if (overrides.value.suitability.length) result.suitability = overrides.value.suitability
  if (sowingWindows.value.length) result.sowing_windows = sowingWindows.value
  if (harvestWindows.value.length) result.harvest_windows = harvestWindows.value
  if (transplantWindows.value.length) result.transplant_windows = transplantWindows.value
  return Object.keys(result).length > 0 ? result : undefined
})

const loading = ref(false)

onMounted(async () => {
  const res = await getApiPlantTypes()
  plantTypes.value = res.data ?? []
})

// Pre-fill fields when editing
watch(
  () => props.plant,
  async (plant) => {
    if (!plant) return
    selectedPlantTypeId.value = plant.plant_type_id ?? ''
    if (plant.plant_type_id) {
      const res = await getApiPlantTypesByIdCatalogue({ path: { id: plant.plant_type_id } })
      catalogueEntries.value = res.data ?? []
    }
    if (plant.catalogue_id) {
      selectedCatalogueId.value = plant.catalogue_id
    } else if (plant.custom_variety) {
      isCustomVariety.value = true
    }
    customVariety.value = plant.custom_variety ?? ''
    sowDates.value = [...(plant.sow_dates ?? [])]
    transplantDates.value = [...(plant.transplant_dates ?? [])]
    notes.value = plant.notes ?? ''
    year.value = plant.year ?? today(getLocalTimeZone()).year
    overrides.value.suitability = plant.suitability ?? []
  },
  { immediate: true },
)

// Fetch catalogue entries when plant type changes
watch(selectedPlantTypeId, async (id) => {
  if (isEditMode.value) return
  selectedCatalogueId.value = ''
  customVariety.value = ''
  isCustomVariety.value = false
  catalogueEntries.value = []
  if (id) {
    const res = await getApiPlantTypesByIdCatalogue({ path: { id } })
    catalogueEntries.value = res.data ?? []
    // Auto-select if there's only one entry with no variety
    const single = catalogueEntries.value[0]
    if (catalogueEntries.value.length === 1 && single && !single.variety) {
      selectedCatalogueId.value = single.id
    }
  }
})

watch(
  () => props.open,
  (open) => {
    if (open && !isEditMode.value) {
      year.value = today(getLocalTimeZone()).year
    }
  },
)

function selectPlantType(id: string) {
  selectedPlantTypeId.value = id
  plantTypeComboOpen.value = false
}

function selectCatalogueEntry(id: string) {
  isCustomVariety.value = false
  selectedCatalogueId.value = id
  catalogueComboOpen.value = false
}

function selectCustomVariety() {
  isCustomVariety.value = true
  selectedCatalogueId.value = ''
  catalogueComboOpen.value = false
}

function reset() {
  selectedPlantTypeId.value = ''
  selectedCatalogueId.value = ''
  customVariety.value = ''
  isCustomVariety.value = false
  catalogueEntries.value = []
  sowDates.value = []
  transplantDates.value = []
  stagingSowDate.value = undefined
  stagingTransplantDate.value = undefined
  notes.value = ''
  year.value = null
  showOverrides.value = false
  overrides.value = {
    description: '',
    position: '',
    hardiness: '',
    spacing: '',
    seed_to_harvest: '',
    sowing_to_transplant: '',
    harvest: '',
    suitability: [],
  }
  sowingWindows.value = []
  harvestWindows.value = []
  transplantWindows.value = []
  stagingSowing.value = undefined
  stagingHarvest.value = undefined
  stagingTransplant.value = undefined
  showSowingPicker.value = false
  showHarvestPicker.value = false
  showTransplantPicker.value = false
}

async function submitPlant() {
  loading.value = true
  const body = {
    plant_type_id: selectedPlantTypeId.value,
    catalogue_id: selectedCatalogueId.value || undefined,
    custom_variety: customVariety.value || undefined,
    sow_dates: sowDates.value.length ? sowDates.value : undefined,
    transplant_dates: transplantDates.value.length ? transplantDates.value : undefined,
    notes: notes.value || undefined,
    year: year.value ?? undefined,
    overrides: cleanedOverrides.value,
  }
  try {
    if (isEditMode.value && props.plant) {
      await putApiPlantsById({
        throwOnError: true,
        path: { id: props.plant.id },
        body,
      })
    } else {
      await postApiPlants({ throwOnError: true, body })
    }
    reset()
    emit('plantAdded')
    emit('update:open', false)
  } catch (error) {
    if (error instanceof TypeError) {
      toast.error('Network error', { description: 'Check your connection and try again.' })
    } else {
      toast.error(
        isEditMode.value ? 'Failed to update plant.' : 'Failed to add plant. Please try again.',
      )
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <Dialog v-model:open="dialogOpen">
    <DialogTrigger as-child>
      <slot />
    </DialogTrigger>

    <DialogScrollContent>
      <DialogHeader>
        <DialogTitle>{{ isEditMode ? 'Edit Plant' : 'Add Plant' }}</DialogTitle>
        <DialogDescription class="sr-only">
          {{ isEditMode ? 'Edit plant details' : 'Add a new plant to your garden' }}
        </DialogDescription>
      </DialogHeader>

      <FieldGroup>
        <!-- Step 1: Plant type -->
        <Field>
          <FieldLabel>Plant type<span>*</span></FieldLabel>
          <Popover v-model:open="plantTypeComboOpen">
            <PopoverTrigger as-child>
              <Button
                variant="outline"
                role="combobox"
                :aria-expanded="plantTypeComboOpen"
                :disabled="isEditMode"
                class="w-full justify-between"
              >
                {{ selectedPlantTypeName }}
                <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
              </Button>
            </PopoverTrigger>
            <PopoverContent class="p-0">
              <Command :model-value="selectedPlantTypeName">
                <CommandInput placeholder="Search plants..." />
                <CommandList>
                  <CommandEmpty>No plants found.</CommandEmpty>
                  <CommandGroup>
                    <CommandItem
                      v-for="pt in plantTypes"
                      :key="pt.id"
                      :value="pt.name"
                      @select="() => selectPlantType(pt.id)"
                    >
                      {{ pt.name }}
                      <Check
                        :class="
                          cn(
                            'ml-auto h-4 w-4',
                            selectedPlantTypeId === pt.id ? 'opacity-100' : 'opacity-0',
                          )
                        "
                      />
                    </CommandItem>
                  </CommandGroup>
                </CommandList>
              </Command>
            </PopoverContent>
          </Popover>
        </Field>

        <!-- Step 2: Variety (shown when plant type has named varieties) -->
        <Field v-if="selectedPlantTypeId && hasVarieties">
          <FieldLabel>Variety<span>*</span></FieldLabel>
          <Popover v-model:open="catalogueComboOpen">
            <PopoverTrigger as-child>
              <Button
                variant="outline"
                role="combobox"
                :aria-expanded="catalogueComboOpen"
                class="w-full justify-between"
              >
                {{ selectedVarietyLabel }}
                <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
              </Button>
            </PopoverTrigger>
            <PopoverContent class="p-0">
              <Command :model-value="selectedVarietyLabel">
                <CommandInput placeholder="Search varieties..." />
                <CommandList>
                  <CommandEmpty>No varieties found.</CommandEmpty>
                  <CommandGroup>
                    <CommandItem
                      v-for="entry in namedVarieties"
                      :key="entry.id"
                      :value="entry.variety!"
                      @select="() => selectCatalogueEntry(entry.id)"
                    >
                      {{ entry.variety }}
                      <Check
                        :class="
                          cn(
                            'ml-auto h-4 w-4',
                            selectedCatalogueId === entry.id ? 'opacity-100' : 'opacity-0',
                          )
                        "
                      />
                    </CommandItem>
                    <CommandItem value="__custom" @select="selectCustomVariety">
                      Custom...
                      <Check
                        :class="
                          cn('ml-auto h-4 w-4', isCustomVariety ? 'opacity-100' : 'opacity-0')
                        "
                      />
                    </CommandItem>
                  </CommandGroup>
                </CommandList>
              </Command>
            </PopoverContent>
          </Popover>
        </Field>

        <!-- Custom variety text input -->
        <Field v-if="isCustomVariety || (selectedPlantTypeId && !hasVarieties)">
          <FieldLabel for="customVariety"
            >Variety name<span v-if="isCustomVariety && hasVarieties">*</span></FieldLabel
          >
          <Input
            id="customVariety"
            v-model="customVariety"
            :placeholder="hasVarieties ? 'Enter variety name' : 'Optional'"
          />
        </Field>

        <Field>
          <FieldLabel>Sow Dates</FieldLabel>
          <div v-if="sowDates.length" class="flex flex-wrap gap-2">
            <span
              v-for="(d, i) in sowDates"
              :key="i"
              class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
            >
              {{ formatDate(d) }}
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground"
                @click="sowDates.splice(i, 1)"
              >
                <X class="h-3 w-3" />
              </button>
            </span>
          </div>
          <Popover v-model:open="showSowDatePicker">
            <PopoverTrigger as-child>
              <Button type="button" variant="outline" size="sm" class="w-full">
                <Plus /> Add sow date
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="stagingSowDate"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
                :highlight-date="isInSowWindow"
                @update:model-value="
                  (v: DateValue | undefined) => {
                    if (!v) return
                    sowDates.push(v.toString())
                    stagingSowDate = undefined
                    showSowDatePicker = false
                  }
                "
              />
            </PopoverContent>
          </Popover>
        </Field>

        <Field>
          <FieldLabel>Transplant Dates</FieldLabel>
          <div v-if="transplantDates.length" class="flex flex-wrap gap-2">
            <span
              v-for="(d, i) in transplantDates"
              :key="i"
              class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
            >
              {{ formatDate(d) }}
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground"
                @click="transplantDates.splice(i, 1)"
              >
                <X class="h-3 w-3" />
              </button>
            </span>
          </div>
          <Popover v-model:open="showTransplantDatePicker">
            <PopoverTrigger as-child>
              <Button type="button" variant="outline" size="sm" class="w-full">
                <Plus /> Add transplant date
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="stagingTransplantDate"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
                :highlight-date="isInTransplantWindow"
                @update:model-value="
                  (v: DateValue | undefined) => {
                    if (!v) return
                    transplantDates.push(v.toString())
                    stagingTransplantDate = undefined
                    showTransplantDatePicker = false
                  }
                "
              />
            </PopoverContent>
          </Popover>
        </Field>

        <Field>
          <FieldLabel for="notes">Notes</FieldLabel>
          <Input id="notes" v-model="notes" placeholder="Optional" />
        </Field>

        <Field>
          <FieldLabel>Year</FieldLabel>
          <Select
            :modal="false"
            :model-value="year?.toString() ?? 'all'"
            @update:model-value="(v) => (year = v === 'all' ? null : Number(v))"
          >
            <SelectTrigger class="w-32">
              <SelectValue placeholder="All years" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All years</SelectItem>
              <SelectItem v-for="y in yearOptions" :key="y" :value="y.toString()">
                {{ y }}
              </SelectItem>
            </SelectContent>
          </Select>

          <p class="text-xs text-muted-foreground">Select "All years" to show in every year.</p>
        </Field>
      </FieldGroup>

      <Collapsible v-model:open="showOverrides">
        <CollapsibleTrigger class="flex items-center gap-1 text-sm text-muted-foreground">
          <ChevronDown
            class="h-4 w-4 transition-transform"
            :class="showOverrides ? 'rotate-180' : ''"
          />
          Customise Plant
        </CollapsibleTrigger>
        <CollapsibleContent>
          <FieldGroup class="mt-3">
            <Field>
              <FieldLabel for="position">Position</FieldLabel>
              <Textarea
                id="position"
                v-model="overrides.position"
                :placeholder="selectedCatalogueEntry?.position ?? ''"
              />
            </Field>
            <Field>
              <FieldLabel for="hardiness">Hardiness</FieldLabel>
              <Textarea
                id="hardiness"
                v-model="overrides.hardiness"
                :placeholder="selectedCatalogueEntry?.hardiness ?? ''"
              />
            </Field>
            <Field>
              <FieldLabel for="spacing">Spacing</FieldLabel>
              <Textarea
                id="spacing"
                v-model="overrides.spacing"
                :placeholder="selectedCatalogueEntry?.spacing ?? ''"
              />
            </Field>
            <Field>
              <FieldLabel for="seed_to_harvest">Seed to harvest</FieldLabel>
              <Textarea
                id="seed_to_harvest"
                v-model="overrides.seed_to_harvest"
                :placeholder="selectedCatalogueEntry?.seed_to_harvest ?? ''"
              />
            </Field>
            <Field>
              <FieldLabel for="sowing_to_transplant">Sowing to transplant</FieldLabel>
              <Textarea
                id="sowing_to_transplant"
                v-model="overrides.sowing_to_transplant"
                :placeholder="selectedCatalogueEntry?.sowing_to_transplant ?? ''"
              />
            </Field>
            <Field>
              <FieldLabel for="harvest">Harvest notes</FieldLabel>
              <Textarea
                id="harvest"
                v-model="overrides.harvest"
                :placeholder="selectedCatalogueEntry?.harvest ?? ''"
              />
            </Field>

            <Field>
              <FieldLabel>Suitability</FieldLabel>
              <CheckboxGroupRoot v-model="overrides.suitability" class="flex flex-wrap gap-3">
                <label
                  v-for="tag in SUITABILITY_OPTIONS"
                  :key="tag"
                  class="flex items-center gap-2 text-sm"
                >
                  <Checkbox :value="tag" />
                  {{ tag.charAt(0).toUpperCase() + tag.slice(1) }}
                </label>
              </CheckboxGroupRoot>
            </Field>

            <!-- Sowing windows -->
            <Field>
              <FieldLabel>Sowing windows</FieldLabel>
              <div v-if="sowingWindows.length" class="flex flex-wrap gap-2">
                <span
                  v-for="(w, i) in sowingWindows"
                  :key="i"
                  class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
                >
                  {{ formatWindow(w) }}
                  <button
                    type="button"
                    class="text-muted-foreground hover:text-foreground"
                    @click="sowingWindows.splice(i, 1)"
                  >
                    <X class="h-3 w-3" />
                  </button>
                </span>
              </div>
              <Popover v-model:open="showSowingPicker">
                <PopoverTrigger as-child>
                  <Button type="button" variant="outline" size="sm" class="w-full">
                    <Plus /> Add sowing window
                  </Button>
                </PopoverTrigger>
                <PopoverContent class="w-auto p-0">
                  <RangeCalendar v-model="stagingSowing" />
                  <div class="p-2">
                    <Button
                      type="button"
                      size="sm"
                      class="w-full"
                      :disabled="!stagingSowing?.start || !stagingSowing?.end"
                      @click="confirmSowingWindow"
                    >
                      Add window
                    </Button>
                  </div>
                </PopoverContent>
              </Popover>
            </Field>

            <!-- Harvest windows -->
            <Field>
              <FieldLabel>Harvest windows</FieldLabel>
              <div v-if="harvestWindows.length" class="flex flex-wrap gap-2">
                <span
                  v-for="(w, i) in harvestWindows"
                  :key="i"
                  class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
                >
                  {{ formatWindow(w) }}
                  <button
                    type="button"
                    class="text-muted-foreground hover:text-foreground"
                    @click="harvestWindows.splice(i, 1)"
                  >
                    <X class="h-3 w-3" />
                  </button>
                </span>
              </div>
              <Popover v-model:open="showHarvestPicker">
                <PopoverTrigger as-child>
                  <Button type="button" variant="outline" size="sm" class="w-full">
                    <Plus /> Add harvest window
                  </Button>
                </PopoverTrigger>
                <PopoverContent class="w-auto p-0">
                  <RangeCalendar v-model="stagingHarvest" />
                  <div class="p-2">
                    <Button
                      type="button"
                      size="sm"
                      class="w-full"
                      :disabled="!stagingHarvest?.start || !stagingHarvest?.end"
                      @click="confirmHarvestWindow"
                    >
                      Add window
                    </Button>
                  </div>
                </PopoverContent>
              </Popover>
            </Field>

            <!-- Transplant windows -->
            <Field>
              <FieldLabel>Transplant windows</FieldLabel>
              <div v-if="transplantWindows.length" class="flex flex-wrap gap-2">
                <span
                  v-for="(w, i) in transplantWindows"
                  :key="i"
                  class="flex items-center gap-1 rounded-md border px-2 py-1 text-sm"
                >
                  {{ formatWindow(w) }}
                  <button
                    type="button"
                    class="text-muted-foreground hover:text-foreground"
                    @click="transplantWindows.splice(i, 1)"
                  >
                    <X class="h-3 w-3" />
                  </button>
                </span>
              </div>
              <Popover v-model:open="showTransplantPicker">
                <PopoverTrigger as-child>
                  <Button type="button" variant="outline" size="sm" class="w-full">
                    <Plus /> Add transplant window
                  </Button>
                </PopoverTrigger>
                <PopoverContent class="w-auto p-0">
                  <RangeCalendar v-model="stagingTransplant" />
                  <div class="p-2">
                    <Button
                      type="button"
                      size="sm"
                      class="w-full"
                      :disabled="!stagingTransplant?.start || !stagingTransplant?.end"
                      @click="confirmTransplantWindow"
                    >
                      Add window
                    </Button>
                  </div>
                </PopoverContent>
              </Popover>
            </Field>
          </FieldGroup>
        </CollapsibleContent>
      </Collapsible>

      <DialogFooter>
        <DialogClose as-child>
          <Button variant="outline">Cancel</Button>
        </DialogClose>
        <Button type="button" :disabled="!canSubmit || loading" class="px-4!" @click="submitPlant">
          <Spinner v-if="loading" class="animate-spin" />
          {{
            loading ? (isEditMode ? 'Saving...' : 'Adding...') : isEditMode ? 'Save' : 'Add Plant'
          }}
        </Button>
      </DialogFooter>
    </DialogScrollContent>
  </Dialog>
</template>
