<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Plus } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
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
import type { Plant, CatalogPlant } from '@/client'
import { getApiPlants, postApiPlants, getApiCatalog } from '@/client'
import { client } from '@/client/client.gen'

const { token } = useAuth()

client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

const plants = ref<Plant[]>([])
const catalogPlants = ref<CatalogPlant[]>([])
const selectedCatalogId = ref<string>('')
const searchTerm = ref('')
const sowDate = ref('')
const notes = ref('')
const dialogOpen = ref(false)

const filteredCatalogPlants = computed(() =>
  catalogPlants.value.filter((p) => p.name.toLowerCase().includes(searchTerm.value.toLowerCase())),
)

onMounted(async () => {
  const [plantsRes, catalogRes] = await Promise.all([getApiPlants(), getApiCatalog()])
  plants.value = plantsRes.data ?? []
  catalogPlants.value = catalogRes.data ?? []
})

async function addPlant() {
  await postApiPlants({
    body: {
      catalogId: selectedCatalogId.value,
      sowDate: sowDate.value,
      notes: notes.value || undefined,
    },
  })

  const res = await getApiPlants()
  plants.value = res.data ?? []

  selectedCatalogId.value = ''
  sowDate.value = ''
  notes.value = ''
  dialogOpen.value = false
}
</script>

<template>
  <main>
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Your Garden</h1>
      <Dialog v-model:open="dialogOpen">
        <form>
          <DialogTrigger as-child>
            <button
              class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
            >
              <Plus :size="18" />
            </button>
          </DialogTrigger>
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

            <input type="date" v-model="sowDate" />
            <textarea v-model="notes" placeholder="Notes (optional)" />

            <DialogFooter>
              <DialogClose as-child>
                <Button variant="outline"> Cancel </Button>
              </DialogClose>
              <Button type="button" @click="addPlant">Add Plant</Button>
            </DialogFooter>
          </DialogContent>
        </form>
      </Dialog>
    </div>
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead class="w-25">Plant Name</TableHead>
          <TableHead>Variety</TableHead>
          <TableHead>Sowing Date</TableHead>
          <TableHead>Notes</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="plant in plants" :key="plant.id">
          <TableCell class="font-medium">{{ plant.name }}</TableCell>
          <TableCell>{{ plant.variety ?? '—' }}</TableCell>
          <TableCell>{{ plant.sowDate }}</TableCell>
          <TableCell>{{ plant.notes ?? '—' }}</TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </main>
</template>
