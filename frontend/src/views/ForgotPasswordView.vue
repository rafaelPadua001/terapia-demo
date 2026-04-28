<template>
  <v-app>
    <v-container class="fill-height" fluid>
      <v-row class="fill-height" align="center" justify="center">
        <v-col cols="12" md="6" lg="5">
          <v-card class="surface-card" elevation="0">
            <v-card-title class="text-h5 section-title">Recuperar senha</v-card-title>
            <v-card-text>
              <div class="text-body-2 mb-6" style="color: #5e7c78;">
                Informe seu email para receber o link de recuperacao.
              </div>

              <v-form @submit.prevent="submit">
                <v-text-field v-model="email" label="Email" type="email" required />
                <v-btn color="primary" :loading="loading" type="submit" block>
                  Enviar link de recuperacao
                </v-btn>
              </v-form>
            </v-card-text>
            <v-card-actions class="px-4 pb-4">
              <v-spacer />
              <v-btn variant="text" to="/login">Voltar ao login</v-btn>
            </v-card-actions>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { ref } from "vue";
import { forgotPassword } from "../services/authService";
import { useUiStore } from "../store/ui";

const email = ref("");
const loading = ref(false);
const ui = useUiStore();

const submit = async () => {
  if (!email.value) {
    ui.notify("Informe o email", "error");
    return;
  }

  loading.value = true;
  try {
    const { data } = await forgotPassword(email.value);
    ui.notify(data.message || "Se o email existir, voce recebera um link", "success");
  } catch {
    ui.notify("Se o email existir, voce recebera um link", "success");
  }
  loading.value = false;
};
</script>
