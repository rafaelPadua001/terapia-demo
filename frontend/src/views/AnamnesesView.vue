<template>
  <MainLayout>
    <v-card title="Anamneses">
      <v-card-text>
        <template v-if="!isRestrictedUser">
          <PatientAutocomplete v-model="patientId" />
          <AnamnesisForm :schema="schema" @submit="create" />
        </template>
        <v-divider class="my-4" />
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
          <template #item.resumo="{ item }">
            <span>{{ getResumo(item) }}</span>
          </template>
          <template #item.data="{ item }">
            <div v-if="getAnamneseSections(item).length">
              <div v-for="section in getAnamneseSections(item)" :key="section.title">
                <div class="text-subtitle-2">{{ fixEncoding(section.title) }}</div>
                <div v-for="line in section.lines" :key="line.label" class="text-body-2">
                  • {{ fixEncoding(line.label) }}: {{ fixEncoding(line.value) }}
                </div>
              </div>
            </div>
          </template>
          <template #item.actions="{ item }">
            <v-btn
              v-if="!isRestrictedUser"
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
      </v-card-text>
    </v-card>

    <ConfirmDialog
      v-if="!isRestrictedUser"
      v-model="confirmDelete"
      message="Tem certeza que deseja excluir este registro?"
      @confirm="remove"
    />
  </MainLayout>
</template>

<script setup>
import { computed, ref } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import AnamnesisForm from "../components/forms/AnamnesisForm.vue";
import PatientAutocomplete from "../components/PatientAutocomplete.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import api from "../services/api";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";
import { isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";
import { fixEncoding } from "../utils/encoding";

const auth = useAuthStore();
const ui = useUiStore();
const items = ref([]);
const total = ref(0);
const loading = ref(false);
const patientId = ref("");
const page = ref(1);
const limit = ref(10);
const confirmDelete = ref(false);
const deleteTarget = ref(null);
const deletingId = ref(null);
const showDeleted = ref(false);
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));

const headers = [
  { title: "Criado em", key: "created_at" },
  { title: "Paciente", key: "patient" },
  { title: "Resumo", key: "resumo" },
  { title: "Dados", key: "data" },
  { title: "Ações", key: "actions", sortable: false }
];

const schema = {
  sections: [
    {
      title: "Histórico Familiar",
      fields: [
        { type: "text", label: "Doenças na família" },
        { type: "textarea", label: "Observações" }
      ]
    }
  ]
};

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/anamneses", {
    params: { page: page.value, limit: limit.value, show_deleted: showDeleted.value }
  });
  items.value = data.items;
  total.value = data.total;
  loading.value = false;
};

const create = async (payload) => {
  if (!patientId.value) return;
  try {
    await api.post("/anamneses", { patient_id: patientId.value, data: payload });
    ui.notify("Anamnese criada");
    await load();
  } catch {
    ui.notify("Erro ao criar anamnese", "error");
  }
};

const askDelete = (item) => {
  deleteTarget.value = item;
  confirmDelete.value = true;
};

const remove = async () => {
  if (!deleteTarget.value) return;
  deletingId.value = deleteTarget.value.id;
  try {
    await api.delete(`/anamneses/${deleteTarget.value.id}`);
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
  const name = patient.name || "Sem nome";
  const code = patient.patient_code ? ` - ${patient.patient_code}` : "";
  return `${name}${code}`;
};

const getResumo = (anamnese) => {
  if (!anamnese?.data?.values) return "-";
  return Object.values(anamnese.data.values)
    .filter((value) => value)
    .join(", ");
};

const getAnamneseSections = (item) => {
  const data = item?.data;
  if (!data || !data.sections || !data.values) return [];
  const sections = [];
  data.sections.forEach((section, sIndex) => {
    const lines = [];
    (section.fields || []).forEach((field, fIndex) => {
      const key = `${sIndex}-${fIndex}`;
      const value = data.values?.[key];
      if (value !== undefined && value !== null && String(value).trim() !== "") {
        lines.push({ label: field.label || "Campo", value: String(value) });
      }
    });
    if (lines.length) {
      sections.push({ title: section.title || "Seção", lines });
    }
  });
  return sections;
};

load();
</script>
