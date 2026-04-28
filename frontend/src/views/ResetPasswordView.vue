<template>
  <v-app>
    <v-container class="fill-height" fluid>
      <v-row class="fill-height" align="center" justify="center">
        <v-col cols="12" md="6" lg="5">
          <v-card class="surface-card" elevation="0">
            <v-card-title class="text-h5 section-title">Redefinir senha</v-card-title>
            <v-card-text>
              <div class="text-body-2 mb-6" style="color: #5e7c78;">
                Defina sua nova senha para continuar.
              </div>

              <v-form @submit.prevent="submit">
                <v-text-field v-model="password" label="Nova senha" type="password" required />
                <v-text-field v-model="confirmPassword" label="Confirmar senha" type="password" required />
                <v-btn color="primary" :loading="loading" type="submit" block>
                  Atualizar senha
                </v-btn>
              </v-form>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { resetPassword, validateResetToken } from "../services/authService";
import { useUiStore } from "../store/ui";

const route = useRoute();
const router = useRouter();
const ui = useUiStore();
const loading = ref(false);
const password = ref("");
const confirmPassword = ref("");
const token = ref("");

const redirectInvalidToken = () => {
  ui.notify("Token invalido ou expirado", "error");
  router.replace("/login");
};

onMounted(async () => {
  token.value = String(route.query.token || "");
  if (!token.value) {
    redirectInvalidToken();
    return;
  }

  try {
    await validateResetToken(token.value);
  } catch {
    redirectInvalidToken();
  }
});

const submit = async () => {
  if (!password.value || !confirmPassword.value) {
    ui.notify("Preencha todos os campos", "error");
    return;
  }
  if (password.value !== confirmPassword.value) {
    ui.notify("As senhas nao coincidem", "error");
    return;
  }

  loading.value = true;
  try {
    const { data } = await resetPassword(token.value, password.value);
    ui.notify(data.message || "Senha atualizada com sucesso", "success");
    router.replace("/login");
  } catch {
    redirectInvalidToken();
  }
  loading.value = false;
};
</script>
