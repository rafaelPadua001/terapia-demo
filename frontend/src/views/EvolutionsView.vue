<template>
  <MainLayout>
    <v-card title="Evoluções">
      <v-card-text>
        <template v-if="!isRestrictedUser">
          <v-tabs v-model="tab" bg-color="transparent" class="mb-4">
            <v-tab value="list">Lista</v-tab>
            <v-tab value="form">Cadastro</v-tab>
          </v-tabs>

          <v-window v-model="tab">
            <v-window-item value="list">
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
                <template #item.description="{ item }">
                  <span>{{ fixEncoding(item.description) }}</span>
                </template>
                <template #item.actions="{ item }">
                  <v-btn
                    v-if="canDeleteEvolutionEntries"
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
              <v-form ref="formRef" v-model="isValid" @submit.prevent="create">
                <PatientAutocomplete v-model="patientId" />
                <v-textarea v-model="description" label="Descrição" :rules="[required]" />
                <v-btn color="success" type="submit" :loading="loadingAction">
                  <v-icon icon="fa-solid fa-floppy-disk" />
                  Salvar
                </v-btn>
              </v-form>
            </v-window-item>
          </v-window>
        </template>

        <template v-else>
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
            <template #item.description="{ item }">
              <span>{{ fixEncoding(item.description) }}</span>
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
import { ref, computed } from "vue";

import MainLayout from "../layouts/MainLayout.vue";
import PatientAutocomplete from "../components/PatientAutocomplete.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import api from "../services/api";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";
import { fixEncoding } from "../utils/encoding";
import { canDeleteEvolution, isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";

const auth = useAuthStore();
const ui = useUiStore();
const items = ref([]);
const total = ref(0);
const loading = ref(false);
const loadingAction = ref(false);
const patientId = ref("");
const description = ref("");
const page = ref(1);
const limit = ref(10);
const confirmDelete = ref(false);
const deleteTarget = ref(null);
const deletingId = ref(null);
const showDeleted = ref(false);
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));
const canDeleteEvolutionEntries = computed(() => canDeleteEvolution(auth.role));
const tab = ref("list");
const formRef = ref(null);
const isValid = ref(false);
const required = (value) => !!String(value ?? "").trim() || "Campo obrigatório";

const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Descrição", key: "description" },
  { title: "Criado em", key: "created_at" },
  { title: "Ações", key: "actions", sortable: false }
];

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/evolutions", {
    params: { page: page.value, limit: limit.value, show_deleted: showDeleted.value }
  });
  items.value = data.items;
  total.value = data.total;
  loading.value = false;
};

const create = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid || !patientId.value) {
    if (!patientId.value) {
      ui.notify("Selecione um paciente", "warning");
    }
    return;
  }
  loadingAction.value = true;
  try {
    await api.post("/evolutions", { patient_id: patientId.value, description: description.value });
    ui.notify("Evolução registrada");
    patientId.value = "";
    description.value = "";
    formRef.value?.resetValidation();
    tab.value = "list";
    await load();
  } catch {
    ui.notify("Erro ao salvar evolução", "error");
  }
  loadingAction.value = false;
};

const askDelete = (item) => {
  deleteTarget.value = item;
  confirmDelete.value = true;
};

const remove = async () => {
  if (!deleteTarget.value) return;
  deletingId.value = deleteTarget.value.id;
  try {
    await api.delete(`/evolutions/${deleteTarget.value.id}`);
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
