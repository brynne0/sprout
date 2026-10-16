<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppNav from '@/components/layout/AppNav.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import { Toaster } from '@/components/ui/sonner'
import { useTheme } from '@/composables/useTheme'

const { state: theme } = useTheme()
const route = useRoute()
const router = useRouter()
const publicRoutes = ['/login', '/auth/callback']

const routerReady = ref(false)
router.isReady().then(() => {
  routerReady.value = true
})
</script>

<template>
  <Toaster :theme="theme" />
  <div
    :class="
      publicRoutes.includes(route.path)
        ? 'min-w-sm'
        : 'min-w-sm pb-[calc(5rem+env(safe-area-inset-bottom))]'
    "
  >
    <AppNav v-if="routerReady && !publicRoutes.includes(route.path)" />
    <LoadingLeaves v-if="!routerReady" />
    <RouterView v-else v-slot="{ Component }">
      <KeepAlive :exclude="['PlantDetailView', 'PlantFormView']">
        <component :is="Component" />
      </KeepAlive>
    </RouterView>
  </div>
</template>
