<template>
  <div>
    <v-row>
      <v-col cols="12" md="4"><v-card rounded="xl" color="green-lighten-5"><v-card-text><div class="text-caption">Total recebido</div><div class="text-h4 font-weight-bold">{{ formatCurrency(summary.received) }}</div></v-card-text></v-card></v-col>
      <v-col cols="12" md="4"><v-card rounded="xl" color="amber-lighten-5"><v-card-text><div class="text-caption">Pendente</div><div class="text-h4 font-weight-bold">{{ formatCurrency(summary.pending) }}</div></v-card-text></v-card></v-col>
      <v-col cols="12" md="4"><v-card rounded="xl" color="red-lighten-5"><v-card-text><div class="text-caption">Atrasado</div><div class="text-h4 font-weight-bold">{{ formatCurrency(summary.overdue) }}</div></v-card-text></v-card></v-col>
    </v-row>
    <v-card class="mt-4" rounded="xl"><v-card-title>Receitas por mês</v-card-title><v-card-text><div class="chart"><div v-for="item in monthlyRevenue" :key="item.month" class="chart-row"><div class="chart-label">{{ item.month }}</div><div class="chart-bar-wrap"><div class="chart-bar" :style="{ width: `${barWidth(item.amount)}%` }"></div></div><div class="chart-value">{{ formatCurrency(item.amount) }}</div></div></div></v-card-text></v-card>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import FinancialLayout from "./FinancialLayout.vue";
import { getTransactions } from "../../services/financialService";
const transactions = ref([]);
const summary = computed(() => {
  const received = transactions.value.filter((item) => item.status === "paid").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  const pending = transactions.value.filter((item) => item.status === "pending").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  const overdue = transactions.value.filter((item) => item.status === "overdue").reduce((acc, item) => acc + Number(item.amount || 0), 0);
  return { received, pending, overdue };
});
const monthlyRevenue = computed(() => { const map = new Map(); transactions.value.forEach((item) => { if (item.status !== "paid" || !item.paid_at) return; const month = new Date(item.paid_at).toLocaleDateString("pt-BR", { month: "short", year: "2-digit" }); map.set(month, (map.get(month) || 0) + Number(item.amount || 0)); }); return Array.from(map.entries()).map(([month, amount]) => ({ month, amount })); });
const formatCurrency = (value) => new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(value || 0));
const barWidth = (amount) => { const max = Math.max(...monthlyRevenue.value.map((item) => item.amount), 1); return Math.max(8, Math.round((amount / max) * 100)); };
onMounted(async () => { const { data } = await getTransactions(); transactions.value = Array.isArray(data) ? data : data.items || []; });
</script>

<style scoped>
.chart { display: flex; flex-direction: column; gap: 14px; }
.chart-row { display: grid; grid-template-columns: 120px 1fr 120px; gap: 12px; align-items: center; }
.chart-bar-wrap { height: 12px; overflow: hidden; border-radius: 999px; background: rgba(15, 23, 42, 0.08); }
.chart-bar { height: 100%; border-radius: inherit; background: linear-gradient(90deg, #2563eb, #60a5fa); }
@media (max-width: 600px) { .chart-row { grid-template-columns: 1fr; } }
</style>
