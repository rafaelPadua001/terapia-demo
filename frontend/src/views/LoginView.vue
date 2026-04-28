<template>
  <v-app>
    <v-container class="fill-height" fluid>
      <v-row class="fill-height" align="center" justify="center">
        <v-col cols="12" md="8" lg="6">
          <v-card class="surface-card" elevation="0">
            <v-row no-gutters>
              <v-col cols="12" md="5" class="pa-6" style="background: linear-gradient(160deg, #1b5e5b, #284f4b); color: white;">
                <div class="text-overline">Clinics SaaS</div>
                <div class="text-h4 section-title">{{ heroTitle }}</div>
                <p class="mt-2" style="opacity: 0.85;">
                  {{ heroDescription }}
                </p>
              </v-col>
              <v-col cols="12" md="7" class="pa-6">
                <div class="text-h5 section-title mb-1">{{ formTitle }}</div>
                <div class="text-body-2 mb-6" style="color: #5e7c78;">{{ formSubtitle }}</div>

                <v-form @submit.prevent="submit">
                  <v-text-field v-model="email" label="Email" type="email" required />
                  <v-text-field v-model="password" label="Senha" type="password" required />

                  <div class="d-flex justify-end mb-4">
                    <v-btn variant="text" size="small" to="/forgot-password">
                      Esqueci minha senha
                    </v-btn>
                  </div>

                  <v-btn color="primary" :loading="loading" type="submit" block>
                    <v-icon icon="fa-solid fa-right-to-bracket" />
                    Entrar
                  </v-btn>
                </v-form>
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script setup>
import { computed, ref } from "vue";
import { useAuthStore } from "../store/auth";
import { useRoute, useRouter } from "vue-router";
import { useUiStore } from "../store/ui";

const email = ref("");
const password = ref("");
const loading = ref(false);
const auth = useAuthStore();
const router = useRouter();
const route = useRoute();
const ui = useUiStore();

const role = computed(() => String(route.query.role || ""));

const roleCopy = {
  therapist: {
    heroTitle: "Acesso profissional",
    heroDescription: "Gestão clínica completa para terapeutas.",
    formTitle: "Entrar",
    formSubtitle: "Use suas credenciais profissionais."
  },
  receptionist: {
    heroTitle: "Gestão da clínica",
    heroDescription: "Organize a rotina e o atendimento da clínica.",
    formTitle: "Entrar",
    formSubtitle: "Use suas credenciais da recepção."
  },
  patient: {
    heroTitle: "Acompanhe seu tratamento",
    heroDescription: "Visualize evoluções e avaliações com segurança.",
    formTitle: "Entrar",
    formSubtitle: "Use as credenciais do paciente."
  },
  guardian: {
    heroTitle: "Acompanhe o desenvolvimento",
    heroDescription: "Acesso seguro às informações dos pacientes vinculados.",
    formTitle: "Entrar",
    formSubtitle: "Use as credenciais do responsável."
  }
};

const defaultCopy = {
  heroTitle: "Bem-vindo",
  heroDescription: "Acompanhe avaliações, anamnese e evolução clínica com segurança.",
  formTitle: "Entrar",
  formSubtitle: "Use suas credenciais da clínica."
};

const heroTitle = computed(() => roleCopy[role.value]?.heroTitle || defaultCopy.heroTitle);
const heroDescription = computed(() => roleCopy[role.value]?.heroDescription || defaultCopy.heroDescription);
const formTitle = computed(() => roleCopy[role.value]?.formTitle || defaultCopy.formTitle);
const formSubtitle = computed(() => roleCopy[role.value]?.formSubtitle || defaultCopy.formSubtitle);

const submit = async () => {
  if (!email.value || !password.value) {
    ui.notify("Informe email e senha", "error");
    return;
  }
  loading.value = true;
  try {
    await auth.login(email.value, password.value, role.value || undefined);
    const destination = auth.role === "patient" || auth.role === "guardian" ? "/portal" : "/dashboard";
    router.push(destination);
  } catch {
    ui.notify("Falha no login", "error");
  }
  loading.value = false;
};
</script>
