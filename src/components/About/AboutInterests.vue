<script setup>
import interests from '../../store/interests.json'

const focused = ref(null)
const interestsTitle = Object.keys(interests)
const currentCol = ref('00')

function colEnter(col) {
  currentCol.value = `0${col}`
  focused.value = interests[interestsTitle[col - 1]]
}
</script>

<template>
  <div class="grid-container">
    <div
      v-for="column in 8"
      :key="column"
      class="col"
      @mouseenter="colEnter(column)"
      @mouseleave="[(focused = null), (currentCol = '00')]"
    />

    <div
      v-for="(entry, index) in Object.entries(interests)"
      :key="entry[0]"
      class="interest-container"
      @mouseenter="colEnter(index + 1)"
      @mouseleave="[(focused = null), (currentCol = '00')]"
    >
      <div class="img-container">
        <img
          :src="`/images/interests/${entry[1].image}.jpg`"
        />
      </div>
      <span :class="{ 'is-visible': focused?.title === entry[1].title }">{{ entry[1].title }}</span>
    </div>

    <div
      v-for="column in 8"
      :key="column"
      class="col"
      @mouseenter="colEnter(column)"
      @mouseleave="[(focused = null), (currentCol = '00')]"
    />
  </div>
</template>

<style lang="scss" scoped>
.page-title,
.interest-num {
  height: 105px;
  display: flex;
  align-items: center;
}

.grid-container {
  display: grid;
  grid-template-columns: repeat(8, minmax(0, 1fr));
  grid-template-rows: 1fr auto 1fr;
  gap: 8px;
  width: 70vw;
  padding-left: 24px;
  padding-right: 24px;
  height: -webkit-fill-available;
  min-height: 0;
  overflow: auto;

  .col {
    height: 100%;
    min-height: 0;
  }

  @media (max-width: 768px) {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: safe center;
    gap: 1.5rem;
    width: 100%;
    max-width: 100%;
    padding-left: 0;
    padding-right: 0;
    height: auto;
    min-height: 0;
    max-height: calc(100dvh - 10rem);
    overflow-y: auto;
    overflow-x: hidden;
    -webkit-overflow-scrolling: touch;

    .col {
      display: none;
    }
  }
}

.interest-container {
  display: flex;
  flex-direction: column;
  width: 100%;
  min-width: 0;

  @media (max-width: 768px) {
    width: auto;
    max-width: 100%;
    align-items: center;
    flex-shrink: 0;
  }

  .img-container {
    width: 100%;
    aspect-ratio: 1;
    flex-shrink: 0;
    outline: #ffffff40 1px solid;
    overflow: hidden;

    @media (max-width: 768px) {
      width: 160px;
      height: 160px;
      aspect-ratio: unset;
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: opacity 0.15s ease;
    }
  }

  span {
    display: block;
    width: 100%;
    min-height: 1.5em;
    margin-top: 6px;
    opacity: 0;
    transition: opacity 0.15s ease;

    &.is-visible {
      opacity: 1;
    }

    @media (max-width: 768px) {
      opacity: 1;
      width: 100%;
      max-width: 160px;
      text-align: left;
    }
  }
}
</style>