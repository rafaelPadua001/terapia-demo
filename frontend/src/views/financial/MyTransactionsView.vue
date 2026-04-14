<template>
  <v-card rounded="xl">
    <v-card-title>Minhas cobranças</v-card-title>
    <v-card-text>
      <v-data-table :headers="headers" :items="items" :loading="loading">
        <template #item.amount="{ item }">{{ formatCurrency(item.amount) }}</template>
        <template #item.status="{ item }">
          <v-chip :color="statusColor(item.status)" size="small" variant="flat">{{ statusLabel(item.status) }}</v-chip>
        </template>
        <template #item.due_date="{ item }">{{ formatDate(item.due_date) }}</template>
        <template #item.actions="{ item }">
          <v-btn
            v-if="item.payment_method === 'mercadopago' && item.status === 'pending'"
            size="small"
            color="success"
            variant="tonal"
            @click="handlePayment(item)"
          >
            Pagar
          </v-btn>
          <span v-else class="text-caption text-medium-emphasis">-</span>
        </template>
      </v-data-table>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { onMounted, ref } from "vue";
import { generatePayment, getMyTransactions } from "../../services/financialService";
import { useUiStore } from "../../store/ui";

const ui = useUiStore();
const items = ref([]);
const loading = ref(false);

const headers = [
  { title: "Descrição", key: "description" },
  { title: "Valor", key: "amount" },
  { title: "Status", key: "status" },
  { title: "Vencimento", key: "due_date" },
  { title: "Ações", key: "actions", sortable: false },
];

const statusColor = (status) => ({ pending: "grey", paid: "success", overdue: "error", canceled: "deep-orange" }[status] || "grey");
const statusLabel = (status) => ({ pending: "Pendente", paid: "Pago", overdue: "Atrasado", canceled: "Cancelado" }[status] || status || "-");
const formatCurrency = (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(value || 0));
const formatDate = (value) => (value ? new Date(value).toLocaleDateString("pt-BR") : "-");

const handlePayment = async (transaction) => {
  try {
    if (transaction?.external_id) {
      window.open(transaction.external_id, "_blank", "noopener,noreferrer");
      return;
    }

    const { data } = await generatePayment(transaction.id);
    const link = data?.payment_link || data?.external_id;
    if (link) {
      window.open(link, "_blank", "noopener,noreferrer");
      return;
    }

    ui.notify("Não foi possível gerar o link de pagamento", "warning");
  } catch {
    ui.notify("Erro ao gerar pagamento", "error");
  }
};

onMounted(async () => {
  loading.value = true;
  try {
    const { data } = await getMyTransactions();
    items.value = Array.isArray(data) ? data : data.items || [];
  } finally {
    loading.value = false;
  }
});
</script>
