<script setup>
defineProps({ name: { type: String, default: "PlanetVim" } })
</script>

<template><h1>Hello from {{ name }}</h1></template>

<style scoped>h1 { font-family: system-ui, sans-serif; }</style>
