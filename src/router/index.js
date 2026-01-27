import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
      meta: { title: 'Accueil' },
    },
  ],
})

router.beforeEach((to) => {
  if (to.meta.title) {
    document.title = `${to.meta.title} | portfolio-2026`
  }
})

export default router
