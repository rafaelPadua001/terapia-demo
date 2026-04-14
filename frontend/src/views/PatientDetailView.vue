<template>
  <MainLayout>
    <v-card title="Detalhe do Paciente">
      <v-card-text>
        <v-tabs v-model="tab">
          <v-tab value="dados">Dados Gerais</v-tab>
          <v-tab value="anamneses">Anamnese</v-tab>
          <v-tab value="avaliacoes">Avaliações</v-tab>
          <v-tab value="evolucoes">Evolução</v-tab>
          <v-tab value="responsaveis">Responsáveis</v-tab>
        </v-tabs>

        <v-window v-model="tab" class="mt-4">
          <v-window-item value="dados">
            <PatientForm
              v-if="patient && !isRestrictedUser"
              :model-value="patient"
              :show-guardians="true"
              :all-guardians="allGuardians"
              @submit="save"
            />
            <v-card v-else-if="patient" variant="outlined">
              <v-card-text>
                <div><strong>Nome:</strong> {{ patient.name }}</div>
                <div><strong>Código:</strong> {{ patient.patient_code }}</div>
                <div><strong>Nascimento:</strong> {{ patient.birth_date }}</div>
                <div><strong>CPF:</strong> {{ patient.cpf || '-' }}</div>
                <div><strong>Email:</strong> {{ patient.email || '-' }}</div>
                <div><strong>Celular:</strong> {{ formatPhone(patient.phone || '') || '-' }}</div>
                <div><strong>Diagnóstico:</strong> {{ patient.diagnosis || '-' }}</div>
                <div><strong>Observações:</strong> {{ patient.notes || '-' }}</div>
              </v-card-text>
            </v-card>
            <v-btn v-if="!isRestrictedUser" class="mt-2" color="error" @click="confirmDelete = true">
              <v-icon icon="fa-solid fa-trash" />
              Excluir
            </v-btn>
          </v-window-item>

          <v-window-item value="anamneses">
            <v-data-table :headers="anamHeaders" :items="anamneses">
              <template #item.data="{ item }">
                <div style="white-space: pre-line; min-width: 320px;">
                  {{ formatAnamneseResumo(item.data) }}
                </div>
              </template>
            </v-data-table>
          </v-window-item>

          <v-window-item value="avaliacoes">
            <v-data-table :headers="evalHeaders" :items="evaluations">
              <template #item.status="{ item }">
                <StatusChip :status="item.status" />
              </template>
            </v-data-table>
          </v-window-item>

          <v-window-item value="evolucoes">
            <v-data-table :headers="evoHeaders" :items="evolutions" />
          </v-window-item>

          <v-window-item value="responsaveis">
            <v-card variant="outlined">
              <v-card-title class="d-flex align-center justify-space-between">
                <span>Responsáveis</span>
                <v-btn v-if="!isRestrictedUser" color="success" size="small" @click="openGuardianCreate">
                  <v-icon icon="fa-solid fa-plus" />
                  Adicionar responsável
                </v-btn>
              </v-card-title>
              <v-card-text>
                <v-data-table
                  :headers="guardianHeaders"
                  :items="guardians"
                  :items-per-page="5"
                >
                  <template #item.phone="{ item }">
                    <span>{{ formatPhone(item.phone || "") }}</span>
                  </template>
                  <template #item.relationship_type="{ item }">
                    <span>{{ getGuardianRelationship(item) }}</span>
                  </template>
                  <template #item.actions="{ item }">
                    <template v-if="!isRestrictedUser">
                      <v-btn size="small" color="primary" @click="openGuardianEdit(item)">
                        <v-icon icon="fa-solid fa-pen" />
                        Editar
                      </v-btn>
                      <v-btn
                        icon
                        color="error"
                        size="small"
                        :loading="deletingGuardianId === item.id"
                        @click="askGuardianDelete(item)"
                      >
                        <v-icon icon="fa-solid fa-trash" />
                      </v-btn>
                    </template>
                    <span v-else>-</span>
                  </template>
                </v-data-table>
              </v-card-text>
            </v-card>
          </v-window-item>
        </v-window>
      </v-card-text>
    </v-card>

    <ConfirmDialog v-if="!isRestrictedUser" v-model="confirmDelete" message="Deseja excluir este paciente?" @confirm="remove" />
    <ConfirmDialog
      v-if="!isRestrictedUser"
      v-model="confirmGuardianDelete"
      message="Tem certeza que deseja excluir este registro?"
      @confirm="removeGuardian"
    />

    <v-dialog v-if="!isRestrictedUser" v-model="guardianDialog" max-width="620">
      <v-card>
        <v-card-title>{{ guardianForm.id ? "Editar responsável" : "Adicionar responsável" }}</v-card-title>
        <v-card-text>
          <v-text-field v-model="guardianForm.name" label="Nome" required />
          <v-text-field
            v-model="guardianForm.email"
            label="E-mail"
            placeholder="responsavel@exemplo.com"
          />
          <v-text-field
            v-model="guardianForm.phone"
            label="Telefone"
            placeholder="(00) 00000-0000"
            @update:modelValue="onGuardianPhoneInput"
          />
          <v-text-field v-model="guardianForm.relationship_type" label="Parentesco" />
          <v-text-field
            v-model="guardianForm.password"
            label="Senha inicial (opcional)"
            type="password"
            placeholder="Brasil2026"
            hint="Se ficar em branco, o sistema usa a senha padrão."
            persistent-hint
          />
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" color="grey" @click="guardianDialog = false">
            <v-icon icon="fa-solid fa-xmark" />
            Cancelar
          </v-btn>
          <v-btn color="success" :loading="savingGuardian" @click="saveGuardian">
            <v-icon icon="fa-solid fa-floppy-disk" />
            Salvar
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </MainLayout>
</template>

