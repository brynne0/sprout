<script setup lang="ts">
import { ref, computed, onMounted, onActivated } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Sprout } from '@lucide/vue'
import PlantCalendar from '@/components/PlantCalendar.vue'
import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from '@/components/ui/empty'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Button } from '@/components/ui/button'
import type { Plant, Reminder, TaskType, Window as PlantWindow } from '@/types'
import { handleApiError } from '@/lib/utils'
import { inWindow, todayMonthDay } from '@/lib/trackUtils'
import { TASKS, TASK_ORDER } from '@/lib/tasks'
import { archivePlant } from '@/lib/plants'
import { supabase } from '@/lib/supabase'
import PlantActions from '@/components/PlantActions.vue'
import PlantIcon from '@/components/PlantIcon.vue'
import RemindersCard from '@/components/RemindersCard.vue'
import LoadingLeaves from '@/components/LoadingLeaves.vue'
import PageHeader from '@/components/layout/PageHeader.vue'

const router = useRouter()
const plants = ref<Plant[]>([])
const reminders = ref<Reminder[]>([])
const loading = ref(true)
const today = new Date()

const activePlants = computed(() => plants.value.filter((p) => !p.archived_at))

// Plants grouped by where they are, from what has been logged
type Group = 'seedlings' | 'garden' | 'planned' | 'lastSeason'

const GROUP_ORDER: Group[] = ['seedlings', 'garden', 'planned', 'lastSeason']

const GROUP_META: Record<Group, { label: string; color: string }> = {
  seedlings: { label: 'Seedlings', color: 'var(--sow-dot)' },
  garden: { label: 'In the garden', color: 'var(--transplant-dot)' },
  planned: { label: 'Planned', color: 'var(--color-muted-foreground)' },
  lastSeason: { label: 'Last season', color: 'var(--color-muted-foreground)' },
}

function hasLog(plant: Plant, type: TaskType): boolean {
  return (plant[TASKS[type].column] ?? []).length > 0
}

// Crops that run past New Year stay put while they have dates this year or reminders left
function activeThisYear(plant: Plant): boolean {
  const year = String(today.getFullYear())
  const logged = TASK_ORDER.some((t) =>
    (plant[TASKS[t].column] ?? []).some((d) => d.startsWith(year)),
  )
  return logged || reminders.value.some((r) => r.plant_id === plant.id)
}

function groupFor(plant: Plant): Group {
  if (plant.year != null && plant.year < today.getFullYear() && !activeThisYear(plant))
    return 'lastSeason'
  if (hasLog(plant, 'transplant')) return 'garden'
  const started = hasLog(plant, 'sow') || hasLog(plant, 'repot')
  if (started && (plant.transplant_windows ?? []).length) return 'seedlings'
  if (started || hasLog(plant, 'harvest')) return 'garden'
  return 'planned'
}

// Halfway between the dark text colour and the bright dot colour
const hintColor = (t: string) => `color-mix(in oklab, var(--${t}) 50%, var(--${t}-dot))`

function hint(plant: Plant, group: Group): { label: string; color: string } | null {
  const now = todayMonthDay()
  const open = (ws: PlantWindow[] | undefined) => (ws ?? []).some((w) => inWindow(now, w))
  if (group === 'planned' && open(plant.sowing_windows))
    return { label: 'Sow now', color: hintColor('sow') }
  if (group === 'seedlings' && open(plant.transplant_windows))
    return { label: 'Ready to transplant', color: hintColor('transplant') }
  if (group === 'garden' && hasLog(plant, 'harvest'))
    return { label: 'Harvesting', color: hintColor('harvest') }
  if (group === 'garden' && open(plant.harvest_windows))
    return { label: 'Harvest season', color: hintColor('harvest') }
  return null
}

const groupedPlants = computed(() => {
  const groups: Record<Group, Plant[]> = { seedlings: [], garden: [], planned: [], lastSeason: [] }
  for (const p of activePlants.value) groups[groupFor(p)].push(p)
  return GROUP_ORDER.filter((k) => groups[k].length > 0).map((k) => ({
    key: k,
    meta: GROUP_META[k],
    plants: [...groups[k]].sort((a, b) => a.name.localeCompare(b.name)),
  }))
})

async function archive(plant: Plant) {
  if (await archivePlant(plant)) fetchAll()
}

// Data fetching
async function fetchAll() {
  try {
    const [plantsRes, remindersRes] = await Promise.all([
      supabase.from('plants_with_details').select('*').order('name').throwOnError(),
      supabase.from('reminders').select('id, plant_id, type, due_date').throwOnError(),
    ])
    plants.value = plantsRes.data as unknown as Plant[]
    reminders.value = remindersRes.data
  } catch (error) {
    handleApiError(error, 'Failed to load plants')
  }
}

