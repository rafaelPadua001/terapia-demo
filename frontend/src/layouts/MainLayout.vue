<template>
  <v-app>
    <v-navigation-drawer
      v-model="drawer"
      app
      width="260"
      class="pa-3"
      :temporary="isCompact"
      :permanent="!isCompact"
      :location="isCompact ? 'left' : undefined"
    >
      <div class="text-h6 section-title mb-2">Clinics SaaS</div>
      <div class="text-body-2 mb-4" style="color: #5e7c78;">Painel da clinica</div>
      <v-divider class="mb-3" />
      <v-list density="compact" nav>
        <v-tooltip
          v-for="item in menuItems"
          :key="item.to"
          :text="item.tooltip"
          location="end"
        >
          <template #activator="{ props }">
            <v-list-item
              v-bind="props"
              :id="item.id"
              :title="item.title"
              :to="item.to"
              :class="[
                'menu-item',
                {
                'tutorial-target': currentTutorialTarget === item.id,
                'active-menu': isMenuItemActive(item.to),
                },
              ]"
              @click="onMenuItemClick"
            >
              <template #append>
                <v-badge
                  v-if="item.to === '/my-financial' && pendingCharges > 0"
                  :content="pendingCharges"
                  color="error"
                  inline
                />
              </template>
            </v-list-item>
          </template>
        </v-tooltip>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar app color="surface" flat>
      <v-btn v-if="isCompact" icon variant="text" class="mr-2" @click="drawer = !drawer">
        <i class="fas fa-bars"></i>
      </v-btn>
      <v-toolbar-title class="section-title">Painel clinico</v-toolbar-title>
      <v-spacer />

      <v-menu location="bottom end">
        <template #activator="{ props }">
          <v-btn icon variant="text" v-bind="props" @click="loadNotifications">
            <v-badge :content="notifications.length" :model-value="notifications.length > 0" color="error">
              <i class="fas fa-bell"></i>
            </v-badge>
          </v-btn>
        </template>
        <v-card min-width="340" max-width="420">
          <v-card-title class="text-subtitle-1">Notificacoes</v-card-title>
          <v-divider />
          <v-list v-if="notifications.length" density="compact">
            <v-list-item
              v-for="notification in notifications"
              :key="notification.id"
              :class="{ 'notification-unread': !notification.is_read }"
              @click="openNotification(notification)"
            >
              <v-list-item-title class="font-weight-medium">{{ notification.title }}</v-list-item-title>
              <v-list-item-subtitle>{{ notification.message }}</v-list-item-subtitle>
              <v-list-item-subtitle class="text-caption text-medium-emphasis">
                {{ formatDate(notification.created_at) }}
              </v-list-item-subtitle>
            </v-list-item>
          </v-list>
          <v-card-text v-else class="text-body-2 text-medium-emphasis">Nenhuma notificacao por enquanto.</v-card-text>
          <v-divider />
          <v-card-actions>
            <v-spacer />
            <v-btn variant="text" @click="clearNotifications">Limpar notificacoes</v-btn>
          </v-card-actions>
        </v-card>
      </v-menu>

      <v-btn variant="text" @click="logout">
        <v-icon icon="fa-solid fa-right-from-bracket" />
        Sair
      </v-btn>
    </v-app-bar>

    <v-main>
      <v-container class="py-6">
        <slot />
      </v-container>
    </v-main>

    <v-dialog :model-value="showFirstLoginDialog" persistent max-width="480">
      <v-card>
        <v-card-title class="text-h6 section-title">Primeiro acesso</v-card-title>
        <v-card-text>Este e seu primeiro acesso. Voce precisa alterar sua senha.</v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn color="primary" @click="goToChangePassword">Alterar senha</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <OnboardingDialog
      :model-value="showTutorial"
      :steps="tutorialSteps"
      :current-index="tutorialIndex"
      @back="previousTutorialStep"
      @next="nextTutorialStep"
      @finish="finishTutorial"
    />
  </v-app>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useDisplay } from "vuetify";
import { useRoute, useRouter } from "vue-router";
import OnboardingDialog from "../components/OnboardingDialog.vue";
import { completeTutorial } from "../services/authService";
import { getMyTransactions } from "../services/financialService";
import { getNotifications, markNotificationAsRead } from "../services/notificationService";
import { useAuthStore } from "../store/auth";

