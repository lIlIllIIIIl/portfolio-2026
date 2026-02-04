<script setup>
import { ref, onMounted, nextTick } from 'vue'
import ScrollPreview from './ScrollPreview.vue'

defineProps({
  work: { type: Object, required: true },
})

const emit = defineEmits(['close'])
const workRightRef = ref(null)
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

      <div class="work-content">
        <div class="work-left">
          <div class="work-left__description">
            <span>{{ work.date }}</span>
            <span>[{{ work.tech }}]</span>
          </div>

          <div class="work-left__preview">
            <ScrollPreview
              :scroll-container-ref="workRightRef"
              :image-folder="work.image"
              :image-count="work.len"
            />
          </div>
        </div>

        <div ref="workRightRef" class="work-right">
          <div class="work-right__description">
            <p>{{ work.description }}</p>

            <a
              v-if="work.live"
              :href="work.live"
              target="_blank"
              rel="noopener noreferrer"
              class="work-right__description__live"
            >
              <img class="live-icon" :src="`/images/works/${work.image}/1.png`" />
              <span>SEE LIVE</span>
            </a>
          </div>

          <div class="work-right__content">
            <img v-for="i in work.len" v-bind:key="i" :src="`/images/works/${work.image}/${i}.png`" />
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
  z-index: 1;
  background-color: #fff;
  color: black;
  width: 70vw;
  height: 100vh;
  right: 0;
  top: 0;
  padding: 2rem;

  display: flex;
  flex-direction: column;

  transform: translateX(100%);
  transition: transform 0.3s ease-in-out;

  &--opening {
    transform: translateX(0);
  }

  &--closing {
    transform: translateX(100%);
  }

  .work-header {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;

    &__title {
      font-size: 2rem;
      font-weight: 400;
    }

    &__close {
      font-family: "Geist Mono";
      font-size: .75rem;
      font-weight: 500;
      padding: 0;
      margin: 0;
      background: none;
      border: none;
      cursor: pointer;
      color: inherit;
      white-space: pre;
    }
  }

.work-content {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  overflow-y: scroll;
  scroll-behavior: smooth;

  @media (max-width: 768px) {
    flex-direction: column;
    flex: 1;
    min-height: 0;
  }
}

  .work-left {
    display: flex;
    flex-direction: column;
    gap: 10rem;
    padding-top: 4rem;

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
    }
  }

  .work-right {
    display: flex;
    flex-direction: column;
    gap: 8rem;
    overflow-y: scroll;
    scroll-behavior: smooth;
    scrollbar-width: none;
    padding-top: 4rem;

    &::-webkit-scrollbar {
      display: none;
    }

    @media (max-width: 768px) {
      overflow-y: visible;
    }

    &__description {
      display: flex;
      flex-direction: row;
      justify-content: space-between;

      p {
        max-width: 20rem;
        color: black;
      }

      &__live {
        position: relative;
        overflow: hidden;
        height: fit-content;
        padding: 8px;
        border-radius: 0;
        background: #00000005;
        color: #000;
        cursor: pointer;
        border: none;
        text-decoration: none;
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: .4rem;

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
        span {
          position: relative;
          z-index: 1;
        }

        .live-icon {
          width: 1rem;
          border-radius: 100%;
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

        @media (max-width: 768px) {
          max-width: 100%;
        }
      }
    }
  }
}
</style>
