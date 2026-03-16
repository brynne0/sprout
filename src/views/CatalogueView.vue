<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getApiCatalogue } from '@/client'
import type { CataloguePlant } from '@/client'
import PlantCalendar from '@/components/PlantCalendar.vue'

const plants = ref<CataloguePlant[]>([])
const loading = ref(true)

onMounted(async () => {
  const res = await getApiCatalogue()
  plants.value = res.data ?? []
  loading.value = false
})
</script>

<template>
  <header class="mb-4 px-8">
    <h1 class="text-3xl font-bold tracking-tight text-primary">Catalogue</h1>
  </header>

  <PlantCalendar v-if="!loading" :plants="plants" />
</template>
