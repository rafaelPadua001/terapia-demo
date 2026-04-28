<template>
  <v-form ref="formRef" v-model="isValid" @submit.prevent="submit">
    <v-text-field v-model="form.type" label="Tipo" :rules="[required]" required />
    <div class="mb-4">
      <div class="text-caption text-medium-emphasis mb-2">Resultado</div>
      <RichTextEditor v-model="form.result" />
    </div>
    <v-btn color="success" type="submit">
      <v-icon icon="fa-solid fa-floppy-disk" />
      Salvar
    </v-btn>
  </v-form>
</template>

<script setup>
import { reactive, ref, watch } from "vue";
import RichTextEditor from "../editor/RichTextEditor.vue";
import { isRichTextEmpty, normalizeRichTextValue } from "../../utils/richText";

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ type: "", result: "" }),
  },
});
const emit = defineEmits(["submit"]);

const form = reactive({ ...props.modelValue });
const formRef = ref(null);
const isValid = ref(false);
const required = (value) => !!String(value ?? "").trim() || "Campo obrigatorio";

watch(
  () => props.modelValue,
  (value) => {
    Object.assign(form, value || {});
    form.result = normalizeRichTextValue(value?.result);
  },
  { immediate: true },
);

const submit = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid || isRichTextEmpty(form.result)) return;
  emit("submit", { type: form.type, result: normalizeRichTextValue(form.result) });
};
</script>
