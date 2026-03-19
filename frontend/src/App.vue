<template>
  <v-app class="app-shell">
    <router-view />
    <v-snackbar v-model="ui.snackbar.show" :color="ui.snackbar.color">
      {{ ui.snackbar.message }}
    </v-snackbar>
  </v-app>
</template>

<script setup>
import { useUiStore } from "./store/ui";

const ui = useUiStore();
</script>

