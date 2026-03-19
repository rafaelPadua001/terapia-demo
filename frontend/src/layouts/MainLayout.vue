<template>
  <v-app>
    <v-navigation-drawer app width="260" class="pa-3">
      <div class="text-h6 section-title mb-2">Clinics SaaS</div>
      <div class="text-body-2 mb-4" style="color: #5e7c78;">Painel da clínica</div>
      <v-divider class="mb-3" />
      <v-list density="compact" nav>
        <v-list-item v-for="item in menuItems" :key="item.to" :title="item.title" :to="item.to" />
      </v-list>
    </v-navigation-drawer>

    <v-app-bar app color="surface" flat>
      <v-toolbar-title class="section-title">Painel clínico</v-toolbar-title>
      <v-spacer />
      <v-btn variant="text" @click="logout">
        <v-icon>
          <span class="material-symbols-outlined">logout</span>
        </v-icon>
        Sair
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-container class="py-6">
        <slot />
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import { computed } from "vue";
import { useAuthStore } from "../store/auth";
import { useRouter } from "vue-router";

const auth = useAuthStore();
const router = useRouter();

const menuItems = computed(() => {
  const role = auth.role;
  if (role === "therapist" || role === "admin") {
    return [
      { title: "Dashboard", to: "/" },
      { title: "Pacientes", to: "/patients" },
      { title: "Anamneses", to: "/anamneses" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Validações", to: "/validations" },
      { title: "Evoluções", to: "/evolutions" },
      { title: "Agendamentos", to: "/appointments" }
    ];
  }
  if (role === "receptionist") {
    return [
      { title: "Dashboard", to: "/" },
      { title: "Pacientes", to: "/patients" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Evoluções", to: "/evolutions" },
      { title: "Agendamentos", to: "/appointments" }
    ];
  }
  if (role === "patient" || role === "guardian") {
    return [
      { title: "Portal", to: "/portal" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Evoluções", to: "/evolutions" }
    ];
  }
  return [
    { title: "Dashboard", to: "/" }
  ];
});

const logout = () => {
  auth.logout();
  router.push("/login");
};
</script>
