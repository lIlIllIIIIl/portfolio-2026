<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import WorkModale from '../components/Work/WorkModale.vue'
import works from '../store/works.json'

const isAnimating = ref(false)
const showProjects = ref(false)
const selectedWork = ref(null)
const homeProjectsVisible = inject('homeProjectsVisible')
const homeHoveredProjectIndex = inject('homeHoveredProjectIndex')
const homeIntroDone = inject('homeIntroDone')
const completeHomeIntro = inject('completeHomeIntro')

const SQUARES_TOP = 3
const SQUARES_BOTTOM = 3

const projects = Object.values(works).slice(0, 6)

const ANIMATION_DURATION = 650
const PROJECTS_FADE_MS = 550
const MIN_LOADER_MS = 2000

let isUnmounted = false

function preloadImage(src) {
  return new Promise((resolve) => {
    const img = new Image()
    img.onload = () => resolve()
    img.onerror = () => resolve()
    img.src = src
  })
}

async function preloadHomeMedia() {
  const urls = projects.flatMap((project) => [
    `/images/works/${project.image}/cover.png`,
    `/images/works/${project.image}/button.png`,
  ])
  await Promise.all(urls.map(preloadImage))
}

async function runLoaderSequence() {
  const start = Date.now()
  await preloadHomeMedia()
  if (isUnmounted) {
    return
  }
  const elapsed = Date.now() - start
  const remaining = Math.max(0, MIN_LOADER_MS - elapsed)
  await new Promise((resolve) => setTimeout(resolve, remaining))
}

function triggerIntroAnimation() {
  if (isUnmounted || isAnimating.value) {
    return
  }
  isAnimating.value = true
  setTimeout(() => {
    if (isUnmounted) {
      return
    }
    showProjects.value = true
    setTimeout(() => {
      if (isUnmounted) {
        return
      }
      completeHomeIntro?.()
    }, PROJECTS_FADE_MS)
  }, ANIMATION_DURATION)
}

watch(showProjects, (visible) => {
  if (homeProjectsVisible) {
    homeProjectsVisible.value = visible
  }
  if (!visible && homeHoveredProjectIndex) {
    homeHoveredProjectIndex.value = 0
  }
}, { immediate: true })

function onProjectHover(index) {
  if (homeHoveredProjectIndex) {
    homeHoveredProjectIndex.value = index + 1
  }
}

function onProjectLeave() {
  if (homeHoveredProjectIndex) {
    homeHoveredProjectIndex.value = 0
  }
}

function openWork(work) {
  selectedWork.value = work
}

function closeWork() {
  selectedWork.value = null
}

onMounted(async () => {
  document.documentElement.classList.add('home-no-scroll')
  document.body.classList.add('home-no-scroll')

  if (homeIntroDone?.value) {
    showProjects.value = true
    return
  }

  await runLoaderSequence()
  if (isUnmounted) {
    return
  }
  triggerIntroAnimation()
})

onUnmounted(() => {
  isUnmounted = true
  document.documentElement.classList.remove('home-no-scroll')
  document.body.classList.remove('home-no-scroll')
  if (homeProjectsVisible) {
    homeProjectsVisible.value = false
  }
  if (homeHoveredProjectIndex) {
    homeHoveredProjectIndex.value = 0
  }
})
</script>

