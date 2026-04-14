export const notifyPaymentCreated = (transaction) => {
  const patientName = transaction?.patient?.name || transaction?.patient_name || "Paciente";

  return {
    message: `Cobrança criada com sucesso para ${patientName}`,
    payload: {
      patient_phone: transaction?.patient?.phone || transaction?.patient_phone || "",
      message: `Olá! Sua cobrança de ${transaction?.amount ?? ""} foi registrada.`,
    },
  };
};
