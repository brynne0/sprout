import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import YourGarden from '@/views/YourGarden.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: YourGarden,
    },
    {
      path: '/catalogue',
      component: () => import('@/views/CatalogueView.vue'),
    },
    {
      path: '/settings',
      component: () => import('@/views/SettingsView.vue'),
    },
    {
      path: '/plants/new',
      component: () => import('@/views/PlantFormView.vue'),
      meta: { activeNav: '/' },
    },
    {
      path: '/plants/:id/edit',
      component: () => import('@/views/PlantFormView.vue'),
      meta: { activeNav: '/' },
    },
    {
      path: '/plants/:id',
      component: () => import('@/views/PlantDetailView.vue'),
      meta: { activeNav: '/' },
    },
    {
      path: '/catalogue/:id',
      component: () => import('@/views/PlantDetailView.vue'),
      meta: { cataloguePlant: true, activeNav: '/catalogue' },
    },
    ...(import.meta.env.DEV
      ? [{ path: '/showcase', component: () => import('@/views/ShowcaseView.vue') }]
      : []),
    { path: '/login', component: () => import('@/views/LoginView.vue') },
    { path: '/auth/callback', component: () => import('@/views/AuthCallback.vue') },
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

const publicRoutes = ['/login', '/auth/callback']

router.beforeEach(async (to) => {
  const { isAuthenticated, ready } = useAuth()
  await ready
  if (!isAuthenticated.value && !publicRoutes.includes(to.path)) {
    return '/login'
  }
  if (isAuthenticated.value && to.path === '/login') {
    return '/'
  }
})

export default router
