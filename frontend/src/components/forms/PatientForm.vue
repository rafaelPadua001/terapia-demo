<template>
  <v-form @submit.prevent="submit">
    <v-text-field v-if="form.patient_code" v-model="form.patient_code" label="Código do paciente" readonly />
    <v-text-field v-model="form.name" label="Nome" required />
    <v-text-field v-model="form.birth_date" label="Data de nascimento" type="date" required />
    <v-text-field
      v-model="form.cpf"
      label="CPF (opcional)"
      placeholder="000.000.000-00"
      :rules="cpfRules"
      @update:modelValue="onCpfInput"
    />
    <v-text-field
      v-model="form.email"
      label="E-mail (opcional)"
      placeholder="paciente@exemplo.com"
      type="email"
    />
    <v-text-field
      v-model="form.phone"
      label="Celular"
      placeholder="(00) 00000-0000"
      :rules="phoneRules"
      @update:modelValue="onPhoneInput"
    />
    <v-text-field
      v-model="form.password"
      label="Senha inicial (opcional)"
      type="password"
      placeholder="Brasil2026"
      hint="Se deixar em branco, o sistema usa a senha padrão."
      persistent-hint
    />
    <v-text-field v-model="form.diagnosis" label="Diagnóstico" />
    <v-textarea v-model="form.notes" label="Observações" />

    <v-autocomplete
      v-if="showGuardians"
      v-model="form.guardian_ids"
      :items="guardianOptions"
      item-title="label"
      item-value="id"
      label="Responsáveis"
      chips
      closable-chips
      multiple
      clearable
      hint="Selecione um ou mais responsáveis já cadastrados."
      persistent-hint
    />

    <v-btn v-if="showGuardians" class="mt-2" color="primary" variant="outlined" @click="guardianDialog = true">
      <v-icon icon="fa-solid fa-user-plus" />
      Adicionar novo responsável
    </v-btn>

    <v-chip v-if="form.new_guardian?.name" class="mt-2" color="primary" variant="tonal">
      Novo responsável: {{ form.new_guardian.name }}
    </v-chip>

    <v-btn class="mt-4" color="success" type="submit">
      <v-icon icon="fa-solid fa-floppy-disk" />
      Salvar
    </v-btn>
  </v-form>

  <v-dialog v-model="guardianDialog" max-width="520">
    <v-card>
      <v-card-title>Novo responsável</v-card-title>
      <v-card-text>
        <v-text-field v-model="newGuardian.name" label="Nome" required />
        <v-text-field v-model="newGuardian.email" label="E-mail" type="email" />
        <v-text-field
          v-model="newGuardian.phone"
          label="Telefone"
          placeholder="(00) 00000-0000"
          @update:modelValue="onNewGuardianPhoneInput"
        />
        <v-text-field v-model="newGuardian.relationship_type" label="Parentesco" />
        <v-text-field
          v-model="newGuardian.password"
          label="Senha inicial (opcional)"
          type="password"
          placeholder="Brasil2026"
        />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" color="grey" @click="guardianDialog = false">Cancelar</v-btn>
        <v-btn color="success" @click="applyNewGuardian">Adicionar</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { formatCpf, formatCpfInput, isValidCpf, normalizeCpf } from "../../utils/cpf";
import { formatPhone, formatPhoneInput, normalizePhone } from "../../utils/phone";

const NEW_GUARDIAN_ID = "__new_guardian__";

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({
      name: "",
      birth_date: "",
      diagnosis: "",
      notes: "",
      cpf: "",
      email: "",
      phone: "",
      password: "",
      patient_code: "",
      guardians: [],
      guardian_ids: [],
      new_guardian: null
    })
  },
  showGuardians: {
    type: Boolean,
    default: true
  },
  allGuardians: {
    type: Array,
    default: () => []
  }
});
const emit = defineEmits(["submit"]);

const normalizeGuardianIds = (value) => {
  const ids = Array.isArray(value?.guardian_ids) && value.guardian_ids.length
    ? value.guardian_ids
    : (value?.guardians || []).map((guardian) => guardian.id).filter(Boolean);
  if (value?.new_guardian?.name && !ids.includes(NEW_GUARDIAN_ID)) {
    return [...ids, NEW_GUARDIAN_ID];
  }
  return ids;
};

const form = reactive({
  ...props.modelValue,
  email: props.modelValue?.email || "",
  password: "",
  guardian_ids: normalizeGuardianIds(props.modelValue),
  new_guardian: props.modelValue?.new_guardian || null
});
form.cpf = formatCpf(form.cpf || "");
form.phone = formatPhone(form.phone || "");

const guardianDialog = ref(false);
const newGuardian = reactive({
  name: "",
  email: "",
  phone: "",
  relationship_type: "",
  password: ""
});

watch(
  () => props.modelValue,
  (value) => {
    Object.assign(form, value || {});
    form.cpf = formatCpf(value?.cpf || "");
    form.email = value?.email || "";
    form.phone = formatPhone(value?.phone || "");
    form.password = "";
    form.guardian_ids = normalizeGuardianIds(value);
    form.new_guardian = value?.new_guardian || null;
  }
);

const guardianOptions = computed(() => {
  const items = (props.allGuardians || []).map((guardian) => ({
    id: guardian.id,
    label: guardian.relationship_type
      ? `${guardian.name} (${guardian.relationship_type})`
      : guardian.name || "Responsável"
  }));

  if (form.new_guardian?.name) {
    items.push({ id: NEW_GUARDIAN_ID, label: `${form.new_guardian.name} (novo)` });
  }

  return items;
});

const cpfRules = computed(() => [
  (value) => {
    if (!value) return true;
    return isValidCpf(value) || "CPF inválido";
  }
]);

const phoneRules = computed(() => [
  (value) => {
    if (!value) return true;
    const digits = normalizePhone(value);
    return digits && (digits.length === 10 || digits.length === 11) ? true : "Telefone inválido";
  }
]);

const onCpfInput = (value) => {
  form.cpf = formatCpfInput(value);
};

const onPhoneInput = (value) => {
  form.phone = formatPhoneInput(value);
};

const onNewGuardianPhoneInput = (value) => {
  newGuardian.phone = formatPhoneInput(value);
};

const resetNewGuardian = () => {
  newGuardian.name = "";
  newGuardian.email = "";
  newGuardian.phone = "";
  newGuardian.relationship_type = "";
  newGuardian.password = "";
};

const applyNewGuardian = () => {
  if (!newGuardian.name?.trim()) return;
  form.new_guardian = {
    name: newGuardian.name.trim(),
    email: newGuardian.email?.trim() || null,
    phone: normalizePhone(newGuardian.phone),
    relationship_type: newGuardian.relationship_type?.trim() || null,
    password: newGuardian.password?.trim() || null
  };
  if (!form.guardian_ids.includes(NEW_GUARDIAN_ID)) {
    form.guardian_ids = [...form.guardian_ids, NEW_GUARDIAN_ID];
  }
  guardianDialog.value = false;
  resetNewGuardian();
};

const submit = () => {
  const { patient_code, guardians, ...payload } = form;
  payload.cpf = normalizeCpf(form.cpf);
  payload.email = form.email?.trim() || null;
  payload.phone = normalizePhone(form.phone);
  payload.password = form.password?.trim() || null;
  payload.guardian_ids = Array.isArray(form.guardian_ids)
    ? form.guardian_ids.filter((value) => value && value !== NEW_GUARDIAN_ID)
    : [];
  payload.new_guardian = form.new_guardian;

  emit("submit", { ...payload });
};
</script>
