<script setup>
import { computed } from "vue";

const props = defineProps({
  icon: { type: Object, required: true },
  size: { type: [Number, String], default: 20 },
});

const strokeWidth = computed(() => Number(props.icon.strokeWidth || 2));
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-linecap="round"
    stroke-linejoin="round"
    :stroke-width="strokeWidth"
    aria-hidden="true"
  >
    <component
      v-for="(segment, index) in icon.iconNode"
      :is="segment[0]"
      :key="index"
      v-bind="segment[1]"
    />
  </svg>
</template>
