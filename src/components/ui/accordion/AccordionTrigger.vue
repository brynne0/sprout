<script setup lang="ts">
import type { AccordionTriggerProps } from 'reka-ui'
import type { HTMLAttributes } from 'vue'
import { ChevronDown } from '@lucide/vue'
import { reactiveOmit } from '@vueuse/core'
import { cn } from '@/lib/utils'
import { AccordionHeader, AccordionTrigger } from 'reka-ui'

const props = defineProps<AccordionTriggerProps & { class?: HTMLAttributes['class'] }>()

const delegatedProps = reactiveOmit(props, 'class')
</script>

<template>
  <AccordionHeader class="flex">
    <AccordionTrigger
      data-slot="accordion-trigger"
      v-bind="delegatedProps"
      :class="
        cn(
          'focus-visible:border-ring focus-visible:ring-ring/50 flex flex-1 items-center gap-1.5 rounded-md text-left text-sm font-medium transition-all outline-none focus-visible:ring-3 disabled:pointer-events-none disabled:opacity-50 [&[data-state=open]>svg]:rotate-180',
          props.class,
        )
      "
    >
      <slot name="icon">
        <ChevronDown
          class="pointer-events-none size-4 shrink-0 transition-transform duration-200"
        />
      </slot>
      <slot />
    </AccordionTrigger>
  </AccordionHeader>
</template>
