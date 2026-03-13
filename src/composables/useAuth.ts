import { computed, ref } from 'vue'

const token = ref<string | null>(localStorage.getItem('token'))

export function useAuth() {
  const isAuthenticated = computed(() => token.value !== null)

  function setToken(newToken: string) {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  function clearToken() {
    token.value = null
    localStorage.removeItem('token')
  }

  return { token, isAuthenticated, setToken, clearToken }
}
