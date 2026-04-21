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
                    Cadastre terapeutas da clínica. A senha é opcional e, se ficar vazia, o sistema usa
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
                  <v-text-field v-model="form.phone" label="Telefone" placeholder="(11) 99999-9999" maxlength="15" :rules="[required, phoneRule]" @update:modelValue="onPhoneInput" />
                </v-col>
                <v-col cols="12" md="6">
                  <v-text-field v-model="form.specialty" label="Especialidade" placeholder="Ex.: Terapia ocupacional" :rules="[required]" />
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
import { onMounted, reactive, ref } from "vue";
import MainLayout from "../layouts/MainLayout.vue";
import api from "../services/api";
import { useUiStore } from "../store/ui";
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
const form = reactive({ name: "", email: "", phone: "", specialty: "", password: "" });

const headers = [
  { title: "Nome", key: "name" },
  { title: "E-mail", key: "email" },
  { title: "Telefone", key: "phone" },
  { title: "Especialidade", key: "specialty" },
  { title: "Ações", key: "actions", sortable: false },
];

const required = (value) => !!String(value ?? "").trim() || "Campo obrigatório";
const emailRule = (value) => /.+@.+\..+/.test(String(value ?? "").trim()) || "E-mail inválido";
const phoneRule = (value) => {
  const digits = normalizePhone(value);
  return digits && (digits.length === 10 || digits.length === 11) ? true : "Telefone inválido";
};

const onPhoneInput = (value) => {
  form.phone = formatPhoneInput(value);
};

const load = async () => {
  loading.value = true;
  try {
    const { data } = await api.get("/users", { params: { role: "therapist" } });
    items.value = data.map((item) => ({ ...item, phone: formatPhone(item.phone || "") }));
  } catch {
    ui.notify("Erro ao carregar terapeutas", "error");
  }
  loading.value = false;
};

const submit = async () => {
  const { valid } = await formRef.value.validate();
  if (!valid) return;
  saving.value = true;
  try {
    const payload = {
      name: form.name.trim(),
      email: form.email.trim(),
      phone: normalizePhone(form.phone),
      specialty: form.specialty.trim() || null,
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
  } catch {
    ui.notify(`Erro ao ${editingId.value ? "atualizar" : "cadastrar"} terapeuta`, "error");
  }
  saving.value = false;
};

const editTherapist = (item) => {
  editingId.value = item.id;
  tab.value = "form";
  form.name = item.name || "";
  form.email = item.email || "";
  form.phone = formatPhone(item.phone || "");
  form.specialty = item.specialty || "";
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
  form.phone = "";
  form.specialty = "";
  form.password = "";
  tab.value = "form";
  formRef.value?.resetValidation();
};

onMounted(load);
</script>
