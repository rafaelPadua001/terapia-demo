const http = require("http");
const fs = require("fs");
const path = require("path");
const dotenv = require("dotenv");
const { Server } = require("socket.io");

const envPath = path.resolve(__dirname, ".env");
if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
}

const port = Number(process.env.CHAT_PORT || 8101);

const allowedOrigins = (
  process.env.CHAT_CORS_ORIGIN ||
  "https://terapia-demo-1.onrender.com,http://localhost:5173"
)
  .split(",")
  .map((item) => item.trim())
  .filter(Boolean);

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok" }));
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Not Found" }));
});

const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    credentials: true,
  },
});

const onlineUsers = new Map();

function normalizeRole(role) {
  return String(role || "").trim().toLowerCase();
}

function createUserSnapshot(user) {
  const normalizedId = String(user.id);
  const normalizedName = String(user.name || user.email || "").trim();
  return {
    id: normalizedId,
    role: normalizeRole(user.role),
    tenantId: user.tenantId ? String(user.tenantId) : "",
    name: normalizedName || "Sem nome",
  };
}

function canSeeUser(viewerRole, targetRole) {
  const privileged = ["admin", "therapist", "terapeuta", "reception", "receptionist"];
  if (privileged.includes(normalizeRole(viewerRole))) {
    return true;
  }
  return ["reception", "receptionist"].includes(normalizeRole(targetRole));
}

function getVisibleUsers(viewer) {
  return Array.from(onlineUsers.values())
    .map((entry) => entry.user)
    .filter((candidate) => candidate.id !== viewer.id)
    .filter((candidate) => candidate.tenantId === viewer.tenantId)
    .filter((candidate) => canSeeUser(viewer.role, candidate.role));
}

function emitOnlineUsers() {
  onlineUsers.forEach((entry) => {
    const visibleUsers = getVisibleUsers(entry.user);
    entry.socketIds.forEach((socketId) => {
      io.to(socketId).emit("users:online", visibleUsers);
    });
  });
}

function registerSocket(user, socketId) {
  const snapshot = createUserSnapshot(user);
  const current = onlineUsers.get(snapshot.id) || {
    user: snapshot,
    socketIds: new Set(),
  };

  current.user = snapshot;
  current.socketIds.add(socketId);
  onlineUsers.set(snapshot.id, current);
}

function unregisterSocket(userId, socketId) {
  const current = onlineUsers.get(userId);
  if (!current) return;
  current.socketIds.delete(socketId);
  if (current.socketIds.size === 0) {
    onlineUsers.delete(userId);
  }
}

function emitToUser(userId, eventName, payload) {
  const target = onlineUsers.get(String(userId));
  if (!target) return;
  target.socketIds.forEach((socketId) => io.to(socketId).emit(eventName, payload));
}

io.on("connection", (socket) => {
  socket.on("user:connect", (user) => {
    if (!user?.id || !user?.role || !user?.tenantId) {
      socket.emit("chat:error", {
        error: "INVALID_USER",
        message: "Usuario invalido para o chat.",
      });
      return;
    }

    socket.user = createUserSnapshot(user);
    registerSocket(socket.user, socket.id);
    socket.emit("chat:ready", { user: socket.user, socketId: socket.id });
    emitOnlineUsers();
  });

  socket.on("message:send", ({ to, message, clientId }) => {
    if (!socket.user || !to || !String(message || "").trim()) return;

    const payload = {
      id: clientId || `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      message: String(message).trim(),
      from: {
        id: socket.user.id,
        name: socket.user.name,
        role: socket.user.role,
      },
      to: String(to),
      timestamp: new Date().toISOString(),
      status: "sent",
    };

    const target = onlineUsers.get(String(to));
    if (target && target.user.tenantId === socket.user.tenantId && canSeeUser(socket.user.role, target.user.role)) {
      emitToUser(payload.to, "message:receive", payload);
      socket.emit("message:status", { id: payload.id, status: "delivered" });
    } else {
      socket.emit("message:status", { id: payload.id, status: "sent" });
    }
  });

  socket.on("message:read", ({ messageId, to }) => {
    if (!socket.user || !messageId || !to) return;
    emitToUser(String(to), "message:read", {
      messageId,
      readBy: socket.user.id,
      timestamp: new Date().toISOString(),
    });
  });

  socket.on("typing:start", ({ to }) => {
    if (!socket.user || !to) return;
    emitToUser(String(to), "typing", { from: socket.user.id, fromName: socket.user.name });
  });

  socket.on("typing:stop", ({ to }) => {
    if (!socket.user || !to) return;
    emitToUser(String(to), "typing:stop", { from: socket.user.id });
  });

  socket.on("disconnect", () => {
    if (socket.user) {
      unregisterSocket(socket.user.id, socket.id);
      emitOnlineUsers();
    }
  });
});

server.on("error", (error) => {
  if (error?.code === "EADDRINUSE") {
    console.error(`[chat] porta ${port} em uso. Ajuste CHAT_PORT para outra porta.`);
    return;
  }

  console.error("[chat] erro inesperado no servidor realtime:", error);
});

server.listen(port, () => {
  console.log(`[chat] realtime server running on http://127.0.0.1:${port}`);
});
