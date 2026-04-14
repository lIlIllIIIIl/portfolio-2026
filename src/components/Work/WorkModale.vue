<script setup>
import { ref, onMounted, nextTick } from 'vue'
import ScrollPreview from './ScrollPreview.vue'

defineProps({
  work: { type: Object, required: true },
})

const emit = defineEmits(['close'])
const workScrollRef = ref(null)
const isClosing = ref(false)
const isOpening = ref(false)

const CLOSE_DURATION = 300
const closeLabel = '[ CLOSE     X  ]'

function onCloseClick() {
  if (isClosing.value) { return }
  isClosing.value = true
  setTimeout(() => {
    emit('close')
  }, CLOSE_DURATION)
}

onMounted(() => {
  nextTick(() => {
    isOpening.value = true
  })
})
</script>

<template>
  <div class="work-modale">
    <div
      class="work-modale__overlay"
      :class="{ 'work-modale__overlay--hidden': isClosing }"
      aria-hidden="true"
      @click="onCloseClick"
    />
    <div
      class="work-container"
      :class="{
        'work-container--opening': isOpening,
        'work-container--closing': isClosing,
      }"
    >
      <div class="work-header">
        <h1 class="work-header__title">{{ work.title }}</h1>
        <span class="work-header__close" @click="onCloseClick">{{ closeLabel }}</span>
      </div>

      <div class="work-body">
        <div class="work-left">
          <div class="work-left__description">
            <span>{{ work.date }}</span>
            <span>[{{ work.tech }}]</span>
            <!-- <a class="opacity hover" v-if="work.github" :href="work.github" target="_blank">the repo</a> -->
          </div>

          <div class="work-left__preview">
            <ScrollPreview
              :scroll-container-ref="workScrollRef"
              :image-folder="work.image"
              :image-count="work.len"
            />
          </div>
        </div>

        <div ref="workScrollRef" class="work-right-scroll">
          <div class="work-content">
            <div class="work-right">
              <div class="work-right__description">
                <p>{{ work.description }}</p>

                <div class="work-right_live_container">
                  <a
                    v-if="work.live"
                    :href="work.live"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="work-right__description__cta"
                  >
                    <img class="live-icon" :src="`/images/works/${work.image}/button.png`" :alt="work.title" />
                    <span>SEE LIVE</span>
                  </a>

                  <a
                    v-if="work.github"
                    :href="work.github"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="work-right__description__cta"
                  >
                    <svg class="cta-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                      <path
                        fill="currentColor"
                        d="M12 .3a12 12 0 0 0-3.8 23.4c.6.1.8-.3.8-.6v-2.2c-3.3.7-4-1.4-4-1.4-.5-1.3-1.2-1.7-1.2-1.7-1-.7.1-.7.1-.7 1.1.1 1.7 1.1 1.7 1.1 1 1.7 2.7 1.2 3.3.9.1-.7.4-1.2.7-1.5-2.6-.3-5.3-1.3-5.3-5.8 0-1.3.5-2.4 1.2-3.2-.1-.3-.5-1.5.1-3.1 0 0 1-.3 3.3 1.2a11.3 11.3 0 0 1 6 0C17.7 4.6 18.7 5 18.7 5c.6 1.6.2 2.8.1 3.1.8.8 1.2 1.9 1.2 3.2 0 4.5-2.7 5.5-5.3 5.8.4.4.8 1.1.8 2.3v3.4c0 .3.2.7.8.6A12 12 0 0 0 12 .3Z"
                      />
                    </svg>
                  </a>
                </div>
              </div>

              <div class="work-right__content">
                <img v-for="i in work.len" v-bind:key="i" :src="`/images/works/${work.image}/${i}.png`" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.work-modale {
  position: fixed;
  inset: 0;
  z-index: 1000;
}

