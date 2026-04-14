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
const MIN_LOADER_MS = 1000
const LOADER_SQUARE_STAGGER_MS = 45
// Aligné sur la durée CSS de transition des carrés (0.65s)
const LOADER_SQUARE_TRANSITION_MS = 650
const PAUSE_AFTER_LOADER_ENTRANCE_MS = 400
const LOADER_ENTRANCE_TOTAL_MS =
  (SQUARES_TOP + SQUARES_BOTTOM - 1) * LOADER_SQUARE_STAGGER_MS +
  LOADER_SQUARE_TRANSITION_MS
const PROJECT_ITEM_ENTER_MS = 500
const PROJECT_STAGGER_MS = 50
const PROJECTS_ENTER_TOTAL_MS =
  PROJECT_ITEM_ENTER_MS + (projects.length - 1) * PROJECT_STAGGER_MS

let isUnmounted = false

const loaderSquaresEntered = ref(false)
let loaderEntranceStartedAt = 0

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
    // Menus (App) et apparition des projets : même instant que le début du fade-in
    completeHomeIntro?.()
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

  await nextTick()
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      if (!isUnmounted) {
        loaderSquaresEntered.value = true
        loaderEntranceStartedAt = Date.now()
      }
    })
  })

  await runLoaderSequence()
  if (isUnmounted) {
    return
  }

  const elapsedSinceEntrance =
    loaderEntranceStartedAt > 0 ? Date.now() - loaderEntranceStartedAt : 0
  const waitEntranceEnd = Math.max(0, LOADER_ENTRANCE_TOTAL_MS - elapsedSinceEntrance)
  await new Promise((resolve) => setTimeout(resolve, waitEntranceEnd))
  if (isUnmounted) {
    return
  }

  await new Promise((resolve) => setTimeout(resolve, PAUSE_AFTER_LOADER_ENTRANCE_MS))
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
    <div
      v-if="!showProjects"
      class="home__center"
      :class="{ 'home__center--squares-in': loaderSquaresEntered }"
    >
      <div class="home__squares home__squares--top">
        <div
          v-for="i in SQUARES_TOP"
          :key="'top-' + i"
          class="home__square"
          :class="[
            { 'home__square--animate': isAnimating && i <= 3 },
            i === 1 && 'home__square--enter-far',
            i === 2 && 'home__square--enter-mid',
            i === 3 && 'home__square--enter-near',
            isAnimating && i === 1 && 'home__square--ease-in',
            isAnimating && i === 2 && 'home__square--ease-none',
            isAnimating && i === 3 && 'home__square--ease-out',
          ]"
          :style="{
            transitionDelay: `${(i - 1) * LOADER_SQUARE_STAGGER_MS}ms`,
          }"
        />
      </div>

      <div class="home__spacer home__spacer--top" />

      <div class="home__text" :class="{ 'home__text--hidden': isAnimating }">
        <h1 class="home__name">Alexis Kessab</h1>
        <p class="home__title">Front-end Developer</p>
      </div>

      <div class="home__spacer home__spacer--bottom" />

      <div class="home__squares home__squares--bottom">
        <div
          v-for="i in SQUARES_BOTTOM"
          :key="'bottom-' + i"
          class="home__square"
          :class="[
            { 'home__square--animate': isAnimating },
            i === 1 && 'home__square--enter-near',
            i === 2 && 'home__square--enter-mid',
            i === 3 && 'home__square--enter-far',
            isAnimating && i === 1 && 'home__square--ease-out',
            isAnimating && i === 2 && 'home__square--ease-none',
            isAnimating && i === 3 && 'home__square--ease-in',
          ]"
          :style="{
            transitionDelay: `${(SQUARES_TOP + i - 1) * LOADER_SQUARE_STAGGER_MS}ms`,
          }"
        />
      </div>
    </div>

    <Transition
      name="projects-fade"
      :duration="{ enter: PROJECTS_ENTER_TOTAL_MS, leave: 0 }"
    >
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
          :style="{ transitionDelay: `${index * PROJECT_STAGGER_MS}ms` }"
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
            <span class="home__project-title-text">{{
              project.title.toUpperCase()
            }}</span>
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

