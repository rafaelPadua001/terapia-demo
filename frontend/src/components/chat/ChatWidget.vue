<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import { useAuthStore } from "../../store/auth";
import { connectChatSocket, disconnectChatSocket, getChatSocket } from "../../services/chatSocket";
import ChatList from "./ChatList.vue";
import ChatWindow from "./ChatWindow.vue";

const auth = useAuthStore();
const opened = ref(false);
const connected = ref(false);
const selectedUserId = ref("");
const typingUserId = ref("");
const onlineUsers = ref([]);
const conversations = reactive({});

const currentUser = computed(() => ({
  id: auth.userId,
  role: auth.role,
  tenantId: auth.clinicId,
  name: String(auth.user?.name || auth.user?.email || "").trim() || "Sem nome",
}));

const selectedConversation = computed(() => conversations[selectedUserId.value] || null);
const selectedUser = computed(() => selectedConversation.value?.user || null);
const currentMessages = computed(() => selectedConversation.value?.messages || []);
const conversationItems = computed(() =>
  Object.values(conversations).sort((a, b) => new Date(b.lastMessageAt || 0) - new Date(a.lastMessageAt || 0)),
);
const unreadCount = computed(() =>
  Object.values(conversations).reduce((total, conversation) => total + (conversation.unread || 0), 0),
);

