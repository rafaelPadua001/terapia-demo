<template>
  <v-form ref="formRef" v-model="isValid" @submit.prevent="submit">
    <v-text-field v-model="form.type" label="Tipo" :rules="[required]" required />
    <v-textarea v-model="form.result" label="Resultado" rows="3" :rules="[required]" required />
    <v-btn color="success" type="submit">
      <v-icon icon="fa-solid fa-floppy-disk" />
      Salvar
    </v-btn>
  </v-form>
</template>

<script setup>
import { reactive, ref, watch } from "vue";

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ type: "", result: "" })
  }
});
const emit = defineEmits(["submit"]);

const form = reactive({ ...props.modelValue });
const formRef = ref(null);
const isValid = ref(false);
const required = (value) => !!String(value ?? "").trim() || "Campo obrigatório";

const normalizeResult = (value) => {
  if (value && typeof value === "object") {
    if (value.value) return String(value.value);
    if (value.raw) return String(value.raw);
    return JSON.stringify(value);
  }
  return value ?? "";
};

watch(
  () => props.modelValue,
  (value) => {
    Object.assign(form, value || {});
    form.result = normalizeResult(value?.result);
  }
);

const submit = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid) return;
  emit("submit", { type: form.type, result: form.result });
};
</script>
