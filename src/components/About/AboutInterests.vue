<script setup>
import { computed, inject, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import interests from '../../store/interests.json'

const INTERESTS_SECTION_INDEX = 1

/** Aligné sur l’entrée des projets homepage (`.projects-fade-enter-from .home__project`). */
const ITEM_ENTER_OFFSET_PX = 28
const ITEM_STAGGER_MS = 45

/** Plus la valeur est basse, plus le texte « traîne » derrière la souris (effet de délai doux). */
const FOLLOW_LERP = 0.12

const activeAboutSection = inject('activeAboutSection', null)
const aboutScrollDirection = inject('aboutScrollDirection', null)

const motionEnabled = computed(() => activeAboutSection != null && aboutScrollDirection != null)

/**
 * below  : hors champ vers le bas (entrée scroll down / sortie scroll up)
 * visible: état affiché
 * above  : hors champ vers le haut (entrée scroll up / sortie scroll down)
 */
const phase = ref(motionEnabled.value ? 'below' : 'visible')
const suppressTransition = ref(false)

watch(
  motionEnabled,
  (enabled) => {
    if (!enabled) {
      phase.value = 'visible'
      suppressTransition.value = false
    } else if (phase.value === 'visible' && activeAboutSection?.value !== INTERESTS_SECTION_INDEX) {
      phase.value = 'below'
    }
  },
  { immediate: true }
)

watch(
  () => activeAboutSection?.value,
  async (next, prev) => {
    if (!motionEnabled.value) {
      return
    }

    if (next === INTERESTS_SECTION_INDEX) {
      const fromDown = aboutScrollDirection.value === 'down'
      suppressTransition.value = true
      phase.value = fromDown ? 'below' : 'above'
      await nextTick()
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          suppressTransition.value = false
          phase.value = 'visible'
          // Si la souris est déjà dans la grille au moment où la section apparaît
          // (scroll/animation), on force un recalcul sans attendre un mousemove.
          requestAnimationFrame(() => {
            refreshFollowerFromLastPointer()
          })
        })
      })
      return
    }

    if (prev === INTERESTS_SECTION_INDEX && typeof next === 'number') {
      const goingDown = next > INTERESTS_SECTION_INDEX
      phase.value = goingDown ? 'above' : 'below'
    }
  },
  { immediate: true }
)

const gridMotionClass = computed(() => {
  if (!motionEnabled.value) {
    return []
  }
  return [
    'interests-motion-on',
    `interests-phase--${phase.value}`,
    suppressTransition.value ? 'interests--no-transition' : '',
  ]
})

const motionGridStyle = computed(() => {
  if (!motionEnabled.value) {
    return {}
  }
  return {
    '--interest-offset-y': `${ITEM_ENTER_OFFSET_PX}px`,
    '--interest-stagger': `${ITEM_STAGGER_MS}ms`,
  }
})

const focused = ref(null)
const isActive = ref(false)
const followerX = ref(0)
const followerY = ref(0)
const targetFollowerX = ref(0)
const targetFollowerY = ref(0)

const gridEl = ref(null)
const itemEls = ref([])

let followRafId = null
let lastClientX = null
let lastClientY = null

function stopFollowRaf() {
  if (followRafId != null) {
    cancelAnimationFrame(followRafId)
    followRafId = null
  }
}

function followTick() {
  const tx = targetFollowerX.value
  const ty = targetFollowerY.value
  const dx = tx - followerX.value
  const dy = ty - followerY.value
  followerX.value += dx * FOLLOW_LERP
  followerY.value += dy * FOLLOW_LERP
  if (Math.abs(tx - followerX.value) < 0.35 && Math.abs(ty - followerY.value) < 0.35) {
    followerX.value = tx
    followerY.value = ty
    followRafId = null
    return
  }
  followRafId = requestAnimationFrame(followTick)
}

function scheduleFollow() {
  if (followRafId == null) {
    followRafId = requestAnimationFrame(followTick)
  }
}

