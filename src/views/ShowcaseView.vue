<script setup lang="ts">
// Dev-only page for checking components and colours in one place.
// The route is only registered when import.meta.env.DEV is true.
import { onMounted, ref } from 'vue'
import { Plus } from '@lucide/vue'
import { supabase } from '@/lib/supabase'
import { PRODUCE_COLOURS } from '@/lib/plants'
import { useTheme } from '@/composables/useTheme'
import type { PlantType } from '@/types'
import PageHeader from '@/components/layout/PageHeader.vue'
import PlantIcon from '@/components/PlantIcon.vue'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Item, ItemContent, ItemMedia, ItemTitle } from '@/components/ui/item'
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group'

const { store: theme } = useTheme()

const plantTypes = ref<PlantType[]>([])

onMounted(async () => {
  const { data } = await supabase.from('plant_types').select('id, name, icon, colour').order('name')
  plantTypes.value = (data ?? []) as PlantType[]
})

const toggleDemo = ref('a')
</script>

<template>
  <main class="pb-24">
    <PageHeader class="flex items-start justify-between gap-4">
      <h1 class="text-3xl font-bold tracking-tight text-primary">Showcase</h1>
      <ToggleGroup
        type="single"
        variant="outline"
        size="sm"
        :model-value="theme"
        @update:model-value="(v) => v && (theme = v as typeof theme)"
      >
        <ToggleGroupItem value="light">Light</ToggleGroupItem>
        <ToggleGroupItem value="dark">Dark</ToggleGroupItem>
      </ToggleGroup>
    </PageHeader>

    <div class="mx-4 flex flex-col gap-8">
      <section>
        <h2 class="text-sm font-semibold mb-3">Badges</h2>
        <div class="flex flex-wrap gap-1.5">
          <Badge variant="sowing">Sow now</Badge>
          <Badge variant="transplant">Transplant now</Badge>
          <Badge variant="harvest">Harvest now</Badge>
          <Badge variant="outline">Multisow</Badge>
          <Badge>Default</Badge>
          <Badge variant="secondary">Secondary</Badge>
          <Badge variant="outline">Outline</Badge>
          <Badge variant="destructive">Destructive</Badge>
        </div>
      </section>

      <section>
        <h2 class="text-sm font-semibold mb-3">Buttons</h2>
        <div class="flex flex-wrap gap-2">
          <Button>Default</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="link">Link</Button>
          <Button variant="destructive">Destructive</Button>
          <Button size="sm"><Plus />Small</Button>
          <Button size="icon-sm" variant="outline"><Plus /></Button>
        </div>
      </section>

      <section>
        <h2 class="text-sm font-semibold mb-3">Toggle group</h2>
        <ToggleGroup
          type="single"
          variant="outline"
          size="sm"
          :model-value="toggleDemo"
          @update:model-value="(v) => v && (toggleDemo = v as string)"
        >
          <ToggleGroupItem value="a">All</ToggleGroupItem>
          <ToggleGroupItem value="b">Veg</ToggleGroupItem>
          <ToggleGroupItem value="c">Flowers</ToggleGroupItem>
        </ToggleGroup>
      </section>

      <section>
        <h2 class="text-sm font-semibold mb-3">Produce colours</h2>
        <div class="flex flex-wrap gap-3">
          <div v-for="c in PRODUCE_COLOURS" :key="c" class="flex flex-col items-center gap-1">
            <PlantIcon :name="c" :colour="c" />
            <code class="text-xs text-muted-foreground">{{ c }}</code>
          </div>
        </div>
      </section>

      <section>
        <h2 class="text-sm font-semibold mb-3">
          Plant icons
          <span class="font-normal text-muted-foreground">{{ plantTypes.length }}</span>
        </h2>
        <div class="flex gap-4 mb-4">
          <div class="flex flex-col items-center gap-1">
            <PlantIcon name="Calendula" icon="flower" colour="orange" size="tile" />
            <span class="text-xs text-muted-foreground">Detail tile</span>
          </div>
        </div>
        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-1.5">
          <Item v-for="p in plantTypes" :key="p.id" variant="outline" size="sm">
            <ItemMedia>
              <PlantIcon :name="p.name" :icon="p.icon" :colour="p.colour" />
            </ItemMedia>
            <ItemContent>
              <ItemTitle>{{ p.name }}</ItemTitle>
              <code class="text-xs text-muted-foreground">{{ p.icon }} · {{ p.colour }}</code>
            </ItemContent>
          </Item>
        </div>
      </section>
    </div>
  </main>
</template>
