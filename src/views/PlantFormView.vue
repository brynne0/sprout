<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, ChevronsUpDown, Check, Plus } from '@lucide/vue'
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
import type { DateRange, DateValue } from 'reka-ui'
import { CheckboxGroupRoot } from 'reka-ui'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion'
import { Field, FieldDescription, FieldGroup, FieldLabel } from '@/components/ui/field'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Checkbox } from '@/components/ui/checkbox'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import {
  TagsInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from '@/components/ui/tags-input'
import type { PlantType, CataloguePlant, Window } from '@/types'
import type { Json } from '@/types/database'
import { supabase } from '@/lib/supabase'
import { cn, handleApiError } from '@/lib/utils'
import { getLocalTimeZone, today } from '@internationalized/date'
import { toast } from 'vue-sonner'
import PageHeader from '@/components/layout/PageHeader.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import PlantDatesField from '@/components/PlantDatesField.vue'

// Add a plant (/plants/new) or edit one (/plants/:id/edit).
const route = useRoute()
const router = useRouter()

const plantId = computed(() => route.params.id as string | undefined)
const isEditMode = computed(() => !!plantId.value)

const pageLoading = ref(isEditMode.value)
const saving = ref(false)

const plantTypeComboOpen = ref(false)
const catalogueComboOpen = ref(false)

// Plant type + catalogue entry selection
const plantTypes = ref<PlantType[]>([])
const catalogueEntries = ref<CataloguePlant[]>([])
const selectedPlantTypeId = ref('')
const selectedCatalogueId = ref('')
const customVariety = ref('')
const isCustomVariety = ref(false)

const sowDates = ref<string[]>([])
const transplantDates = ref<string[]>([])
const repotDates = ref<string[]>([])
const harvestDates = ref<string[]>([])

const year = ref<number | null>(today(getLocalTimeZone()).year)

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

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function toMonthDay(d: DateValue): string {
  return `${String(d.month).padStart(2, '0')}-${String(d.day).padStart(2, '0')}`
}

function formatWindow(w: Window): string {
  const [sm = 1, sd = 1] = w.start.split('-').map(Number)
  const [em = 1, ed = 1] = w.end.split('-').map(Number)
  return `${sd} ${MONTHS[sm - 1]} → ${ed} ${MONTHS[em - 1]}`
}

// TagsInput types its values loosely, so narrow back to Window for display
const displayWindow = (v: unknown) => formatWindow(v as Window)

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

// The plant's own windows take precedence over the catalogue's, as on the detail page
// The windows under Growing details (pre-filled from the catalogue) drive the date highlights
const calendarWindows = computed(() => ({
  sow: sowingWindows.value,
  transplant: transplantWindows.value,
  harvest: harvestWindows.value,
}))

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

// Growing details are pre-filled from the catalogue, but only values that differ from it are
// saved as overrides, so later catalogue updates still reach the plant
const TEXT_FIELDS = [
  'position',
  'hardiness',
  'spacing',
  'seed_to_harvest',
  'sowing_to_transplant',
  'harvest',
] as const

function catalogueDefaults(entry: CataloguePlant | undefined) {
  return {
    text: Object.fromEntries(TEXT_FIELDS.map((k) => [k, entry?.[k] ?? ''])) as Record<
      (typeof TEXT_FIELDS)[number],
      string
    >,
    suitability: (entry?.suitability ?? []) as string[],
    sowing: entry?.sowing_windows ?? [],
    transplant: entry?.transplant_windows ?? [],
    harvest: entry?.harvest_windows ?? [],
  }
}

const same = (a: unknown, b: unknown) => JSON.stringify(a) === JSON.stringify(b)
const copyWindows = (ws: Window[]) => ws.map((w) => ({ ...w }))

// Fill fields that are empty or still hold the previous entry's values, so switching variety
// updates the defaults without overwriting anything the user typed
watch(selectedCatalogueEntry, (entry, old) => {
  const prev = catalogueDefaults(old)
  const next = catalogueDefaults(entry)
  for (const k of TEXT_FIELDS) {
    if (overrides.value[k] === '' || overrides.value[k] === prev.text[k]) {
      overrides.value[k] = next.text[k]
    }
  }
  const s = overrides.value.suitability
  if (!s.length || same(s, prev.suitability)) overrides.value.suitability = [...next.suitability]
  if (!sowingWindows.value.length || same(sowingWindows.value, prev.sowing))
    sowingWindows.value = copyWindows(next.sowing)
  if (!transplantWindows.value.length || same(transplantWindows.value, prev.transplant))
    transplantWindows.value = copyWindows(next.transplant)
  if (!harvestWindows.value.length || same(harvestWindows.value, prev.harvest))
    harvestWindows.value = copyWindows(next.harvest)
})

const cleanedOverrides = computed(() => {
  const defaults = catalogueDefaults(selectedCatalogueEntry.value)
  const result: Record<string, unknown> = {}
  if (overrides.value.description) result.description = overrides.value.description
  for (const k of TEXT_FIELDS) {
    const v = overrides.value[k]
    if (v !== '' && v !== defaults.text[k]) result[k] = v
  }
  if (!same(overrides.value.suitability, defaults.suitability))
    result.suitability = overrides.value.suitability
  if (!same(sowingWindows.value, defaults.sowing)) result.sowing_windows = sowingWindows.value
  if (!same(transplantWindows.value, defaults.transplant))
    result.transplant_windows = transplantWindows.value
  if (!same(harvestWindows.value, defaults.harvest)) result.harvest_windows = harvestWindows.value
  return Object.keys(result).length > 0 ? result : undefined
})

async function fetchCatalogueEntries(plantTypeId: string): Promise<CataloguePlant[]> {
  const { data } = await supabase
    .from('catalogue_with_details')
    .select('*')
    .eq('plant_type_id', plantTypeId)
    .order('variety', { nullsFirst: true })
  return (data ?? []) as unknown as CataloguePlant[]
}

// Loads the raw plants row (not the merged view) so the plant's own overrides are kept
async function loadPlant(id: string) {
  try {
    const { data: plant } = await supabase
      .from('plants')
      .select('*')
      .eq('id', id)
      .single()
      .throwOnError()
    selectedPlantTypeId.value = plant.plant_type_id
    catalogueEntries.value = await fetchCatalogueEntries(plant.plant_type_id)
    if (plant.catalogue_id) {
      selectedCatalogueId.value = plant.catalogue_id
    } else if (plant.custom_variety) {
      isCustomVariety.value = true
      const baseEntry = catalogueEntries.value.find((e) => !e.variety) ?? catalogueEntries.value[0]
      selectedCatalogueId.value = baseEntry?.id ?? ''
    }
    customVariety.value = plant.custom_variety ?? ''
    sowDates.value = [...plant.sow_dates]
    transplantDates.value = [...plant.transplant_dates]
    repotDates.value = [...plant.repot_dates]
    harvestDates.value = [...plant.harvest_dates]
    year.value = plant.year

    const o = (plant.overrides ?? {}) as Record<string, unknown>
    const text = (k: string) => (typeof o[k] === 'string' ? (o[k] as string) : '')
    overrides.value = {
      description: text('description'),
      position: text('position'),
      hardiness: text('hardiness'),
      spacing: text('spacing'),
      seed_to_harvest: text('seed_to_harvest'),
      sowing_to_transplant: text('sowing_to_transplant'),
      harvest: text('harvest'),
      suitability: (o.suitability as string[] | undefined) ?? [],
    }
    sowingWindows.value = (o.sowing_windows as Window[] | undefined) ?? []
    harvestWindows.value = (o.harvest_windows as Window[] | undefined) ?? []
    transplantWindows.value = (o.transplant_windows as Window[] | undefined) ?? []
  } catch (error) {
    handleApiError(error, 'Failed to load plant')
  }
  pageLoading.value = false
}

onMounted(async () => {
  const { data } = await supabase
    .from('plant_types')
    .select('id, name, category_id, icon')
    .order('name')
  plantTypes.value = (data ?? []) as unknown as PlantType[]
  if (plantId.value) await loadPlant(plantId.value)
})

// Fetch catalogue entries when the plant type changes (the type is fixed when editing)
watch(selectedPlantTypeId, async (id) => {
  if (isEditMode.value) return
  selectedCatalogueId.value = ''
  customVariety.value = ''
  isCustomVariety.value = false
  catalogueEntries.value = []
  if (id) {
    catalogueEntries.value = await fetchCatalogueEntries(id)
    // Auto-select if there's only one entry with no variety
    const single = catalogueEntries.value[0]
    if (catalogueEntries.value.length === 1 && single && !single.variety) {
      selectedCatalogueId.value = single.id
    }
  }
})

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
  const baseEntry = catalogueEntries.value.find((e) => !e.variety) ?? catalogueEntries.value[0]
  selectedCatalogueId.value = baseEntry?.id ?? ''
  catalogueComboOpen.value = false
}

