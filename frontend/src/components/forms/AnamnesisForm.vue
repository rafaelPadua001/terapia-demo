<template>
  <v-form @submit.prevent="submit">
    <div v-for="(section, sIndex) in schema.sections" :key="sIndex">
      <h3>{{ section.title }}</h3>
      <div v-for="(field, fIndex) in section.fields" :key="fIndex">
        <v-text-field
          v-if="field.type === 'text'"
          v-model="formValues[`${sIndex}-${fIndex}`]"
          :label="field.label"
        />
        <v-textarea
          v-else-if="field.type === 'textarea'"
          v-model="formValues[`${sIndex}-${fIndex}`]"
          :label="field.label"
        />
        <v-select
          v-else-if="field.type === 'select'"
          v-model="formValues[`${sIndex}-${fIndex}`]"
          :label="field.label"
          :items="field.options || []"
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
import { reactive } from "vue";

const props = defineProps({
  schema: {
    type: Object,
    default: () => ({
      sections: [
        {
          title: "Histórico Familiar",
          fields: [
            { type: "text", label: "Doenças na família" },
            { type: "textarea", label: "Observações" }
          ]
        }
      ]
    })
  }
});

const emit = defineEmits(["submit"]);

const formValues = reactive({});

const submit = () => {
  emit("submit", { ...props.schema, values: { ...formValues } });
};
</script>
