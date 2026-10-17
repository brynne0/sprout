import type { Component } from 'vue'
import { Replace, Scissors, Shovel, Sprout } from '@lucide/vue'
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
    color: string
    bg: string
  }
> = {
  sow: {
    label: 'Sow',
    done: 'Sown',
    column: 'sow_dates',
    icon: Sprout,
    dot: 'track-sowing-dot',
    color: 'var(--sow)',
    bg: 'var(--sow-bg)',
  },
  repot: {
    label: 'Repot',
    done: 'Repotted',
    column: 'repot_dates',
    icon: Replace,
    dot: 'track-repot-dot',
    color: 'var(--repot)',
    bg: 'var(--repot-bg)',
  },
  transplant: {
    label: 'Transplant',
    done: 'Transplanted',
    column: 'transplant_dates',
    icon: Shovel,
    dot: 'track-transplant-dot',
    color: 'var(--transplant)',
    bg: 'var(--transplant-bg)',
  },
  harvest: {
    label: 'Harvest',
    done: 'Harvested',
    column: 'harvest_dates',
    icon: Scissors,
    dot: 'track-harvest-dot',
    color: 'var(--harvest)',
    bg: 'var(--harvest-bg)',
  },
}
