<template>
  <v-app>
    <v-container class="fill-height" fluid>
      <v-row class="fill-height" align="center" justify="center">
        <v-col cols="12" md="8" lg="6">
          <v-card class="surface-card" elevation="0">
            <v-row no-gutters>
              <v-col
                cols="12"
                md="5"
                class="pa-6 login-brand-col"
                :style="brandBackgroundStyle"
              >
                <div class="mb-4">
                  <h2 class="login-brand-name">{{ safeClinicName }}</h2>
                </div>
                <div class="text-h4 section-title">{{ heroTitle }}</div>
                <p class="mt-2 login-brand-description">
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
import { useClinicStore } from "../store/clinic";

const email = ref("");
const password = ref("");
const loading = ref(false);
const auth = useAuthStore();
const router = useRouter();
const route = useRoute();
const ui = useUiStore();
const clinic = useClinicStore();

const role = computed(() => String(route.query.role || ""));

const roleCopy = {
  therapist: {
    heroTitle: "Acesso profissional",
    heroDescription: "Acesse a gestão clínica com foco no atendimento e na evolução dos pacientes.",
    formTitle: "Entrar",
    formSubtitle: "Use suas credenciais profissionais."
  },
  receptionist: {
    heroTitle: "Gestão da clínica",
    heroDescription: "Organize agenda, cadastros e atendimento diário da clínica.",
    formTitle: "Entrar",
    formSubtitle: "Use suas credenciais da recepção."
  },
  patient: {
    heroTitle: "Acompanhe seu tratamento",
    heroDescription: "Consulte suas informações clínicas e acompanhe seu progresso com segurança.",
    formTitle: "Entrar",
    formSubtitle: "Use as credenciais do paciente."
  },
  guardian: {
    heroTitle: "Acompanhe o desenvolvimento",
    heroDescription: "Acesse com segurança as informações dos pacientes vinculados à sua conta.",
    formTitle: "Entrar",
    formSubtitle: "Use as credenciais do responsável."
  }
};

const defaultCopy = {
  heroTitle: "Bem-vindo",
  heroDescription: "Centralize agenda, prontuário e acompanhamento clínico em um único ambiente.",
  formTitle: "Entrar",
  formSubtitle: "Use suas credenciais da clínica."
};

const heroTitle = computed(() => roleCopy[role.value]?.heroTitle || defaultCopy.heroTitle);
const heroDescription = computed(() => roleCopy[role.value]?.heroDescription || defaultCopy.heroDescription);
const formTitle = computed(() => roleCopy[role.value]?.formTitle || defaultCopy.formTitle);
const formSubtitle = computed(() => roleCopy[role.value]?.formSubtitle || defaultCopy.formSubtitle);
const safeClinicName = computed(() => {
  if (!clinic.name) return "Minha Clinica";
  try {
    return decodeURIComponent(escape(clinic.name));
  } catch {
    return clinic.name;
  }
});

const brandBackgroundStyle = computed(() => {
  if (clinic.logoUrl) {
    return {
      backgroundImage: `linear-gradient(rgba(0,0,0,0.62), rgba(0,0,0,0.62)), url(${clinic.logoUrl})`,
      backgroundSize: "cover",
      backgroundPosition: "center",
      backgroundRepeat: "no-repeat",
      backgroundColor: "#1b5e5b",
      backgroundBlendMode: "multiply",
      color: "white",
      backdropFilter: "blur(2px)",
    };
  }

  return {
    background: "linear-gradient(160deg, #1b5e5b, #284f4b)",
    color: "white",
  };
});

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

<style scoped>
.login-brand-col {
  min-height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.login-brand-name {
  margin: 0;
  font-size: 1.8rem;
  font-weight: 600;
  line-height: 1.2;
}

.login-brand-description {
  opacity: 0.88;
  max-width: 28rem;
}
</style>
