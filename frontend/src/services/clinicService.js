import api from "./api";

export const getCurrentClinic = () => api.get("/clinics/current");
