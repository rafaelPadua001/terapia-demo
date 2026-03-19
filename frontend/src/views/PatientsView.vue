<template>
  <MainLayout>
    <v-card :title="pageTitle">
      <v-card-text>
        <div v-if="isRestrictedUser" class="mb-4">
          <v-alert variant="tonal" color="primary" :icon="portalIcon" class="mb-4">
            {{ portalDescription }}
          </v-alert>

          <v-row class="mb-2">
            <v-col cols="12" md="4">
              <v-card variant="outlined">
                <v-card-text>
                  <div class="text-overline text-medium-emphasis">Pacientes vinculados</div>
                  <div class="text-h4">{{ total }}</div>
                </v-card-text>
              </v-card>
            </v-col>
          </v-row>
        </div>

        <PatientForm v-if="!isRestrictedUser" :all-guardians="allGuardians" @submit="create" />
        <v-divider class="my-4" />

        <v-row>
          <v-col cols="12" md="8">
            <v-text-field
              v-model="search"
              :label="isRestrictedUser ? 'Buscar paciente vinculado' : 'Buscar por nome'"
              :placeholder="isRestrictedUser ? 'Digite o nome do paciente' : undefined"
              @update:modelValue="load"
            />
          </v-col>
          <v-col v-if="!isRestrictedUser" cols="12" md="4" class="d-flex align-center">
            <v-switch v-model="showDeleted" label="Exibir excluídos" @update:modelValue="load" />
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
          <template #item.cpf="{ item }">
            <span>{{ formatCpf(item.cpf || "") }}</span>
          </template>
          <template #item.guardians="{ item }">
            <span>{{ formatGuardians(item.guardians) }}</span>
          </template>
          <template #item.actions="{ item }">
            <v-btn size="small" color="primary" :to="`/patients/${item.id}`">
              <v-icon>
                <span class="material-symbols-outlined">{{ isRestrictedUser ? "visibility" : "edit" }}</span>
              </v-icon>
              {{ isRestrictedUser ? "Abrir" : "Detalhe" }}
            </v-btn>
            <v-btn
              v-if="!isRestrictedUser"
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
import { useRoute } from "vue-router";
import MainLayout from "../layouts/MainLayout.vue";
import api from "../services/api";
import PatientForm from "../components/forms/PatientForm.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";
import { isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";
import { formatCpf } from "../utils/cpf";
import guardianService from "../services/guardianService";

const auth = useAuthStore();
const route = useRoute();
const ui = useUiStore();
const items = ref([]);
const total = ref(0);
const loading = ref(false);
const search = ref("");
const page = ref(1);
const limit = ref(10);
const confirmDelete = ref(false);
const deleteTarget = ref(null);
const deletingId = ref(null);
const showDeleted = ref(false);
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));
const allGuardians = ref([]);

const isPortal = computed(() => route.path === "/portal");
const isGuardian = computed(() => auth.role === "guardian");

const pageTitle = computed(() => {
  if (!isPortal.value) return "Pacientes";
  return isGuardian.value ? "Portal do Responsável" : "Meu Portal";
});

const portalDescription = computed(() => {
  if (isGuardian.value) {
    return "Aqui você acompanha todos os pacientes vinculados ao seu perfil, incluindo co-dependentes.";
  }
  return "Aqui você acompanha apenas os seus próprios dados clínicos.";
});

const portalIcon = computed(() => (isGuardian.value ? "groups" : "person"));

const headers = computed(() => [
  { title: "Nome", key: "name" },
  { title: "Código", key: "patient_code" },
  { title: "CPF", key: "cpf" },
  { title: "Nascimento", key: "birth_date" },
  { title: "Diagnóstico", key: "diagnosis" },
  { title: "Responsáveis", key: "guardians", sortable: false },
  { title: isRestrictedUser.value ? "Abrir" : "Ações", key: "actions", sortable: false }
]);

const formatGuardians = (guardians) => {
  if (!Array.isArray(guardians) || guardians.length === 0) return "-";
  return guardians
    .map((guardian) => {
      const name = guardian.name || "";
      const relationship = guardian.relationship || guardian.relationship_type || "";
      return relationship ? `${name} (${relationship})` : name;
    })
    .filter(Boolean)
    .join(", ");
};

const load = async () => {
  loading.value = true;
  const { data } = await api.get("/patients", {
    params: {
      page: page.value,
      limit: limit.value,
      search: search.value || undefined,
      show_deleted: !isRestrictedUser.value ? showDeleted.value : false
    }
  });
  items.value = data.items;
  total.value = data.total;
  loading.value = false;
};

const loadGuardians = async () => {
  if (isRestrictedUser.value) return;
  allGuardians.value = await guardianService.listAll();
};

const create = async (payload) => {
  try {
    await api.post("/patients", payload);
    ui.notify("Paciente criado com sucesso");
    await load();
    await loadGuardians();
  } catch {
    ui.notify("Erro ao criar paciente", "error");
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
    await api.delete(`/patients/${deleteTarget.value.id}`);
    ui.notify("Registro excluído com sucesso");
    await load();
  } catch {
    ui.notify("Erro ao excluir registro", "error");
  }
  deletingId.value = null;
  deleteTarget.value = null;
  confirmDelete.value = false;
};

load();
loadGuardians();
</script>
