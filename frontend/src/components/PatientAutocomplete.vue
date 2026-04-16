<template>
  <v-autocomplete
    v-model="selectedObject"
    v-model:search="search"
    :items="items"
    :loading="loading"
    item-title="label"
    return-object
    clearable
    hide-details="auto"
    label="Buscar paciente"
    no-data-text="Nenhum paciente encontrado"
  >
    <template #item="{ props, item }">
      <v-list-item v-bind="props" :title="item.raw.label" />
    </template>
    <template #selection="{ item }">
      <span>{{ item.raw.label }}</span>
    </template>
  </v-autocomplete>
</template>

<script setup>
import { ref, watch } from "vue";
import api from "../services/api";

const props = defineProps({
  modelValue: {
    type: [String, Object],
    default: ""
  },
  returnObject: {
    type: Boolean,
    default: false
  },
  selectedPatient: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(["update:modelValue"]);

const search = ref("");
const items = ref([]);
const loading = ref(false);
const selectedObject = ref(null);
let timeoutId = null;
let lastQuery = "";
let lastEmittedId = null;

const normalizePatient = (patient) => {
  if (!patient?.id) return null;
  const name = patient.name || "Paciente";
  const patientCode = patient.patient_code || null;
  return {
    id: patient.id,
    name,
    patient_code: patientCode,
    birth_date: patient.birth_date || null,
    label: `${name}${patientCode ? ` - ${patientCode}` : ""}`
  };
};

const syncSelectedPatient = (patient) => {
  const normalized = normalizePatient(patient);
  if (!normalized) return;
  selectedObject.value = normalized;
  if (!items.value.some((item) => item.id === normalized.id)) {
    items.value = [normalized, ...items.value];
  }
};

const fetchPatients = async (term) => {
  loading.value = true;
  try {
    const { data } = await api.get("/patients/search", { params: { q: term } });
    items.value = (Array.isArray(data) ? data : []).map(normalizePatient).filter(Boolean);
    if (selectedObject.value) {
      const match = items.value.find((item) => item.id === selectedObject.value.id);
      if (match) selectedObject.value = match;
    }
  } catch {
    items.value = [];
  } finally {
    loading.value = false;
  }
};

watch(
  () => props.modelValue,
  (value) => {
    if (!value) {
      selectedObject.value = null;
      lastEmittedId = null;
      return;
    }

    if (typeof value === "object" && value?.id) {
      if (selectedObject.value?.id === value.id) {
        return;
      }
      syncSelectedPatient(value);
      return;
    }

    const match = items.value.find((item) => item.id === value);
    if (match) {
      if (selectedObject.value?.id === match.id) {
        return;
      }
      selectedObject.value = match;
    }
  },
  { immediate: true }
);

watch(selectedObject, (value) => {
  if (!value) {
    lastEmittedId = null;
    emit("update:modelValue", "");
    return;
  }

  if (value.id && value.id === lastEmittedId) {
    return;
  }

  lastEmittedId = value.id || null;
  emit("update:modelValue", props.returnObject ? value : value.id);
});

watch(search, (value) => {
  if (timeoutId) clearTimeout(timeoutId);

  if (!value) {
    lastQuery = "";
    return;
  }

  timeoutId = setTimeout(() => {
    if (value === lastQuery) return;
    lastQuery = value;
    fetchPatients(value);
  }, 300);
});

watch(
  () => props.selectedPatient,
  (value) => {
    if (value?.id) syncSelectedPatient(value);
  },
  { immediate: true }
);
</script>
