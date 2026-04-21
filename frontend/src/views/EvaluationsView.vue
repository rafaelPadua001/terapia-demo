<template>
  <MainLayout>
    <v-card title="Avaliações">
      <v-card-text>
        <template v-if="canModerateEvaluations">
          <v-tabs v-model="tab" bg-color="transparent" class="mb-4">
            <v-tab value="list">Lista</v-tab>
            <v-tab value="form">Cadastro</v-tab>
          </v-tabs>
          <v-window v-model="tab">
            <v-window-item value="list">
              <v-row>
                <v-col cols="12" md="6">
                  <v-text-field v-model="search" label="Buscar por tipo" @update:modelValue="load" />
                </v-col>
                <v-col cols="12" md="6">
                  <v-select
                    v-model="statusFilter"
                    :items="statusOptions"
                    label="Status"
                    clearable
                    @update:modelValue="load"
                  />
                </v-col>
              </v-row>

              <v-switch v-model="showDeleted" label="Exibir excluídos" @update:modelValue="load" />

              <v-data-table-server
                :headers="headers"
                :items="items"
                :items-length="total"
                :loading="loading"
                v-model:page="page"
                v-model:items-per-page="limit"
                @update:page="load"
                @update:items-per-page="load"
              >
                <template #item.patient="{ item }">
                  <span>{{ formatPatient(item.patient) }}</span>
                </template>
                <template #item.type="{ item }">
                  <span>{{ fixEncoding(item.type) }}</span>
                </template>
                <template #item.status="{ item }">
                  <StatusChip :status="item.status" />
                </template>
                <template #item.actions="{ item }">
                  <v-btn v-if="canModerateEvaluations" size="small" color="success" @click="validate(item.id, 'approved')">
                    <v-icon icon="fa-solid fa-circle-check" />
                    Aprovar
                  </v-btn>
                  <v-btn v-if="canModerateEvaluations" size="small" color="error" @click="validate(item.id, 'rejected')">
                    <v-icon icon="fa-solid fa-xmark" />
                    Rejeitar
                  </v-btn>
                  <v-btn size="small" color="red-darken-2" @click="downloadPdf(item.id)">
                    <v-icon icon="fa-solid fa-file-pdf" />
                    PDF
                  </v-btn>
                  <v-btn
                    v-if="canDeleteEvaluations"
                    icon
                    color="error"
                    size="small"
                    :loading="deletingId === item.id"
                    @click="askDelete(item)"
                  >
                    <v-icon icon="fa-solid fa-trash" />
                  </v-btn>
                </template>
              </v-data-table-server>
            </v-window-item>

            <v-window-item value="form">
              <PatientAutocomplete v-model="patientId" />
              <EvaluationForm :key="formKey" @submit="create" />
            </v-window-item>
          </v-window>
        </template>
        <template v-else>
          <v-row>
            <v-col cols="12" md="6">
              <v-text-field v-model="search" label="Buscar por tipo" @update:modelValue="load" />
            </v-col>
            <v-col cols="12" md="6">
              <v-select
                v-model="statusFilter"
                :items="statusOptions"
                label="Status"
                clearable
                @update:modelValue="load"
              />
            </v-col>
          </v-row>

          <v-data-table-server
            :headers="headers"
            :items="items"
            :items-length="total"
            :loading="loading"
            v-model:page="page"
            v-model:items-per-page="limit"
            @update:page="load"
            @update:items-per-page="load"
          >
            <template #item.patient="{ item }">
              <span>{{ formatPatient(item.patient) }}</span>
            </template>
            <template #item.type="{ item }">
              <span>{{ fixEncoding(item.type) }}</span>
            </template>
            <template #item.status="{ item }">
              <StatusChip :status="item.status" />
            </template>
            <template #item.actions="{ item }">
              <v-btn size="small" color="red-darken-2" @click="downloadPdf(item.id)">
                <v-icon icon="fa-solid fa-file-pdf" />
                PDF
              </v-btn>
            </template>
          </v-data-table-server>
        </template>
      </v-card-text>
    </v-card>

    <ConfirmDialog
      v-model="confirmDelete"
      message="Tem certeza que deseja excluir este registro?"
      @confirm="remove"
    />
  </MainLayout>
</template>

<script setup>
import { computed, ref } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import EvaluationForm from "../components/forms/EvaluationForm.vue";
import PatientAutocomplete from "../components/PatientAutocomplete.vue";
import StatusChip from "../components/StatusChip.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import api from "../services/api";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";
import { canRemove, canValidateEvaluation, isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";
import { fixEncoding } from "../utils/encoding";

const auth = useAuthStore();
const ui = useUiStore();
const items = ref([]);
const total = ref(0);
const loading = ref(false);
const page = ref(1);
const limit = ref(10);
const search = ref("");
const statusFilter = ref(null);
const statusOptions = [
  { title: "Pendente", value: "pending" },
  { title: "Aprovado", value: "approved" },
  { title: "Rejeitado", value: "rejected" }
];
const patientId = ref("");
const confirmDelete = ref(false);
const deleteTarget = ref(null);
const deletingId = ref(null);
const showDeleted = ref(false);
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));
const canModerateEvaluations = computed(() => canValidateEvaluation(auth.role));
const canDeleteEvaluations = computed(() => canRemove(auth.role));
const tab = ref("list");
const formKey = ref(0);

const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Tipo", key: "type" },
  { title: "Status", key: "status" },
  { title: "Ações", key: "actions", sortable: false }
];

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/evaluations", {
    params: {
      page: page.value,
      limit: limit.value,
      search: search.value || undefined,
      status: statusFilter.value || undefined,
      show_deleted: showDeleted.value
    }
  });
  items.value = data.items;
  total.value = data.total;
  loading.value = false;
};

const create = async (payload) => {
  try {
    if (!patientId.value) {
      ui.notify("Selecione um paciente", "warning");
      return;
    }
    await api.post("/evaluations", { ...payload, patient_id: patientId.value });
    ui.notify("Avaliação criada com sucesso");
    patientId.value = "";
    formKey.value += 1;
    tab.value = "list";
    await load();
  } catch {
    ui.notify("Erro ao criar avaliação", "error");
  }
};

const validate = async (id, status) => {
  try {
    await api.post(`/evaluations/${id}/validate`, { status });
    ui.notify("Avaliação atualizada");
    await load();
  } catch {
    ui.notify("Erro ao validar avaliação", "error");
  }
};

const downloadPdf = async (id) => {
  const { data } = await api.get(`/evaluations/${id}/pdf`, { responseType: "blob" });
  const url = window.URL.createObjectURL(data);
  const link = document.createElement("a");
  link.href = url;
  link.download = `evaluation_${id}.pdf`;
  link.click();
  window.URL.revokeObjectURL(url);
};

const askDelete = (item) => {
  deleteTarget.value = item;
  confirmDelete.value = true;
};

const remove = async () => {
  if (!deleteTarget.value) return;
  deletingId.value = deleteTarget.value.id;
  try {
    await api.delete(`/evaluations/${deleteTarget.value.id}`);
    ui.notify("Registro excluído com sucesso");
    await load();
  } catch {
    ui.notify("Erro ao excluir registro", "error");
  }
  deletingId.value = null;
  deleteTarget.value = null;
  confirmDelete.value = false;
};

const formatPatient = (patient) => {
  if (!patient) return "";
  const name = fixEncoding(patient.name || "Sem nome");
  const code = patient.patient_code ? ` - ${patient.patient_code}` : "";
  return `${name}${code}`;
};

load();
</script>
