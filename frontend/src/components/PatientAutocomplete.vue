<template>
  <v-autocomplete
    
    v-model="selected"
    v-model:search="search"
    :items="items"
    :loading="loading"
    item-title="label"
    item-value="id"
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
import { ref, watch, computed } from "vue";
import api from "../services/api";
import { isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";

const props = defineProps({
  modelValue: {
    type: String,
    default: ""
  },
  selectedPatient: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(["update:modelValue"]);

const selected = computed({
  get: () => props.modelValue,
  set: (value) => emit("update:modelValue", value)
});

const search = ref("");
const items = ref([]);
const loading = ref(false);
const selectedItem = ref(null);
let timeoutId = null;
let lastQuery = "";
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));

const normalizePatient = (patient) => {
  if (!patient?.id) return null;

  const name = patient.name || "Paciente";
  const patientCode = patient.patient_code || null;

  return {
    id: patient.id,
    name,
    patient_code: patientCode,
    birth_date: patient.birth_date || null,
    label: `${name} - ${patientCode || "Sem código"}`
  };
};

const syncSelectedItem = (patient) => {
  const normalized = normalizePatient(patient);
  if (!normalized) return;

  selectedItem.value = normalized;
  if (!items.value.some((item) => item.id === normalized.id)) {
    items.value = [normalized, ...items.value];
  }
};

const fetchPatients = async (term) => {
  loading.value = true;
  try {
    const { data } = await api.get("/patients/search", { params: { q: term } });
    items.value = data.map(normalizePatient).filter(Boolean);
    if (selected.value) {
      const match = items.value.find((item) => item.id === selected.value);
      if (match) selectedItem.value = match;
    }
  } catch {
    items.value = [];
  }
  loading.value = false;
};

watch(selected, (value) => {
  if (!value) {
    selectedItem.value = null;
    return;
  }

  const match = items.value.find((item) => item.id === value);
  if (match) {
    selectedItem.value = match;
    return;
  }

  syncSelectedItem(props.selectedPatient);
});

watch(search, (value) => {
  if (timeoutId) {
    clearTimeout(timeoutId);
  }

  if (!value) {
    items.value = selectedItem.value ? [selectedItem.value] : [];
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
    if (!value || !selected.value) return;
    syncSelectedItem(value);
  },
  { immediate: true }
);
</script>