.work-modale__overlay {
  position: absolute;
  inset: 0;
  background: #00000040;
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  transition: opacity 0.15s ease-out;
  cursor: pointer;

  &--hidden {
    opacity: 0;
    pointer-events: none;
  }
}

.work-container {
  position: fixed;
  z-index: 900;
  background-color: #fff;
  color: black;
  width: 70vw;
  height: 100vh;
  right: 0;
  top: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transform: translateX(100%);
  transition: transform 0.3s ease-in-out;

  @media (max-width: 768px) {
        width: 90vw;
      }

  &--opening {
    transform: translateX(0);
  }

  &--closing {
    transform: translateX(100%);
  }

  .work-body {
    flex: 1;
    min-height: 0;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    gap: 2rem;
    padding: 0 2rem 2rem;

    @media (max-width: 768px) {
      flex-direction: column;
      gap: 2rem;
      padding: 0 2rem 2rem;
    }
  }

  .work-right-scroll {
    flex: 1;
    min-width: 0;
    min-height: 0;
    overflow-y: auto;
    scroll-behavior: smooth;
  }

  .work-header {
    z-index: 2;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding: 2rem 2rem 0;
    mix-blend-mode: exclusion;
    color: #ffffff;

    &__title {
      font-size: 2rem;
      font-weight: 400;
    }

    &__close {
      font-family: "Geist Mono";
      font-size: 0.75rem;
      font-weight: 500;
      padding: 0;
      margin: 0;
      background: none;
      border: none;
      cursor: pointer;
      color: inherit;
      white-space: pre;

      &:hover {
        opacity: .7;
      }
    }
  }

  .work-content {
    padding-top: 2rem;
  }

  .work-left {
    display: flex;
    flex-direction: column;
    gap: 10rem;
    padding-top: 2rem;

    @media (max-width: 768px) {
      gap: 0;
    }

    &__preview {
      width: 10rem;

      @media (max-width: 768px) {
        display: none;
      }
    }

    &__description {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      width: 10rem;

      @media (max-width: 768px) {
        width: 100%;
      }

      span {
        color: #00000040;
        max-width: 10rem;
      }

      a {
        color: #00000040;

        &:hover {
          text-decoration: underline;
        }
      }
    }
  }

  .work-right {
    display: flex;
    flex-direction: column;
    gap: 8rem;
    flex: 1;
    min-width: 0;

    &__description {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 1rem;

      @media (max-width: 768px) {
        flex-direction: column;
        gap: 1rem;
      }

      p {
        max-width: 25rem;
        color: black;
      }

      &__cta {
        position: relative;
        overflow: hidden;
        height: fit-content;
        padding: 8px;
        border-radius: 2px;
        background: rgba(0, 0, 0, 0.05);
        color: #000;
        cursor: pointer;
        border: none;
        text-decoration: none;
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 0.4rem;
        width: fit-content;
        font-size: 0.75rem;

        @media (max-width: 768px) {
       max-width: max-content;
      }

        &::before {
          content: '';
          position: absolute;
          left: 0;
          top: 0;
          height: 100%;
          width: 0;
          background: #00000006;
          transition: width 0.25s ease-out;
          z-index: 0;
        }

        &:hover::before {
          width: 100%;
        }

        img,
        svg,
        span {
          position: relative;
          z-index: 1;
        }

        .live-icon {
          width: 1rem;
          height: 1rem;
          border-radius: 100%;
        }

        .cta-icon {
          width: 1rem;
          height: 1rem;
          flex-shrink: 0;
        }
      }
    }

    &__content {
      display: flex;
      flex-direction: column;
      gap: 10px;
      padding-bottom: 10rem;

      img {
        max-width: 55vw;
        width: -webkit-fill-available;
        border-radius: 2px;

        @media (max-width: 768px) {
          max-width: 100%;
        }
      }
    }
  }
}

.work-right_live_container {
  display: flex;
  flex-direction: row;
  gap: 0.2rem;
}
</style>
