import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Home from '../views/Home.vue'
import ContributorRegistration from '../views/ContributorRegistration.vue'
import ContributorList from '../views/ContributorList.vue'

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
  {
    path: '/contributors',
    name: 'Contributor List',
    component: ContributorList,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