// Back to wherever the user came from, or a sensible page if they landed here directly
function leave(fallback: string) {
  if (window.history.state?.back) router.back()
  else router.replace(fallback)
}

async function submitPlant() {
  saving.value = true
  // Explicit nulls so that clearing a field in edit mode actually clears it
  const body = {
    plant_type_id: selectedPlantTypeId.value,
    catalogue_id: isCustomVariety.value ? null : selectedCatalogueId.value || null,
    custom_variety: customVariety.value || null,
    sow_dates: sowDates.value,
    transplant_dates: transplantDates.value,
    repot_dates: repotDates.value,
    harvest_dates: harvestDates.value,
    year: year.value,
    overrides: (cleanedOverrides.value ?? null) as Json,
  }
  try {
    if (plantId.value) {
      await supabase.from('plants').update(body).eq('id', plantId.value).throwOnError()
      toast.success('Plant saved')
      leave(`/plants/${plantId.value}`)
    } else {
      await supabase.from('plants').insert(body).throwOnError()
      toast.success(`${selectedPlantTypeName.value} added to your garden`)
      leave('/')
    }
  } catch (error) {
    if (error instanceof TypeError) {
      toast.error('Network error', { description: 'Check your connection and try again.' })
    } else {
      toast.error(isEditMode.value ? 'Failed to save plant.' : 'Failed to add plant.')
    }
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <main>
    <PageHeader class="grid grid-cols-[2rem_1fr_2rem] items-center gap-3">
      <Button
        type="button"
        variant="ghost"
        size="icon-sm"
        aria-label="Back"
        @click="leave(plantId ? `/plants/${plantId}` : '/')"
      >
        <ArrowLeft class="size-4.5" />
      </Button>
      <h1 class="text-3xl font-bold tracking-tight text-primary text-center">
        {{ isEditMode ? 'Edit plant' : 'Add plant' }}
      </h1>
      <span aria-hidden="true" />
    </PageHeader>

    <LoadingLeaves v-if="pageLoading" />

    <form v-else class="mx-4 sm:mx-auto flex flex-col gap-6 max-w-xl" @submit.prevent="submitPlant">
      <section>
        <h2 class="text-[13px] font-semibold mb-2 px-0.5">Plant</h2>
        <Card>
          <CardContent>
            <FieldGroup>
              <Field>
                <FieldLabel>Plant type<span>*</span></FieldLabel>
                <Popover v-model:open="plantTypeComboOpen">
                  <PopoverTrigger as-child>
                    <Button
                      type="button"
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

              <!-- Variety (shown when the plant type has named varieties) -->
              <Field v-if="selectedPlantTypeId && hasVarieties">
                <FieldLabel>Variety<span>*</span></FieldLabel>
                <Popover v-model:open="catalogueComboOpen">
                  <PopoverTrigger as-child>
                    <Button
                      type="button"
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
                                  !isCustomVariety && selectedCatalogueId === entry.id
                                    ? 'opacity-100'
                                    : 'opacity-0',
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
                <p class="text-xs text-muted-foreground">
                  Select "All years" to show in every year.
                </p>
              </Field>
            </FieldGroup>
          </CardContent>
        </Card>
      </section>

      <section>
        <h2 class="text-[13px] font-semibold mb-2 px-0.5">Tasks</h2>
        <Card>
          <CardContent>
            <PlantDatesField
              v-model:sow="sowDates"
              v-model:repot="repotDates"
              v-model:transplant="transplantDates"
              v-model:harvest="harvestDates"
              :windows="calendarWindows"
              :year="year"
            />
          </CardContent>
        </Card>
      </section>

      <section>
        <Accordion type="single" collapsible>
          <AccordionItem value="growing-details">
            <AccordionTrigger class="gap-1 px-0.5 text-[13px] font-semibold">
              <span>
                Growing details
                <span class="font-normal text-muted-foreground">· optional</span>
              </span>
            </AccordionTrigger>
            <AccordionContent>
              <Card class="mt-2">
                <CardContent>
                  <FieldGroup>
                    <FieldDescription v-if="selectedCatalogueEntry">
                      Pre-filled from the catalogue. Changes here only apply to your plant, not the
                      catalogue entry.
                    </FieldDescription>
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
                      <CheckboxGroupRoot
                        v-model="overrides.suitability"
                        class="flex flex-wrap gap-3"
                      >
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
                      <TagsInput
                        v-if="sowingWindows.length"
                        v-model="sowingWindows"
                        :display-value="displayWindow"
                      >
                        <TagsInputItem v-for="(w, i) in sowingWindows" :key="i" :value="w">
                          <TagsInputItemText />
                          <TagsInputItemDelete tabindex="0" />
                        </TagsInputItem>
                      </TagsInput>
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

                    <!-- Transplant windows -->
                    <Field>
                      <FieldLabel>Transplant windows</FieldLabel>
                      <TagsInput
                        v-if="transplantWindows.length"
                        v-model="transplantWindows"
                        :display-value="displayWindow"
                      >
                        <TagsInputItem v-for="(w, i) in transplantWindows" :key="i" :value="w">
                          <TagsInputItemText />
                          <TagsInputItemDelete tabindex="0" />
                        </TagsInputItem>
                      </TagsInput>
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

                    <!-- Harvest windows -->
                    <Field>
                      <FieldLabel>Harvest windows</FieldLabel>
                      <TagsInput
                        v-if="harvestWindows.length"
                        v-model="harvestWindows"
                        :display-value="displayWindow"
                      >
                        <TagsInputItem v-for="(w, i) in harvestWindows" :key="i" :value="w">
                          <TagsInputItemText />
                          <TagsInputItemDelete tabindex="0" />
                        </TagsInputItem>
                      </TagsInput>
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
                  </FieldGroup>
                </CardContent>
              </Card>
            </AccordionContent>
          </AccordionItem>
        </Accordion>
      </section>

      <div class="flex justify-end gap-2">
        <Button
          type="button"
          variant="outline"
          @click="leave(plantId ? `/plants/${plantId}` : '/')"
        >
          Cancel
        </Button>
        <Button type="submit" :disabled="!canSubmit || saving" class="px-4!">
          <Spinner v-if="saving" />
          {{ saving ? 'Saving...' : isEditMode ? 'Save' : 'Add plant' }}
        </Button>
      </div>
    </form>
  </main>
</template>
