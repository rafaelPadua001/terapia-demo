<template>
  <v-dialog :model-value="modelValue" persistent max-width="520">
    <v-card>
      <v-card-title class="text-h6 section-title">Primeiros passos</v-card-title>
      <v-card-text>
        <div class="text-overline mb-2">{{ activeStep.label }}</div>
        <div class="text-body-1">{{ activeStep.description }}</div>
        <div class="text-caption text-medium-emphasis mt-4">
          Passo {{ currentIndex + 1 }} de {{ steps.length }}
        </div>
      </v-card-text>
      <v-card-actions>
        <v-btn variant="text" :disabled="currentIndex === 0" @click="$emit('back')">
          Voltar
        </v-btn>
        <v-spacer />
        <v-btn color="primary" @click="$emit(currentIndex === steps.length - 1 ? 'finish' : 'next')">
          {{ currentIndex === steps.length - 1 ? "Concluir" : "Proximo" }}
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  steps: { type: Array, default: () => [] },
  currentIndex: { type: Number, default: 0 },
});

defineEmits(["back", "next", "finish"]);

const activeStep = computed(() => props.steps[props.currentIndex] || { label: "", description: "" });
</script>
