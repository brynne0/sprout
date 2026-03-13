import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: () => import('@/views/YourGarden.vue'),
    },
    { path: '/login', component: () => import('@/views/LoginView.vue') },
    { path: '/auth/callback', component: () => import('@/views/AuthCallback.vue') },
  ],
})

const publicRoutes = ['/login', '/auth/callback']

router.beforeEach((to) => {
  const { isAuthenticated } = useAuth()
  if (!isAuthenticated.value && !publicRoutes.includes(to.path)) {
    return '/login'
  }
})

export default router