const auth = useAuthStore();
const router = useRouter();
const route = useRoute();
const { mdAndDown, smAndDown } = useDisplay();
const notifications = ref([]);
const pendingCharges = ref(0);
const tutorialIndex = ref(0);
const tutorialOpened = ref(false);
const storedDrawer = typeof window !== "undefined" ? window.localStorage.getItem("drawer") : null;
const drawer = ref(storedDrawer !== null ? storedDrawer === "true" : !mdAndDown.value);
const isCompact = computed(() => mdAndDown.value || smAndDown.value);
let pollingId = null;
let chargesPollingId = null;

const showFirstLoginDialog = computed(() => Boolean(auth.user?.first_login) && route.path !== "/change-password");
const showTutorial = computed(
  () =>
    Boolean(auth.token) &&
    Boolean(auth.user) &&
    !auth.user.first_login &&
    !auth.user.has_seen_tutorial &&
    tutorialSteps.value.length > 0 &&
    tutorialOpened.value,
);
const currentTutorialTarget = computed(() => tutorialSteps.value[tutorialIndex.value]?.target || "");

const formatDate = (value) => (value ? new Date(value).toLocaleString("pt-BR") : "-");

const menuItems = computed(() => {
  const role = auth.role;
  if (role === "therapist" || role === "admin") {
    const items = [
      { id: "menu-dashboard", title: "Dashboard", to: "/", tooltip: "Visao geral da clinica" },
      { id: "menu-patients", title: "Pacientes", to: "/patients", tooltip: "Gerenciar pacientes cadastrados" },
      { id: "menu-anamneses", title: "Anamneses", to: "/anamneses", tooltip: "Registrar dados clinicos iniciais" },
      { id: "menu-evaluations", title: "Avaliacoes", to: "/evaluations", tooltip: "Acompanhar avaliacoes clinicas" },
      { id: "menu-validations", title: "Validacoes", to: "/validations", tooltip: "Revisar validacoes pendentes" },
      { id: "menu-evolutions", title: "Evolucoes", to: "/evolutions", tooltip: "Consultar evolucoes registradas" },
      { id: "menu-appointments", title: "Agendamentos", to: "/appointments", tooltip: "Visualizar e organizar atendimentos" },
      { id: "menu-financial", title: "Financeiro", to: "/financial/dashboard", tooltip: "Controle de pagamentos e faturamento" },
    ];
    if (role === "admin") {
      items.splice(2, 0, { id: "menu-therapists", title: "Terapeutas", to: "/therapists", tooltip: "Gerenciar profissionais cadastrados" });
    }
    return items;
  }
  if (role === "receptionist") {
    return [
      { id: "menu-dashboard", title: "Dashboard", to: "/", tooltip: "Visao geral da clinica" },
      { id: "menu-patients", title: "Pacientes", to: "/patients", tooltip: "Gerenciar pacientes cadastrados" },
      { id: "menu-evaluations", title: "Avaliacoes", to: "/evaluations", tooltip: "Acompanhar avaliacoes clinicas" },
      { id: "menu-evolutions", title: "Evolucoes", to: "/evolutions", tooltip: "Consultar evolucoes registradas" },
      { id: "menu-appointments", title: "Agendamentos", to: "/appointments", tooltip: "Visualizar e organizar atendimentos" },
      { id: "menu-financial", title: "Financeiro", to: "/financial/dashboard", tooltip: "Controle de pagamentos e faturamento" },
    ];
  }
  if (role === "patient" || role === "guardian") {
    return [
      { id: "menu-portal", title: "Portal", to: "/portal", tooltip: "Acompanhar seus dados clinicos" },
      { id: "menu-my-financial", title: "Minhas cobrancas", to: "/my-financial", tooltip: "Controle de pagamentos e faturamento" },
      { id: "menu-evaluations", title: "Avaliacoes", to: "/evaluations", tooltip: "Acompanhar avaliacoes clinicas" },
      { id: "menu-evolutions", title: "Evolucoes", to: "/evolutions", tooltip: "Consultar evolucoes registradas" },
    ];
  }
  return [{ id: "menu-dashboard", title: "Dashboard", to: "/", tooltip: "Visao geral da clinica" }];
});

