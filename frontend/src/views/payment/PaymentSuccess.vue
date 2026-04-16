<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";

import { useAuthStore } from "../../store/auth";
import { getMyTransactions, getTransactions } from "../../services/financialService";

const route = useRoute();
const router = useRouter();
const auth = useAuthStore();

const loading = ref(true);
const transaction = ref(null);
const errorMessage = ref("");
let pollId = null;

const externalReference = computed(() => String(route.query.external_reference || "").trim());
const paymentStatus = computed(() => String(route.query.status || "").trim());
const statusLabel = computed(() => {
  const value = paymentStatus.value.toLowerCase();
  if (value === "approved") return "Aprovado";
  if (value === "pending") return "Pendente";
  if (value === "rejected") return "Recusado";
  return paymentStatus.value || "Desconhecido";
});

const listTransactions = () =>
  auth.role === "patient" || auth.role === "guardian"
    ? getMyTransactions({ page: 1, limit: 100 })
    : getTransactions({ page: 1, limit: 100 });

const resolveTransaction = async () => {
  if (!externalReference.value) {
    loading.value = false;
    return;
  }

  const response = await listTransactions();
  const items = response.data?.items || [];
  transaction.value = items.find((item) => String(item.id) === externalReference.value) || null;
  loading.value = false;
};

onMounted(async () => {
  try {
    await resolveTransaction();
    pollId = setInterval(async () => {
      if (!transaction.value?.id) return;

      const response = await listTransactions();
      const items = response.data?.items || [];
      const current = items.find((item) => String(item.id) === String(transaction.value.id));
      if (current) {
        transaction.value = current;
      }
    }, 3000);
  } catch (error) {
    errorMessage.value = "Nao foi possivel consultar os detalhes do pagamento.";
    loading.value = false;
  }
});

onBeforeUnmount(() => {
  clearInterval(pollId);
});

const goBack = () => {
  const role = auth.role;
  router.push(role === "patient" || role === "guardian" ? "/portal" : "/dashboard");
};
</script>

<template>
  <v-container class="py-10" style="max-width: 760px;">
    <v-card rounded="xl" class="pa-2 text-center">
      <v-card-text>
        <v-icon icon="fa-solid fa-circle-check" color="success" size="64" class="mb-4" />
        <h1 class="text-h4 mb-2">Pagamento confirmado</h1>
        <p class="text-body-1 mb-4">
          O Mercado Pago retornou com status <strong>{{ statusLabel }}</strong>.
        </p>
        <div v-if="loading" class="text-body-2 mb-4">Carregando detalhes...</div>
        <div v-else-if="errorMessage" class="text-body-2 mb-4">{{ errorMessage }}</div>
        <div v-else-if="transaction" class="text-body-1 mb-4">
          <div>Valor: R$ {{ transaction.amount }}</div>
          <div>Status atual no sistema: {{ transaction.status }}</div>
          <div v-if="externalReference">Transação: {{ externalReference }}</div>
        </div>
        <div v-else class="text-body-2 mb-4">
          A transação ainda não foi localizada. O webhook pode demorar alguns segundos.
        </div>
        <v-btn color="primary" @click="goBack">Voltar ao sistema</v-btn>
      </v-card-text>
    </v-card>
  </v-container>
</template>
