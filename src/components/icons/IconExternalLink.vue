<script setup>
defineProps({
  width: { type: [Number, String], default: 14 },
  height: { type: [Number, String], default: 14 },
})
</script>

<template>
  <svg
    width="11"
    height="11"
    viewBox="0 0 11 11"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <path
      d="M3.5 3.5V0.5H10V7H7M7 3.5H0.5V10H7V3.5Z"
      stroke="currentColor"
      stroke-linecap="square"
    />
  </svg>
</template>
