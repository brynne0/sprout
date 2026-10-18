import type { Component } from 'vue'
import { PlantPot, Scissors, Shovel, Sprout } from '@lucide/vue'
import type { TaskType } from '@/types'

export const TASK_ORDER: TaskType[] = ['sow', 'repot', 'transplant', 'harvest']

export const TASKS: Record<
  TaskType,
  {
    label: string
    done: string
    column: 'sow_dates' | 'repot_dates' | 'transplant_dates' | 'harvest_dates'
    icon: Component
    dot: string
    soft: string
  }
> = {
  sow: {
    label: 'Sow',
    done: 'Sown',
    column: 'sow_dates',
    icon: Sprout,
    dot: 'track-sowing-dot',
    soft: 'color-mix(in oklab, var(--sow) 50%, var(--sow-dot))',
  },
  repot: {
    label: 'Repot',
    done: 'Repotted',
    column: 'repot_dates',
    icon: PlantPot,
    dot: 'track-repot-dot',
    soft: 'color-mix(in oklab, var(--repot) 50%, var(--repot-dot))',
  },
  transplant: {
    label: 'Transplant',
    done: 'Transplanted',
    column: 'transplant_dates',
    icon: Shovel,
    dot: 'track-transplant-dot',
    soft: 'color-mix(in oklab, var(--transplant) 50%, var(--transplant-dot))',
  },
  harvest: {
    label: 'Harvest',
    done: 'Harvested',
    column: 'harvest_dates',
    icon: Scissors,
    dot: 'track-harvest-dot',
    soft: 'color-mix(in oklab, var(--harvest) 50%, var(--harvest-dot))',
  },
}
