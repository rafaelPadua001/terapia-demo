import { defineStore } from "pinia";

export const useUiStore = defineStore("ui", {
  state: () => ({
    snackbar: { show: false, message: "", color: "success" }
  }),
  actions: {
    notify(message, color = "success") {
      this.snackbar = { show: true, message, color };
    },
    close() {
      this.snackbar.show = false;
    }
  }
});