// Entrée loader : opposé de la sortie (depuis l’extérieur vers la position finale)
.home__center:not(.home__center--squares-in) {
  .home__squares--top .home__square {
    opacity: 0;
    transform: translateY(-150px);
  }

  .home__squares--bottom .home__square {
    opacity: 0;
    transform: translateY(150px);
  }

  .home__text {
    opacity: 0;
  }
}

.home__center--squares-in .home__text:not(.home__text--hidden) {
  opacity: 1;
  transition: opacity 0.55s ease-out 0.12s;
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
    transition:
      transform 0.65s,
      opacity 0.65s;

    // Entrée loader (par distance au centre)
    &--enter-near {
      transition-timing-function: cubic-bezier(0.5, 0, 0, 1);
    }

    &--enter-mid {
      transition-timing-function: cubic-bezier(0.5, 0, 0, 0.79);
    }

    &--enter-far {
      transition-timing-function: cubic-bezier(0.5, 0, 0, 0.6);
    }

    // Sortie : uniquement avec --animate
    &--animate {
      opacity: 0;

      &.home__square--ease-out {
        transition-timing-function: cubic-bezier(0.25, 0.46, 0.45, 0.94);
      }

      &.home__square--ease-none {
        transition-timing-function: linear;
      }

      &.home__square--ease-in {
        transition-timing-function: cubic-bezier(0.895, 0.03, 0.685, 0.22);
      }
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

  &--hidden {
    opacity: 0;
    transition: opacity 0.5s ease-out;
  }

  .home__name {
    margin: 0;
    font-family: "Geist", system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.95);
  }

  .home__title {
    margin: 0.25rem 0 0;
    font-family: "Geist", system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.6);
  }
}

.home__projects {
  position: absolute;
  inset: 0;
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  align-items: center;
  justify-items: stretch;
  gap: 1.5rem;
  padding: 2rem;
  box-sizing: border-box;
  pointer-events: auto;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
    align-content: start;
    justify-items: center;
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
  width: 100%;
  min-width: 0;

  @media (max-width: 768px) {
    width: min(217px, calc(100vw - 4rem));
  }

  &:hover .home__project-image {
    transform: scale(1.06);
  }

  &-cover {
    width: 100%;
    aspect-ratio: 1;
    overflow: hidden;
    border-radius: 2px;

    @media (max-width: 768px) {
      width: 100%;
    }
  }

  &-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transform: scale(1);
    transform-origin: center center;
    transition: transform 0.35s ease-out;
  }

  &-title {
    position: relative;
    overflow: hidden;
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    text-align: left;
    padding: 0.35rem 0.6rem;
    border-radius: 2px;
    background: rgba(255, 255, 255, 0.06);
    font-family: "Geist Mono", ui-monospace, monospace;
    font-size: 0.75rem;
    color: rgba(255, 255, 255, 0.9);

    &::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      height: 100%;
      width: 0;
      background: rgba(255, 255, 255, 0.02);
      transition: width 0.25s ease-out;
      z-index: 0;
    }

    &:hover::before {
      width: 100%;
    }

    .home__project-icon,
    .home__project-title-text {
      position: relative;
      z-index: 1;
    }

    .home__project-icon {
      width: 1rem;
      height: 1rem;
      border-radius: 100%;
      flex-shrink: 0;
    }
  }
}

// Un seul calque animé (les cartes) : pas de fondu sur le wrapper pour éviter
// l’empilement opacity parent × enfant et les saccades (durée alignée avec PROJECT_ITEM_ENTER_MS).
.projects-fade-enter-active .home__project {
  transition:
    opacity 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94),
    transform 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

.projects-fade-enter-from .home__project {
  opacity: 0;
  transform: translate3d(0, 28px, 0);
}

.projects-fade-enter-to .home__project {
  opacity: 1;
  transform: translate3d(0, 0, 0);
}
</style>
