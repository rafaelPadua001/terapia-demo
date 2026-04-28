<template>
  <MainLayout>
    <v-card title="Anamneses">
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
              <AnamnesisForm :key="formKey" :schema="schema" @submit="create" />
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
          </v-data-table-server>
        </template>
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
import { richTextToPlainText } from "../utils/richText";

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
const tab = ref("list");
const formKey = ref(0);

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
  if (!patientId.value) {
    ui.notify("Selecione um paciente", "warning");
    return;
  }
  try {
    await api.post("/anamneses", { patient_id: patientId.value, data: payload });
    ui.notify("Anamnese criada");
    patientId.value = "";
    formKey.value += 1;
    tab.value = "list";
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
    .map((value) => (typeof value === "object" ? richTextToPlainText(value) : value))
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
      const normalizedValue = typeof value === "object" ? richTextToPlainText(value) : String(value ?? "").trim();
      if (normalizedValue) {
        lines.push({ label: field.label || "Campo", value: normalizedValue });
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
