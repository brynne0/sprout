<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { CalendarIcon } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Combobox,
  ComboboxAnchor,
  ComboboxEmpty,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from '@/components/ui/combobox'
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

const { token } = useAuth()

client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

const df = new DateFormatter('en-US', { dateStyle: 'long' })
const defaultPlaceholder = today(getLocalTimeZone())

const catalogPlants = ref<CatalogPlant[]>([])
const selectedCatalogId = ref('')
const searchTerm = ref('')
const date = ref<DateValue>()
const notes = ref('')
const variety = ref('')
const sowingWindowsOverride = ref<{ start: string; end: string }[] | undefined>(undefined)
const harvestWindowsOverride = ref<{ start: string; end: string }[] | undefined>(undefined)
const transplantWindowsOverride = ref<{ start: string; end: string }[] | undefined>(undefined)

const canSubmit = computed(() => !!selectedCatalogId.value && !!date.value)

const filteredCatalogPlants = computed(() =>
  catalogPlants.value.filter((p) =>
    p.name.toLowerCase().includes(searchTerm.value.toLowerCase()),
  ),
)

onMounted(async () => {
  const res = await getApiCatalog()
  catalogPlants.value = res.data ?? []
})

function reset() {
  selectedCatalogId.value = ''
  searchTerm.value = ''
  date.value = undefined
  notes.value = ''
  variety.value = ''
  sowingWindowsOverride.value = undefined
  harvestWindowsOverride.value = undefined
  transplantWindowsOverride.value = undefined
}

async function addPlant() {
  await postApiPlants({
    body: {
      catalogId: selectedCatalogId.value || undefined,
      variety: variety.value || undefined,
      sowDate: date.value?.toString() ?? '',
      notes: notes.value || undefined,
      sowingWindowsOverride: sowingWindowsOverride.value,
      harvestWindowsOverride: harvestWindowsOverride.value,
      transplantWindowsOverride: transplantWindowsOverride.value,
    },
  })

  reset()
  emit('plantAdded')
  emit('update:open', false)
}
</script>

<template>
  <Dialog v-model:open="dialogOpen">
    <slot name="trigger">
      <DialogTrigger as-child>
        <slot />
      </DialogTrigger>
    </slot>
    <DialogContent class="sm:max-w-106.25">
      <DialogHeader>
        <DialogTitle>Add Plant</DialogTitle>
      </DialogHeader>

      <Combobox v-model="selectedCatalogId" open-on-focus ignore-filter>
        <ComboboxAnchor class="w-full">
          <ComboboxInput
            placeholder="Search plants..."
            :display-value="(id: string) => catalogPlants.find((p) => p.id === id)?.name ?? ''"
            @input="searchTerm = ($event.target as HTMLInputElement).value"
          />
        </ComboboxAnchor>
        <ComboboxList class="w-(--reka-combobox-trigger-width)">
          <ComboboxEmpty>No plants found.</ComboboxEmpty>
          <ComboboxItem
            v-for="plant in filteredCatalogPlants"
            :key="plant.id"
            :value="plant.id"
          >
            {{ plant.name }}
          </ComboboxItem>
        </ComboboxList>
      </Combobox>

      <div class="flex flex-col gap-1.5">
        <label class="text-sm font-medium">Sow Date</label>
        <Popover>
          <PopoverTrigger as-child>
            <Button
              variant="outline"
              :class="cn('w-full justify-start text-left font-normal', !date && 'text-muted-foreground')"
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
      </div>

      <Input v-model="notes" placeholder="Notes (optional)" />

      <DialogFooter>
        <DialogClose as-child>
          <Button variant="outline">Cancel</Button>
        </DialogClose>
        <Button type="button" :disabled="!canSubmit" @click="addPlant">Add Plant</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
