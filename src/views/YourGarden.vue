<script setup lang="ts">
import { ref, onMounted } from 'vue'
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
  ComboboxEmpty,
  ComboboxInput,
  ComboboxItem,
  ComboboxList,
} from '@/components/ui/combobox'
import { Button } from '@/components/ui/button'

interface Plant {
  id: string
  name: string
  variety: string | null
  sowDate: string
  notes: string | null
}

interface CatalogPlant {
  id: string
  name: string
  variety: string | null
}

const { token } = useAuth()
const plants = ref<Plant[]>([])
const catalogPlants = ref<CatalogPlant[]>([])
const selectedCatalogId = ref<string>('')

onMounted(async () => {
  const [plantsRes, catalogRes] = await Promise.all([
    fetch('http://localhost:8080/api/plants', {
      headers: { Authorization: `Bearer ${token.value}` },
    }),
    fetch('http://localhost:8080/api/catalog', {
      headers: { Authorization: `Bearer ${token.value}` },
    }),
  ])
  plants.value = await plantsRes.json()
  catalogPlants.value = await catalogRes.json()
})
</script>

<template>
  <main>
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Your Garden</h1>
      <Dialog>
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
            <Combobox v-model="selectedCatalogId" :items="catalogPlants.map(p => p.name)">
              <ComboboxInput placeholder="Search plants..." />
              <ComboboxList>
                <ComboboxEmpty>No plants found.</ComboboxEmpty>
                <ComboboxItem v-for="plant in catalogPlants" :key="plant.id" :value="plant.id">
                  {{ plant.name }}{{ plant.variety ? ` — ${plant.variety}` : '' }}
                </ComboboxItem>
              </ComboboxList>
            </Combobox>

            <DialogFooter>
              <DialogClose as-child>
                <Button variant="outline"> Cancel </Button>
              </DialogClose>
              <Button type="submit"> Add Plant </Button>
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