function setItemRef(el, index, interestValue) {
  if (!el) {
    return
  }
  itemEls.value[index] = el
  // Store the value on the element so we can retrieve it
  // while iterating through DOM rects on mouse move.
  el.__interestValue = interestValue
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value))
}

function updateFromMouse(event) {
  if (!gridEl.value) {
    return
  }
  const gridRect = gridEl.value.getBoundingClientRect()
  const xInGrid = event.clientX - gridRect.left

  // Find which item is currently under the mouse X
  let nextFocused = null
  for (const el of itemEls.value) {
    if (!el) {
      continue
    }
    const rect = el.getBoundingClientRect()
    if (event.clientX >= rect.left && event.clientX <= rect.right) {
      nextFocused = el.__interestValue ?? null
      break
    }
  }
  focused.value = nextFocused

  // Position cible du follower (la position affichée le rejoint avec un léger retard)
  const padding = 8
  targetFollowerX.value = clamp(xInGrid, padding, gridRect.width - padding)

  const firstItem = itemEls.value?.[0]
  const imgEl = firstItem?.querySelector?.('.img-container')
  if (imgEl) {
    const imgRect = imgEl.getBoundingClientRect()
    const offsetUnderImg = 10
    targetFollowerY.value = (imgRect.bottom - gridRect.top) + gridEl.value.scrollTop + offsetUnderImg
  }

  scheduleFollow()
}

function updateFromClientXY(clientX, clientY) {
  updateFromMouse({ clientX, clientY })
}

function refreshFollowerFromLastPointer({ forceVisible } = { forceVisible: false }) {
  if (!gridEl.value || lastClientX == null || lastClientY == null) {
    return
  }
  const rect = gridEl.value.getBoundingClientRect()
  const isInside =
    lastClientX >= rect.left &&
    lastClientX <= rect.right &&
    lastClientY >= rect.top &&
    lastClientY <= rect.bottom

  if (!isInside && !forceVisible) {
    return
  }

  if (!isInside) {
    isActive.value = false
    focused.value = null
    stopFollowRaf()
    return
  }

  const wasActive = isActive.value
  isActive.value = true
  updateFromClientXY(lastClientX, lastClientY)
  if (!wasActive) {
    followerX.value = targetFollowerX.value
    followerY.value = targetFollowerY.value
    stopFollowRaf()
  }
}

function onEnter(event) {
  isActive.value = true
  updateFromMouse(event)
  followerX.value = targetFollowerX.value
  followerY.value = targetFollowerY.value
  stopFollowRaf()
}

function onMove(event) {
  if (!isActive.value) {
    return
  }
  updateFromMouse(event)
}

function onLeave() {
  isActive.value = false
  focused.value = null
  stopFollowRaf()
}

function onWindowMouseMove(event) {
  lastClientX = event.clientX
  lastClientY = event.clientY
}

function onGridScroll() {
  if (!isActive.value) {
    return
  }
  refreshFollowerFromLastPointer()
}

function onWindowResize() {
  refreshFollowerFromLastPointer()
}

onMounted(() => {
  window.addEventListener('mousemove', onWindowMouseMove, { passive: true })
  window.addEventListener('resize', onWindowResize, { passive: true })
  gridEl.value?.addEventListener?.('scroll', onGridScroll, { passive: true })
})

onUnmounted(() => {
  stopFollowRaf()
  window.removeEventListener('mousemove', onWindowMouseMove)
  window.removeEventListener('resize', onWindowResize)
  gridEl.value?.removeEventListener?.('scroll', onGridScroll)
})
</script>

