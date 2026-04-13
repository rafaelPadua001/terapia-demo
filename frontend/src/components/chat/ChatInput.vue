<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  disabled: { type: Boolean, default: false },
});

const emit = defineEmits(["send", "typing-start", "typing-stop"]);

const text = ref("");
let typingTimer;

const canSend = computed(() => !props.disabled && text.value.trim().length > 0);

function handleInput() {
  if (props.disabled) return;
  emit("typing-start");
  window.clearTimeout(typingTimer);
  typingTimer = window.setTimeout(() => {
    emit("typing-stop");
  }, 1200);
}

function submit() {
  if (!canSend.value) return;
  emit("send", text.value.trim());
  text.value = "";
  emit("typing-stop");
}

watch(
  () => props.disabled,
  (disabled) => {
    if (disabled) {
      text.value = "";
      emit("typing-stop");
    }
  },
);
</script>

<template>
  <div class="chat-input">
    <v-textarea
      v-model="text"
      variant="solo-filled"
      density="comfortable"
      rows="1"
      auto-grow
      hide-details
      flat
      bg-color="#f8fafc"
      placeholder="Digite uma mensagem"
      :disabled="disabled"
      @update:model-value="handleInput"
      @keydown.enter.exact.prevent="submit"
    />
    <button class="chat-send-btn" type="button" :disabled="!canSend" @click="submit">
      <i class="fa-solid fa-paper-plane"></i>
    </button>
  </div>
</template>

<style scoped>
.chat-input {
  display: flex;
  align-items: flex-end;
  gap: 12px;
}

.chat-input :deep(textarea),
.chat-input :deep(input) {
  color: #111827;
}

.chat-send-btn {
  width: 52px;
  height: 52px;
  border: 0;
  border-radius: 999px;
  background: linear-gradient(135deg, #25d366, #128c7e);
  color: #fff;
  display: grid;
  place-items: center;
  box-shadow: 0 14px 24px rgba(18, 140, 126, 0.22);
  cursor: pointer;
  flex: 0 0 auto;
}

.chat-send-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  box-shadow: none;
}

.chat-send-btn i {
  font-size: 16px;
}
</style>
