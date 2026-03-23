<script setup>
import experiences from '../../store/experiences.json'
</script>

<template>
  <div class="experiences-container">
    <div
      v-for="(exp, index) in experiences"
      :key="index"
      class="experience-row"
    >
      <div class="experience-left">
        <div class="experience-left__title">{{ exp.title }}</div>
        <div class="experience-left__company">- {{ exp.company }}</div>
      </div>
      <div class="experience-dates opacity">
        <span class="experience-dates__start">
          <span class="experience-dates__bracket">[</span>{{ exp.start }}
        </span>
        <span class="experience-dates__end">
          → {{ exp.end }} <span class="experience-dates__bracket">]</span>
        </span>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.experiences-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.experience-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 6rem;
}

.experience-left {
  display: flex;
  flex-direction: column;

  &__title {
    font-family: "Geist";
    font-size: 1.35rem;
    font-weight: 400;
  }

  &__company {
    font-family: "Geist Mono";
    font-size: 0.88rem;
    text-transform: uppercase;
  }
}

.experience-dates {
  display: flex;
  flex-direction: column;
  text-align: right;
  font-family: "Geist";
  font-size: 0.88rem;

  &__bracket {
    margin-right: 1rem;

    &:last-child {
      margin: 0 0.2rem;
    }
  }

  &__start {
    width: fit-content;
  }

  &__end {
    width: fit-content;
    padding-left: 1.2rem;
  }
}
</style>