<template>
  <div class="flex h-dvh flex-col items-center justify-center gap-8 px-6 overflow-hidden">
    <div class="flex flex-col items-center gap-2">
      <div class="flex items-center gap-2 text-primary">
        <Sprout class="size-10" />
      </div>
      <h1 class="text-3xl font-bold tracking-tight text-primary">Sprout</h1>
      <p class="text-sm text-foreground/60">Track your garden, season by season.</p>
    </div>

    <div v-if="sent" class="flex w-full max-w-2xs flex-col items-center gap-3 text-center">
      <p class="text-sm text-foreground/60">
        We've sent a sign-in link to
        <span class="font-semibold text-foreground">{{ email }}</span>. Check your inbox.
      </p>
      <Button variant="link" size="sm" @click="sent = false">Use a different email</Button>
    </div>

    <form v-else class="flex w-full max-w-2xs flex-col gap-3" @submit.prevent="sendLink">
      <Input
        v-model="email"
        type="email"
        required
        autocomplete="email"
        placeholder="you@example.com"
        aria-label="Email address"
      />
      <Button type="submit" class="rounded-xl" :disabled="sending">
        <Spinner v-if="sending" />
        Email me a sign-in link
      </Button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Sprout } from 'lucide-vue-next'
import { toast } from 'vue-sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Spinner } from '@/components/ui/spinner'
import { useAuth } from '@/composables/useAuth'

const { signInWithEmail } = useAuth()

const email = ref('')
const sending = ref(false)
const sent = ref(false)

async function sendLink() {
  sending.value = true
  try {
    await signInWithEmail(email.value.trim())
    sent.value = true
  } catch {
    toast.error('Could not send the sign-in link. Please try again.')
  }
  sending.value = false
}
</script>
