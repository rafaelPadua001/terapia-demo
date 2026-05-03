<template>
  <MainLayout>
    <v-card title="Terapeutas">
      <v-card-text>
        <v-tabs v-model="tab" bg-color="trasparent" class="mb-4">
          <v-tab value="list">Lista</v-tab>
          <v-tab value="form">Cadastro</v-tab>
        </v-tabs>

        <v-window v-model="tab">
          <v-window-item value="list">
            <v-data-table :headers="headers" :items="items" :loading="loading">
              <template #item.actions="{ item }">
                <div class="d-flex ga-2">
                  <v-btn size="small" variant="tonal" color="primary" @click="editTherapist(item)">
                    Editar
                  </v-btn>
                  <v-btn size="small" variant="tonal" color="error" @click="confirmDelete(item)">
                    Remover
                  </v-btn>
                </div>
              </template>
            </v-data-table>
          </v-window-item>

          <v-window-item value="form">
            <v-form ref="formRef" v-model="isValid" class="mb-6" @submit.prevent="submit">
              <v-row>
                <v-col cols="12">
                  <div class="text-body-2 mb-4" style="color: #5e7c78;">
                    Cadastre terapeutas da clinica. A senha e opcional e, se ficar vazia, o sistema usa
                    <strong>Brasil2026</strong>.
                  </div>
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field v-model="form.name" label="Nome completo" placeholder="Ex.: Mariana Souza" :rules="[required]" required />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field v-model="form.email" label="E-mail" type="email" placeholder="terapeuta@clinica.com" :rules="[required, emailRule]" required />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="form.cpf"
                    label="CPF"
                    placeholder="000.000.000-00"
                    maxlength="14"
                    :rules="[required, cpfRule]"
                    @update:modelValue="onCpfInput"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="form.phone"
                    label="Telefone"
                    placeholder="(11) 99999-9999"
                    maxlength="15"
                    :rules="[required, phoneRule]"
                    @update:modelValue="onPhoneInput"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-select
                    v-model="form.specialty"
                    label="Especialidade"
                    :items="specialties"
                    item-title="label"
                    item-value="value"
                    :rules="[required]"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-select
                    v-model="form.registration_type"
                    label="Tipo de registro"
                    :items="registrationOptions"
                    :disabled="registrationOptions.length === 1"
                    :rules="[required]"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field
                    v-model="form.professional_registration"
                    :label="registrationLabel"
                    placeholder="Ex.: 12345"
                    maxlength="20"
                    :rules="[required, registrationRule]"
                    @update:modelValue="onProfessionalRegistrationInput"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field v-model="form.password" label="Senha" type="password" placeholder="Senha opcional" hint="Opcional. Se ficar vazio, usa Brasil2026." persistent-hint />
                </v-col>
              </v-row>

              <div class="d-flex justify-end ga-2 mt-4 flex-wrap">
                <v-btn variant="outlined" color="secondary" @click="resetForm">Cancelar</v-btn>
                <v-btn color="primary" type="submit" :loading="saving">{{ editingId ? "Salvar" : "Cadastrar" }}</v-btn>
              </div>
            </v-form>
          </v-window-item>
        </v-window>
      </v-card-text>
    </v-card>

    <v-dialog v-model="deleteDialog" max-width="420">
      <v-card>
        <v-card-title>Remover terapeuta</v-card-title>
        <v-card-text>Tem certeza que deseja remover este terapeuta?</v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="deleteDialog = false">Cancelar</v-btn>
          <v-btn color="error" :loading="deleting" @click="removeTherapist">Remover</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </MainLayout>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue";

import MainLayout from "../layouts/MainLayout.vue";
import api from "../services/api";
import { useUiStore } from "../store/ui";
import { formatCpf, formatCpfInput, isValidCpf, normalizeCpf } from "../utils/cpf";
import { formatPhone, formatPhoneInput, normalizePhone } from "../utils/phone";

const ui = useUiStore();
const loading = ref(false);
const saving = ref(false);
const deleting = ref(false);
const items = ref([]);
const editingId = ref(null);
const deleteDialog = ref(false);
const deleteTarget = ref(null);
const tab = ref("list");
const formRef = ref(null);
const isValid = ref(false);

const specialties = [
  { label: "Psicologa", value: "psicologa" },
  { label: "Pedagoga", value: "pedagoga" },
  { label: "Psicopedagoga", value: "psicopedagoga" },
  { label: "Neuropsicologo", value: "neuropsicologo" },
  { label: "Terapeuta ABA", value: "terapeuta aba" },
  { label: "Fonoaudiologa", value: "fonoaudiologa" },
  { label: "Psiquiatra", value: "psiquiatra" },
];

const specialtyRegistrationMap = {
  psicologa: ["CRP"],
  pedagoga: ["MEC"],
  psicopedagoga: ["ABPP"],
  neuropsicologo: ["CFP"],
  "terapeuta aba": ["CRP", "CREFONO", "CREFITO"],
  fonoaudiologa: ["CREFONO", "CFFA"],
  psiquiatra: ["CRM"],
};

const registrationRegexMap = {
  CRP: /^\d{2,6}$/,
  CRM: /^\d{4,6}$/,
  CREFONO: /^\d{4,6}$/,
  CFFA: /^\d{4,6}$/,
  CREFITO: /^\d{4,6}$/,
  MEC: /^[A-Za-z0-9\-\/]{1,20}$/,
  ABPP: /^[A-Za-z0-9\-\/]{1,20}$/,
  CFP: /^[A-Za-z0-9\-\/]{1,20}$/,
};

