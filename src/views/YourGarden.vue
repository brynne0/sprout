<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Sprout, CalendarDays, ChevronDown } from 'lucide-vue-next'
import PlantCalendar from '@/components/PlantCalendar.vue'
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
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import type { Plant } from '@/client'
import { getApiPlants } from '@/client'
import PlantDialogue from '@/components/PlantDialogue.vue'
import PlantActions from '@/components/PlantActions.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import PageHeader from '@/components/layout/PageHeader.vue'
import { handleApiError } from '@/lib/utils'
const router = useRouter()
const plants = ref<Plant[]>([])
const dialogOpen = ref(false)
const loading = ref(true)
import { formatDate } from '@/lib/utils'

const groupedPlants = computed(() => {
  const groups = new Map<string, Plant[]>()
  for (const plant of plants.value) {
    const cat = plant.category_name ?? 'Uncategorised'
    if (!groups.has(cat)) groups.set(cat, [])
    groups.get(cat)!.push(plant)
  }
  for (const groupPlants of groups.values()) {
    groupPlants.sort((a, b) => a.name.localeCompare(b.name))
  }
  return Array.from(groups, ([label, plants]) => ({ label, plants })).sort((a, b) =>
    a.label.localeCompare(b.label),
  )
})

async function fetchPlants() {
  try {
    const res = await getApiPlants({ throwOnError: true })
    plants.value = res.data ?? []
  } catch (error) {
    handleApiError(error, 'Failed to load plants')
  }
}

onMounted(async () => {
  await fetchPlants()
  loading.value = false
})

async function onPlantAdded() {
  await fetchPlants()
}
</script>

<template>
  <main>
    <PageHeader class="flex items-center justify-between">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Your Garden</h1>
      <PlantDialogue
        v-if="!loading && plants.length > 0"
        v-model:open="dialogOpen"
        @plant-added="onPlantAdded"
      >
        <button
          class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
        >
          <Plus :size="18" />
        </button>
      </PlantDialogue>
    </PageHeader>

    <LoadingLeaves v-if="loading" />

    <div v-else-if="!loading && plants.length > 0">
      <Tabs default-value="gardenList">
        <TabsList class="mx-4">
          <TabsTrigger value="gardenList"> Plants </TabsTrigger>
          <TabsTrigger value="gardenCalendar"> Calendar </TabsTrigger>
        </TabsList>

        <TabsContent value="gardenList" class="px-4">
          <template v-for="group in groupedPlants" :key="group.label">
            <h3
              v-if="groupedPlants.length > 1"
              class="text-sm font-medium text-muted-foreground mt-4 mb-2 first:mt-0"
            >
              {{ group.label }}
            </h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
              <Collapsible v-for="plant in group.plants" :key="plant.id" class="rounded-xl border">
                <div class="flex items-center gap-4 py-2 px-4">
                  <!-- <img
                  v-if="plant.icon"
                  :src="`/icons/${plant.icon}`"
                  :alt="plant.name"
                  class="w-12 h-12 rounded-lg object-cover shrink-0 brightness-90"
                />
                <div v-else class="w-12 h-12 rounded-lg flex items-center justify-center shrink-0">
                  <Sprout class="w-8 h-8 text-primary" />
                </div> -->
                  <div class="min-w-0 flex-1">
                    <h3
                      class="font-medium truncate cursor-pointer hover:text-primary transition-colors"
                      @click="router.push(`/plants/${plant.id}`)"
                    >
                      {{ plant.name }}
                      <span v-if="plant.variety" class="font-normal text-muted-foreground">
                        · {{ plant.variety }}
                      </span>
                    </h3>
                  </div>
                  <div class="flex items-center gap-1 shrink-0">
                    <CollapsibleTrigger
                      v-if="
                        (plant.sow_dates ?? []).length ||
                        (plant.transplant_dates ?? []).length ||
                        plant.notes
                      "
                      class="p-1 rounded-md hover:bg-muted transition-colors"
                    >
                      <ChevronDown
                        class="w-4 h-4 text-muted-foreground transition-transform duration-200 in-data-[state=open]:rotate-180"
                      />
                    </CollapsibleTrigger>
                    <PlantActions
                      :plant="plant"
                      @updated="fetchPlants"
                      @archived="plants = plants.filter((p) => p.id !== $event)"
                      @deleted="fetchPlants"
                    />
                  </div>
                </div>
                <CollapsibleContent>
                  <div class="px-4 pb-3 pt-0 text-sm text-muted-foreground flex flex-col gap-1">
                    <div v-if="(plant.sow_dates ?? []).length" class="flex items-center gap-2">
                      <CalendarDays class="w-3.5 h-3.5" />
                      <span>Sow: {{ plant.sow_dates!.map(formatDate).join(', ') }}</span>
                    </div>
                    <div
                      v-if="(plant.transplant_dates ?? []).length"
                      class="flex items-center gap-2"
                    >
                      <CalendarDays class="w-3.5 h-3.5" />
                      <span
                        >Transplant: {{ plant.transplant_dates!.map(formatDate).join(', ') }}</span
                      >
                    </div>
                    <p v-if="plant.notes">{{ plant.notes }}</p>
                  </div>
                </CollapsibleContent>
              </Collapsible>
            </div>
          </template>
        </TabsContent>

        <TabsContent value="gardenCalendar">
          <PlantCalendar
            :plants="plants"
            :show-dots="true"
            :show-year-nav="true"
            :clickable="true"
            @plant-click="(p) => router.push(`/plants/${p.id}`)"
          />
        </TabsContent>
      </Tabs>
    </div>

    <div v-else-if="!loading" class="flex items-center justify-center min-h-[70vh]">
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
          <PlantDialogue v-model:open="dialogOpen" @plant-added="onPlantAdded">
            <Button>Add Plant</Button>
          </PlantDialogue>
        </EmptyContent>
      </Empty>
    </div>
  </main>
</template>
