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

interface Plant {
  id: string
  name: string
  variety: string | null
  sowDate: string
  notes: string | null
}

const { token } = useAuth()
const plants = ref<Plant[]>([])

onMounted(async () => {
  const res = await fetch('http://localhost:8080/api/plants', {
    headers: { Authorization: `Bearer ${token.value}` },
  })
  plants.value = await res.json()
})
</script>

<template>
  <main>
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Your Garden</h1>
      <button
        class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
      >
        <Plus :size="18" />
      </button>
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
