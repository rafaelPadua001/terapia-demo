<template>
  <v-card class="financial-shell" rounded="xl" elevation="2">
    <v-card-text class="pa-0">
      <v-row no-gutters>
        <v-col cols="12" md="3" class="financial-sidebar">
          <div class="pa-5">
            <div class="text-h6 font-weight-bold">Financeiro</div>
            <div class="text-body-2 text-medium-emphasis mt-1">Gestão de cobranças e contas</div>
            <v-divider class="my-4" />
            <v-list density="compact" nav class="bg-transparent">
              <v-list-item
                to="/financial/dashboard"
                title="Dashboard"
                prepend-icon="fa-solid fa-chart-line"
                :class="[
                  'menu-item',
                  {
                    'active-menu': isActive({
                      to: '/financial/dashboard',
                      matchChildren: true
                    })
                  }
                ]"
              />
              <v-list-item
                to="/financial"
                title="Transações"
                prepend-icon="fa-solid fa-dollar-sign"
                :class="[
                  'menu-item',
                  {
                    'active-menu': isActive({
                      to: '/financial'
                    })
                  }
                ]"
              />
              <v-list-item
                to="/financial/accounts"
                title="Contas"
                prepend-icon="fa-solid fa-building-columns"
                :class="[
                  'menu-item',
                  {
                    'active-menu': isActive({
                      to: '/financial/accounts',
                      matchChildren: true
                    })
                  }
                ]"
              />
            </v-list>
          </div>
        </v-col>
        <v-col cols="12" md="9">
          <div class="pa-5">
            <div class="d-flex justify-end mb-4">
              <v-btn
                v-if="!mdAndDown"
                variant="text"
                prepend-icon="fa-solid fa-arrow-left"
                @click="router.push('/')"
              >
                Voltar ao início
              </v-btn>
              <v-btn
                v-else
                icon
                variant="text"
                @click="router.push('/')"
              >
                <i class="fas fa-arrow-left"></i>
              </v-btn>
            </div>
            <router-view />
          </div>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<script setup>
import { useDisplay } from "vuetify";
import { useRouter } from "vue-router";
import { useActiveMenu } from "../../composables/useActiveMenu";

const router = useRouter();
const { isActive } = useActiveMenu();
const { mdAndDown } = useDisplay();
</script>

<style scoped>
.financial-shell {
  overflow: hidden;
}

.financial-sidebar {
  min-height: 72vh;
  background: linear-gradient(180deg, #f8fbff 0%, #eef5ff 100%);
  border-right: 1px solid rgba(15, 23, 42, 0.08);
}

.menu-item :deep(.v-list-item--active),
:deep(.v-list-item--active) {
  background: transparent !important;
}

.menu-item :deep(.v-list-item--active::before),
:deep(.v-list-item--active::before) {
  opacity: 0 !important;
}

:deep(.active-menu) {
  border-left: 4px solid #4caf50;
  background-color: rgba(76, 175, 80, 0.1);
  color: inherit;
  font-weight: 500;
}

@media (max-width: 960px) {
  .financial-sidebar {
    min-height: auto;
    border-right: 0;
    border-bottom: 1px solid rgba(15, 23, 42, 0.08);
  }
}
</style>
