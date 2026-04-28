<template>
  <MainLayout>
    <v-card class="mx-auto" max-width="560">
      <v-card-title class="text-h5 section-title">Alterar senha</v-card-title>
      <v-card-text>
        <div class="text-body-2 mb-6" style="color: #5e7c78;">
          Atualize sua senha para liberar o acesso completo ao sistema.
        </div>

        <v-form @submit.prevent="submit">
          <v-text-field v-model="password" label="Nova senha" type="password" required />
          <v-text-field v-model="confirmPassword" label="Confirmar senha" type="password" required />
          <v-btn color="primary" :loading="loading" type="submit" block>
            Salvar nova senha
          </v-btn>
        </v-form>
      </v-card-text>
    </v-card>
  </MainLayout>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import MainLayout from "../layouts/MainLayout.vue";
import { changePassword } from "../services/authService";
import { useAuthStore } from "../store/auth";
import { useUiStore } from "../store/ui";

const router = useRouter();
const auth = useAuthStore();
const ui = useUiStore();
const loading = ref(false);
const password = ref("");
const confirmPassword = ref("");

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
    const { data } = await changePassword(password.value);
    auth.setFirstLoginResolved();
    await auth.loadCurrentUser();
    ui.notify(data.message || "Senha atualizada com sucesso", "success");
    const destination = auth.role === "patient" || auth.role === "guardian" ? "/portal" : "/dashboard";
    router.replace(destination);
  } catch {
    ui.notify("Nao foi possivel alterar a senha", "error");
  }
  loading.value = false;
};
</script>
