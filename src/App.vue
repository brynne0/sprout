<script setup lang="ts">
import { useRoute } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'

const route = useRoute()
const publicRoutes = ['/login', '/auth/callback']
</script>

<template>
  <div
    :class="
      publicRoutes.includes(route.path)
        ? 'min-w-sm'
        : 'min-w-sm pt-[max(2rem,env(safe-area-inset-top))] pb-[calc(5rem+env(safe-area-inset-bottom))]'
    "
  >
    <AppNav v-if="!publicRoutes.includes(route.path)" />
    <RouterView />
  </div>
</template>
