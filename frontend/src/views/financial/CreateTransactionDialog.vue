<template>
  <v-dialog v-model="dialog" max-width="720">
    <v-card rounded="xl">
      <v-card-title class="text-h6">{{ isEditing ? "Editar cobrança" : "Nova cobrança" }}</v-card-title>
      <v-card-text>
        <v-form ref="formRef" @submit.prevent="save">
          <v-row>
            <v-col cols="12">
              <PatientAutocomplete v-model="form.patient" return-object />
            </v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.description" label="Descrição" :rules="[required]" /></v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.amount" label="Valor" prefix="R$" inputmode="decimal" :rules="[requiredAmount]" /></v-col>
            <v-col cols="12" md="6"><v-text-field v-model="form.due_date" label="Vencimento" type="date" :rules="[required]" /></v-col>
            <v-col cols="12" md="6"><v-select v-model="form.payment_method" :items="paymentMethods" label="Método de pagamento" :rules="[required]" /></v-col>
            <v-col cols="12" md="6"><v-select v-model="form.account_id" :items="accounts" item-title="name" item-value="id" label="Conta financeira" :rules="[required]" /></v-col>
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
import { createTransaction, updateTransaction } from "../../services/financialService";
import { notifyPaymentCreated } from "../../utils/notifyFinancial";

const props = defineProps({
  modelValue: Boolean,
  accounts: { type: Array, default: () => [] },
  transaction: { type: Object, default: null },
});
const emit = defineEmits(["update:modelValue", "saved", "notify"]);
const dialog = computed({ get: () => props.modelValue, set: (value) => emit("update:modelValue", value) });
const loading = ref(false);
const formRef = ref(null);
const form = reactive({ patient: null, description: "Sessão terapêutica", amount: "", due_date: "", payment_method: "pix", account_id: "" });
const paymentMethods = [
  { title: "Pix", value: "pix" },
  { title: "Dinheiro", value: "cash" },
  { title: "Cartão", value: "card" },
  { title: "Mercado Pago", value: "mercadopago" }
];
const isEditing = computed(() => Boolean(props.transaction?.id));
const required = (value) => !!String(value ?? "").trim() || "Campo obrigatório";
const requiredAmount = (value) => Number(String(value ?? "").replace(",", ".")) > 0 || "Informe um valor válido";

const reset = () => {
  form.patient = null;
  form.description = "Sessão terapêutica";
  form.amount = "";
  form.due_date = "";
  form.payment_method = "pix";
  form.account_id = "";
  formRef.value?.resetValidation();
};

const syncForm = (transaction) => {
  if (!transaction) {
    reset();
    return;
  }
  form.patient = transaction.patient ? { id: transaction.patient.id, name: transaction.patient.name } : null;
  form.description = transaction.description || "Sessão terapêutica";
  form.amount = transaction.amount != null ? String(transaction.amount) : "";
  form.due_date = transaction.due_date ? String(transaction.due_date).slice(0, 10) : "";
  form.payment_method = transaction.payment_method || "pix";
  form.account_id = transaction.account_id || "";
  formRef.value?.resetValidation();
};

const close = () => {
  dialog.value = false;
};

const save = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid) return;
  loading.value = true;
  try {
    const payload = {
      patient_id: form.patient?.id || props.transaction?.patient_id || null,
      description: form.description.trim(),
      amount: Number(String(form.amount).replace(",", ".")),
      due_date: form.due_date,
      payment_method: form.payment_method,
      account_id: form.account_id,
      status: props.transaction?.status || "pending",
      external_id: props.transaction?.external_id || null,
    };
    const { data } = isEditing.value ? await updateTransaction(props.transaction.id, payload) : await createTransaction(payload);
    emit("saved", data);
    emit("notify", isEditing.value ? { message: "Cobrança atualizada com sucesso" } : notifyPaymentCreated(data));
    close();
    reset();
  } finally {
    loading.value = false;
  }
};

watch(() => props.modelValue, (value) => {
  if (value) {
    syncForm(props.transaction);
  } else {
    reset();
  }
});

watch(() => props.transaction, (value) => {
  if (dialog.value) {
    syncForm(value);
  }
});
</script>
