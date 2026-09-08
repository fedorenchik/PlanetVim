<script setup>
import { ref } from 'vue'

defineProps({ msg: { type: String, default: 'PlanetVim Vue App' } })
const count = ref(0)
</script>

<template>
  <section>
    <h1>{{ msg }}</h1>
    <button type="button" @click="count++">Clicked {{ count }} times</button>
    <p>Edit <code>src/components/HelloWorld.vue</code> to get started.</p>
    <p>
      <a href="https://vuejs.org/guide/" target="_blank" rel="noopener">Vue guide</a>
      · <a href="https://vite.dev/guide/" target="_blank" rel="noopener">Vite guide</a>
    </p>
  </section>
</template>

<style scoped>
button { padding: 0.6rem 1rem; cursor: pointer; }
a { color: #287f5a; }
</style>
