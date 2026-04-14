<template>
  <div>
    <v-card rounded="xl" elevation="1">
      <v-card-title class="d-flex align-center justify-space-between">
        <div>
          <div class="text-h6">Contas financeiras</div>
          <div class="text-body-2 text-medium-emphasis">Mercado Pago, banco e caixa</div>
        </div>
        <v-btn color="primary" @click="openCreate">Criar conta</v-btn>
      </v-card-title>
      <v-card-text>
        <v-data-table :headers="headers" :items="items" :loading="loading">
          <template #item.is_active="{ item }">
            <v-chip :color="item.is_active ? 'success' : 'grey'" size="small" variant="flat">
              {{ item.is_active ? 'Ativa' : 'Inativa' }}
            </v-chip>
          </template>
          <template #item.actions="{ item }">
            <div class="d-flex ga-2">
              <v-btn size="small" variant="tonal" @click="openEdit(item)">Editar</v-btn>
              <v-btn icon="fa-solid fa-trash" size="small" color="error" variant="text" @click="deleteAccount(item.id)" />
            </div>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>

    <v-dialog v-model="dialog" max-width="620">
      <v-card rounded="xl">
        <v-card-title>{{ editingId ? 'Editar conta' : 'Criar conta' }}</v-card-title>
        <v-card-text>
          <v-text-field v-model="form.name" label="Nome" />
          <v-select v-model="form.type" :items="types" label="Tipo" />
          <v-switch v-model="form.is_active" label="Ativa" />

          <v-expand-transition>
            <div v-if="form.type === 'mercadopago'" class="mt-4">
              <v-divider class="mb-4" />
              <div class="text-subtitle-1 font-weight-medium mb-3">Configura\u00e7\u00e3o do Mercado Pago</div>
              <v-text-field
                v-model="form.metadata.access_token"
                label="Access Token"
                :type="showAccessToken ? 'text' : 'password'"
                :append-inner-icon="showAccessToken ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye'"
                @click:append-inner="showAccessToken = !showAccessToken"
              />
              <v-text-field v-model="form.metadata.public_key" label="Public Key" />
              <v-text-field v-model="form.metadata.notification_url" label="Notification URL" />
              <v-select v-model="form.metadata.environment" :items="environmentOptions" label="Ambiente" />
            </div>
          </v-expand-transition>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="dialog = false">Cancelar</v-btn>
          <v-btn color="primary" :loading="saving" @click="save">Salvar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { createAccount, deleteAccount as apiDeleteAccount, getAccounts, updateAccount } from "../../services/financialService";
import { useUiStore } from "../../store/ui";

const ui = useUiStore();
const loading = ref(false);
const saving = ref(false);
const dialog = ref(false);
const editingId = ref("");
const items = ref([]);
const headers = [
  { title: "Nome", key: "name" },
  { title: "Tipo", key: "type" },
  { title: "Status", key: "is_active" },
  { title: "A\u00e7\u00f5es", key: "actions", sortable: false }
];
const types = [
  { title: "Mercado Pago", value: "mercadopago" },
  { title: "Banco", value: "bank" },
  { title: "Caixa", value: "cash" }
];
const form = reactive({
  name: "",
  type: "bank",
  is_active: true,
  metadata: {
    access_token: "",
    public_key: "",
    notification_url: "",
    environment: "sandbox"
  }
});
const showAccessToken = ref(false);
const environmentOptions = [
  { title: "Sandbox", value: "sandbox" },
  { title: "Production", value: "production" }
];

const load = async () => {
  loading.value = true;
  try {
    const { data } = await getAccounts();
    items.value = Array.isArray(data) ? data : data.items || [];
  } finally {
    loading.value = false;
  }
};

const resetForm = () => {
  editingId.value = "";
  form.name = "";
  form.type = "bank";
  form.is_active = true;
  form.metadata.access_token = "";
  form.metadata.public_key = "";
  form.metadata.notification_url = "";
  form.metadata.environment = "sandbox";
  showAccessToken.value = false;
};

const openCreate = () => {
  resetForm();
  dialog.value = true;
};

const openEdit = (item) => {
  editingId.value = item.id;
  form.name = item.name || "";
  form.type = item.type || "bank";
  form.is_active = Boolean(item.is_active);
  if (item.type === "mercadopago" && item.metadata) {
    form.metadata.access_token = item.metadata.access_token || "";
    form.metadata.public_key = item.metadata.public_key || "";
    form.metadata.notification_url = item.metadata.notification_url || "";
    form.metadata.environment = item.metadata.environment || "sandbox";
  } else {
    form.metadata.access_token = "";
    form.metadata.public_key = "";
    form.metadata.notification_url = "";
    form.metadata.environment = "sandbox";
  }
  showAccessToken.value = false;
  dialog.value = true;
};

const save = async () => {
  saving.value = true;
  try {
    const payload = {
      name: form.name,
      type: form.type,
      is_active: form.is_active,
      metadata: form.type === "mercadopago" ? { ...form.metadata } : null
    };

    if (editingId.value) {
      await updateAccount(editingId.value, payload);
      ui.notify("Conta atualizada com sucesso");
    } else {
      await createAccount(payload);
      ui.notify("Conta criada com sucesso");
    }

    dialog.value = false;
    resetForm();
    await load();
  } finally {
    saving.value = false;
  }
};

const deleteAccount = async (id) => {
  if (!window.confirm("Deseja remover esta conta?")) return;
  await apiDeleteAccount(id);
  ui.notify("Conta removida com sucesso");
  await load();
};

onMounted(load);
</script>

