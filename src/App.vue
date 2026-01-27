<script setup>
</script>

<template>
  <div id="app">
    <nav class="app-nav">
      <router-link to="/">
        Accueil
      </router-link>
      <router-link to="/about">
        À propos
      </router-link>
      <router-link to="/projects">
        Projets
      </router-link>
    </nav>
    <main>
      <router-view />
    </main>
  </div>
</template>

<style scoped>
#app {
  min-height: 100vh;
}
.app-nav {
  display: flex;
  gap: 1.5rem;
  padding: 1rem 2rem;
  background: #1a1a1a;
  border-bottom: 1px solid #333;
}
.app-nav a {
  color: #eee;
  text-decoration: none;
}
.app-nav a:hover,
.app-nav a.router-link-active {
  color: #42b883;
}
main {
  padding: 2rem;
}
</style>