const form = reactive({
  name: "",
  email: "",
  cpf: "",
  phone: "",
  specialty: "",
  registration_type: "",
  professional_registration: "",
  password: "",
});

const headers = [
  { title: "Nome", key: "name" },
  { title: "E-mail", key: "email" },
  { title: "CPF", key: "cpf" },
  { title: "Telefone", key: "phone" },
  { title: "Especialidade", key: "specialty" },
  { title: "Registro", key: "professional_registration" },
  { title: "Acoes", key: "actions", sortable: false },
];

const required = (value) => !!String(value ?? "").trim() || "Campo obrigatorio";
const emailRule = (value) => /.+@.+\..+/.test(String(value ?? "").trim()) || "E-mail invalido";
const cpfRule = (value) => {
  const normalized = normalizeCpf(value);
  return normalized && isValidCpf(normalized) ? true : "CPF invalido";
};
const phoneRule = (value) => {
  const digits = normalizePhone(value);
  return digits && (digits.length === 10 || digits.length === 11) ? true : "Telefone invalido";
};

const registrationOptions = computed(() => specialtyRegistrationMap[form.specialty] || []);
const registrationLabel = computed(() => {
  const labels = {
    psicologa: "CRP",
    psiquiatra: "CRM",
    fonoaudiologa: "CREFONO/CFFA",
    terapeuta_aba: "CRP/CREFONO/CREFITO",
  };
  const specialty = String(form.specialty || "").replace(/\s+/g, "_");
  return labels[specialty] || "Registro profissional";
});
const registrationRule = (value) => {
  if (!form.registration_type) return "Selecione o tipo de registro";
  const regex = registrationRegexMap[form.registration_type];
  if (!regex) return "Tipo de registro invalido";
  return regex.test(String(value || "").trim()) ? true : "Registro profissional invalido";
};

watch(
  () => form.specialty,
  (specialty) => {
    const options = specialtyRegistrationMap[specialty] || [];
    if (!options.includes(form.registration_type)) {
      form.registration_type = options.length === 1 ? options[0] : "";
    }
  },
);

const onPhoneInput = (value) => {
  form.phone = formatPhoneInput(value);
};

const onCpfInput = (value) => {
  form.cpf = formatCpfInput(value);
};

const onProfessionalRegistrationInput = (value) => {
  form.professional_registration = String(value || "").toUpperCase().slice(0, 20);
};

const load = async () => {
  loading.value = true;
  try {
    const { data } = await api.get("/users", { params: { role: "therapist" } });
    items.value = data.map((item) => ({
      ...item,
      cpf: formatCpf(item.cpf || ""),
      phone: formatPhone(item.phone || ""),
    }));
  } catch {
    ui.notify("Erro ao carregar terapeutas", "error");
  }
  loading.value = false;
};

const submit = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid) return;
  if (!isValidCpf(normalizeCpf(form.cpf))) {
    ui.notify("CPF invalido", "error");
    return;
  }
  saving.value = true;
  try {
    const payload = {
      name: form.name.trim(),
      email: form.email.trim(),
      cpf: normalizeCpf(form.cpf),
      phone: normalizePhone(form.phone),
      specialty: form.specialty.trim() || null,
      registration_type: form.registration_type || null,
      professional_registration: form.professional_registration.trim() || null,
      password: form.password || null,
    };
    if (editingId.value) {
      await api.put(`/users/therapists/${editingId.value}`, payload);
      ui.notify("Terapeuta atualizado com sucesso");
    } else {
      await api.post("/users/therapists", payload);
      ui.notify("Terapeuta cadastrado com sucesso");
    }
    resetForm();
    tab.value = "list";
    await load();
  } catch (error) {
    const message = error?.response?.data?.detail || `Erro ao ${editingId.value ? "atualizar" : "cadastrar"} terapeuta`;
    ui.notify(message, "error");
  }
  saving.value = false;
};

const editTherapist = (item) => {
  editingId.value = item.id;
  tab.value = "form";
  form.name = item.name || "";
  form.email = item.email || "";
  form.cpf = formatCpf(item.cpf || "");
  form.phone = formatPhone(item.phone || "");
  form.specialty = item.specialty || "";
  form.registration_type = item.registration_type || "";
  form.professional_registration = item.professional_registration || "";
  form.password = "";
};

const confirmDelete = (item) => {
  deleteTarget.value = item;
  deleteDialog.value = true;
};

const removeTherapist = async () => {
  if (!deleteTarget.value) return;
  deleting.value = true;
  try {
    await api.delete(`/users/therapists/${deleteTarget.value.id}`);
    ui.notify("Terapeuta removido com sucesso");
    if (editingId.value === deleteTarget.value.id) {
      resetForm();
    }
    await load();
  } catch {
    ui.notify("Erro ao remover terapeuta", "error");
  }
  deleting.value = false;
  deleteDialog.value = false;
  deleteTarget.value = null;
};

const resetForm = () => {
  editingId.value = null;
  form.name = "";
  form.email = "";
  form.cpf = "";
  form.phone = "";
  form.specialty = "";
  form.registration_type = "";
  form.professional_registration = "";
  form.password = "";
  tab.value = "form";
  formRef.value?.resetValidation();
};

onMounted(load);
</script>
