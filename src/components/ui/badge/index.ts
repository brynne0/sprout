import type { VariantProps } from 'class-variance-authority'
import { cva } from 'class-variance-authority'

export { default as Badge } from './Badge.vue'

export const badgeVariants = cva(
  'inline-flex items-center justify-center rounded-full border px-2.5 py-1 text-[11px] w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-3 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden',
  {
    variants: {
      variant: {
        default: 'border-transparent bg-primary text-primary-foreground [a&]:hover:bg-primary/90',
        secondary:
          'border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90',
        destructive:
          'border-transparent bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60',
        outline: 'text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground',
        sowing:
          'border-[color-mix(in_oklab,var(--sow-dot)_40%,var(--card))] font-medium text-(--sow) bg-[color-mix(in_oklab,var(--sow-dot)_16%,var(--card))]',
        transplant:
          'border-[color-mix(in_oklab,var(--transplant-dot)_65%,var(--card))] font-medium text-(--transplant) bg-[color-mix(in_oklab,var(--transplant-dot)_16%,var(--card))]',
        harvest:
          'border-[color-mix(in_oklab,var(--harvest-dot)_40%,var(--card))] font-medium text-(--harvest) bg-[color-mix(in_oklab,var(--harvest-dot)_16%,var(--card))]',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  },
)
export type BadgeVariants = VariantProps<typeof badgeVariants>
