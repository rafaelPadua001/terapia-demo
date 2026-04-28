<template>
  <v-form ref="formRef" v-model="isValid" @submit.prevent="submit">
    <div v-for="(section, sectionIndex) in schema.sections" :key="sectionIndex" class="mb-4">
      <h3 class="mb-3">{{ section.title }}</h3>
      <div v-for="(field, fieldIndex) in section.fields" :key="fieldIndex" class="mb-4">
        <v-text-field
          v-if="field.type === 'text'"
          v-model="formValues[fieldKey(sectionIndex, fieldIndex)]"
          :label="field.label"
          :rules="[required]"
        />
        <div v-else-if="field.type === 'textarea'">
          <div class="text-caption text-medium-emphasis mb-2">{{ field.label }}</div>
          <RichTextEditor v-model="formValues[fieldKey(sectionIndex, fieldIndex)]" />
        </div>
        <v-select
          v-else-if="field.type === 'select'"
          v-model="formValues[fieldKey(sectionIndex, fieldIndex)]"
          :label="field.label"
          :items="field.options || []"
          :rules="[required]"
        />
      </div>
    </div>
    <v-btn color="success" type="submit">
      <v-icon icon="fa-solid fa-floppy-disk" />
      Salvar
    </v-btn>
  </v-form>
</template>

<script setup>
import { reactive, ref } from "vue";
import RichTextEditor from "../editor/RichTextEditor.vue";
import { isRichTextEmpty } from "../../utils/richText";

const props = defineProps({
  schema: {
    type: Object,
    default: () => ({
      sections: [
        {
          title: "Historico Familiar",
          fields: [
            { type: "text", label: "Doencas na familia" },
            { type: "textarea", label: "Observacoes" },
          ],
        },
      ],
    }),
  },
});

const emit = defineEmits(["submit"]);

const formValues = reactive({});
const formRef = ref(null);
const isValid = ref(false);
const required = (value) => !!String(value ?? "").trim() || "Campo obrigatorio";
const fieldKey = (sectionIndex, fieldIndex) => `${sectionIndex}-${fieldIndex}`;

const hasRequiredValue = (field, key) => {
  if (field.type === "textarea") return !isRichTextEmpty(formValues[key]);
  return !!String(formValues[key] ?? "").trim();
};

const submit = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid) return;

  const missingField = props.schema.sections.some((section, sectionIndex) =>
    (section.fields || []).some((field, fieldIndex) => !hasRequiredValue(field, fieldKey(sectionIndex, fieldIndex))),
  );
  if (missingField) return;

  emit("submit", { ...props.schema, values: { ...formValues } });
};
</script>
