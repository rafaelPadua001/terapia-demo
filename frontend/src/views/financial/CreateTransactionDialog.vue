<template>
  <v-dialog v-model="dialog" max-width="720">
    <v-card rounded="xl">
      <v-card-title class="text-h6">Nova cobrança</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="save">
          <v-row>
            <v-col cols="12">
              <PatientAutocomplete v-model="form.patient" return-object />
            </v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.description" label="Descrição" /></v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.amount" label="Valor" prefix="R$" inputmode="decimal" /></v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.due_date" label="Vencimento" type="date" /></v-col>
            <v-col cols="12" md="6"><v-select v-model="form.payment_method" :items="paymentMethods" label="Método de pagamento" /></v-col>
            <v-col cols="12" md="6"><v-select v-model="form.account_id" :items="accounts" item-title="name" item-value="id" label="Conta financeira" /></v-col>
          </v-row>
        </v-form>
      </v-card-text>
      <v-card-actions class="px-4 pb-4">
        <v-spacer />
        <v-btn variant="text" @click="close">Cancelar</v-btn>
        <v-btn color="primary" :loading="loading" @click="save">Salvar</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import PatientAutocomplete from "../../components/PatientAutocomplete.vue";
import { createTransaction } from "../../services/financialService";
import { notifyPaymentCreated } from "../../utils/notifyFinancial";

const props = defineProps({ modelValue: Boolean, accounts: { type: Array, default: () => [] } });
const emit = defineEmits(["update:modelValue", "saved", "notify"]);
const dialog = computed({ get: () => props.modelValue, set: (value) => emit("update:modelValue", value) });
const loading = ref(false);
const form = reactive({ patient: null, description: "Sessão terapêutica", amount: "", due_date: "", payment_method: "pix", account_id: "" });
const paymentMethods = [
  { title: "Pix", value: "pix" },
  { title: "Dinheiro", value: "cash" },
  { title: "Cartão", value: "card" },
  { title: "Mercado Pago", value: "mercadopago" }
];
const reset = () => { form.patient = null; form.description = "Sessão terapêutica"; form.amount = ""; form.due_date = ""; form.payment_method = "pix"; form.account_id = ""; };
const close = () => { dialog.value = false; };
const save = async () => {
  loading.value = true;
  try {
    const payload = {
      patient_id: form.patient?.id || null,
      description: form.description,
      amount: Number(String(form.amount).replace(",", ".")),
      due_date: form.due_date,
      payment_method: form.payment_method,
      account_id: form.account_id
    };
    const { data } = await createTransaction(payload);
    emit("saved", data);
    emit("notify", notifyPaymentCreated(data));
    close();
    reset();
  } finally {
    loading.value = false;
  }
};
watch(() => props.modelValue, (value) => { if (!value) reset(); });
</script>