<script setup>
import { computed, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import MainLayout from "../layouts/MainLayout.vue";
import PatientForm from "../components/forms/PatientForm.vue";
import StatusChip from "../components/StatusChip.vue";
import ConfirmDialog from "../components/ConfirmDialog.vue";
import api from "../services/api";
import guardianService from "../services/guardianService";
import { formatAnamneseResumo } from "../utils/encoding";
import { formatPhone, formatPhoneInput, normalizePhone } from "../utils/phone";
import { useUiStore } from "../store/ui";
import { useAuthStore } from "../store/auth";
import { isRestrictedUser as isRestrictedUserRole } from "../composables/useAuth";

const auth = useAuthStore();
const ui = useUiStore();
const route = useRoute();
const router = useRouter();
const tab = ref("dados");
const patient = ref(null);
const confirmDelete = ref(false);
const isRestrictedUser = computed(() => isRestrictedUserRole(auth));

const anamneses = ref([]);
const evaluations = ref([]);
const evolutions = ref([]);
const guardians = ref([]);
const allGuardians = ref([]);

const guardianDialog = ref(false);
const confirmGuardianDelete = ref(false);
const deleteGuardianTarget = ref(null);
const deletingGuardianId = ref(null);
const savingGuardian = ref(false);

const guardianForm = reactive({
  id: null,
  name: "",
  email: "",
  phone: "",
  relationship_type: "",
  password: ""
});

const anamHeaders = [
  { title: "Criado em", key: "created_at" },
  { title: "Resumo", key: "data" }
];
const evalHeaders = [
  { title: "Tipo", key: "type" },
  { title: "Status", key: "status" }
];
const evoHeaders = [
  { title: "Descrição", key: "description" },
  { title: "Criado em", key: "created_at" }
];
const guardianHeaders = [
  { title: "Nome", key: "name" },
  { title: "E-mail", key: "email" },
  { title: "Telefone", key: "phone" },
  { title: "Parentesco", key: "relationship_type" },
  { title: "Ações", key: "actions", sortable: false }
];

const getGuardianRelationship = (guardian) =>
  guardian?.relationship_type || guardian?.relationship || "-";

const load = async () => {
  const { data } = await api.get(`/patients/${route.params.id}`);
  patient.value = data;

  const anam = await api.get("/anamneses", { params: { patient_id: route.params.id } });
  anamneses.value = anam.data.items;

  const evals = await api.get("/evaluations", { params: { patient_id: route.params.id } });
  evaluations.value = evals.data.items;

  const evo = await api.get("/evolutions", { params: { patient_id: route.params.id } });
  evolutions.value = evo.data.items;

  await loadGuardians();
  await loadAllGuardians();
};

const loadGuardians = async () => {
  guardians.value = await guardianService.listByPatient(route.params.id);
};

const loadAllGuardians = async () => {
  if (isRestrictedUser.value) return;
  allGuardians.value = await guardianService.listAll();
};

const save = async (payload) => {
  await api.put(`/patients/${route.params.id}`, payload);
  ui.notify("Paciente atualizado");
  await load();
};

const remove = async () => {
  await api.delete(`/patients/${route.params.id}`);
  ui.notify("Paciente removido");
  router.push("/patients");
};

const openGuardianCreate = () => {
  guardianForm.id = null;
  guardianForm.name = "";
  guardianForm.email = "";
  guardianForm.phone = "";
  guardianForm.relationship_type = "";
  guardianForm.password = "";
  guardianDialog.value = true;
};

const openGuardianEdit = (item) => {
  guardianForm.id = item.id;
  guardianForm.name = item.name || "";
  guardianForm.email = item.email || "";
  guardianForm.phone = formatPhone(item.phone || "");
  guardianForm.relationship_type = item.relationship_type || item.relationship || "";
  guardianForm.password = "";
  guardianDialog.value = true;
};

const onGuardianPhoneInput = (value) => {
  guardianForm.phone = formatPhoneInput(value);
};

const saveGuardian = async () => {
  savingGuardian.value = true;
  const payload = {
    name: guardianForm.name,
    email: guardianForm.email?.trim() || null,
    phone: normalizePhone(guardianForm.phone),
    relationship_type: guardianForm.relationship_type?.trim() || null,
    password: guardianForm.password?.trim() || null
  };
  try {
    if (guardianForm.id) {
      await guardianService.update(guardianForm.id, payload);
      ui.notify("Responsável atualizado");
    } else {
      payload.patient_id = route.params.id;
      await guardianService.create(payload);
      ui.notify("Responsável adicionado");
    }
    guardianDialog.value = false;
    await load();
    await loadGuardians();
    await loadAllGuardians();
  } catch {
    ui.notify("Erro ao salvar responsável", "error");
  }
  savingGuardian.value = false;
};

const askGuardianDelete = (item) => {
  deleteGuardianTarget.value = item;
  confirmGuardianDelete.value = true;
};

const removeGuardian = async () => {
  if (!deleteGuardianTarget.value) return;
  deletingGuardianId.value = deleteGuardianTarget.value.id;
  try {
    await guardianService.delete(deleteGuardianTarget.value.id);
    ui.notify("Registro excluído com sucesso");
    await loadGuardians();
  } catch {
    ui.notify("Erro ao excluir registro", "error");
  }
  deletingGuardianId.value = null;
  deleteGuardianTarget.value = null;
  confirmGuardianDelete.value = false;
};

load();
</script>
