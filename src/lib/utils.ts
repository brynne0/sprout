import type { ClassValue } from 'clsx'
import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'
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

// Converts a date string (plain YYYY-MM-DD or UTC ISO timestamp) to a local YYYY-MM-DD string.
export function toLocalDateStr(dateStr: string): string {
  if (dateStr.includes('T') || dateStr.endsWith('Z')) {
    const d = new Date(dateStr)
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }
  return dateStr.substring(0, 10)
}

export function localToday(): string {
  return toLocalDateStr(new Date().toISOString())
}

export function isDateUpcoming(dateStr: string): boolean {
  return toLocalDateStr(dateStr) > localToday()
}

export function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '—'
  const s = String(dateStr)
  const d =
    s.includes('T') || s.endsWith('Z') ? new Date(s) : new Date(toLocalDateStr(s) + 'T00:00:00')
  return isNaN(d.getTime())
    ? s
    : d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}
