<script setup lang="ts">
import { Settings, LogOut } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'
import { useAuth } from '@/composables/useAuth'

const router = useRouter()
const { clearToken } = useAuth()

function logout() {
  clearToken()
  router.push('/login')
}
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger
      class="flex flex-col items-center gap-1 py-3 px-4 text-xs font-semibold text-foreground/60 transition-colors hover:text-foreground"
    >
      <div class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center">
        <Settings class="size-5" />
      </div>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" side="top" class="mr-2">
      <DropdownMenuItem @click="logout">
        <LogOut class="size-4" />
        Log out
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
