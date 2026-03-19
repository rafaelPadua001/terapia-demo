<template>
  <MainLayout>
    <v-card title="Agendamentos">
      <v-card-text>
        <div v-if="canEdit" class="mb-4">
          <v-row>
            <v-col cols="12" md="6">
              <PatientAutocomplete v-model="form.patient_id" :selected-patient="selectedPatient" />
            </v-col>
            <v-col cols="12" md="6">
              <v-select
                v-model="form.therapist_id"
                :items="therapists"
                item-title="name"
                item-value="id"
                label="Terapeuta"
                :disabled="auth.role === 'therapist'"
              />
            </v-col>
            <v-col cols="12" md="3">
              <v-text-field v-model="form.date" label="Data" type="date" />
            </v-col>
            <v-col cols="12" md="3">
              <v-text-field v-model="form.time" label="Hora" type="time" />
            </v-col>
            <v-col cols="12" md="3">
              <v-select v-model="form.type" :items="typeOptions" label="Tipo" />
            </v-col>
            <v-col cols="12" md="3">
              <v-select v-model="form.status" :items="statusOptions" label="Status" />
            </v-col>
            <v-col cols="12" md="6">
              <v-textarea v-model="form.notes" label="Observações" rows="2" />
            </v-col>
            <v-col cols="12" md="6" class="d-flex align-center">
              <v-checkbox
                v-model="form.is_first_visit"
                density="compact"
                color="primary"
                hide-details
                label="Primeira consulta (acolhimento)"
                class="mt-1"
              />
            </v-col>
          </v-row>

          <v-btn color="success" :loading="saving" @click="save">
            <v-icon>
              <span class="material-symbols-outlined">save</span>
            </v-icon>
            {{ editingId ? "Atualizar" : "Agendar" }}
          </v-btn>
          <v-btn variant="text" color="grey" class="ml-2" @click="resetForm">
            <v-icon>
              <span class="material-symbols-outlined">cancel</span>
            </v-icon>
            Limpar
          </v-btn>
        </div>

        <v-switch v-model="showDeleted" label="Exibir excluídos" @update:modelValue="load" />

        <v-divider class="my-4" />

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
            <span>{{ item.type || '-' }}</span>
            <v-chip v-if="item.is_first_visit" class="ml-2" color="orange" size="x-small" variant="flat">
              Primeira consulta
            </v-chip>
          </template>
          <template #item.date="{ item }">
            <span>{{ item.date || formatDate(item.scheduled_at) }}</span>
          </template>
          <template #item.time="{ item }">
            <span>{{ formatTime(item.time || item.scheduled_at) }}</span>
          </template>
          <template #item.is_confirmed="{ item }">
            <div class="d-flex align-center ga-2">
              <v-chip v-if="item.is_confirmed" color="success" variant="flat" size="small">
                Confirmado
              </v-chip>
              <v-chip v-else color="warning" variant="outlined" size="small">
                Pendente
              </v-chip>
              <v-btn
                v-if="!item.is_confirmed && canEdit"
                size="small"
                color="success"
                :loading="confirmingId === item.id"
                @click="confirmAppointment(item)"
              >
                <v-icon>
                  <span class="material-symbols-outlined">check_circle</span>
                </v-icon>
                Confirmar
              </v-btn>
            </div>
          </template>
          <template #item.actions="{ item }">
            <div class="actions-cell">
              <v-tooltip text="Enviar WhatsApp" location="top" v-if="item.whatsapp_link">
                <template #activator="{ props }">
                  <v-btn v-bind="props" icon color="success" size="small" @click="openWhatsapp(item)">
                    <v-icon>
                      <span class="material-symbols-outlined">chat</span>
                    </v-icon>
                  </v-btn>
                </template>
              </v-tooltip>
              <v-tooltip text="Editar agendamento" location="top" v-if="canEdit">
                <template #activator="{ props }">
                  <v-btn v-bind="props" icon color="primary" size="small" @click="edit(item)">
                    <v-icon>
                      <span class="material-symbols-outlined">edit</span>
                    </v-icon>
                  </v-btn>
                </template>
              </v-tooltip>
              <v-tooltip text="Excluir agendamento" location="top" v-if="canEdit">
                <template #activator="{ props }">
                  <v-btn
                    v-bind="props"
                    icon
                    color="error"
                    size="small"
                    :loading="deletingId === item.id"
                    @click="askDelete(item)"
                  >
                    <v-icon>
                      <span class="material-symbols-outlined">delete</span>
                    </v-icon>
                  </v-btn>
                </template>
              </v-tooltip>
            </div>
          </template>
        </v-data-table-server>
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
import PatientAutocomplete from "../components/PatientAutocomplete.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import api from "../services/api";
import { useAuthStore } from "../store/auth";
import { useUiStore } from "../store/ui";
import { isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";

const auth = useAuthStore();
const ui = useUiStore();

const items = ref([]);
const total = ref(0);
const loading = ref(false);
const saving = ref(false);
const page = ref(1);
const limit = ref(10);
const confirmDelete = ref(false);
const deleteTarget = ref(null);
const deletingId = ref(null);
const confirmingId = ref(null);
const showDeleted = ref(false);

const therapists = ref([]);
const selectedPatient = ref(null);

const form = ref({
  patient_id: "",
  therapist_id: "",
  date: "",
  time: "",
  type: "",
  status: "scheduled",
  is_first_visit: false,
  notes: ""
});

const editingId = ref(null);

const typeOptions = [
  "Terapia ABA",
  "Terapia convencional",
  "Reforço escolar",
  "Primeira visita / acolhimento"
];

const statusOptions = [
  { title: "Agendado", value: "scheduled" },
  { title: "Confirmado", value: "confirmed" },
  { title: "Cancelado", value: "cancelled" },
  { title: "Concluído", value: "completed" }
];

const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Tipo", key: "type" },
  { title: "Data", key: "date" },
  { title: "Hora", key: "time" },
  { title: "Status", key: "status" },
  { title: "Confirmação", key: "is_confirmed", sortable: false },
  { title: "Ações", key: "actions", sortable: false, width: 180 }
];

