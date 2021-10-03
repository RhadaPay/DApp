import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Home from '../views/Home.vue'
import ContributorRegistration from '../views/ContributorRegistration.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/register',
    name: 'Contributor Registration',
    component: ContributorRegistration,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