function normalizeRoleLabel(role) {
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

function ensureConversation(userData) {
  const userId = String(userData.id);
  if (!conversations[userId]) {
    conversations[userId] = {
      user: {
        id: userId,
        name: userData.name || "Sem nome",
        role: userData.role || "",
        roleLabel: normalizeRoleLabel(userData.role),
      },
      messages: [],
      unread: 0,
      lastMessage: "",
      lastMessageAt: null,
      isOnline: true,
    };
  } else {
    conversations[userId].user = {
      ...conversations[userId].user,
      name: userData.name || conversations[userId].user.name || "Sem nome",
      role: userData.role || conversations[userId].user.role || "",
      roleLabel: normalizeRoleLabel(userData.role || conversations[userId].user.role),
    };
    conversations[userId].isOnline = true;
  }
  return conversations[userId];
}

function markRead(message) {
  if (!message || !selectedUser.value || String(message.from) === String(currentUser.value.id) || message.readAt) return;
  message.readAt = new Date().toISOString();
  getChatSocket().emit("message:read", {
    messageId: message.id,
    to: selectedUser.value.id,
  });
}

function markConversationAsRead() {
  currentMessages.value.forEach((message) => markRead(message));
  if (selectedConversation.value) {
    selectedConversation.value.unread = 0;
  }
}

function handleUsers(users) {
  onlineUsers.value = (users || []).map((user) => {
    const rawName = String(user?.name || "").trim();
    const sanitizedName = rawName && !rawName.toLowerCase().startsWith("id:") ? rawName : "Sem nome";
    return { ...user, name: sanitizedName };
  });

  Object.values(conversations).forEach((conversation) => {
    conversation.isOnline = false;
  });

  onlineUsers.value.forEach((user) => {
    ensureConversation(user);
  });

  if (!selectedUserId.value && conversationItems.value.length) {
    selectedUserId.value = conversationItems.value[0].user.id;
  }
}

function handleIncomingMessage(message) {
  const fromUser = typeof message.from === "object"
    ? message.from
    : { id: String(message.from), name: message.fromName || "Sem nome", role: "" };
  const conversation = ensureConversation(fromUser);
  const normalizedMessage = {
    ...message,
    from: String(fromUser.id),
    fromUser,
  };
  conversation.messages.push(normalizedMessage);
  conversation.lastMessage = normalizedMessage.message;
  conversation.lastMessageAt = normalizedMessage.timestamp;
  if (opened.value && selectedUserId.value === String(fromUser.id)) {
    markRead(normalizedMessage);
  } else {
    conversation.unread += 1;
  }
}

function updateMessageStatus(messageId, status) {
  Object.values(conversations).forEach((conversation) => {
    const target = conversation.messages.find((item) => item.id === messageId);
    if (target) {
      target.status = status;
      if (status === "read") {
        target.readAt = new Date().toISOString();
      }
    }
  });
}

function bindSocketEvents() {
  const socket = getChatSocket();
  socket.off("connect");
  socket.off("disconnect");
  socket.off("users:online");
  socket.off("message:receive");
  socket.off("message:status");
  socket.off("message:read");
  socket.off("typing");
  socket.off("typing:stop");
  socket.off("chat:error");

  socket.on("connect", () => {
    connected.value = true;
  });

  socket.on("disconnect", () => {
    connected.value = false;
    typingUserId.value = "";
  });

  socket.on("users:online", handleUsers);
  socket.on("message:receive", handleIncomingMessage);
  socket.on("message:status", ({ id, status }) => updateMessageStatus(id, status));
  socket.on("message:read", ({ messageId }) => updateMessageStatus(messageId, "read"));
  socket.on("typing", ({ from }) => {
    typingUserId.value = String(from);
  });
  socket.on("typing:stop", ({ from }) => {
    if (!from || typingUserId.value === String(from)) {
      typingUserId.value = "";
    }
  });
}

function connect() {
  if (!currentUser.value.id || !currentUser.value.tenantId) return;
  bindSocketEvents();
  connectChatSocket();
}

function toggleWidget() {
  opened.value = !opened.value;
  if (opened.value) {
    markConversationAsRead();
  }
}

function selectUser(user) {
  selectedUserId.value = String(user.id);
  const conversation = conversations[selectedUserId.value];
  if (conversation) {
    conversation.unread = 0;
  }
  markConversationAsRead();
}

function sendMessage(text) {
  if (!selectedUser.value || !currentUser.value.id) return;
  const clientId = `local-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`;
  const conversation = ensureConversation(selectedUser.value);
  const localMessage = {
    id: clientId,
    message: text,
    from: currentUser.value.id,
    fromUser: {
      id: currentUser.value.id,
      name: currentUser.value.name,
      role: currentUser.value.role,
    },
    to: selectedUser.value.id,
    timestamp: new Date().toISOString(),
    status: "sent",
  };
  conversation.messages.push(localMessage);
  conversation.lastMessage = localMessage.message;
  conversation.lastMessageAt = localMessage.timestamp;
  getChatSocket().emit("message:send", {
    to: selectedUser.value.id,
    message: text,
    clientId,
  });
}

function startTyping() {
  if (!selectedUser.value) return;
  getChatSocket().emit("typing:start", { to: selectedUser.value.id });
}

function stopTyping() {
  if (!selectedUser.value) return;
  getChatSocket().emit("typing:stop", { to: selectedUser.value.id });
}

watch(
  () => auth.token,
  () => {
    if (auth.token && auth.userId && auth.clinicId) {
      connect();
    } else {
      disconnectChatSocket();
      connected.value = false;
    }
  },
  { immediate: true },
);

watch(
  () => [auth.user?.name, auth.user?.email, auth.role, auth.userId, auth.clinicId],
  () => {
    if (auth.token && auth.userId && auth.clinicId) {
      // Re-emite o perfil quando nome/email chegam do /users/me para evitar "Sem nome" preso na sessao.
      connectChatSocket();
    }
  },
);

watch(selectedUserId, () => {
  typingUserId.value = "";
  markConversationAsRead();
});

onMounted(connect);
onBeforeUnmount(disconnectChatSocket);
</script>

<template>
  <div v-if="auth.token && auth.userId" class="chat-widget">
    <transition name="chat-pop">
      <div v-if="opened" class="chat-widget__panel">
        <div class="chat-widget__toolbar">
          <div class="chat-widget__brand">
            <div class="chat-widget__avatar">
              <i class="fa-solid fa-comments"></i>
            </div>
            <div>
              <div class="chat-widget__title">Chat interno</div>
              <div class="chat-widget__status" :class="connected ? 'is-online' : 'is-offline'">
                <span class="chat-widget__status-dot"></span>
                {{ connected ? "Conectado" : "Reconectando..." }}
              </div>
            </div>
          </div>
          <button class="chat-widget__close" type="button" @click="opened = false">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>

        <div class="chat-widget__body">
          <ChatList
            :conversations="conversationItems"
            :selected-user-id="selectedUserId"
            :loading="!connected"
            @select="selectUser"
          />
          <ChatWindow
            :current-user-id="currentUser.id"
            :selected-user="selectedUser"
            :messages="currentMessages"
            :typing-user-id="typingUserId"
            @send="sendMessage"
            @typing-start="startTyping"
            @typing-stop="stopTyping"
            @mark-read="markRead"
          />
        </div>
      </div>
    </transition>

    <button class="chat-widget__fab" type="button" @click="toggleWidget">
      <span class="chat-widget__badge" v-if="unreadCount">{{ unreadCount }}</span>
      <i class="fa-solid fa-comment-dots"></i>
    </button>
  </div>
</template>

<style scoped>
.chat-widget {
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 1200;
}

.chat-widget__panel {
  width: min(92vw, 760px);
  height: min(76vh, 620px);
  margin-bottom: 18px;
  padding: 18px;
  border-radius: 28px;
  background: #ffffff;
  color: #0f172a;
  border: 1px solid rgba(148, 163, 184, 0.24);
  box-shadow: 0 28px 70px rgba(15, 23, 42, 0.16);
  display: flex;
  flex-direction: column;
  gap: 16px;
  position: relative;
  overflow: hidden;
}

.chat-widget__panel::before {
  content: "";
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at top right, rgba(37, 99, 235, 0.08), transparent 22%),
    radial-gradient(circle at bottom left, rgba(16, 185, 129, 0.06), transparent 18%);
  pointer-events: none;
}

