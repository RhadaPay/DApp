<template>
  <div class="container">
    <img alt="App Logo" src="../assets/logo.png" />
    <HelloWorld/>
  </div>
</template>
<script setup lang="ts">
  import HelloWorld from '../components/HelloWorld.vue'
</script>
<style scoped lang="scss">
  .container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    padding-top: 60px;
    text-align: center;
  }
  .creator {
    position: absolute;
    bottom: 20px;
    left: 50%;
    transform: translateX(-50%);
    text-decoration: none;
    color: black;
  }
  .icon {
    color: white;
  }
</style>