<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { getApiCatalogue } from '@/client'
import type { CataloguePlant } from '@/client'
import PlantCalendar from '@/components/PlantCalendar.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import { Input } from '@/components/ui/input'
import { Search } from 'lucide-vue-next'
import { toast } from 'vue-sonner'

const plants = ref<CataloguePlant[]>([])
const loading = ref(true)
const searchQuery = ref('')

const filteredPlants = computed(() => {
  const q = searchQuery.value.toLowerCase().trim()
  if (!q) return plants.value
  return plants.value.filter(
    (p) => p.name.toLowerCase().includes(q) || (p.variety && p.variety.toLowerCase().includes(q)),
  )
})

onMounted(async () => {
  try {
    const res = await getApiCatalogue({ throwOnError: true })
    plants.value = res.data ?? []
  } catch (error) {
    if (error instanceof TypeError) {
      toast.error('Network error', { description: 'Check your connection and try again.' })
    } else {
      toast.error('Failed to load catalogue', { description: 'Please try refreshing.' })
    }
  }
  loading.value = false
})
</script>

<template>
  <header class="mb-4 mx-4">
    <h1 class="text-3xl font-bold tracking-tight text-primary">Catalogue</h1>
  </header>

  <LoadingLeaves v-if="loading" />
  <PlantCalendar v-else :plants="filteredPlants">
    <template #header>
      <div class="relative max-w-xs">
        <Search class="absolute left-2 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input v-model="searchQuery" placeholder="Search plants..." class="pl-8 h-8" />
      </div>
    </template>
  </PlantCalendar>
</template>