.chat-widget__toolbar,
.chat-widget__body {
  position: relative;
  z-index: 1;
}

.chat-widget__toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.14);
}

.chat-widget__brand {
  display: flex;
  align-items: center;
  gap: 12px;
}

.chat-widget__avatar {
  width: 44px;
  height: 44px;
  border-radius: 999px;
  display: grid;
  place-items: center;
  color: #fff;
  background: linear-gradient(135deg, #25d366, #128c7e);
  box-shadow: 0 10px 24px rgba(18, 140, 126, 0.18);
}

.chat-widget__title {
  font-weight: 800;
  color: #0f172a;
}

.chat-widget__status {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
}

.chat-widget__status-dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: currentColor;
}

.chat-widget__status.is-online {
  color: #16a34a;
}

.chat-widget__status.is-offline {
  color: #f59e0b;
}

.chat-widget__close {
  width: 38px;
  height: 38px;
  border: 0;
  border-radius: 999px;
  background: #eff6ff;
  color: #0f172a;
  display: grid;
  place-items: center;
  cursor: pointer;
}

.chat-widget__body {
  min-height: 0;
  flex: 1;
  display: flex;
  gap: 18px;
}

.chat-widget__fab {
  min-width: 64px;
  min-height: 64px;
  border: 0;
  border-radius: 999px;
  color: #ffffff;
  background: linear-gradient(135deg, #25d366, #128c7e);
  box-shadow: 0 18px 32px rgba(18, 140, 126, 0.28);
  position: relative;
}

.chat-widget__fab i,
.chat-widget__close i {
  font-size: 18px;
}

.chat-widget__badge {
  position: absolute;
  top: -6px;
  right: -4px;
  min-width: 22px;
  height: 22px;
  border-radius: 999px;
  background: #ef4444;
  color: #fff;
  display: grid;
  place-items: center;
  font-size: 11px;
  font-weight: 700;
  padding: 0 6px;
  box-shadow: 0 8px 18px rgba(239, 68, 68, 0.28);
}

.chat-pop-enter-active,
.chat-pop-leave-active {
  transition: all 0.25s ease;
}

.chat-pop-enter-from,
.chat-pop-leave-to {
  opacity: 0;
  transform: translateY(18px) scale(0.98);
}

.chat-overlay-enter-active,
.chat-overlay-leave-active {
  transition: opacity 0.22s ease;
}

.chat-overlay-enter-from,
.chat-overlay-leave-to {
  opacity: 0;
}

@media (max-width: 780px) {
  .chat-widget {
    inset: 0;
  }

  .chat-widget__panel {
    width: 100%;
    height: 100vh;
    margin: 0;
    border-radius: 0;
    padding: 14px;
  }

  .chat-widget__body {
    flex-direction: column;
  }

  .chat-widget__fab {
    right: 16px;
    bottom: 16px;
    position: fixed;
  }
}
</style>
