<script setup lang="ts">
import type { TagsInputItemProps } from 'reka-ui'
import type { HTMLAttributes } from 'vue'

import { reactiveOmit } from '@vueuse/core'
import { cn } from '@/lib/utils'
import { TagsInputItem, useForwardProps } from 'reka-ui'

const props = defineProps<TagsInputItemProps & { class?: HTMLAttributes['class'] }>()

const delegatedProps = reactiveOmit(props, 'class')

const forwardedProps = useForwardProps(delegatedProps)
</script>

<template>
  <TagsInputItem
    v-bind="forwardedProps"
    :class="
      cn(
        'flex items-center gap-1.5 rounded-md border px-2 py-1 text-sm data-[state=active]:ring-ring data-[state=active]:ring-2 data-[state=active]:ring-offset-2 ring-offset-background',
        props.class,
      )
    "
  >
    <slot />
  </TagsInputItem>
</template>
