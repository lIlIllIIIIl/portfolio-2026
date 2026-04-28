<!-- À faire : lien github projets? -->

<script setup>
import GlobalMenu from './components/GlobalMenu.vue'
import PageMenu from './components/PageMenu.vue'
import ShaderBackground from './components/ShaderBackground.vue'
import CopyFeedback from './components/CopyFeedback.vue'
import CustomCursor from './components/CustomCursor.vue'

const HOME_INTRO_STORAGE_KEY = 'portfolio-home-intro-done'
const VISITED_NON_HOME_KEY = 'portfolio-visited-non-home'

const activeAboutSection = ref(0)
const aboutScrollDirection = ref('down')
const homeProjectsVisible = ref(false)
const homeHoveredProjectIndex = ref(0)

const homeIntroDone = ref(
  typeof sessionStorage !== 'undefined' &&
    sessionStorage.getItem(HOME_INTRO_STORAGE_KEY) === '1'
)

const hasVisitedNonHome = ref(
  typeof sessionStorage !== 'undefined' &&
    sessionStorage.getItem(VISITED_NON_HOME_KEY) === '1'
)

function completeHomeIntro() {
  homeIntroDone.value = true
  try {
    sessionStorage.setItem(HOME_INTRO_STORAGE_KEY, '1')
  } catch {
    /* ignore */
  }
}

const route = useRoute()

watch(
  () => route.name,
  (name) => {
    if (name && name !== 'home' && !hasVisitedNonHome.value) {
      hasVisitedNonHome.value = true
      try {
        sessionStorage.setItem(VISITED_NON_HOME_KEY, '1')
      } catch {
        /* ignore */
      }
    }
  },
  { immediate: true }
)

const menusVisible = computed(
  () =>
    route.name !== 'home' ||
    homeIntroDone.value ||
    hasVisitedNonHome.value
)

provide('activeAboutSection', activeAboutSection)
provide('aboutScrollDirection', aboutScrollDirection)
provide('homeProjectsVisible', homeProjectsVisible)
provide('homeHoveredProjectIndex', homeHoveredProjectIndex)
provide('homeIntroDone', homeIntroDone)
provide('completeHomeIntro', completeHomeIntro)
</script>

<template>
  <div id="app">
    <ShaderBackground />

    <div class="app-menus" :class="{ 'app-menus--visible': menusVisible }">
      <GlobalMenu />

      <PageMenu />
    </div>

    <router-view v-slot="{ Component }">
      <Transition name="fade" mode="out-in">
        <component :is="Component" />
      </Transition>
    </router-view>

    <CopyFeedback />

    <CustomCursor />
  </div>
</template>

<style lang="scss" scoped>
#app {
  position: relative;
  min-height: 100vh;
  z-index: 0;
}

.app-menus {
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.5s ease-out;

  &--visible {
    opacity: 1;
    pointer-events: auto;
  }
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
