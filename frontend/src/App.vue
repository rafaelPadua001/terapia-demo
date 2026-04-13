<script setup>
import ChatWidget from "./components/chat/ChatWidget.vue";
import { useUiStore } from "./store/ui";

const ui = useUiStore();
</script>

<template>
  <v-app class="app-shell">
    <router-view />

    <v-snackbar v-model="ui.snackbar.show" :color="ui.snackbar.color">
      {{ ui.snackbar.message }}
    </v-snackbar>

    <ChatWidget />
  </v-app>
</template>
