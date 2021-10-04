import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Home from '../views/Home.vue'
import Voting from '../views/Voting.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/vote',
    name: 'Vote',
    component: Voting,
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
