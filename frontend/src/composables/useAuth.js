const resolveRole = (user) => {
  const role = user?.role || "";
  return role === "reception" ? "receptionist" : role;
};

export const isRestrictedUser = (user) => ["patient", "guardian"].includes(resolveRole(user));

export const canRemove = (userRole) => !["receptionist", "reception", "patient"].includes(userRole || "");

export const canValidateEvaluation = (userRole) => !["receptionist", "reception", "patient", "guardian"].includes(userRole || "");

export const canDeleteEvolution = (userRole) => !["receptionist", "reception", "patient", "guardian"].includes(userRole || "");
