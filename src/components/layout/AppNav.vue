<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { Sprout, Calendar } from 'lucide-vue-next'

const links = [
  { to: '/', label: 'Your Garden', icon: Sprout, exact: true },
  { to: '/calendar', label: 'Calendar', icon: Calendar, exact: false },
]
</script>

<template>
  <nav
    class="fixed bottom-0 left-0 right-0 flex border-t bg-background pb-[env(safe-area-inset-bottom)]"
  >
    <RouterLink
      v-for="link in links"
      :key="link.to"
      :to="link.to"
      class="flex flex-1 flex-col items-center gap-1 py-3 text-xs font-semibold text-foreground/60 transition-colors hover:text-foreground"
      active-class="!text-primary [&>div]:bg-primary/15"
      :exact-active-class="link.exact ? '!text-primary [&>div]:bg-primary/15' : ''"
    >
      <div class="rounded-full p-2 transition-colors flex flex-row gap-2 items-center">
        <component :is="link.icon" class="size-5" />
        {{ link.label }}
      </div>
    </RouterLink>
  </nav>
</template>
