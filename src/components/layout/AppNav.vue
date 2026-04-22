<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { Sprout, NotepadText } from 'lucide-vue-next'
import SettingsMenu from '@/components/layout/SettingsMenu.vue'

const route = useRoute()

const links = [
  { to: '/', label: 'Your Garden', icon: Sprout },
  { to: '/catalogue', label: 'Catalogue', icon: NotepadText },
]

const activeTab = computed(() => (route.meta.activeNav as string | undefined) ?? route.path)
</script>

<template>
  <nav
    class="fixed bottom-0 left-0 right-0 z-50 flex justify-center gap-8 border-t bg-background pb-[env(safe-area-inset-bottom)]"
  >
    <RouterLink
      v-for="link in links"
      :key="link.to"
      :to="link.to"
      class="flex flex-col items-center gap-1 py-3 text-xs font-semibold transition-colors hover:text-foreground"
      :class="activeTab === link.to ? 'text-primary' : 'text-foreground/60'"
    >
      <div
        class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center"
        :class="{ 'bg-primary/15': activeTab === link.to }"
      >
        <component :is="link.icon" class="size-5" />
        {{ link.label }}
      </div>
    </RouterLink>

    <SettingsMenu />
  </nav>
</template>
