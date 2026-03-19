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
    const payload = token ? parseJwt(token) : null;
    return {
      token,
      role: payload?.role || "",
      userId: payload?.sub || "",
      clinicId: payload?.clinic_id || "",
      user: null
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
    },
    logout() {
      this.token = "";
      this.role = "";
      this.userId = "";
      this.clinicId = "";
      this.user = null;
      localStorage.removeItem("token");
    }
  }
});
