<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getApiCatalog } from '@/client'
import type { CatalogPlant } from '@/client'
import PlantCalendar from '@/components/PlantCalendar.vue'

const plants = ref<CatalogPlant[]>([])

onMounted(async () => {
  const res = await getApiCatalog()
  plants.value = res.data ?? []
})
</script>

<template>
  <header class="mb-4 px-8">
    <h1 class="text-3xl font-bold tracking-tight text-primary">Catalog</h1>
  </header>

  <PlantCalendar :plants="plants" />
</template>