<template>
  <div
    ref="gridEl"
    class="grid-container"
    :class="gridMotionClass"
    :style="motionGridStyle"
    @mouseenter="onEnter"
    @mousemove="onMove"
    @mouseleave="onLeave"
  >
    <!-- Top spacer row (keeps content vertically centered) -->
    <div v-for="spacer in 8" :key="`top-${spacer}`" class="col-spacer" aria-hidden="true" />

    <div
      v-for="(entry, index) in Object.entries(interests)"
      :key="entry[0]"
      class="interest-container"
      :ref="(el) => setItemRef(el, index, entry[1])"
      :style="{ '--interest-index': index }"
    >
      <div class="img-container">
        <img
          :src="`/images/interests/${entry[1].image}.jpg`"
        />
      </div>
      <span class="mobile-title">{{ entry[1].title }}</span>
    </div>

    <!-- Bottom spacer row (keeps content vertically centered) -->
    <div v-for="spacer in 8" :key="`bottom-${spacer}`" class="col-spacer" aria-hidden="true" />

    <div
      class="follower"
      :class="{ 'is-visible': isActive && focused?.title }"
      :style="{ left: `${followerX}px`, top: `${followerY}px` }"
      aria-hidden="true"
    >
      <Transition name="fade" mode="out-in">
        <span :key="focused?.title ?? 'empty'" class="follower__text">{{ focused?.title ?? '' }}</span>
      </Transition>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.page-title,
.interest-num {
  height: 105px;
  display: flex;
  align-items: center;
}

.grid-container {
  position: relative;
  display: grid;
  grid-template-columns: repeat(8, minmax(0, 1fr));
  grid-template-rows: 1fr auto 1fr;
  gap: 8px;
  width: 70vw;
  padding-left: 24px;
  padding-right: 24px;
  height: -webkit-fill-available;
  min-height: 0;
  overflow: auto;

  @media (max-width: 768px) {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-start;
    gap: 1.5rem;
    width: 100%;
    max-width: 100%;
    padding: 10rem 0;
    height: 100%;
    min-height: 0;
    max-height: 100dvh;
    overflow-y: auto;
    overflow-x: hidden;
    -webkit-overflow-scrolling: touch;
    z-index: 0;
  }
}

.col-spacer {
  height: 100%;
  min-height: 0;

  @media (max-width: 768px) {
    display: none;
  }
}

.interest-container {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-width: 0;
  opacity: 1;
  transform: translate3d(0, 0.54rem, 0);
  transition:
    opacity 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94),
    transform 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  transition-delay: calc(var(--interest-index, 0) * var(--interest-stagger, 0ms));

  @media (max-width: 768px) {
    width: auto;
    max-width: 100%;
    align-items: center;
    flex-shrink: 0;
  }

  .img-container {
    width: 100%;
    aspect-ratio: 1;
    flex-shrink: 0;
    overflow: hidden;
    border-radius: 2px;

    @media (max-width: 768px) {
      width: 160px;
      height: 160px;
      aspect-ratio: unset;
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: opacity 0.15s ease;
    }
  }

  .mobile-title {
    display: block;
    width: 100%;
    min-height: 1.5em;
    margin-top: 6px;
    opacity: 0;

    @media (max-width: 768px) {
      opacity: 1;
      width: 100%;
      max-width: 160px;
      text-align: left;
    }
  }
}

.grid-container.interests--no-transition .interest-container {
  transition: none;
}

.grid-container.interests-phase--below .interest-container {
  opacity: 0;
  transform: translate3d(0, calc(0.54rem + var(--interest-offset-y, 28px)), 0);
}

.grid-container.interests-phase--above .interest-container {
  opacity: 0;
  transform: translate3d(0, calc(0.54rem - var(--interest-offset-y, 28px)), 0);
}

.grid-container.interests-phase--visible .interest-container {
  opacity: 1;
  transform: translate3d(0, 0.54rem, 0);
}

.grid-container.interests-motion-on:not(.interests-phase--visible) {
  pointer-events: none;
}

.follower {
  position: absolute;
  left: 0;
  top: 0;
  transform: translateX(-50%);
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.12s ease;
  width: max-content;
  max-width: calc(100% - 16px);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;

  &.is-visible {
    opacity: 1;
  }

  @media (max-width: 768px) {
    display: none;
  }
}

.follower__text {
  display: inline-block;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>