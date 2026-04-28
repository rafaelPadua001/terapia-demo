import api from "./api";

export const forgotPassword = (email) => api.post("/auth/forgot-password", { email });
export const validateResetToken = (token) => api.get("/auth/validate-reset-token", { params: { token } });
export const resetPassword = (token, newPassword) => api.post("/auth/reset-password", { token, new_password: newPassword });
export const changePassword = (newPassword) => api.post("/auth/change-password", { new_password: newPassword });
export const completeTutorial = () => api.post("/auth/tutorial-complete");
