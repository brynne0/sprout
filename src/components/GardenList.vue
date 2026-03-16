<script setup lang="ts">
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import type { Plant } from '@/client'

defineProps<{ plants: Plant[] }>()

function formatDate(dateStr: string | null | undefined) {
  if (!dateStr) return '—'
  const d = new Date(String(dateStr).slice(0, 10) + 'T00:00:00')
  return isNaN(d.getTime())
    ? dateStr
    : d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}
</script>

<template>
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
</template>
