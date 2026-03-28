import { createApp } from 'vue'
import './index.css'
import App from './App.vue'
import router from './router'
import { client } from '@/client/client.gen'
import { useAuth } from '@/composables/useAuth'

const { token, clearToken } = useAuth()
client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

client.interceptors.response.use((response) => {
  if (response.status === 401) {
    clearToken()
    router.push('/login')
  }
  return response
})

const app = createApp(App)

app.use(router)

app.mount('#app')
