import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Home from '../views/Home.vue'
import ContributorRegistration from '../views/ContributorRegistration.vue'
import ContributorList from '../views/ContributorList.vue'
import Voting from '../views/Voting.vue'

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
  {
    path: '/vote',
    name: 'Vote',
    component: Voting,
  }
]
  const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
