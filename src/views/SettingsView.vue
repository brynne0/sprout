<script setup lang="ts">
import { computed, ref } from 'vue'
import { Sun, Moon, Monitor } from '@lucide/vue'
import { toast } from 'vue-sonner'
import { useAuth } from '@/composables/useAuth'
import { useTheme } from '@/composables/useTheme'
import { supabase } from '@/lib/supabase'
import PageHeader from '@/components/layout/PageHeader.vue'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import {
  Item,
  ItemActions,
  ItemContent,
  ItemDescription,
  ItemGroup,
  ItemSeparator,
  ItemTitle,
} from '@/components/ui/item'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'
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

// Signing out fires SIGNED_OUT, which redirects to /login (see main.ts).
const { session, signOut } = useAuth()
const { store: theme } = useTheme()
const showDeleteAccount = ref(false)

const email = computed(() => session.value?.user.email)

const themes = [
  { value: 'light', label: 'Light', icon: Sun },
  { value: 'dark', label: 'Dark', icon: Moon },
  { value: 'auto', label: 'System', icon: Monitor },
] as const

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
  <main>
    <PageHeader>
      <h1 class="text-3xl font-bold tracking-tight text-primary text-center">Settings</h1>
    </PageHeader>

    <div class="mx-4 sm:mx-auto flex flex-col gap-6 max-w-xl">
      <section>
        <h2 class="text-sm font-semibold mb-2 px-0.5">Appearance</h2>
        <Card>
          <CardContent class="flex items-center justify-between gap-4">
            <span class="text-sm">Theme</span>
            <!-- Clicking the active item emits an empty value; ignore it so one is always selected -->
            <ToggleGroup
              type="single"
              variant="outline"
              size="sm"
              :model-value="theme"
              @update:model-value="(v) => v && (theme = v as typeof theme)"
            >
              <ToggleGroupItem v-for="t in themes" :key="t.value" :value="t.value">
                <component :is="t.icon" />
                {{ t.label }}
              </ToggleGroupItem>
            </ToggleGroup>
          </CardContent>
        </Card>
      </section>

      <section>
        <h2 class="text-sm font-semibold mb-2 px-0.5">Account</h2>
        <Card>
          <ItemGroup>
            <Item>
              <ItemContent>
                <ItemTitle>Signed in as</ItemTitle>
                <ItemDescription>
                  {{ email }}
                </ItemDescription>
              </ItemContent>
            </Item>
            <ItemSeparator />
            <Item>
              <ItemContent>
                <ItemTitle>Delete account</ItemTitle>
                <ItemDescription> Permanently removes you and your plants </ItemDescription>
              </ItemContent>
              <ItemActions>
                <Button variant="destructive" size="sm" @click="showDeleteAccount = true"
                  >Delete</Button
                >
              </ItemActions>
            </Item>
          </ItemGroup>
        </Card>
      </section>
    </div>

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
          <AlertDialogAction variant="destructive" @click="deleteAccount">Delete</AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </main>
</template>
