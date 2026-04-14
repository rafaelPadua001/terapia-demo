<template>
  <v-app>
    <v-container class="fill-height" fluid>
      <v-row class="fill-height" align="center" justify="center">
        <v-col cols="12" md="6" lg="4">
          <v-card class="pa-6 text-center">
            <v-progress-circular v-if="loading" indeterminate color="primary" class="mb-4" />
            <v-icon v-else :color="success ? 'success' : 'error'" size="56" class="mb-4">
              <template v-if="success">
                <i class="fa-solid fa-envelope-circle-check"></i>
              </template>
              <template v-else>
                <i class="fa-solid fa-circle-exclamation"></i>
              </template>
            </v-icon>
            <div class="text-h5 mb-2">
              {{ success ? "Email confirmado" : "Não foi possível confirmar" }}
            </div>
            <div class="text-body-1 text-medium-emphasis mb-6">
              {{ message }}
            </div>
            <v-btn color="primary" to="/login">
              <v-icon icon="fa-solid fa-right-to-bracket" />
              Ir para o login
            </v-btn>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import api from "../services/api";

const route = useRoute();
const loading = ref(true);
const success = ref(false);
const message = ref("Validando seu link de confirmação...");

onMounted(async () => {
  const token = String(route.query.token || "");
  if (!token) {
    loading.value = false;
    message.value = "Link inválido ou expirado.";
    return;
  }

  try {
    const { data } = await api.get("/auth/confirm-email", { params: { token } });
    success.value = true;
    message.value = data?.message || "Email confirmado com sucesso.";
  } catch (error) {
    message.value = error?.response?.data?.error || "Link inválido ou expirado.";
  } finally {
    loading.value = false;
  }
});
</script>
