<template>
  <v-chip :color="color" size="small" label dark>{{ label }}</v-chip>
</template>

<script setup>
import { computed } from "vue";
import { getStatusColor, getValidationStatusLabel } from "../utils/status";

const props = defineProps({
  status: { type: String, required: true }
});

const color = computed(() => getStatusColor(props.status));
const label = computed(() => getValidationStatusLabel(props.status));
</script>
