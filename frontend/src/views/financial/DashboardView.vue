<template>
  <div>
    <v-row>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4 financial-card financial-card--success">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Total recebido</div>
              <div class="text-h5 font-weight-bold text-success">{{ formatCurrency(summary.received) }}</div>
            </div>
            <i class="fas fa-check-circle financial-icon financial-icon--success"></i>
          </div>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4 financial-card financial-card--warning">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Pendente</div>
              <div class="text-h5 font-weight-bold text-warning">{{ formatCurrency(summary.pending) }}</div>
            </div>
            <i class="fas fa-clock financial-icon financial-icon--warning"></i>
          </div>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" class="pa-4 financial-card financial-card--error">
          <div class="d-flex align-center justify-space-between">
            <div>
              <div class="text-caption text-medium-emphasis">Atrasado</div>
              <div class="text-h5 font-weight-bold text-error">{{ formatCurrency(summary.overdue) }}</div>
            </div>
            <i class="fas fa-times-circle financial-icon financial-icon--error"></i>
          </div>
        </v-card>
      </v-col>
    </v-row>

    <v-card class="mt-4" rounded="xl">
      <v-card-title class="d-flex align-center justify-space-between flex-wrap ga-2">
        <span>Receitas por mês</span>
        <span class="text-caption text-medium-emphasis">Somente pagamentos confirmados</span>
      </v-card-title>
      <v-card-text>
        <div v-if="monthlyRevenue.length" class="chart">
          <div v-for="item in monthlyRevenue" :key="item.month" class="chart-row">
            <div class="chart-label">{{ item.month }}</div>
            <div class="chart-bar-wrap">
              <div class="chart-bar" :style="{ width: `${barWidth(item.amount)}%` }"></div>
            </div>
            <div class="chart-value">{{ formatCurrency(item.amount) }}</div>
          </div>
        </div>
        <v-alert v-else type="info" variant="tonal" class="mb-0">
          Ainda não há receitas confirmadas para exibir.
        </v-alert>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { getTransactions } from "../../services/financialService";

const transactions = ref([]);

const summary = computed(() => {
  const received = transactions.value.filter((item) => item.status === "paid").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  const pending = transactions.value.filter((item) => item.status === "pending").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  const overdue = transactions.value.filter((item) => item.status === "overdue").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  return { received, pending, overdue };
});

const monthlyRevenue = computed(() => {
  const map = new Map();
  transactions.value.forEach((item) => {
    if (item.status !== "paid" || !item.paid_at) return;
    const month = new Date(item.paid_at).toLocaleDateString("pt-BR", { month: "short", year: "2-digit" });
    map.set(month, (map.get(month) || 0) + Number(item.amount || 0));
  });
  return Array.from(map.entries()).map(([month, amount]) => ({ month, amount }));
});

const formatCurrency = (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(value || 0));
const barWidth = (amount) => {
  const max = Math.max(...monthlyRevenue.value.map((item) => item.amount), 1);
  return Math.max(8, Math.round((amount / max) * 100));
};

onMounted(async () => {
  const { data } = await getTransactions();
  transactions.value = Array.isArray(data) ? data : data.items || [];
});
</script>

<style scoped>
.financial-card {
  border: 1px solid rgba(15, 23, 42, 0.08);
}

.financial-card--success {
  background: linear-gradient(180deg, rgba(220, 252, 231, 0.85), rgba(255, 255, 255, 1));
}

.financial-card--warning {
  background: linear-gradient(180deg, rgba(254, 249, 195, 0.85), rgba(255, 255, 255, 1));
}

.financial-card--error {
  background: linear-gradient(180deg, rgba(254, 226, 226, 0.85), rgba(255, 255, 255, 1));
}

.financial-icon {
  font-size: 28px;
}

.financial-icon--success {
  color: #16a34a;
}

.financial-icon--warning {
  color: #d97706;
}

.financial-icon--error {
  color: #dc2626;
}

.chart {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.chart-row {
  display: grid;
  grid-template-columns: 120px 1fr 120px;
  gap: 12px;
  align-items: center;
}

.chart-bar-wrap {
  height: 12px;
  overflow: hidden;
  border-radius: 999px;
  background: rgba(15, 23, 42, 0.08);
}

.chart-bar {
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, #2563eb, #60a5fa);
}

@media (max-width: 600px) {
  .chart-row {
    grid-template-columns: 1fr;
  }
}
</style>
