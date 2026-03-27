<script setup lang="ts">
import { Settings, LogOut, UserRoundMinus } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from '@/components/ui/dropdown-menu'
import { useAuth } from '@/composables/useAuth'
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
import { deleteAuthUser } from '@/client'

const router = useRouter()
const { clearToken } = useAuth()
const showDeleteAccount = ref(false)

function logout() {
  clearToken()
  router.push('/login')
}

async function deleteAccount() {
  await deleteAuthUser()
  clearToken()
  router.push('/login')
}
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger
      class="flex flex-col items-center gap-1 py-3 text-xs font-semibold text-foreground/60 transition-colors hover:text-foreground"
    >
      <div class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center">
        <Settings class="size-5" />
      </div>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" side="top" class="mr-2">
      <DropdownMenuItem @click="showDeleteAccount = true">
        <UserRoundMinus class="size-4" />
        Delete Account
      </DropdownMenuItem>
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