onMounted(async () => {
  await fetchAll()
  loading.value = false
})

// The page is kept alive, so refresh when coming back from adding or editing a plant
onActivated(() => {
  if (!loading.value) fetchAll()
})
</script>

<template>
  <main>
    <PageHeader class="flex items-start justify-between">
      <div>
        <p class="text-[11.5px] font-medium uppercase tracking-widest text-muted-foreground">
          {{
            today.toLocaleDateString('en-AU', { weekday: 'long', day: 'numeric', month: 'long' })
          }}
        </p>
        <h1 class="text-3xl font-bold tracking-tight text-primary mt-0.5">Your Garden</h1>
      </div>
      <RouterLink
        v-if="!loading && plants.length > 0"
        to="/plants/new"
        class="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-primary-foreground"
        aria-label="Add plant"
      >
        <Plus :size="18" />
      </RouterLink>
    </PageHeader>

    <LoadingLeaves v-if="loading" />

    <div v-else-if="!loading && plants.length > 0">
      <Tabs default-value="gardenList">
        <TabsList class="mx-4">
          <TabsTrigger value="gardenList">Plants</TabsTrigger>
          <TabsTrigger value="gardenCalendar">Calendar</TabsTrigger>
        </TabsList>

        <TabsContent value="gardenList" class="px-4 flex flex-col gap-4">
          <RemindersCard
            v-if="reminders.length"
            :reminders="reminders"
            :plants="activePlants"
            :limit="6"
            @changed="fetchAll"
          />

          <div class="flex flex-col gap-5">
            <section v-for="group in groupedPlants" :key="group.key">
              <header class="flex items-center gap-2 mb-2 px-0.5">
                <span
                  class="w-2 h-2 rounded-full shrink-0"
                  :style="{ background: group.meta.color }"
                />
                <h3 class="text-[14px] font-semibold">{{ group.meta.label }}</h3>
              </header>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-1.5">
                <div
                  v-for="plant in group.plants"
                  :key="plant.id"
                  class="flex items-center gap-1 pr-2 rounded-xl border bg-card border-border transition-colors hover:bg-[color-mix(in_oklab,var(--color-foreground)_3%,transparent)]"
                >
                  <RouterLink
                    :to="`/plants/${plant.id}`"
                    class="flex flex-1 min-w-0 items-center gap-3 pl-3 py-2 rounded-xl outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
                  >
                    <PlantIcon
                      :name="plant.name"
                      :icon="plant.icon"
                      :colour="plant.colour"
                      class="w-8 h-8 rounded-full text-sm"
                    />
                    <div class="min-w-0 flex-1">
                      <div class="text-[13.5px] font-medium line-clamp-2">
                        {{ plant.name
                        }}<span v-if="plant.variety" class="font-normal text-muted-foreground">
                          · {{ plant.variety }}</span
                        >
                      </div>
                    </div>
                    <span
                      v-if="hint(plant, group.key)"
                      class="text-[11px] font-medium shrink-0"
                      :style="{ color: hint(plant, group.key)?.color }"
                    >
                      {{ hint(plant, group.key)?.label }}
                    </span>
                  </RouterLink>
                  <Button
                    v-if="group.key === 'lastSeason'"
                    variant="outline"
                    size="xs"
                    @click="archive(plant)"
                  >
                    Archive
                  </Button>
                  <!-- Sibling of the link, not inside it, so the menu button is valid HTML -->
                  <PlantActions :plant="plant" @archived="fetchAll" @deleted="fetchAll" />
                </div>
              </div>
            </section>
          </div>
        </TabsContent>

        <TabsContent value="gardenCalendar">
          <PlantCalendar
            :plants="plants"
            :reminders="reminders"
            :show-dots="true"
            :show-year-nav="true"
            :clickable="true"
            @plant-click="(p) => router.push(`/plants/${p.id}`)"
          />
        </TabsContent>
      </Tabs>
    </div>

    <div v-else-if="!loading" class="flex items-center justify-center min-h-[70vh]">
      <Empty>
        <EmptyHeader>
          <EmptyMedia>
            <Sprout />
          </EmptyMedia>
          <EmptyTitle>No Plants Yet</EmptyTitle>
          <EmptyDescription>
            You haven't added any plants yet. Get started by adding your first plant.
          </EmptyDescription>
        </EmptyHeader>
        <EmptyContent>
          <Button as-child>
            <RouterLink to="/plants/new">Add Plant</RouterLink>
          </Button>
        </EmptyContent>
      </Empty>
    </div>
  </main>
</template>