const canEdit = computed(() =>
  !isRestrictedUserRole(auth) && ["admin", "therapist", "receptionist", "reception"].includes(auth.role)
);

const loadTherapists = async () => {
  const { data } = await api.get("/users", { params: { role: "therapist" } });
  therapists.value = data;
  if (auth.role === "therapist") {
    form.value.therapist_id = auth.userId;
  }
};

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/appointments", {
    params: {
      page: page.value,
      limit: limit.value,
      show_deleted: showDeleted.value
    }
  });
  items.value = data.items;
  total.value = data.total;
  loading.value = false;
};

const resetForm = () => {
  selectedPatient.value = null;
  form.value = {
    patient_id: "",
    therapist_id: auth.role === "therapist" ? auth.userId : "",
    date: "",
    time: "",
    type: "",
    status: "scheduled",
    is_first_visit: false,
    notes: ""
  };
  editingId.value = null;
};

const save = async () => {
  if (!form.value.patient_id || !form.value.therapist_id || !form.value.date || !form.value.time) {
    ui.notify("Preencha paciente, terapeuta, data e hora", "error");
    return;
  }
  saving.value = true;
  form.value.is_first_visit = Boolean(form.value.is_first_visit);
  try {
    if (editingId.value) {
      await api.put(`/appointments/${editingId.value}`, { ...form.value });
      ui.notify("Agendamento atualizado");
    } else {
      const { data } = await api.post("/appointments", {
        ...form.value,
        is_first_visit: Boolean(form.value.is_first_visit)
      });
      ui.notify("Agendamento criado");
      if (data?.whatsapp_link) {
        ui.notify("Agendamento criado. Use o botão Enviar WhatsApp para abrir a conversa.");
      }
    }
    resetForm();
    await load();
  } catch {
    ui.notify("Erro ao salvar agendamento", "error");
  }
  saving.value = false;
};

const edit = (item) => {
  editingId.value = item.id;
  selectedPatient.value = item.patient
    ? { ...item.patient, id: item.patient_id }
    : { id: item.patient_id, name: "Paciente", patient_code: null };
  form.value = {
    patient_id: item.patient_id,
    therapist_id: item.therapist_id,
    date: item.date || formatDate(item.scheduled_at),
    time: formatTime(item.time || item.scheduled_at),
    type: item.type || "",
    status: item.status || "scheduled",
    is_first_visit: !!item.is_first_visit,
    notes: item.notes || ""
  };
};

const openWhatsapp = (item) => {
  if (!item?.whatsapp_link) return;
  window.open(item.whatsapp_link, "_blank");
  ui.notify("WhatsApp aberto em uma nova guia");
  window.setTimeout(() => {
    ui.notify("Você já enviou a mensagem? Se sim, clique em Confirmar para finalizar o agendamento.");
  }, 1500);
};

const confirmAppointment = async (item) => {
  confirmingId.value = item.id;
  try {
    const { data } = await api.patch(`/appointments/${item.id}/confirm`);
    item.is_confirmed = data.is_confirmed;
    item.confirmed_at = data.confirmed_at;
    item.confirmed_by = data.confirmed_by;
    item.updated_at = data.updated_at;
    ui.notify(data.is_confirmed ? "Agendamento confirmado" : "Agendamento já estava confirmado");
  } catch {
    ui.notify("Erro ao confirmar agendamento", "error");
  }
  confirmingId.value = null;
};

const askDelete = (item) => {
  deleteTarget.value = item;
  confirmDelete.value = true;
};

const remove = async () => {
  if (!deleteTarget.value) return;
  deletingId.value = deleteTarget.value.id;
  try {
    await api.delete(`/appointments/${deleteTarget.value.id}`);
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

const formatDate = (value) => {
  if (!value) return "";
  const dateObj = new Date(value);
  if (Number.isNaN(dateObj.getTime())) return value;
  return dateObj.toISOString().slice(0, 10);
};

const formatTime = (value) => {
  if (!value) return "";
  if (typeof value === "string" && value.includes(":") && value.length <= 8) {
    return value.slice(0, 5);
  }
  const dateObj = new Date(value);
  if (Number.isNaN(dateObj.getTime())) return "";
  return dateObj.toISOString().slice(11, 16);
};

load();
loadTherapists();
</script>

<style scoped>
:deep(.v-data-table-footer__pagination) {
  display: none;
}

.actions-cell {
  display: flex;
  gap: 8px;
  flex-wrap: nowrap;
  align-items: center;
  min-width: 140px;
}
</style>
