<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'

const props = defineProps({
  scrollContainerRef: { type: Object, default: null },
  imageFolder: { type: String, required: true },
  imageCount: { type: Number, required: true },
  imageExt: { type: String, default: 'png' },
})

const IMAGE_MAX_WIDTH = 65
const VIEWPORT_EXTRA = 18
const VIEWPORT_WIDTH = IMAGE_MAX_WIDTH + VIEWPORT_EXTRA
const VIEWPORT_OFFSET = VIEWPORT_EXTRA / 2
const trackRef = ref(null)
const centeredIndex = ref(0)
const thumbRects = ref([])

const imageExt = computed(() => {
  const ext = (props.imageExt || 'png').toLowerCase()
  return ext === 'jpg' || ext === 'jpeg' ? 'jpg' : 'png'
})

const imageUrls = computed(() =>
  Array.from({ length: props.imageCount }, (_unused, index) =>
    `/images/works/${props.imageFolder}/${index + 1}.${imageExt.value}`
  )
)

const viewportStyle = computed(() => {
  const rects = thumbRects.value
  const idx = centeredIndex.value
  if (rects.length === 0 || idx < 0 || idx >= rects.length) { return null }
  const thumbRect = rects[idx]
  return {
    left: '0',
    top: (thumbRect.top - VIEWPORT_OFFSET) + 'px',
    width: VIEWPORT_WIDTH + 'px',
    height: (thumbRect.height + VIEWPORT_EXTRA) + 'px',
  }
})

function getContainerEl() {
  const refOrEl = props.scrollContainerRef
  return refOrEl?.value ?? refOrEl?.$el ?? refOrEl
}

function getContentImages(container) {
  if (!container) { return [] }
  const content = container.querySelector('.work-right__content')
  return content ? Array.from(content.querySelectorAll('img')) : []
}

function updateCenteredIndex() {
  const el = getContainerEl()
  if (!el) { return }
  const images = getContentImages(el)
  if (images.length === 0) { return }
  const containerRect = el.getBoundingClientRect()
  const viewportCenterY = containerRect.top + containerRect.height / 2
  let best = 0
  let bestDist = Infinity
  images.forEach((img, index) => {
    const rect = img.getBoundingClientRect()
    const centerY = rect.top + rect.height / 2
    const dist = Math.abs(centerY - viewportCenterY)
    if (dist < bestDist) {
      bestDist = dist
      best = index
    }
  })
  centeredIndex.value = best
}

function measureThumbs() {
  if (!trackRef.value) { return }
  const track = trackRef.value
  const trackRect = track.getBoundingClientRect()
  const thumbs = track.querySelectorAll('.scroll-preview__thumb')
  thumbRects.value = Array.from(thumbs).map((thumb) => {
    const rect = thumb.getBoundingClientRect()
    return {
      top: rect.top - trackRect.top,
      left: rect.left - trackRect.left,
      width: rect.width,
      height: rect.height,
    }
  })
}

function scrollToImage(index) {
  const el = getContainerEl()
  if (!el) { return }
  const images = getContentImages(el)
  if (index < 0 || index >= images.length) { return }
  const img = images[index]
  const containerRect = el.getBoundingClientRect()
  const imgRect = img.getBoundingClientRect()
  const imgTopInContent = el.scrollTop + (imgRect.top - containerRect.top)
  const targetScroll = imgTopInContent - el.clientHeight / 2 + imgRect.height / 2
  el.scrollTo({ top: Math.max(0, targetScroll), behavior: 'smooth' })
}

function onTrackClick(evt) {
  if (!trackRef.value) { return }
  const trackRect = trackRef.value.getBoundingClientRect()
  const clickY = evt.clientY - trackRect.top
  const rects = thumbRects.value
  const idx = rects.findIndex((rect) => clickY >= rect.top && clickY < rect.top + rect.height)
  if (idx >= 0) { scrollToImage(idx) }
}

let scrollListener = null
let resizeObserver = null
let trackResizeObserver = null
let observedEl = null
let observedTrackEl = null

function attachScroll() {
  const el = getContainerEl()
  if (!el) { return }
  updateCenteredIndex()
  scrollListener = () => updateCenteredIndex()
  el.addEventListener('scroll', scrollListener)
  resizeObserver = new ResizeObserver(() => {
    updateCenteredIndex()
    nextTick(measureThumbs)
  })
  resizeObserver.observe(el)
  observedEl = el
}

function attachTrackObserver() {
  const track = trackRef.value
  if (!track) { return }
  if (observedTrackEl && trackResizeObserver) {
    trackResizeObserver.unobserve(observedTrackEl)
  }
  trackResizeObserver = new ResizeObserver(() => measureThumbs())
  trackResizeObserver.observe(track)
  observedTrackEl = track
}

function detachScroll() {
  if (observedEl && scrollListener) {
    observedEl.removeEventListener('scroll', scrollListener)
  }
  if (resizeObserver && observedEl) {
    resizeObserver.unobserve(observedEl)
  }
  resizeObserver = null
  observedEl = null
  if (trackResizeObserver && observedTrackEl) {
    trackResizeObserver.unobserve(observedTrackEl)
  }
  trackResizeObserver = null
  observedTrackEl = null
}

watch(
  () => getContainerEl(),
  (el) => {
    detachScroll()
    if (el) { attachScroll() }
  },
  { immediate: true, flush: 'post' }
)

watch(trackRef, (track) => {
  if (track) {
    nextTick(() => {
      measureThumbs()
      attachTrackObserver()
    })
  }
}, { flush: 'post' })

onMounted(() => {
  attachScroll()
  nextTick(measureThumbs)
})

onUnmounted(() => {
  detachScroll()
})
</script>

<template>
  <div class="scroll-preview">
    <div
      ref="trackRef"
      class="scroll-preview__track"
      @click="onTrackClick"
    >
      <div class="scroll-preview__thumbnails">
        <img
          v-for="(url, index) in imageUrls"
          :key="index"
          :src="url"
          class="scroll-preview__thumb"
          loading="lazy"
        />
      </div>
      <div
        v-if="viewportStyle"
        class="scroll-preview__viewport"
        :style="viewportStyle"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.scroll-preview {
  width: 100%;

  &__track {
    position: relative;
    width: 100%;
    min-height: 120px;
    overflow: hidden;
    cursor: pointer;
    overflow: visible;
  }

  &__thumbnails {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
    margin-left: 9px; /* (VIEWPORT_WIDTH - IMAGE_MAX_WIDTH) / 2 pour centrer dans le carré */
    pointer-events: none;
  }

  &__thumb {
    max-width: 65px;
    width: auto;
    height: auto;
    flex-shrink: 0;
    opacity: 0.85;
  }

  &__viewport {
    position: absolute;
    box-sizing: border-box;
    border: 1px solid #00000020;
    border-radius: 2px;
    pointer-events: none;
  }
}
</style>
