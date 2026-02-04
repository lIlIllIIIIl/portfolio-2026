<script setup>
import AboutInterests from '../components/About/AboutInterests.vue'
import AboutExperiences from '../components/About/AboutExperiences.vue'
import AboutContact from '../components/About/AboutContact.vue'

const activeAboutSection = inject('activeAboutSection')
const aboutScrollDirection = inject('aboutScrollDirection')
const containerRef = ref(null)
const sectionIds = ['intro', 'interests', 'experiences', 'contact']

let observer = null

onMounted(() => {
  const container = containerRef.value
  if (!container) {
    return
  }

  observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) {
          continue
        }
        const id = entry.target.id
        const index = sectionIds.indexOf(id)
        if (index !== -1 && index !== activeAboutSection.value) {
          aboutScrollDirection.value = index > activeAboutSection.value ? 'down' : 'up'
          activeAboutSection.value = index
        }
      }
    },
    {
      root: container,
      threshold: 0.5,
    }
  )

  sectionIds.forEach((id) => {
    const el = document.getElementById(id)
    if (el) {
      observer.observe(el)
    }
  })
})

onUnmounted(() => {
  observer?.disconnect()
})
</script>

<template>
  <div ref="containerRef" class="about-scroll-container">
    <section id="intro" class="about-section">
      <div>
        <p>I'm Alexis Kessab, a fullstack developer, currently looking for a job <span class="emoji">💻</span> after traveling around the world for 1 year. <span class="emoji">🎒</span></p>
        <p class="opacity">Available starting february 2026</p>
      </div>
    </section>

    <section id="interests" class="about-section">
      <AboutInterests />
    </section>

    <section id="experiences" class="about-section">
      <AboutExperiences />
    </section>

    <section id="contact" class="about-section">
      <AboutContact />
    </section>
  </div>
</template>

<style lang="scss" scoped>
.about-scroll-container {
  height: 100vh;
  overflow-y: scroll;
  overflow-x: hidden;
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
  scrollbar-width: none;
  -ms-overflow-style: none;
  padding-left: 12vw;
  padding-right: 12vw;
  box-sizing: border-box;
  &::-webkit-scrollbar {
    display: none;
  }
}

.about-section {
  height: 100vh;
  scroll-snap-align: start;
  scroll-snap-stop: always;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;

  p {
    max-width: 16rem;
  }
}
</style>