<template>
  <div
    class="home-container"
    :class="{ 'home--animating': isAnimating }"
  >
    <div v-if="!showProjects" class="home__center">
      <div class="home__squares home__squares--top">
        <div
          v-for="i in SQUARES_TOP"
          :key="'top-' + i"
          class="home__square"
          :class="[
            { 'home__square--animate': isAnimating && i <= 3 },
            i === 1 && 'home__square--ease-in',
            i === 2 && 'home__square--ease-none',
            i === 3 && 'home__square--ease-out'
          ]"
        />
      </div>

      <div class="home__spacer home__spacer--top" />

      <div class="home__text" :class="{ 'home__text--hidden': isAnimating }">
        <h1 class="home__name">Alexis Kessab</h1>
        <p class="home__title">Fullstack Developer</p>
      </div>

      <div class="home__spacer home__spacer--bottom" />

      <div class="home__squares home__squares--bottom">
        <div
          v-for="i in SQUARES_BOTTOM"
          :key="'bottom-' + i"
          class="home__square"
          :class="[
            { 'home__square--animate': isAnimating },
            i === 1 && 'home__square--ease-out',
            i === 2 && 'home__square--ease-none',
            i === 3 && 'home__square--ease-in'
          ]"
        />
      </div>
    </div>

    <Transition name="projects-fade">
      <div
        v-if="showProjects"
        class="home__projects"
        @click.stop
      >
        <button
          v-for="(project, index) in projects"
          :key="project.title"
          type="button"
          class="home__project"
          :style="{ transitionDelay: `${index * 50}ms` }"
          @click="openWork(project)"
          @mouseenter="onProjectHover(index)"
          @mouseleave="onProjectLeave"
        >
          <div class="home__project-cover">
            <img
              :src="`/images/works/${project.image}/cover.png`"
              :alt="project.title"
              class="home__project-image"
            />
          </div>
          <span class="home__project-title">
            <img
              class="home__project-icon"
              :src="`/images/works/${project.image}/button.png`"
              :alt="project.title"
            />
            {{ project.title.toUpperCase() }}
          </span>
        </button>
      </div>
    </Transition>

    <Teleport to="body">
      <WorkModale
        v-if="selectedWork"
        :work="selectedWork"
        @close="closeWork"
      />
    </Teleport>
  </div>
</template>

<style lang="scss" scoped>
.home-container {
  position: fixed;
  inset: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  z-index: 1;

  .home__center {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
}

.home__squares {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;

  .home__square {
    width: 105px;
    height: 105px;
    border-radius: 2px;
    background: transparent;
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.25);
    transition: transform 0.6s ease-out, opacity 0.6s ease-out;

    &--ease-out {
      transition-timing-function: cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    &--ease-none {
      transition-timing-function: linear;
    }

    &--ease-in {
      transition-timing-function: cubic-bezier(0.895, 0.03, 0.685, 0.22);
    }

    &--animate {
      opacity: 0;
    }
  }

  &--top .home__square--animate {
    transform: translateY(150px);
  }

  &--bottom .home__square--animate {
    transform: translateY(-150px);
  }
}

.home__spacer {
  height: 100px;
  flex-shrink: 0;
}

.home__text {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  transition: opacity 0.5s ease-out;

  &--hidden {
    opacity: 0;
  }

  .home__name {
    margin: 0;
    font-family: "Geist", system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.95);
    letter-spacing: 0.02em;
  }

  .home__title {
    margin: 0.25rem 0 0;
    font-family: "Geist", system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.6);
    letter-spacing: 0.02em;
  }
}

.home__projects {
  position: absolute;
  inset: 0;
  display: flex;
  flex-wrap: nowrap;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  padding: 2rem;
  box-sizing: border-box;
  pointer-events: auto;

  @media (max-width: 768px) {
    flex-direction: column;
    flex-wrap: nowrap;
    align-items: center;
    justify-content: flex-start;
    padding-top: 5rem;
    overflow-y: auto;
  }
}

.home__project {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.75rem;
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  font: inherit;
  color: inherit;
  transition: opacity 0.5s ease-out, transform 0.5s ease-out;

  &:hover .home__project-cover {
    opacity: 0.9;
  }

  &-cover {
    width: min(217px, calc((100vw - 4rem - 7.5rem) / 6));
    aspect-ratio: 1;
    overflow: hidden;
    border-radius: 2px;
    transition: opacity 0.2s ease;

    @media (max-width: 768px) {
      width: min(217px, calc(100vw - 4rem));
    }
  }

  &-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  &-title {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    text-align: left;
    padding: 0.35rem 0.6rem;
    background: #ffffff15;
    border-radius: 2px;
    font-family: "Geist Mono", ui-monospace, monospace;
    font-size: 0.75rem;
    letter-spacing: 0.08em;
    color: rgba(255, 255, 255, 0.9);

    .home__project-icon {
      width: 1rem;
      height: 1rem;
      border-radius: 100%;
      flex-shrink: 0;
    }
  }
}

.projects-fade-enter-active {
  transition: opacity 0.5s ease-out;

  .home__project {
    transition: opacity 0.5s ease-out, transform 0.5s ease-out;
  }
}

.projects-fade-enter-from {
  opacity: 0;

  .home__project {
    opacity: 0;
    transform: translateY(40px);
  }
}

.projects-fade-enter-to {
  opacity: 1;

  .home__project {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
