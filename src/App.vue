<script setup lang="ts">
import AppNav from '@/components/layout/AppNav.vue'
</script>

<template>
  <div class="p-6 pb-[calc(5rem+env(safe-area-inset-bottom))]">
    <AppNav />
    <RouterView />
  </div>
</template>

<style scoped></style>