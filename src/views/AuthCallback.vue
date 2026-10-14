<template>
  <div class="flex min-h-screen items-center justify-center">
    <p class="text-base font-medium text-foreground/60">Signing you in…</p>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from 'vue-sonner'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { isAuthenticated } = useAuth()

// supabase-js reads the session from the magic-link URL itself; the router
// guard has already waited for that by the time this mounts.
onMounted(() => {
  if (isAuthenticated.value) {
    router.replace('/')
  } else {
    toast.error('That sign-in link is invalid or has expired.')
    router.replace('/login')
  }
})
</script>
