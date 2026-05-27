<script setup>
import { computed } from 'vue'
import { resolveStackIcon } from '../../utils/stackTechIcons'

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
})

const icon = computed(() => resolveStackIcon(props.label))
const path = computed(() => icon.value?.path ?? null)
</script>

<template>
  <span class="tech-stack-chip">
    <svg
      v-if="path"
      class="tech-stack-chip__svg"
      viewBox="0 0 24 24"
      width="14"
      height="14"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      focusable="false"
    >
      <path fill="currentColor" :d="path" />
    </svg>
    <span class="tech-stack-chip__label">{{ label }}</span>
  </span>
</template>

<style lang="scss" scoped>
.tech-stack-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: #00000050;

  &__svg {
    flex-shrink: 0;
    display: block;
  }

  &__label {
    font-family: 'Geist Mono', ui-monospace, monospace;
    font-size: 0.75rem;
    font-weight: 500;
    letter-spacing: 0.02em;
  }
}
</style>
