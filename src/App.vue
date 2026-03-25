<!-- À faire : lien github projets? -->

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

<style lang="scss" scoped>
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

  a {
    color: #eee;
    text-decoration: none;

    &:hover,
    &.router-link-active {
      color: #42b883;
    }
  }
}
</style>
