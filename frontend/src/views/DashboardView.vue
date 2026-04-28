<template>
  <MainLayout>
    <v-row>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Pacientes</div>
              <div class="text-h4 font-weight-bold">{{ dashboard.total_patients }}</div>
            </div>
            <i class="fas fa-user-injured dashboard-icon"></i>
          </div>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Avaliações pendentes</div>
              <div class="text-h4 font-weight-bold text-warning">{{ dashboard.evaluations_pending }}</div>
            </div>
            <i class="fas fa-clock dashboard-icon dashboard-icon--warning"></i>
          </div>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Avaliações aprovadas</div>
              <div class="text-h4 font-weight-bold text-success">{{ dashboard.evaluations_approved }}</div>
            </div>
            <i class="fas fa-check-circle dashboard-icon dashboard-icon--success"></i>
          </div>
        </v-card>
      </v-col>
    </v-row>

    <v-card class="mt-4" rounded="xl">
      <v-card-title>Últimas Evoluções</v-card-title>
      <v-list>
        <v-list-item
          v-for="e in dashboard.last_evolutions"
          :key="e.id"
          :title="formatEvolutionTitle(e.description)"
          :subtitle="formatDate(e.created_at)"
        >
          <template #prepend>
            <v-avatar color="primary" variant="tonal" size="36">
              <span class="text-caption font-weight-bold">{{ initials(e.patient_name) }}</span>
            </v-avatar>
          </template>
          <template #append>
            <div class="text-right">
              <div class="text-subtitle-2">{{ e.patient_name || "Paciente" }}</div>
              <div class="text-caption text-medium-emphasis">{{ formatDate(e.created_at) }}</div>
            </div>
          </template>
        </v-list-item>
      </v-list>
    </v-card>
  </MainLayout>
</template>

<script setup>
import { reactive } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import api from "../services/api";
import { richTextToPlainText } from "../utils/richText";

const dashboard = reactive({
  total_patients: 0,
  evaluations_pending: 0,
  evaluations_approved: 0,
  last_evolutions: []
});

const formatDate = (value) =>
  value
    ? new Date(value).toLocaleString("pt-BR", { dateStyle: "short", timeStyle: "short" })
    : "-";

const initials = (value) =>
  String(value || "P")
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join("");

const formatEvolutionTitle = (value) => richTextToPlainText(value) || "-";

const load = async () => {
  const { data } = await api.get("/dashboard");
  Object.assign(dashboard, data);
};

load();
</script>

<style scoped>
.dashboard-icon {
  font-size: 28px;
  color: #2563eb;
}

.dashboard-icon--warning {
  color: #d97706;
}

.dashboard-icon--success {
  color: #16a34a;
}
</style>
