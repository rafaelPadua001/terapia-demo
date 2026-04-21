<template>
  <v-card rounded="xl">
    <v-card-title class="d-flex align-center justify-space-between flex-wrap ga-2">
      <div>
        <div class="text-h6">Minhas cobranças</div>
        <div class="text-body-2 text-medium-emphasis">Acompanhe pagamentos e vencimentos</div>
      </div>
      <v-btn variant="text" prepend-icon="fas fa-arrow-left" @click="$router.push('/portal')">
        Voltar ao portal
      </v-btn>
    </v-card-title>
    <v-card-text>
      <v-data-table :headers="headers" :items="items" :loading="loading">
        <template #item.amount="{ item }">
          <div class="text-h6 font-weight-bold">{{ formatCurrency(item.amount) }}</div>
        </template>
        <template #item.status="{ item }">
          <v-chip :color="statusColor(item.status)" size="small" variant="flat">
            {{ statusLabel(item.status) }}
          </v-chip>
        </template>
        <template #item.due_date="{ item }">{{ formatDate(item.due_date) }}</template>
        <template #item.actions="{ item }">
          <v-btn
            v-if="item.payment_method === 'mercadopago' && !item.external_id && isPending(item.status)"
            size="small"
            color="primary"
            variant="tonal"
            @click="handlePayment(item)"
          >
            Gerar pagamento
          </v-btn>
          <v-btn
            v-else-if="item.payment_method === 'mercadopago' && item.external_id && isPending(item.status)"
            size="small"
            color="success"
            variant="tonal"
            @click="handlePayment(item)"
          >
            Pagar
          </v-btn>
          <v-chip
            v-else-if="isPaid(item.status)"
            size="small"
            color="success"
            variant="flat"
          >
            Pago
          </v-chip>
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

const statusColor = (status) => ({ pending: "warning", paid: "success", overdue: "error", canceled: "deep-orange" }[status] || "grey");
const statusLabel = (status) => ({ pending: "Pendente", paid: "Pago", overdue: "Atrasado", canceled: "Cancelado" }[status] || status || "-");
const isPending = (status) => status === "pending";
const isPaid = (status) => status === "paid" || status === "approved";
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
