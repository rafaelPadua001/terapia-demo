<script setup>
defineProps({
  conversations: { type: Array, default: () => [] },
  selectedUserId: { type: String, default: "" },
  loading: { type: Boolean, default: false },
});

const emit = defineEmits(["select"]);

const roleLabel = (role) => {
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
};
</script>

<template>
  <div class="chat-list">
    <div class="chat-list__header">
      <div>
        <div class="text-subtitle-1 font-weight-bold">Online agora</div>
        <div class="text-caption text-medium-emphasis">Usuarios disponiveis para conversa.</div>
      </div>
      <v-progress-circular v-if="loading" indeterminate size="18" width="2" color="primary" />
    </div>

    <div v-if="!conversations.length" class="chat-list__empty">
      Nenhum usuario visivel no momento.
    </div>

    <v-list v-else lines="two" bg-color="transparent" class="py-0 chat-list__list">
      <v-list-item
        v-for="conversation in conversations"
        :key="conversation.user.id"
        rounded="xl"
        :active="selectedUserId === conversation.user.id"
        color="primary"
        :class="{ 'chat-user--unread': conversation.unread > 0 }"
        @click="emit('select', conversation.user)"
      >
        <template #prepend>
          <v-badge dot floating :color="conversation.isOnline ? 'success' : 'grey-lighten-1'">
            <v-avatar color="#eef2f7" size="42" class="chat-user-avatar">
              <i class="fa-solid fa-user"></i>
            </v-avatar>
          </v-badge>
        </template>
        <v-list-item-title>{{ conversation.user.name }}</v-list-item-title>
        <v-list-item-subtitle class="chat-user-role">{{ roleLabel(conversation.user.role) }}</v-list-item-subtitle>
        <v-list-item-subtitle class="chat-last-message">{{ conversation.lastMessage || "Sem mensagens" }}</v-list-item-subtitle>

        <template #append>
          <v-chip v-if="conversation.unread > 0" size="x-small" color="primary" class="chat-unread-badge">
            {{ conversation.unread }}
          </v-chip>
        </template>
      </v-list-item>
    </v-list>
  </div>
</template>

<style scoped>
.chat-list {
  min-width: 250px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chat-list__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.chat-list__empty {
  min-height: 120px;
  display: grid;
  place-items: center;
  border-radius: 20px;
  border: 1px dashed rgba(148, 163, 184, 0.22);
  color: #64748b;
  background: #f8fafc;
  padding: 20px;
  text-align: center;
}

.chat-list__list {
  max-height: 100%;
  overflow-y: auto;
  scroll-behavior: smooth;
}

.chat-user-avatar {
  color: #334155;
}

.chat-list :deep(.v-list-item) {
  margin-bottom: 8px;
  border-radius: 18px;
}

.chat-list :deep(.v-list-item:hover) {
  background: rgba(37, 99, 235, 0.06);
}

.chat-list :deep(.v-list-item--active) {
  background: rgba(37, 99, 235, 0.08);
}

.chat-user-role {
  color: #64748b;
  font-size: 12px;
}

.chat-last-message {
  max-width: 170px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 11px;
  color: #475569;
}

.chat-user--unread :deep(.v-list-item-title) {
  font-weight: 700;
}

.chat-user--unread {
  background: #eef2ff !important;
}

.chat-unread-badge {
  min-width: 22px;
  justify-content: center;
}
</style>
