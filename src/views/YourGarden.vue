<script setup lang="ts">
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
</script>

<template>
  <main>
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead class="w-25">Plant Name</TableHead>
          <TableHead>Sowing Date</TableHead>
          <TableHead>Transplant Date</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow>
          <TableCell class="font-medium">Tomato</TableCell>
          <TableCell>01.03.26</TableCell>
          <TableCell>04.03.26</TableCell>
        </TableRow>
      </TableBody>
    </Table>
  </main>
</template>