const tutorialSteps = computed(() => {
  const role = auth.role;
  if (role === "patient" || role === "guardian") {
    return [
      { target: "menu-portal", label: "Portal", description: "Aqui voce acompanha seus dados clinicos." },
      { target: "menu-my-financial", label: "Minhas cobrancas", description: "Aqui voce acompanha pagamentos e cobrancas pendentes." },
      { target: "menu-evaluations", label: "Avaliacoes", description: "Aqui voce visualiza as avaliacoes registradas." },
      { target: "menu-evolutions", label: "Evolucoes", description: "Aqui voce acompanha as evolucoes do tratamento." },
    ];
  }

  const steps = [
    { target: "menu-patients", label: "Pacientes", description: "Aqui voce cadastra e gerencia pacientes." },
    { target: "menu-appointments", label: "Agenda", description: "Aqui voce organiza os atendimentos da clinica." },
    { target: "menu-financial", label: "Financeiro", description: "Aqui voce acompanha pagamentos e faturamento." },
  ];

  if (role === "admin") {
    steps.push({ target: "menu-therapists", label: "Terapeutas", description: "Aqui voce gerencia os profissionais cadastrados." });
  }

  return steps;
});

const loadNotifications = async () => {
  if (!auth.token) return;
  try {
    const { data } = await getNotifications(20);
    notifications.value = Array.isArray(data) ? data : [];
  } catch {
    notifications.value = [];
  }
};

const clearNotifications = () => {
  notifications.value = [];
};

const loadPendingCharges = async () => {
  if (!auth.token || (auth.role !== "patient" && auth.role !== "guardian")) {
    pendingCharges.value = 0;
    return;
  }
  try {
    const { data } = await getMyTransactions({ page: 1, limit: 100 });
    const items = Array.isArray(data) ? data : data.items || [];
    pendingCharges.value = items.filter((item) => item.status === "pending").length;
  } catch {
    pendingCharges.value = 0;
  }
};

const openNotification = async (notification) => {
  if (!notification || notification.is_read) return;
  try {
    await markNotificationAsRead(notification.id);
    notification.is_read = true;
  } catch {
  }
};

const isMenuItemActive = (path) => route.path === path;

const onMenuItemClick = () => {
  if (isCompact.value) {
    drawer.value = false;
  }
};

const goToChangePassword = () => {
  router.push("/change-password");
};

const nextTutorialStep = () => {
  if (tutorialIndex.value < tutorialSteps.value.length - 1) {
    tutorialIndex.value += 1;
  }
};

const previousTutorialStep = () => {
  if (tutorialIndex.value > 0) {
    tutorialIndex.value -= 1;
  }
};

const finishTutorial = async () => {
  try {
    await completeTutorial();
    auth.setTutorialSeen();
    await auth.loadCurrentUser();
  } catch {
  } finally {
    tutorialOpened.value = false;
    tutorialIndex.value = 0;
  }
};

const logout = () => {
  auth.logout();
  router.push("/login");
};

onMounted(async () => {
  if (auth.token && !auth.user) {
    await auth.loadCurrentUser();
  }
  loadNotifications();
  loadPendingCharges();
  pollingId = setInterval(loadNotifications, 5000);
  chargesPollingId = setInterval(loadPendingCharges, 15000);
});

watch(
  () => [auth.user?.first_login, auth.user?.has_seen_tutorial, route.path],
  () => {
    if (auth.user?.first_login) {
      tutorialOpened.value = false;
      tutorialIndex.value = 0;
      return;
    }
    if (auth.user && !auth.user.has_seen_tutorial && route.path !== "/change-password") {
      tutorialOpened.value = true;
    }
  },
  { immediate: true },
);

watch(drawer, (val) => {
  if (typeof window !== "undefined") {
    window.localStorage.setItem("drawer", String(val));
  }
});

onBeforeUnmount(() => {
  if (pollingId) {
    clearInterval(pollingId);
    pollingId = null;
  }
  if (chargesPollingId) {
    clearInterval(chargesPollingId);
    chargesPollingId = null;
  }
});
</script>

<style scoped>
.notification-unread {
  background: rgba(25, 118, 210, 0.08);
}

.menu-item :deep(.v-list-item--active),
:deep(.v-list-item--active) {
  background: transparent !important;
}

.menu-item :deep(.v-list-item--active::before),
:deep(.v-list-item--active::before) {
  opacity: 0 !important;
}

.tutorial-target {
  outline: 2px solid rgba(45, 138, 111, 0.65);
  border-radius: 10px;
  background: rgba(45, 138, 111, 0.08);
}

.active-menu {
  border-left: 4px solid #4caf50;
  background: rgba(76, 175, 80, 0.12);
  color: #1f3a32 !important;
}
</style>
