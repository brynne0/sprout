<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/lib/supabase'
import type { CataloguePlant, PlantKind } from '@/types'
import PlantCalendar from '@/components/PlantCalendar.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import {
  InputGroup,
  InputGroupAddon,
  InputGroupButton,
  InputGroupInput,
} from '@/components/ui/input-group'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
import { Search, X } from '@lucide/vue'
import { handleApiError } from '@/lib/utils'
import PageHeader from '@/components/layout/PageHeader.vue'

const router = useRouter()

const plants = ref<CataloguePlant[]>([])
const loading = ref(true)
const searchQuery = ref('')
const selectedKind = ref<PlantKind | 'all'>('all')

const kindFilters: { kind: PlantKind | 'all'; label: string }[] = [
  { kind: 'all', label: 'All' },
  { kind: 'vegetable', label: 'Veg' },
  { kind: 'herb', label: 'Herbs' },
  { kind: 'fruit', label: 'Fruit' },
  { kind: 'flower', label: 'Flowers' },
]

const filteredPlants = computed(() => {
  const q = searchQuery.value.toLowerCase().trim()
  return plants.value.filter(
    (p) =>
      (selectedKind.value === 'all' || p.kind === selectedKind.value) &&
      (!q ||
        p.name.toLowerCase().includes(q) ||
        (p.variety && p.variety.toLowerCase().includes(q))),
  )
})

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('catalogue_with_details')
      .select('*')
      .order('name')
      .order('variety', { nullsFirst: true })
      .throwOnError()
    plants.value = data as unknown as CataloguePlant[]
  } catch (error) {
    handleApiError(error, 'Failed to load catalogue')
  }
  loading.value = false
})
</script>

<template>
  <PageHeader>
    <h1 class="text-3xl font-bold tracking-tight text-primary">Catalogue</h1>
  </PageHeader>

  <LoadingLeaves v-if="loading" />
  <PlantCalendar
    v-else
    :plants="filteredPlants"
    :group-by-name="true"
    :clickable="true"
    @plant-click="(p) => router.push(`/catalogue/${p.id}`)"
  >
    <template #header>
      <InputGroup class="max-w-sm h-8">
        <InputGroupInput v-model="searchQuery" placeholder="Search plants..." />
        <InputGroupAddon>
          <Search />
        </InputGroupAddon>
        <InputGroupAddon v-if="searchQuery" align="inline-end">
          <InputGroupButton size="icon-xs" aria-label="Clear search" @click="searchQuery = ''">
            <X />
          </InputGroupButton>
        </InputGroupAddon>
      </InputGroup>
      <!-- Clicking the active item emits an empty value; ignore it so one is always selected -->
      <ToggleGroup
        type="single"
        variant="outline"
        size="sm"
        class="mt-3"
        :model-value="selectedKind"
        @update:model-value="(v) => v && (selectedKind = v as PlantKind | 'all')"
      >
        <ToggleGroupItem v-for="f in kindFilters" :key="f.kind" :value="f.kind">
          {{ f.label }}
        </ToggleGroupItem>
      </ToggleGroup>
    </template>
  </PlantCalendar>
</template>
