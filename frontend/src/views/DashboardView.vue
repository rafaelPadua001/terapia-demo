<template>
  <MainLayout>
    <v-row>
      <v-col cols="12" md="4">
        <v-card title="Pacientes">
          <v-card-text>{{ dashboard.total_patients }}</v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card title="Avaliações Pendentes">
          <v-card-text>{{ dashboard.evaluations_pending }}</v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card title="Avaliações Aprovadas">
          <v-card-text>{{ dashboard.evaluations_approved }}</v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card class="mt-4" title="Últimas Evoluções">
      <v-list>
        <v-list-item
          v-for="e in dashboard.last_evolutions"
          :key="e.id"
          :title="e.description"
          :subtitle="e.created_at"
        />
      </v-list>
    </v-card>
  </MainLayout>
</template>

<script setup>
import { reactive } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import api from "../services/api";

const dashboard = reactive({
  total_patients: 0,
  evaluations_pending: 0,
  evaluations_approved: 0,
  last_evolutions: []
});

const load = async () => {
  const { data } = await api.get("/dashboard");
  Object.assign(dashboard, data);
};

load();
</script>
