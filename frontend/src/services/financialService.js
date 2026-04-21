import api from "./api";

const cleanParams = (params = {}) => {
  const normalized = { ...params };
  Object.keys(normalized).forEach((key) => {
    if (normalized[key] === "" || normalized[key] === null || normalized[key] === undefined) {
      delete normalized[key];
    }
  });
  return normalized;
};

export const getTransactions = (params = {}) => api.get("/financial/transactions", { params: cleanParams(params) });
export const createTransaction = (payload) => api.post("/financial/transactions", payload);
export const updateTransaction = (transactionId, payload) => api.patch(`/financial/transactions/${transactionId}`, payload);
export const payTransaction = (transactionId) => api.patch(`/financial/transactions/${transactionId}/pay`);
export const refundPayment = (transactionId) => api.post(`/financial/transactions/${transactionId}/refund`);
export const cancelPayment = (transactionId) => api.post(`/financial/transactions/${transactionId}/cancel`);
export const deleteTransaction = (transactionId) => api.delete(`/financial/transactions/${transactionId}`);
export const generatePayment = (transactionId) => api.post(`/financial/transactions/${transactionId}/generate-payment`);
export const getAccounts = (params = {}) => api.get("/financial/accounts", { params: cleanParams(params) });
export const createAccount = (payload) => api.post("/financial/accounts", payload);
export const updateAccount = (accountId, payload) => api.patch(`/financial/accounts/${accountId}`, payload);
export const deleteAccount = (accountId) => api.delete(`/financial/accounts/${accountId}`);
export const getMyTransactions = (params = {}) => api.get("/financial/my-transactions", { params: cleanParams(params) });
