import { createApp } from 'vue'
import './index.css'
import App from './App.vue'
import router from './router'
import { client } from '@/client/client.gen'
import { useAuth } from '@/composables/useAuth'

const { token } = useAuth()
client.setConfig({
  baseUrl: import.meta.env.VITE_API_URL,
  auth: () => token.value ?? '',
})

const app = createApp(App)

app.use(router)

app.mount('#app')
