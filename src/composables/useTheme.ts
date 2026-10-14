import { watchEffect } from 'vue'
import { createSharedComposable, useColorMode } from '@vueuse/core'

const STATUS_BAR = { light: '#e8e5df', dark: '#1d2620' }

export const useTheme = createSharedComposable(() => {
  const mode = useColorMode({ storageKey: 'sprout-theme' })

  watchEffect(() => {
    document
      .querySelector('meta[name="theme-color"]')
      ?.setAttribute('content', STATUS_BAR[mode.state.value === 'dark' ? 'dark' : 'light'])
  })

  return mode
})
