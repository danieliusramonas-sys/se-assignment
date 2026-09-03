import { createRouter, createWebHistory } from 'vue-router'

import HomeView from '@/views/HomeView.vue'
import AgeView from '@/views/AgeView.vue'
import PiView from '@/views/PiView.vue'
import InvoiceView from '@/views/InvoiceView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),

  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/age',
      name: 'age',
      component: AgeView,
    },
    {
      path: '/pi',
      name: 'pi',
      component: PiView,
    },
    {
      path: '/invoices',
      name: 'invoices',
      component: InvoiceView,
    },
  ],
})

export default router
