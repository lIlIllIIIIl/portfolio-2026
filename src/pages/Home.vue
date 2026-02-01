<script setup>
import { ref } from 'vue'
import WorkModale from '../components/Work/WorkModale.vue'
import works from '../store/works.json'

const selectedWork = ref(null)

function openWork(workItem) {
  selectedWork.value = workItem
}

function closeWork() {
  selectedWork.value = null
}
</script>

<template>
  <div class="view home">
    <div class="home__works">
      <button
        v-for="(workItem, key) in works"
        :key="key"
        type="button"
        class="home__work-btn"
        @click="openWork(workItem)"
      >
        {{ workItem.title }}
      </button>
    </div>
    <WorkModale
      v-if="selectedWork"
      :work="selectedWork"
      @close="closeWork"
    />
  </div>
</template>

<style scoped>
.view.home {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  /* padding: 2rem; */
}

.view {
  /* padding: 2rem; */
}

.home__works {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1rem;
}

.home__work-btn {
  padding: 0.5rem 1rem;
  cursor: pointer;
  background: transparent;
  border: 1px solid currentColor;
  color: inherit;
  font: inherit;
}

nav {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}
nav a {
  color: #42b883;
}
nav a.router-link-active {
  font-weight: bold;
  text-decoration: underline;
}
</style>
