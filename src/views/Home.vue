<script setup>
</script>

<template>
  <div class="view home">
    <h1>Accueil</h1>
    <p>Bienvenue sur mon portfolio.</p>
    <nav>
      <router-link to="/about">À propos</router-link>
      <router-link to="/projects">Projets</router-link>
    </nav>
  </div>
</template>

<style scoped>
.view {
  padding: 2rem;
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
