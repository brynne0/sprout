import { createApp } from 'vue'
import './index.css'
import App from './App.vue'
import router from './router'
import { supabase } from '@/lib/supabase'

supabase.auth.onAuthStateChange((event) => {
  if (event === 'SIGNED_OUT') router.push('/login')
})

const app = createApp(App)

app.use(router)

app.mount('#app')
