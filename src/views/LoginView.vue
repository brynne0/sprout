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
        We've sent a sign-in code to
        <span class="font-semibold text-foreground">{{ email }}</span
        >. Enter it below, or tap the link in the email.
      </p>
      <form class="flex w-full flex-col gap-3" @submit.prevent="submitCode">
        <InputOTP
          v-model="code"
          :maxlength="6"
          :pattern="REGEXP_ONLY_DIGITS"
          :disabled="verifying"
          aria-label="Sign-in code"
          class="justify-center"
          @complete="submitCode"
        >
          <InputOTPGroup>
            <InputOTPSlot v-for="i in 6" :key="i" :index="i - 1" />
          </InputOTPGroup>
        </InputOTP>
        <Button type="submit" class="rounded-xl" :disabled="verifying || code.length < 6">
          <Spinner v-if="verifying" />
          Sign in
        </Button>
      </form>
      <Button variant="link" size="sm" @click="useDifferentEmail">Use a different email</Button>
    </div>

    <form v-else class="flex w-full max-w-2xs flex-col gap-3" @submit.prevent="sendLink">
      <div class="relative">
        <Mail
          class="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground"
        />
        <Input
          v-model="email"
          type="email"
          required
          autocomplete="email"
          placeholder="Email address"
          aria-label="Email address"
          class="pl-9"
        />
      </div>
      <Button type="submit" class="rounded-xl" :disabled="sending">
        <Spinner v-if="sending" />
        Email me a sign-in link
      </Button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Mail, Sprout } from '@lucide/vue'
import { REGEXP_ONLY_DIGITS } from 'vue-input-otp'
import { toast } from 'vue-sonner'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { InputOTP, InputOTPGroup, InputOTPSlot } from '@/components/ui/input-otp'
import { Spinner } from '@/components/ui/spinner'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { signInWithEmail, verifyCode } = useAuth()

const email = ref('')
const sending = ref(false)
const sent = ref(false)
const code = ref('')
const verifying = ref(false)

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

async function submitCode() {
  // Typing the last digit and pressing Enter would otherwise both submit.
  if (verifying.value) return
  verifying.value = true
  try {
    await verifyCode(email.value.trim(), code.value.trim())
    router.replace('/')
  } catch {
    toast.error('That code is invalid or has expired.')
    code.value = ''
  }
  verifying.value = false
}

function useDifferentEmail() {
  sent.value = false
  code.value = ''
}
</script>
