<script setup>
import GlobalMenu from './components/GlobalMenu.vue'
import PageMenu from './components/PageMenu.vue'
import ShaderBackground from './components/ShaderBackground.vue'

const activeAboutSection = ref(0)
const aboutScrollDirection = ref('down')
provide('activeAboutSection', activeAboutSection)
provide('aboutScrollDirection', aboutScrollDirection)
</script>

<template>
  <div id="app">
    <ShaderBackground />

    <GlobalMenu />

    <PageMenu />

    <router-view />
  </div>
</template>

<style scoped>
#app {
  position: relative;
  min-height: 100vh;
  z-index: 0;
}
.app-nav {
  display: flex;
  gap: 1.5rem;
  background: #1a1a1a;
  border-bottom: 1px solid #333;
}
.app-nav a {
  color: #eee;
  text-decoration: none;
}
.app-nav a:hover,
.app-nav a.router-link-active {
  color: #42b883;
}
</style>
