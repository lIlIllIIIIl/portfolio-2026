<script setup>
import cursorSrc from '../assets/cursor.svg?url'

/** Pointe approximative du curseur (coin de la flèche), en coordonnées du viewBox 20×21 */
const HOTSPOT_X = 2
const HOTSPOT_Y = 3

const x = ref(0)
const y = ref(0)
const show = ref(false)
const hideOverText = ref(false)

function onPointerMove(e) {
  x.value = e.clientX
  y.value = e.clientY
  if (!show.value) { show.value = true }

  const el = document.elementFromPoint(e.clientX, e.clientY)
  hideOverText.value = el
    ? !!el.closest('input, textarea, select, [contenteditable="true"]')
    : false
}

function onPointerLeaveWindow() {
  show.value = false
}

function teardown() {
  document.documentElement.classList.remove('custom-cursor-active')
  window.removeEventListener('pointermove', onPointerMove)
  document.documentElement.removeEventListener('pointerleave', onPointerLeaveWindow)
  show.value = false
}

let mq
let mqHandler

onMounted(() => {
  mq = window.matchMedia('(hover: hover) and (pointer: fine)')

  mqHandler = () => {
    teardown()
    if (mq.matches) {
      document.documentElement.classList.add('custom-cursor-active')
      window.addEventListener('pointermove', onPointerMove, { passive: true })
      document.documentElement.addEventListener('pointerleave', onPointerLeaveWindow)
    }
  }

  mqHandler()
  mq.addEventListener('change', mqHandler)
})

onUnmounted(() => {
  if (mq) {
    mq.removeEventListener('change', mqHandler)
  }
  teardown()
})
</script>

<template>
  <Teleport to="body">
    <div
      v-show="show && !hideOverText"
      class="custom-cursor"
      aria-hidden="true"
      :style="{
        transform: `translate3d(${x - HOTSPOT_X}px, ${y - HOTSPOT_Y}px, 0)`,
      }"
    >
      <img
        class="custom-cursor__img"
        :src="cursorSrc"
        width="20"
        height="21"
        alt=""
        draggable="false"
      />
    </div>
  </Teleport>
</template>

<style lang="scss" scoped>
.custom-cursor {
  position: fixed;
  left: 0;
  top: 0;
  z-index: 10001;
  pointer-events: none;
  will-change: transform;
  mix-blend-mode: exclusion;
}

.custom-cursor__img {
  display: block;
  user-select: none;
}
</style>
