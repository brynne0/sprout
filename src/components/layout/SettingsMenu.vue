<script setup lang="ts">
import { Settings, LogOut, Sun, Moon, Monitor } from '@lucide/vue'
import { toast } from 'vue-sonner'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
} from '@/components/ui/dropdown-menu'
import { useAuth } from '@/composables/useAuth'
import { useTheme } from '@/composables/useTheme'
import { ref } from 'vue'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { supabase } from '@/lib/supabase'

// Signing out fires SIGNED_OUT, which redirects to /login (see main.ts).
const { signOut } = useAuth()
const { store: theme } = useTheme()
const showDeleteAccount = ref(false)

async function logout() {
  await signOut()
}

async function deleteAccount() {
  try {
    await supabase.rpc('delete_my_account').throwOnError()
  } catch {
    toast.error('Failed to delete account. Please try again.')
    return
  }
  // The user no longer exists server-side, so only clear the local session.
  await signOut('local')
}
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger
      class="flex flex-col items-center gap-1 py-3 text-xs font-semibold text-foreground/60 transition-colors hover:text-foreground"
    >
      <div class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center outline-none">
        <Settings class="size-5" />
      </div>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" side="top" class="mr-2">
      <DropdownMenuLabel class="text-xs text-muted-foreground">Theme</DropdownMenuLabel>
      <DropdownMenuRadioGroup v-model="theme">
        <DropdownMenuRadioItem value="light">
          <Sun class="size-4" />
          Light
        </DropdownMenuRadioItem>
        <DropdownMenuRadioItem value="dark">
          <Moon class="size-4" />
          Dark
        </DropdownMenuRadioItem>
        <DropdownMenuRadioItem value="auto">
          <Monitor class="size-4" />
          System
        </DropdownMenuRadioItem>
      </DropdownMenuRadioGroup>
      <DropdownMenuSeparator />
      <DropdownMenuItem @click="showDeleteAccount = true"> Delete Account </DropdownMenuItem>
      <DropdownMenuItem @click="logout">
        <LogOut class="size-4" />
        Log out
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>

  <AlertDialog v-model:open="showDeleteAccount">
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Delete account?</AlertDialogTitle>
        <AlertDialogDescription>
          This will permanently delete your account and all your plants. This can't be undone.
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>Cancel</AlertDialogCancel>
        <AlertDialogAction variant="destructive" @click="deleteAccount"> Delete </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
