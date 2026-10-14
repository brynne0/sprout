<script setup lang="ts">
import { computed, type Component } from 'vue'
import { Bean, Broccoli, Carrot, Leaf, LeafyGreen } from '@lucide/vue'

// Icon keys come from plant_types.icon. Lucide icons are used where they exist;
// everything else is a custom SVG in src/icons/<key>.svg.
const lucideIcons: Record<string, Component> = {
  bean: Bean,
  broccoli: Broccoli,
  carrot: Carrot,
  leaf: Leaf,
  'leafy-green': LeafyGreen,
}

const customIcons = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>('@/icons/*.svg', { query: '?raw', import: 'default', eager: true }),
  ).map(([path, svg]) => [path.split('/').pop()!.replace('.svg', ''), svg]),
)

const props = defineProps<{
  name: string
  icon?: string | null
  colour?: string | null
}>()

const lucideIcon = computed(() => (props.icon ? lucideIcons[props.icon] : undefined))
const customIcon = computed(() => (props.icon ? customIcons[props.icon] : undefined))

// Falls back to the primary colour when a plant has no colour (or an unknown one).
const colour = computed(() =>
  props.colour ? `var(--produce-${props.colour}, var(--primary))` : 'var(--primary)',
)
</script>

<template>
  <div
    class="shrink-0 grid place-items-center font-semibold"
    :style="{
      color: colour,
      background: `color-mix(in oklab, ${colour} var(--produce-tint), transparent)`,
    }"
  >
    <component :is="lucideIcon" v-if="lucideIcon" class="size-[56%]" />
    <span v-else-if="customIcon" class="size-[56%] [&>svg]:size-full" v-html="customIcon" />
    <span v-else>{{ name.charAt(0).toUpperCase() }}</span>
  </div>
</template>
