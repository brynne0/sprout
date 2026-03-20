<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import LoadingSprout from '@/components/LoadingSprout.vue'
import { Toaster } from '@/components/ui/sonner'

const route = useRoute()
const router = useRouter()
const publicRoutes = ['/login', '/auth/callback']

const routerReady = ref(false)
router.isReady().then(() => {
  routerReady.value = true
})
</script>

<template>
  <Toaster />
  <LoadingSprout v-if="!routerReady" />
  <div
    v-else
    :class="
      publicRoutes.includes(route.path)
        ? 'min-w-sm'
        : 'min-w-sm pt-[max(2rem,env(safe-area-inset-top))] pb-[calc(5rem+env(safe-area-inset-bottom))]'
    "
  >
    <AppNav v-if="routerReady && !publicRoutes.includes(route.path)" />
    <RouterView />
  </div>
</template>
