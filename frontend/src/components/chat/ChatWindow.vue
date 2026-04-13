<script setup>
import { computed } from "vue";
import ChatInput from "./ChatInput.vue";

const props = defineProps({
  currentUserId: { type: [String, Number], default: "" },
  selectedUser: { type: Object, default: null },
  messages: { type: Array, default: () => [] },
  typingUserId: { type: String, default: "" },
});

const emit = defineEmits(["send", "typing-start", "typing-stop", "mark-read"]);

const orderedMessages = computed(() =>
  [...props.messages].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp)),
);

function isMine(message) {
  const fromId = typeof message.from === "object" ? message.from.id : message.from;
  return String(fromId) === String(props.currentUserId);
}

function statusIcon(message) {
  if (message.status === "read") return "fa-solid fa-check-double";
  if (message.status === "delivered") return "fa-solid fa-check-double";
  return "fa-solid fa-check";
}

function formatTime(timestamp) {
  return new Intl.DateTimeFormat("pt-BR", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(timestamp));
}

function roleLabel(role) {
  const labels = {
    admin: "Administrador",
    therapist: "Terapeuta",
    terapeuta: "Terapeuta",
    receptionist: "Recepcao",
    reception: "Recepcao",
    patient: "Paciente",
    guardian: "Responsavel",
  };
  return labels[String(role || "").toLowerCase()] || String(role || "");
}
</script>

<template>
  <div class="chat-window">
    <div v-if="selectedUser" class="chat-window__header">
      <div class="chat-window__contact">
        <v-avatar size="40" class="chat-window__avatar">
          <i class="fa-solid fa-user"></i>
        </v-avatar>
        <div>
          <div class="chat-window__name">{{ selectedUser.name }}</div>
          <div class="chat-window__meta">
            <span class="chat-window__online-dot"></span>
            <span v-if="typingUserId === selectedUser.id" class="chat-window__typing">digitando...</span>
            <span v-else>{{ roleLabel(selectedUser.role) }}</span>
          </div>
        </div>
      </div>
      <v-chip size="small" variant="flat" class="chat-online-chip">online</v-chip>
    </div>

    <div v-else class="chat-window__placeholder">
      Selecione um usuario online para iniciar a conversa.
    </div>

    <div v-if="selectedUser" class="chat-window__messages">
      <div
        v-for="message in orderedMessages"
        :key="message.id"
        class="chat-bubble"
        :class="{ 'chat-bubble--mine': isMine(message) }"
        @mouseenter="!isMine(message) && emit('mark-read', message)"
      >
        <div v-if="!isMine(message)" class="chat-bubble__sender">
          {{ message.fromUser?.name || selectedUser.name }}
          <small>{{ roleLabel(message.fromUser?.role || selectedUser.role) }}</small>
        </div>
        <div class="chat-bubble__text">{{ message.message }}</div>
        <div class="chat-bubble__meta">
          <span>{{ formatTime(message.timestamp) }}</span>
          <i v-if="isMine(message)" :class="statusIcon(message)"></i>
        </div>
      </div>
    </div>

    <ChatInput
      :disabled="!selectedUser"
      @send="emit('send', $event)"
      @typing-start="emit('typing-start')"
      @typing-stop="emit('typing-stop')"
    />
  </div>
</template>

<style scoped>
.chat-window {
  min-width: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.chat-window__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 14px 16px;
  border-radius: 20px;
  background: #f8fafc;
  border: 1px solid rgba(148, 163, 184, 0.22);
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.05);
}

.chat-window__contact {
  display: flex;
  align-items: center;
  gap: 12px;
}

.chat-window__avatar {
  color: #0f172a;
  background: #e2e8f0;
}

.chat-window__name {
  font-weight: 800;
  color: #0f172a;
}

.chat-window__meta {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #64748b;
  font-size: 12px;
}

.chat-window__placeholder {
  min-height: 160px;
  display: grid;
  place-items: center;
  text-align: center;
  color: #64748b;
  border: 1px dashed rgba(148, 163, 184, 0.22);
  background: #f8fafc;
  border-radius: 20px;
  padding: 20px;
}

.chat-window__messages {
  flex: 1;
  min-height: 280px;
  max-height: 360px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 12px 4px 4px;
  scroll-behavior: smooth;
}

.chat-bubble {
  max-width: 78%;
  align-self: flex-start;
  background: #eef2f7;
  color: #1f2937;
  border-radius: 18px 18px 18px 6px;
  padding: 12px 14px 10px;
  box-shadow: 0 12px 24px rgba(15, 23, 42, 0.08);
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.chat-bubble--mine {
  align-self: flex-end;
  background: linear-gradient(135deg, #dbeafe, #bfdbfe);
  color: #0f172a;
  border-radius: 18px 18px 6px 18px;
}

.chat-bubble__text {
  flex: 1;
  white-space: pre-wrap;
  word-break: break-word;
}

.chat-bubble__sender {
  font-size: 11px;
  color: #475569;
  font-weight: 600;
  margin-bottom: 4px;
}

.chat-bubble__sender small {
  margin-left: 8px;
  font-weight: 500;
}

.chat-bubble__meta {
  margin-top: 6px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
  font-size: 12px;
  opacity: 0.8;
}

.chat-online-chip {
  color: #0f172a;
  background: #e2e8f0;
  border: 1px solid rgba(148, 163, 184, 0.24);
  text-transform: lowercase;
}

.chat-window__online-dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: #22c55e;
  box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.14);
}

.chat-window__typing {
  font-weight: 500;
}
</style>
