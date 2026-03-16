<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { CalendarIcon, ChevronDown, ChevronsUpDown, Check, Plus, X } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'
import {
  Dialog,
  DialogClose,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogScrollContent,
} from '@/components/ui/dialog'
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command'
import { RangeCalendar } from '@/components/ui/range-calendar'
import type { DateRange } from 'reka-ui'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import { Field, FieldGroup, FieldLabel } from '@/components/ui/field'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import type { CatalogPlant } from '@/client'
import { postApiPlants, getApiCatalog } from '@/client'
import { client } from '@/client/client.gen'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { cn } from '@/lib/utils'
import { DateFormatter, getLocalTimeZone, today } from '@internationalized/date'
import type { DateValue } from 'reka-ui'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{ 'update:open': [boolean]; plantAdded: [] }>()

const dialogOpen = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
})

const comboboxOpen = ref(false)
const showOverrides = ref(false)

const { token } = useAuth()

client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

const df = new DateFormatter('en-US', { dateStyle: 'long' })
const defaultPlaceholder = today(getLocalTimeZone())

const catalogPlants = ref<CatalogPlant[]>([])
const selectedCatalogId = ref('')
const date = ref<DateValue>()
const notes = ref('')
const variety = ref('')

const overrides = ref({
  description: '',
  position: '',
  hardiness: '',
  spacing: '',
  seed_to_harvest: '',
  sowing_to_transplant: '',
  harvest: '',
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

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function toMonthDay(d: DateValue): string {
  return `${String(d.month).padStart(2, '0')}-${String(d.day).padStart(2, '0')}`
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
  }
}
function confirmHarvestWindow() {
  if (stagingHarvest.value?.start && stagingHarvest.value?.end) {
    harvestWindows.value.push({
      start: toMonthDay(stagingHarvest.value.start),
      end: toMonthDay(stagingHarvest.value.end),
    })
    stagingHarvest.value = undefined
  }
}
function confirmTransplantWindow() {
  if (stagingTransplant.value?.start && stagingTransplant.value?.end) {
    transplantWindows.value.push({
      start: toMonthDay(stagingTransplant.value.start),
      end: toMonthDay(stagingTransplant.value.end),
    })
    stagingTransplant.value = undefined
  }
}

const selectedPlantName = computed(
  () =>
    catalogPlants.value.find((p) => p.id === selectedCatalogId.value)?.name ?? 'Select plant...',
)

const canSubmit = computed(() => !!selectedCatalogId.value && !!date.value)

const cleanedOverrides = computed(() => {
  const result: Record<string, unknown> = Object.fromEntries(
    Object.entries(overrides.value).filter(([, v]) => v !== '' && v != null),
  )
  if (sowingWindows.value.length) result.sowing_windows = sowingWindows.value
  if (harvestWindows.value.length) result.harvest_windows = harvestWindows.value
  if (transplantWindows.value.length) result.transplant_windows = transplantWindows.value
  return Object.keys(result).length > 0 ? result : undefined
})

onMounted(async () => {
  const res = await getApiCatalog()
  catalogPlants.value = res.data ?? []
})

function selectPlant(id: string) {
  selectedCatalogId.value = id
  comboboxOpen.value = false
}

function reset() {
  selectedCatalogId.value = ''
  date.value = undefined
  notes.value = ''
  variety.value = ''
  showOverrides.value = false
  overrides.value = {
    description: '',
    position: '',
    hardiness: '',
    spacing: '',
    seed_to_harvest: '',
    sowing_to_transplant: '',
    harvest: '',
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

async function addPlant() {
  await postApiPlants({
    body: {
      catalog_id: selectedCatalogId.value || undefined,
      variety: variety.value || undefined,
      sow_date: date.value?.toString() ?? '',
      notes: notes.value || undefined,
      overrides: cleanedOverrides.value,
    },
  })

  reset()
  emit('plantAdded')
  emit('update:open', false)
}
</script>

<template>
  <Dialog v-model:open="dialogOpen">
    <DialogTrigger as-child>
      <slot />
    </DialogTrigger>

    <DialogScrollContent>
      <DialogHeader>
        <DialogTitle>Add Plant</DialogTitle>
      </DialogHeader>

      <FieldGroup>
        <Field>
          <FieldLabel>Plant name</FieldLabel>
          <Popover v-model:open="comboboxOpen">
            <PopoverTrigger as-child>
              <Button
                variant="outline"
                role="combobox"
                :aria-expanded="comboboxOpen"
                class="w-full justify-between"
              >
                {{ selectedPlantName }}
                <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
              </Button>
            </PopoverTrigger>
            <PopoverContent class="p-0">
              <Command>
                <CommandInput placeholder="Search plants..." />
                <CommandList>
                  <CommandEmpty>No plants found.</CommandEmpty>
                  <CommandGroup>
                    <CommandItem
                      v-for="plant in catalogPlants"
                      :key="plant.id"
                      :value="plant.name"
                      @select="() => selectPlant(plant.id)"
                    >
                      {{ plant.name }}
                      <Check
                        :class="
                          cn(
                            'ml-auto h-4 w-4',
                            selectedCatalogId === plant.id ? 'opacity-100' : 'opacity-0',
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

        <Field>
          <FieldLabel for="variety">Variety</FieldLabel>
          <Input id="variety" v-model="variety" placeholder="e.g. Cherry, Roma" />
        </Field>

        <Field>
          <FieldLabel>Sow Date</FieldLabel>
          <Popover>
            <PopoverTrigger as-child>
              <Button
                variant="outline"
                :class="
                  cn('w-full justify-start text-left font-normal', !date && 'text-muted-foreground')
                "
              >
                <CalendarIcon class="mr-2 h-4 w-4" />
                {{ date ? df.format(date.toDate(getLocalTimeZone())) : 'Pick a date' }}
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-auto p-0">
              <Calendar
                v-model="date"
                :initial-focus="true"
                :default-placeholder="defaultPlaceholder"
                layout="month-and-year"
              />
            </PopoverContent>
          </Popover>
        </Field>

        <Field>
          <FieldLabel for="notes">Notes</FieldLabel>
          <Input id="notes" v-model="notes" placeholder="Optional" />
        </Field>
      </FieldGroup>

      <Collapsible v-model:open="showOverrides">
        <CollapsibleTrigger class="flex items-center gap-1 text-sm text-muted-foreground">
          <ChevronDown
            class="h-4 w-4 transition-transform"
            :class="showOverrides ? 'rotate-180' : ''"
          />
          Customise details
        </CollapsibleTrigger>
        <CollapsibleContent>
          <FieldGroup class="mt-3">
            <Field>
              <FieldLabel for="description">Description</FieldLabel>
              <Input
                id="description"
                v-model="overrides.description"
                placeholder="Override catalog description"
              />
            </Field>
            <Field>
              <FieldLabel for="position">Position</FieldLabel>
              <Input id="position" v-model="overrides.position" placeholder="e.g. Full sun" />
            </Field>
            <Field>
              <FieldLabel for="hardiness">Hardiness</FieldLabel>
              <Input
                id="hardiness"
                v-model="overrides.hardiness"
                placeholder="e.g. Hardy to -5°C"
              />
            </Field>
            <Field>
              <FieldLabel for="spacing">Spacing</FieldLabel>
              <Input id="spacing" v-model="overrides.spacing" placeholder="e.g. 30cm apart" />
            </Field>
            <Field>
              <FieldLabel for="seed_to_harvest">Seed to harvest</FieldLabel>
              <Input
                id="seed_to_harvest"
                v-model="overrides.seed_to_harvest"
                placeholder="e.g. 3 months"
              />
            </Field>
            <Field>
              <FieldLabel for="sowing_to_transplant">Sowing to transplant</FieldLabel>
              <Input
                id="sowing_to_transplant"
                v-model="overrides.sowing_to_transplant"
                placeholder="e.g. 4-6 weeks"
              />
            </Field>
            <Field>
              <FieldLabel for="harvest">Harvest notes</FieldLabel>
              <Input
                id="harvest"
                v-model="overrides.harvest"
                placeholder="e.g. Pick regularly to encourage pods"
              />
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
        <Button type="button" :disabled="!canSubmit" @click="addPlant">Add Plant</Button>
      </DialogFooter>
    </DialogScrollContent>
  </Dialog>
</template>
