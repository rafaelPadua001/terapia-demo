<template>
  <v-form @submit.prevent="submit">
    <v-text-field v-model="form.type" label="Tipo" required />
    <v-textarea v-model="form.result" label="Resultado" rows="3" required />
    <v-btn color="success" type="submit">
      <v-icon>
        <span class="material-symbols-outlined">save</span>
      </v-icon>
      Salvar
    </v-btn>
  </v-form>
</template>

<script setup>
import { reactive, watch } from "vue";

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ type: "", result: "" })
  }
});
const emit = defineEmits(["submit"]);

const form = reactive({ ...props.modelValue });

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

const submit = () => {
  emit("submit", { type: form.type, result: form.result });
};
</script>
