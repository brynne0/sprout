<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getApiCatalogue } from '@/client'
import type { CataloguePlant } from '@/client'
import PlantCalendar from '@/components/PlantCalendar.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import { toast } from 'vue-sonner'

const plants = ref<CataloguePlant[]>([])
const loading = ref(true)

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
  <header class="mb-4 px-8">
    <h1 class="text-3xl font-bold tracking-tight text-primary">Catalogue</h1>
  </header>

  <LoadingLeaves v-if="loading" />
  <PlantCalendar v-else :plants="plants" />
</template>
