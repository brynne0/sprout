<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Settings, LogOut } from '@lucide/vue'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'
import { useAuth } from '@/composables/useAuth'

// Signing out fires SIGNED_OUT, which redirects to /login (see main.ts).
const { signOut } = useAuth()
const route = useRoute()
const router = useRouter()

const active = computed(() => route.path === '/settings')
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger
      class="flex flex-col items-center gap-1 py-3 text-xs font-semibold transition-colors hover:text-foreground"
      :class="active ? 'text-primary' : 'text-foreground/60'"
    >
      <div
        class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center outline-none"
        :class="{ 'bg-primary/15': active }"
      >
        <Settings class="size-5" />
      </div>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" side="top" class="mr-2">
      <DropdownMenuItem @click="router.push('/settings')">
        <Settings class="size-4" />
        Settings
      </DropdownMenuItem>
      <DropdownMenuItem @click="signOut()">
        <LogOut class="size-4" />
        Log out
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
