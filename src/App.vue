<!-- À faire : lien github -->

<script setup>
import GlobalMenu from './components/GlobalMenu.vue'
import PageMenu from './components/PageMenu.vue'
import ShaderBackground from './components/ShaderBackground.vue'
import CopyFeedback from './components/CopyFeedback.vue'

const activeAboutSection = ref(0)
const aboutScrollDirection = ref('down')
const homeProjectsVisible = ref(false)
const homeHoveredProjectIndex = ref(0)

provide('activeAboutSection', activeAboutSection)
provide('aboutScrollDirection', aboutScrollDirection)
provide('homeProjectsVisible', homeProjectsVisible)
provide('homeHoveredProjectIndex', homeHoveredProjectIndex)
</script>

<template>
  <div id="app">
    <ShaderBackground />

    <GlobalMenu />

    <PageMenu />

    <router-view v-slot="{ Component }">
      <Transition name="fade" mode="out-in">
        <component :is="Component" />
      </Transition>
    </router-view>

    <CopyFeedback />
  </div>
</template>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

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
