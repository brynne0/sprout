<script setup lang="ts">
import { computed, type Component } from 'vue'
import { Bean, Broccoli, Carrot, Flower, Flower2, Leaf, LeafyGreen } from '@lucide/vue'
import type { TaskType } from '@/types'
import { TASKS } from '@/lib/tasks'
import { Tooltip, TooltipContent, TooltipTrigger } from '@/components/ui/tooltip'

// Icon keys come from plant_types.icon. Lucide icons are used where they exist;
// everything else is a custom SVG in src/icons/<key>.svg.
const lucideIcons: Record<string, Component> = {
  bean: Bean,
  broccoli: Broccoli,
  carrot: Carrot,
  flower: Flower,
  'flower-2': Flower2,
  leaf: Leaf,
  'leafy-green': LeafyGreen,
}

const customIcons = Object.fromEntries(
  Object.entries(
    import.meta.glob<string>('@/icons/*.svg', { query: '?raw', import: 'default', eager: true }),
  ).map(([path, svg]) => [path.split('/').pop()!.replace('.svg', ''), svg]),
)

const props = withDefaults(
  defineProps<{
    name: string
    icon?: string | null
    colour?: string | null
    task?: TaskType | null
    taskLabel?: string
    size?: 'default' | 'tile'
  }>(),
  { size: 'default' },
)

const sizes = {
  default: 'size-8 rounded-full text-sm',
  tile: 'size-16 rounded-xl sm:size-20 sm:rounded-2xl text-2xl sm:text-3xl border [--icon-base:var(--background)]',
}

const lucideIcon = computed(() => (props.icon ? lucideIcons[props.icon] : undefined))
const customIcon = computed(() => (props.icon ? customIcons[props.icon] : undefined))

// Falls back to the primary colour when a plant has no colour (or an unknown one).
const colour = computed(() =>
  props.colour ? `var(--produce-${props.colour}, var(--primary))` : 'var(--primary)',
)
</script>

<template>
  <div
    class="relative shrink-0 grid place-items-center font-semibold"
    :class="sizes[size]"
    :style="{
      color: colour,
      background: `color-mix(in oklab, ${colour} var(--produce-tint), var(--icon-base, var(--card)))`,
      borderColor: `color-mix(in oklab, ${colour} 30%, var(--icon-base, var(--card)))`,
    }"
  >
    <component :is="lucideIcon" v-if="lucideIcon" class="size-[56%]" />
    <span v-else-if="customIcon" class="size-[56%] [&>svg]:size-full!" v-html="customIcon" />
    <span v-else>{{ name.charAt(0).toUpperCase() }}</span>
    <Tooltip v-if="task" :disabled="!taskLabel">
      <TooltipTrigger as-child>
        <span
          class="absolute -right-0.5 -bottom-0.5 size-3 rounded-full border-2 border-(--icon-base,var(--card))"
          :class="TASKS[task].dot"
        >
          <span v-if="taskLabel" class="sr-only">{{ taskLabel }}</span>
        </span>
      </TooltipTrigger>
      <TooltipContent>{{ taskLabel }}</TooltipContent>
    </Tooltip>
  </div>
</template>
