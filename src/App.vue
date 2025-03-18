<template>
  <div id="app">
    <FlappyBird />
  </div>
</template>

<script>
import FlappyBird from './components/FlappyBird.vue'

export default {
  name: 'App',
  components: {
    FlappyBird
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f5f5f7;
  color: #1d1d1f;
  overflow: hidden;
}

#app {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 10px;
}
</style>
