import api from "./api";

const listByPatient = async (patientId) => {
  const { data } = await api.get("/guardians", { params: { patient_id: patientId } });
  return data;
};

const listAll = async () => {
  const { data } = await api.get("/guardians");
  return data;
};

const create = async (payload) => {
  const { data } = await api.post("/guardians", payload);
  return data;
};

const update = async (id, payload) => {
  const { data } = await api.put(`/guardians/${id}`, payload);
  return data;
};

const remove = async (id) => {
  await api.delete(`/guardians/${id}`);
};

export default {
  listAll,
  listByPatient,
  create,
  update,
  delete: remove
};
