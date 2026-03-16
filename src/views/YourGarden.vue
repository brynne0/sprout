<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Plus, Sprout } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'
import PlantCalendar from '@/components/PlantCalendar.vue'
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import type { Plant } from '@/client'
import { getApiPlants } from '@/client'
import { client } from '@/client/client.gen'
import AddPlantDialog from '@/components/AddPlantDialog.vue'

const { token } = useAuth()

client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

const plants = ref<Plant[]>([])
const dialogOpen = ref(false)

onMounted(async () => {
  const res = await getApiPlants()
  plants.value = res.data ?? []
})

async function onPlantAdded() {
  const res = await getApiPlants()
  plants.value = res.data ?? []
}

function formatDate(dateStr: string | null | undefined) {
  if (!dateStr) return '—'
  const d = new Date(String(dateStr).slice(0, 10) + 'T00:00:00')
  return isNaN(d.getTime())
    ? dateStr
    : d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}
</script>

<template>
  <main>
    <header class="flex items-center justify-between mb-4 px-8">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Your Garden</h1>
      <AddPlantDialog
        v-if="plants.length > 0"
        v-model:open="dialogOpen"
        @plant-added="onPlantAdded"
      >
        <button
          class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
        >
          <Plus :size="18" />
        </button>
      </AddPlantDialog>
    </header>

    <div v-if="plants.length > 0">
      <Tabs default-value="gardenList">
        <TabsList class="mx-8">
          <TabsTrigger value="gardenList"> Your Plants </TabsTrigger>
          <TabsTrigger value="gardenCalendar"> Calendar </TabsTrigger>
        </TabsList>

        <TabsContent value="gardenList">
          <Table v-if="plants.length > 0">
            <TableHeader>
              <TableRow>
                <TableHead class="w-25">Plant Name</TableHead>
                <!-- <TableHead>Variety</TableHead> -->
                <TableHead>Sowing Date</TableHead>
                <TableHead>Notes</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="plant in plants" :key="plant.id">
                <TableCell class="font-medium">{{ plant.name }}</TableCell>
                <!-- <TableCell>{{ plant.variety ?? '—' }}</TableCell> -->
                <TableCell>{{ formatDate(plant.sowDate) }}</TableCell>
                <TableCell>{{ plant.notes ?? '—' }}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </TabsContent>

        <TabsContent value="gardenCalendar">
          <PlantCalendar :plants="plants" :show-sow-dot="true" />
        </TabsContent>
      </Tabs>
    </div>

    <div v-else class="flex items-center justify-center min-h-[70vh]">
      <Empty>
        <EmptyHeader>
          <EmptyMedia>
            <Sprout />
          </EmptyMedia>
          <EmptyTitle>No Plants Yet</EmptyTitle>
          <EmptyDescription>
            You haven't added any plants yet. Get started by adding your first plant.
          </EmptyDescription>
        </EmptyHeader>
        <EmptyContent>
          <AddPlantDialog v-model:open="dialogOpen" @plant-added="onPlantAdded">
            <Button>Add Plant</Button>
          </AddPlantDialog>
        </EmptyContent>
      </Empty>
    </div>
  </main>
</template>
