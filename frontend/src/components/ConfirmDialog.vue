<template>
  <v-dialog :model-value="modelValue" max-width="420" @update:modelValue="emit('update:modelValue', $event)">
    <v-card>
      <v-card-title>Confirmar ação</v-card-title>
      <v-card-text>{{ message }}</v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" color="grey" @click="cancel">
          <v-icon icon="fa-solid fa-xmark" />
          Cancelar
        </v-btn>
        <v-btn color="error" @click="confirm">
          <v-icon icon="fa-solid fa-trash" />
          Confirmar
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
const props = defineProps({
  modelValue: Boolean,
  message: String
});

const emit = defineEmits(["update:modelValue", "confirm"]);

const cancel = () => emit("update:modelValue", false);
const confirm = () => emit("confirm");
</script>
