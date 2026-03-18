<script setup lang="ts">
import { Leaf } from 'lucide-vue-next'
defineProps<{ small?: boolean }>()
</script>

<template>
  <div :class="['flex items-center justify-center gap-2', small ? '' : 'min-h-[70vh]']">
    <Leaf
      class="w-5 h-5 text-primary animate-[leaf-bounce_1.4s_ease-in-out_infinite_both] [animation-delay:-0.32s]"
    />
    <Leaf
      class="w-5 h-5 text-primary animate-[leaf-bounce_1.4s_ease-in-out_infinite_both] [animation-delay:-0.16s]"
    />
    <Leaf class="w-5 h-5 text-primary animate-[leaf-bounce_1.4s_ease-in-out_infinite_both]" />
  </div>
</template>
