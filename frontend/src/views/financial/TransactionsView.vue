<template>
  <div>
    <v-card rounded="xl" elevation="1">
      <v-card-title class="d-flex align-center justify-space-between flex-wrap ga-3">
        <div>
          <div class="text-h6">Transações</div>
          <div class="text-body-2 text-medium-emphasis">Cobranças, pagamentos e pendências</div>
        </div>
        <v-btn color="primary" @click="openCreateDialog">Nova cobrança</v-btn>
      </v-card-title>
      <v-card-text>
        <v-row class="mb-4">
          <v-col cols="12" md="3"><v-select v-model="filters.status" :items="statusOptions" label="Status" clearable /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="filters.patient" label="Paciente" clearable /></v-col>
          <v-col cols="12" md="3"><v-text-field v-model="filters.due_date" label="Vencimento" type="date" clearable /></v-col>
          <v-col cols="12" md="2">
            <div class="d-flex justify-end mt-2 mt-md-0">
              <v-btn color="primary" variant="tonal" @click="load">Filtrar</v-btn>
            </div>
          </v-col>
        </v-row>
        <v-data-table :headers="headers" :items="items" :loading="loading">
          <template #item.patient="{ item }">
            <div>
              <div class="font-weight-medium">{{ item.patient_name || item.patient?.name || "Não informado" }}</div>
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
              <v-btn icon variant="text" color="primary" @click="editTransaction(item)"><i class="fas fa-edit"></i></v-btn>
              <v-btn v-if="item.payment_method === 'mercadopago'" size="small" variant="tonal" @click="generatePaymentLink(item)">Gerar link de pagamento</v-btn>
              <v-btn v-if="item.status !== 'paid' && item.status !== 'canceled'" size="small" color="success" @click="markPaid(item)">Marcar como pago</v-btn>
              <v-btn v-if="item.status === 'paid'" size="small" color="warning" variant="tonal" @click="refund(item)">Extornar</v-btn>
              <v-btn v-if="item.status !== 'canceled'" size="small" color="error" variant="tonal" @click="cancel(item)">Cancelar</v-btn>
              <v-btn icon="fa-solid fa-trash" size="small" color="error" variant="text" @click="deleteTransaction(item.id)" />
            </div>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
    <CreateTransactionDialog v-model="dialog" :accounts="accounts" :transaction="editingTransaction" @saved="handleSaved" @notify="handleNotify" />
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import CreateTransactionDialog from "./CreateTransactionDialog.vue";
import { cancelPayment, deleteTransaction as apiDeleteTransaction, generatePayment, getAccounts, getTransactions, payTransaction, refundPayment } from "../../services/financialService";
import { useUiStore } from "../../store/ui";

const ui = useUiStore();
const loading = ref(false);
const dialog = ref(false);
const items = ref([]);
const accounts = ref([]);
const editingTransaction = ref(null);
const filters = reactive({ status: "", patient: "", due_date: "" });
const headers = [
  { title: "Paciente", key: "patient" },
  { title: "Valor", key: "amount" },
  { title: "Status", key: "status" },
  { title: "Vencimento", key: "due_date" },
  { title: "Ações", key: "actions", sortable: false },
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
    items.value = normalized.map((t) => ({ ...t, patient_name: t.patient?.name || "Não informado" }));
    accounts.value = Array.isArray(accountsData) ? accountsData : accountsData.items || [];
  } finally {
    loading.value = false;
  }
};

const openCreateDialog = () => {
  editingTransaction.value = null;
  dialog.value = true;
};

const editTransaction = (item) => {
  editingTransaction.value = { ...item };
  dialog.value = true;
};

const markPaid = async (item) => {
  await payTransaction(item.id);
  ui.notify("Pagamento registrado", "success");
  await load();
};

const generatePaymentLink = async (item) => {
  await generatePayment(item.id);
  ui.notify("Link de pagamento gerado com sucesso", "success");
  await load();
};

const refund = async (item) => {
  await refundPayment(item.id);
  ui.notify("Pagamento estornado com sucesso", "success");
  await load();
};

const cancel = async (item) => {
  await cancelPayment(item.id);
  ui.notify("Cobrança cancelada com sucesso", "success");
  await load();
};

const deleteTransaction = async (id) => {
  if (!window.confirm("Deseja remover esta cobrança?")) return;
  await apiDeleteTransaction(id);
  ui.notify("Cobrança removida com sucesso");
  await load();
};

const handleNotify = ({ message }) => ui.notify(message, "success");

const handleSaved = async () => {
  dialog.value = false;
  editingTransaction.value = null;
  await load();
};

onMounted(load);
</script>
