export const isRestrictedUser = (user) => ["patient", "guardian"].includes(user?.role);
