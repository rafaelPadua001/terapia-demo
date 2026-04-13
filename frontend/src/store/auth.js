import { defineStore } from "pinia";

import api from "../services/api";

const parseJwt = (token) => {
  try {
    const payload = token.split(".")[1];
    const base64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    return JSON.parse(atob(base64));
  } catch {
    return null;
  }
};

export const useAuthStore = defineStore("auth", {
  state: () => {
    const token = localStorage.getItem("token") || "";
    const persistedUserRaw = localStorage.getItem("auth_user");
    const persistedUser = persistedUserRaw ? JSON.parse(persistedUserRaw) : null;
    const payload = token ? parseJwt(token) : null;
    return {
      token,
      role: payload?.role || "",
      userId: payload?.sub || "",
      clinicId: payload?.clinic_id || "",
      user: persistedUser
    };
  },
  actions: {
    async login(email, password, role) {
      const { data } = await api.post("/auth/login", { email, password, role });
      this.token = data.access_token;
      localStorage.setItem("token", this.token);
      const payload = parseJwt(this.token) || {};
      this.role = payload.role || "";
      this.userId = payload.sub || "";
      this.clinicId = payload.clinic_id || "";
      await this.loadCurrentUser();
    },
    async loadCurrentUser() {
      if (!this.token) return;
      try {
        const { data } = await api.get("/users/me");
        this.user = data;
        localStorage.setItem("auth_user", JSON.stringify(data));
      } catch {
        this.user = null;
        localStorage.removeItem("auth_user");
      }
    },
    logout() {
      this.token = "";
      this.role = "";
      this.userId = "";
      this.clinicId = "";
      this.user = null;
      localStorage.removeItem("token");
      localStorage.removeItem("auth_user");
    }
  }
});
