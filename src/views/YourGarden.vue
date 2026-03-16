<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Plus, Sprout } from 'lucide-vue-next'
import { useAuth } from '@/composables/useAuth'
import GardenList from '@/components/GardenList.vue'
import GardenCalendar from '@/components/GardenCalendar.vue'
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
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
          <GardenList :plants="plants"></GardenList>
        </TabsContent>

        <TabsContent value="gardenCalendar">
          <GardenCalendar :plants="plants"> </GardenCalendar>
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
