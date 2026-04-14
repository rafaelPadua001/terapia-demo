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

      <v-menu location="bottom end">
        <template #activator="{ props }">
          <v-btn icon variant="text" v-bind="props" @click="loadNotifications">
            <v-badge :content="unreadCount" :model-value="unreadCount > 0" color="error">
              <v-icon icon="fa-solid fa-bell" />
            </v-badge>
          </v-btn>
        </template>
        <v-card min-width="340" max-width="420">
          <v-card-title class="text-subtitle-1">Notificações</v-card-title>
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
              <v-list-item-subtitle class="text-caption text-medium-emphasis">{{ formatDate(notification.created_at) }}</v-list-item-subtitle>
            </v-list-item>
          </v-list>
          <v-card-text v-else class="text-body-2 text-medium-emphasis">Nenhuma notificação por enquanto.</v-card-text>
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
  </v-app>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useAuthStore } from "../store/auth";
import { useRouter } from "vue-router";
import { getNotifications, markNotificationAsRead } from "../services/notificationService";

const auth = useAuthStore();
const router = useRouter();
const notifications = ref([]);
let pollingId = null;

const unreadCount = computed(() => notifications.value.filter((item) => !item.is_read).length);
const formatDate = (value) => (value ? new Date(value).toLocaleString("pt-BR") : "-");

const loadNotifications = async () => {
  if (!auth.token) return;
  try {
    const { data } = await getNotifications(20);
    notifications.value = Array.isArray(data) ? data : [];
  } catch {
    notifications.value = [];
  }
};

const openNotification = async (notification) => {
  if (!notification || notification.is_read) return;
  try {
    await markNotificationAsRead(notification.id);
    notification.is_read = true;
  } catch {
    // Nao interrompe UX se a requisicao falhar.
  }
};

const menuItems = computed(() => {
  const role = auth.role;
  if (role === "therapist" || role === "admin") {
    const items = [
      { title: "Dashboard", to: "/" },
      { title: "Pacientes", to: "/patients" },
      { title: "Anamneses", to: "/anamneses" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Validações", to: "/validations" },
      { title: "Evoluções", to: "/evolutions" },
      { title: "Agendamentos", to: "/appointments" },
      { title: "Financeiro", to: "/financial/dashboard" },
    ];
    if (role === "admin") {
      items.splice(2, 0, { title: "Terapeutas", to: "/therapists" });
    }
    return items;
  }
  if (role === "receptionist") {
    return [
      { title: "Dashboard", to: "/" },
      { title: "Pacientes", to: "/patients" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Evoluções", to: "/evolutions" },
      { title: "Agendamentos", to: "/appointments" },
      { title: "Financeiro", to: "/financial/dashboard" },
    ];
  }
  if (role === "patient" || role === "guardian") {
    return [
      { title: "Portal", to: "/portal" },
      { title: "Minhas cobranças", to: "/my-financial" },
      { title: "Avaliações", to: "/evaluations" },
      { title: "Evoluções", to: "/evolutions" },
    ];
  }
  return [{ title: "Dashboard", to: "/" }];
});

const logout = () => {
  auth.logout();
  router.push("/login");
};

onMounted(() => {
  loadNotifications();
  pollingId = setInterval(loadNotifications, 5000);
});

onBeforeUnmount(() => {
  if (pollingId) {
    clearInterval(pollingId);
    pollingId = null;
  }
});
</script>

<style scoped>
.notification-unread {
  background: rgba(25, 118, 210, 0.08);
}
</style>
