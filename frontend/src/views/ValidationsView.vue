<template>
  <MainLayout>
    <v-card title="Validações">
      <v-card-text>
        <v-switch v-model="showDeleted" label="Exibir excluídos" @update:modelValue="load" />

        <v-data-table
          :headers="headers"
          :items="items"
          :loading="loading"
        >
          <template #item.patient="{ item }">
            <span>{{ formatPatient(item.evaluation?.patient) }}</span>
          </template>

          <template #item.created_at="{ item }">
            <span>{{ formatDateTime(item.created_at) }}</span>
          </template>

          <template #item.evaluation_summary="{ item }">
            <div class="text-body-2">
              {{ formatEvaluationResumo(item.evaluation?.result) }}
            </div>
          </template>

          <template #item.status="{ item }">
            <StatusChip :status="item.status" />
          </template>

          <template #item.actions="{ item }">
            <div v-if="canValidate" class="d-flex align-center ga-3">
              <v-switch
                :model-value="item.status === 'approved'"
                color="success"
                hide-details
                inset
                :loading="updatingId === item.id"
                @update:modelValue="(value) => toggleStatus(item, value)"
              />
              <span class="text-caption text-medium-emphasis">
                {{ item.status === "approved" ? "Aprovado" : item.status === "rejected" ? "Rejeitado" : "Pendente" }}
              </span>
            </div>
            <span v-else class="text-medium-emphasis">-</span>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
  </MainLayout>
</template>

<script setup>
import { computed, ref } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import StatusChip from "../components/StatusChip.vue";
import api from "../services/api";
import { formatEvaluationResumo, fixEncoding } from "../utils/encoding";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";

const auth = useAuthStore();
const ui = useUiStore();
const items = ref([]);
const showDeleted = ref(false);
const loading = ref(false);
const updatingId = ref(null);

const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Data e hora", key: "created_at" },
  { title: "Resumo da avaliação", key: "evaluation_summary", sortable: false },
  { title: "Status", key: "status" },
  { title: "Ações", key: "actions", sortable: false }
];

const canValidate = computed(() => ["admin", "therapist"].includes(auth.role));

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/validations", { params: { show_deleted: showDeleted.value } });
  items.value = data;
  loading.value = false;
};

const formatPatient = (patient) => {
  if (!patient) return "-";
  const name = fixEncoding(patient.name || "Sem nome");
  const code = patient.patient_code ? ` - ${patient.patient_code}` : "";
  return `${name}${code}`;
};

const formatDateTime = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString("pt-BR");
};

const toggleStatus = async (item, enabled) => {
  console.log("validation toggle", item);
  if (!item?.id || !canValidate.value) {
    ui.notify("Não foi possível localizar a validação selecionada", "error");
    return;
  }

  const nextStatus = enabled ? "approved" : "rejected";
  updatingId.value = item.id;
  try {
    const { data } = await api.patch(`/validations/${item.id}`, { status: nextStatus });
    item.status = data.status;
    if (item.evaluation) item.evaluation.status = data.status;
    ui.notify("Status atualizado");
  } catch (error) {
    console.log("validation toggle error", error, item);
    ui.notify("Erro ao atualizar status", "error");
  }
  updatingId.value = null;
};

load();
</script>
