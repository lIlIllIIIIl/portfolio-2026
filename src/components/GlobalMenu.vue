<script setup>
const route = useRoute()

const isHome = computed(() => route.name === 'home')
const isAbout = computed(() => route.name === 'about')
</script>

<template>
  <header class="global-menu" role="banner">
    <div class="global-menu__logo">
      <router-link to="/" class="global-menu__logo-link" aria-label="Accueil">
        <!-- <img class="global-menu__logo-image" src="/src/assets/logo.png" alt="logo" /> -->
        <span>Alexis<br />Kessab</span>
      </router-link>
    </div>
    <nav class="global-menu__nav" aria-label="Navigation principale">
      <div class="global-menu__grid">
        <span
          class="global-menu__bracket global-menu__bracket--open"
          :class="{ 'global-menu__bracket--row-2': isAbout }"
          aria-hidden="true"
        >[</span>
        <span
          class="global-menu__bracket global-menu__bracket--close"
          :class="{ 'global-menu__bracket--row-2': isAbout }"
          aria-hidden="true"
        >]</span>
        <router-link
          to="/"
          class="global-menu__item"
          :class="{ 'global-menu__item--active': isHome }"
        >
          INDEX
        </router-link>
        <router-link
          to="/about"
          class="global-menu__item"
          :class="{ 'global-menu__item--active': isAbout }"
        >
          ABOUT
        </router-link>
      </div>
    </nav>
  </header>
</template>

<style lang="scss" scoped>
.global-menu {
  position: fixed;
  top: 48px;
  left: 0;
  right: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-left: 48px;
  padding-right: 48px;
  box-sizing: border-box;
  height: 3.5rem;
  pointer-events: none;

  @media (max-width: 768px) {
    top: 24px;
    padding-left: 24px;
    padding-right: 24px;
  }

  & > * {
    pointer-events: auto;
  }

  &__logo-link {
    font-family: "Geist Mono", ui-monospace, monospace;
    font-size: 0.9rem;
    letter-spacing: 0.05em;
    color: rgba(255, 255, 255, 0.87);
    text-decoration: none;
    transition: opacity 0.2s ease;
    &:hover {
      opacity: 0.8;
    }
  }

  &__logo-image {
    width: 2rem;
    height: 2rem;
  }

  &__nav {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
  }

  $row-height: 1.25em;
  $row-gap: 0.25rem;

  &__grid {
    display: grid;
    grid-template-columns: 1ch 4px 1fr 50px;
    grid-template-rows: $row-height $row-height;
    row-gap: $row-gap;
    column-gap: 0;
    min-width: 8rem;
    font-family: "Geist Mono", ui-monospace, monospace;
    font-size: 0.85em;
    color: rgba(255, 255, 255, 0.87);
  }

  &__bracket {
    grid-row: 1;
    align-self: center;
    pointer-events: none;
    transition: transform 0.35s ease-out;

    &--open {
      grid-column: 1;
      padding-right: 4px;
    }

    &--close {
      grid-column: 4;
      text-align: right;
    }

    /* Ligne 2 : on garde grid-row: 1 (non animable) et on décale avec transform */
    &--row-2 {
      transform: translateY(calc(#{$row-height} + #{$row-gap})); /* 1 ligne + gap entre les lignes */
    }
  }

  &__item {
    grid-column: 3;
    align-self: center;
    font-family: inherit;
    font-size: inherit;
    letter-spacing: 0.05em;
    color: inherit;
    text-decoration: none;
    text-align: left;
    transition: opacity 0.2s ease;
    opacity: 0.4;

    &:first-of-type {
      grid-row: 1;
    }

    &:last-of-type {
      grid-row: 2;
    }

    &:hover {
      opacity: 0.8;
    }

    &--active {
      opacity: 1;
    }
  }
}
</style>
