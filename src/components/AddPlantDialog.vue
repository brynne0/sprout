<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { CalendarIcon, ChevronDown, ChevronsUpDown, Check } from 'lucide-vue-next'
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
  seedToHarvest: '',
  sowingToTransplant: '',
  harvest: '',
  // window overrides to be added when month range picker is built
})

const selectedPlantName = computed(
  () =>
    catalogPlants.value.find((p) => p.id === selectedCatalogId.value)?.name ?? 'Select plant...',
)

const canSubmit = computed(() => !!selectedCatalogId.value && !!date.value)

const cleanedOverrides = computed(() => {
  const result = Object.fromEntries(
    Object.entries(overrides.value).filter(([, v]) => v !== '' && v != null),
  )
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
    seedToHarvest: '',
    sowingToTransplant: '',
    harvest: '',
  }
}

async function addPlant() {
  await postApiPlants({
    body: {
      catalogId: selectedCatalogId.value || undefined,
      variety: variety.value || undefined,
      sowDate: date.value?.toString() ?? '',
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

    <DialogScrollContent class="sm:max-w-106.25">
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
            <PopoverContent class="w-[--reka-popover-trigger-width] p-0">
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
                      <Check
                        :class="
                          cn(
                            'mr-2 h-4 w-4',
                            selectedCatalogId === plant.id ? 'opacity-100' : 'opacity-0',
                          )
                        "
                      />
                      {{ plant.name }}
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
              <FieldLabel for="seedToHarvest">Seed to harvest</FieldLabel>
              <Input
                id="seedToHarvest"
                v-model="overrides.seedToHarvest"
                placeholder="e.g. 3 months"
              />
            </Field>
            <Field>
              <FieldLabel for="sowingToTransplant">Sowing to transplant</FieldLabel>
              <Input
                id="sowingToTransplant"
                v-model="overrides.sowingToTransplant"
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
            <!-- Sowing, harvest, and transplant window overrides to be added with month range picker -->
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
