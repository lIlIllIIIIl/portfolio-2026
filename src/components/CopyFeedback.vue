<script setup>
import { useCopyFeedback } from '../composables/useCopyFeedback'

const { visible, posX, posY, text } = useCopyFeedback()

const offset = { x: 12, y: 12 }
</script>

<template>
  <Transition name="copy-feedback">
    <div
      v-if="visible"
      class="copy-feedback"
      :style="{
        left: `${posX + offset.x}px`,
        top: `${posY + offset.y}px`,
      }"
    >
      {{ text }}
    </div>
  </Transition>
</template>

<style lang="scss" scoped>
.copy-feedback {
  position: fixed;
  pointer-events: none;
  z-index: 9999;
  font-family: "Geist", system-ui, sans-serif;
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.9);
  white-space: nowrap;
}

.copy-feedback-enter-active,
.copy-feedback-leave-active {
  transition: opacity 0.25s ease;
}

.copy-feedback-enter-from,
.copy-feedback-leave-to {
  opacity: 0;
}
</style>
