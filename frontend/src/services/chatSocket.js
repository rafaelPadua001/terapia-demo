import { io } from "socket.io-client";
import { useAuthStore } from "../store/auth";

const CHAT_URL = import.meta.env.VITE_CHAT_URL || "http://127.0.0.1:8100";

let socket;

function getSocket() {
  if (!socket) {
    socket = io(CHAT_URL, {
      autoConnect: false,
      transports: ["websocket", "polling"],
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 800,
    });
  }
  return socket;
}

export function connectChatSocket() {
  const auth = useAuthStore();
  const instance = getSocket();

  if (auth.token && auth.userId && auth.clinicId) {
    if (!instance.connected) {
      instance.connect();
    }

    const displayName = String(auth.user?.name || auth.user?.email || "").trim() || "Sem nome";

    instance.emit("user:connect", {
      id: auth.userId,
      role: auth.role,
      tenantId: auth.clinicId,
      name: displayName,
    });
  }

  return instance;
}

export function disconnectChatSocket() {
  if (socket?.connected) {
    socket.disconnect();
  }
}

export function getChatSocket() {
  return getSocket();
}
