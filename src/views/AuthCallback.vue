<template>
  <div class="flex min-h-screen items-center justify-center">
    <p class="text-base font-medium text-foreground/60">Signing you in…</p>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const route = useRoute()
const router = useRouter()
const { setToken } = useAuth()

onMounted(() => {
  const token = route.query.token as string | undefined
  if (token) {
    setToken(token)
    router.replace('/')
  } else {
    router.replace('/login')
  }
})
</script>
