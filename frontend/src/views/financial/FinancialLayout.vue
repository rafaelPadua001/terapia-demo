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
              <v-list-item to="/financial/dashboard" title="Dashboard" prepend-icon="fa-solid fa-chart-line" />
              <v-list-item to="/financial" title="Transações" prepend-icon="fa-solid fa-dollar-sign" />
              <v-list-item to="/financial/accounts" title="Contas" prepend-icon="fa-solid fa-building-columns" />
            </v-list>
          </div>
        </v-col>
        <v-col cols="12" md="9">
          <div class="pa-5">
            <router-view />
          </div>
        </v-col>
      </v-row>
    </v-card-text>
  </v-card>
</template>

<style scoped>
.financial-shell { overflow: hidden; }
.financial-sidebar {
  min-height: 72vh;
  background: linear-gradient(180deg, #f8fbff 0%, #eef5ff 100%);
  border-right: 1px solid rgba(15, 23, 42, 0.08);
}
</style>
