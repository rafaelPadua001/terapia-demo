import { createRouter, createWebHistory } from "vue-router";

import { useAuthStore } from "../store/auth";

import LoginView from "../views/LoginView.vue";
import ConfirmEmailView from "../views/ConfirmEmailView.vue";
import DashboardView from "../views/DashboardView.vue";
import PatientsView from "../views/PatientsView.vue";
import PatientDetailView from "../views/PatientDetailView.vue";
import AnamnesesView from "../views/AnamnesesView.vue";
import EvaluationsView from "../views/EvaluationsView.vue";
import ValidationsView from "../views/ValidationsView.vue";
import EvolutionsView from "../views/EvolutionsView.vue";
import AppointmentsView from "../views/AppointmentsView.vue";

const getHomePathByRole = (role) => {
  if (role === "patient" || role === "guardian") return "/portal";
  return "/dashboard";
};

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/login", component: LoginView },
    { path: "/confirm-email", component: ConfirmEmailView },
    { path: "/", redirect: () => getHomePathByRole(useAuthStore().role) },
    { path: "/dashboard", component: DashboardView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] } },
    { path: "/portal", component: PatientsView, meta: { requiresAuth: true, roles: ["patient", "guardian"] } },
    { path: "/patients", component: PatientsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/patients/:id", component: PatientDetailView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/anamneses", component: AnamnesesView, meta: { requiresAuth: true, roles: ["admin", "therapist"] } },
    { path: "/evaluations", component: EvaluationsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/validations", component: ValidationsView, meta: { requiresAuth: true, roles: ["admin", "therapist"] } },
    { path: "/evolutions", component: EvolutionsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/appointments", component: AppointmentsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } }
  ]
});

router.beforeEach((to, from, next) => {
  const auth = useAuthStore();
  const token = auth.token || localStorage.getItem("token");
  const isLogin = to.path === "/login";
  const homePath = getHomePathByRole(auth.role);

  if (!token && to.meta.requiresAuth) {
    if (isLogin) return next();
    return next("/login");
  }

  if (token && isLogin) {
    return next(homePath);
  }

  if (to.meta.roles && auth.role && !to.meta.roles.includes(auth.role)) {
    if (to.path === homePath) return next();
    return next(homePath);
  }

  return next();
});

export default router;
