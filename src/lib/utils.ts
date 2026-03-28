import type { ClassValue } from "clsx"
import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"
import { toast } from 'vue-sonner'
import { useAuth } from '@/composables/useAuth'

const { isAuthenticated } = useAuth()

export function handleApiError(error: unknown, message: string) {
  if (!isAuthenticated.value) return
  if (error instanceof TypeError) {
    toast.error('Network error', { description: 'Check your connection and try again.' })
  } else {
    toast.error(message, { description: 'Please try refreshing.' })
  }
}

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '—'
  const d = new Date(String(dateStr).slice(0, 10) + 'T00:00:00')
  return isNaN(d.getTime())
    ? String(dateStr)
    : d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}
