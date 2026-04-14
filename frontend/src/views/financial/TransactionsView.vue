<template>
  <div>
    <v-card rounded="xl" elevation="1">
      <v-card-title class="d-flex align-center justify-space-between flex-wrap ga-3">
        <div>
          <div class="text-h6">Transações</div>
          <div class="text-body-2 text-medium-emphasis">Cobranças, pagamentos e pendências</div>
        </div>
        <v-btn color="primary" @click="dialog = true">Nova cobrança</v-btn>
      </v-card-title>
      <v-card-text>
        <v-row class="mb-4">
          <v-col cols="12" md="3"><v-select v-model="filters.status" :items="statusOptions" label="Status" clearable /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="filters.patient" label="Paciente" clearable /></v-col>
          <v-col cols="12" md="3"><v-text-field v-model="filters.due_date" label="Vencimento" type="date" clearable /></v-col>
          <v-col cols="12" md="2" class="d-flex align-end"><v-btn block variant="tonal" @click="load">Filtrar</v-btn></v-col>
        </v-row>
        <v-data-table :headers="headers" :items="items" :loading="loading">
          <template #item.patient="{ item }">
            <div>
              <div class="font-weight-medium">{{ item.patient_name || item.patient?.name || "N\u00e3o informado" }}</div>
              <div v-if="item.external_id" class="text-caption text-medium-emphasis">{{ item.external_id }}</div>
            </div>
          </template>
          <template #item.amount="{ item }">{{ formatCurrency(item.amount) }}</template>
          <template #item.status="{ item }">
            <v-chip :color="statusColor(item.status)" size="small" variant="flat">{{ statusLabel(item.status) }}</v-chip>
          </template>
          <template #item.due_date="{ item }">{{ formatDate(item.due_date) }}</template>
          <template #item.actions="{ item }">
            <div class="d-flex ga-2 flex-wrap">
              <v-btn
                v-if="item.payment_method === 'mercadopago'"
                size="small"
                variant="tonal"
                @click="generatePaymentLink(item)"
              >
                Gerar link de pagamento
              </v-btn>
              <v-btn v-if="item.status !== 'paid'" size="small" color="success" @click="markPaid(item)">Marcar como pago</v-btn>
              <v-btn icon="fa-solid fa-trash" size="small" color="error" variant="text" @click="deleteTransaction(item.id)" />
            </div>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
    <CreateTransactionDialog v-model="dialog" :accounts="accounts" @saved="load" @notify="handleNotify" />
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import CreateTransactionDialog from "./CreateTransactionDialog.vue";
import {
  deleteTransaction as apiDeleteTransaction,
  generatePayment,
  getAccounts,
  getTransactions,
  payTransaction,
} from "../../services/financialService";
import { useUiStore } from "../../store/ui";

const ui = useUiStore();
const loading = ref(false);
const dialog = ref(false);
const items = ref([]);
const accounts = ref([]);
const filters = reactive({ status: "", patient: "", due_date: "" });
const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Valor", key: "amount" },
  { title: "Status", key: "status" },
  { title: "Vencimento", key: "due_date" },
  { title: "A\u00e7\u00f5es", key: "actions", sortable: false },
];
const statusOptions = [
  { title: "Pendente", value: "pending" },
  { title: "Pago", value: "paid" },
  { title: "Atrasado", value: "overdue" },
  { title: "Cancelado", value: "canceled" },
];

const statusColor = (status) => ({ pending: "grey", paid: "success", overdue: "error", canceled: "deep-orange" }[status] || "grey");
const statusLabel = (status) => ({ pending: "Pendente", paid: "Pago", overdue: "Atrasado", canceled: "Cancelado" }[status] || status || "-");
const formatCurrency = (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(value || 0));
const formatDate = (value) => (value ? new Date(value).toLocaleDateString("pt-BR") : "-");

const load = async () => {
  loading.value = true;
  try {
    const [{ data: transactions }, { data: accountsData }] = await Promise.all([getTransactions(filters), getAccounts()]);
    const normalized = Array.isArray(transactions) ? transactions : transactions.items || [];
    items.value = normalized.map((t) => ({
      ...t,
      patient_name: t.patient?.name || "N\u00e3o informado",
    }));
    accounts.value = Array.isArray(accountsData) ? accountsData : accountsData.items || [];
  } finally {
    loading.value = false;
  }
};

const markPaid = async (item) => {
  await payTransaction(item.id);
  ui.notify("Pagamento registrado", "success");
  await load();
};

const generatePaymentLink = async (item) => {
  const { data } = await generatePayment(item.id);
  if (data?.payment_link) {
    window.open(data.payment_link, "_blank", "noopener,noreferrer");
  }
  ui.notify("Link de pagamento gerado", "success");
  await load();
};

const deleteTransaction = async (id) => {
  if (!window.confirm("Deseja remover esta cobran\u00e7a?")) return;
  await apiDeleteTransaction(id);
  ui.notify("Cobran\u00e7a removida com sucesso");
  await load();
};

const handleNotify = ({ message }) => ui.notify(message, "success");

onMounted(load);
</script>

