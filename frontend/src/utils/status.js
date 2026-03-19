export const validationStatusMap = {
  approved: "Aprovado",
  rejected: "Rejeitado",
  pending: "Pendente"
};

export function getValidationStatusLabel(status) {
  return validationStatusMap[status] || status;
}

export function getStatusColor(status) {
  switch (status) {
    case "approved":
      return "green";
    case "rejected":
      return "red";
    case "pending":
      return "orange";
    default:
      return "grey";
  }
}
