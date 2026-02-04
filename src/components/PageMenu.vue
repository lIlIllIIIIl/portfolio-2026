<script setup>
const route = useRoute()
const activeAboutSection = inject('activeAboutSection')
const aboutScrollDirection = inject('aboutScrollDirection')

const menuItems = computed(() => {
  switch (route.name) {
    case 'home':
      return ['', 'Work']
    case 'about':
      return ['Intro', 'Interests', 'Experiences', 'Contact']
    default:
      return []
  }
})

const isAbout = computed(() => route.name === 'about')

const activeIndex = computed(() => {
  if (!isAbout.value || !menuItems.value.length) {
    return 0
  }
  return Math.min(activeAboutSection?.value ?? 0, menuItems.value.length - 1)
})

const activeItem = computed(() => {
  if (!isAbout.value || !menuItems.value.length) {
    return menuItems.value[0] ?? ''
  }
  return menuItems.value[activeIndex.value]
})

const counterValue = computed(() => activeIndex.value + 1)
const counterPrefix = '[ 0'
const counterSuffix = '     ]'

const menuTransitionName = computed(() =>
  aboutScrollDirection?.value === 'up' ? 'menu-slide-reverse' : 'menu-slide'
)
</script>

<template>
  <!-- Page About : label à gauche, compteur à droite, contenu au centre -->
  <div
    v-if="isAbout"
    class="about-menu about-menu--left"
    aria-label="Navigation par section"
  >
    <div class="about-menu__mask">
      <Transition :name="menuTransitionName" mode="out-in">
        <div :key="activeItem" class="menu-item menu-item--current">
          {{ activeItem }}
        </div>
      </Transition>
    </div>
  </div>
  <div
    v-if="isAbout"
    class="about-menu about-menu--right"
    aria-label="Section {{ counterValue }} sur {{ menuItems.length }}"
  >
    <div class="about-menu__counter">
      <span class="about-menu__counter-static">{{ counterPrefix }}</span>
      <div class="about-menu__counter-digit-wrap">
        <div class="about-menu__mask">
          <Transition :name="menuTransitionName" mode="out-in">
            <span :key="counterValue" class="about-menu__counter-digit">
              {{ counterValue }}
            </span>
          </Transition>
        </div>
      </div>
      <span class="about-menu__counter-static">{{ counterSuffix }}</span>
    </div>
  </div>
  <!-- Autres pages : menu classique à gauche -->
  <div v-if="!isAbout" class="about-menu">
    <div v-for="item in menuItems" :key="item" class="menu-item">
      {{ item }}
    </div>
  </div>
</template>

<style lang="scss" scoped>
.about-menu {
  height: 100vh;
  position: fixed;
  top: 0;

  &--left {
    width: 12vw;
    left: 0;
    display: flex;
    align-items: center;
    padding-left: 1rem;
    box-sizing: border-box;
  }

  &--right {
    width: 12vw;
    right: 0;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding-right: 1rem;
    box-sizing: border-box;
  }

  @media (max-width: 768px) {
    &--left,
    &--right {
      top: auto;
      bottom: 24px;
      height: auto;
      width: auto;
    }
  }

  &__mask {
    height: 1.2em;
    display: flex;
    align-items: center;
    width: 100%;
    // overflow: hidden;
  }

  &__counter {
    font-family: "Geist Mono", ui-monospace, monospace;
    font-variant-numeric: tabular-nums;
    font-size: 0.85em;
    letter-spacing: 0.05em;
    color: rgba(255, 255, 255, 0.6);
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    white-space: pre;
  }

  &__counter-static {
    flex-shrink: 0;
    white-space: pre;
  }

  &__counter-digit-wrap {
    display: inline-flex;
    align-items: center;
  }

  &__counter .about-menu__mask {
    width: 1ch;
    min-width: 1ch;
    display: inline-flex;
    justify-content: center;
  }

  &__counter-digit {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 1ch;
  }

  .menu-item {
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;

    &--current {
      height: auto;
      width: 100%;
      justify-content: center;
    }
  }
}

/* Scroll vers le bas : sortie vers le haut, entrée depuis le bas */
.menu-slide-leave-active,
.menu-slide-enter-active {
  transition: transform 0.35s ease-out, opacity 0.25s ease-out;
}
.menu-slide-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
.menu-slide-enter-from {
  transform: translateY(100%);
  opacity: 0;
}
.menu-slide-enter-to {
  transform: translateY(0);
  opacity: 1;
}

/* Scroll vers le haut : sortie vers le bas, entrée depuis le haut */
.menu-slide-reverse-leave-active,
.menu-slide-reverse-enter-active {
  transition: transform 0.35s ease-out, opacity 0.25s ease-out;
}
.menu-slide-reverse-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
.menu-slide-reverse-enter-from {
  transform: translateY(-100%);
  opacity: 0;
}
.menu-slide-reverse-enter-to {
  transform: translateY(0);
  opacity: 1;
}
</style>
