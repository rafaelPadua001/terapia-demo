import api from "./api";

export const getNotifications = (limit = 20) => api.get("/financial/notifications", { params: { limit } });
export const markNotificationAsRead = (notificationId) => api.patch(`/financial/notifications/${notificationId}/read`);
