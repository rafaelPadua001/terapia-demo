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
import TherapistsView from "../views/TherapistsView.vue";
import PaymentSuccess from "../views/payment/PaymentSuccess.vue";
const PaymentPending = () => import("../views/payment/Pending.vue");
const PaymentFailure = () => import("../views/payment/Failure.vue");

const getHomePathByRole = (role) => {
  if (role === "patient" || role === "guardian") return "/portal";
  return "/dashboard";
};

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/login", component: LoginView },
    { path: "/confirm-email", component: ConfirmEmailView },
    { path: "/payment/success", name: "PaymentSuccess", component: PaymentSuccess },
    { path: "/payment/pending", name: "PaymentPending", component: PaymentPending },
    { path: "/payment/failure", name: "PaymentFailure", component: PaymentFailure },
    { path: "/", redirect: () => getHomePathByRole(useAuthStore().role) },

    { path: "/dashboard", component: DashboardView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] } },
    { path: "/portal", component: PatientsView, meta: { requiresAuth: true, roles: ["patient", "guardian"] } },

    { path: "/patients", component: PatientsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/patients/:id", component: PatientDetailView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },

    { path: "/anamneses", component: AnamnesesView, meta: { requiresAuth: true, roles: ["admin", "therapist"] } },
    { path: "/evaluations", component: EvaluationsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/validations", component: ValidationsView, meta: { requiresAuth: true, roles: ["admin", "therapist"] } },
    { path: "/evolutions", component: EvolutionsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/appointments", component: AppointmentsView, meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist", "patient", "guardian"] } },
    { path: "/therapists", component: TherapistsView, meta: { requiresAuth: true, roles: ["admin"] } },

    {
      path: "/financial",
      component: () => import("../views/financial/FinancialLayout.vue"),
      meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] },
      children: [
        { path: "", component: () => import("../views/financial/TransactionsView.vue"), meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] } },
        { path: "accounts", component: () => import("../views/financial/AccountsView.vue"), meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] } },
        { path: "dashboard", component: () => import("../views/financial/DashboardView.vue"), meta: { requiresAuth: true, roles: ["admin", "therapist", "receptionist"] } },
      ],
    },

    { path: "/my-financial", component: () => import("../views/financial/MyTransactionsView.vue"), meta: { requiresAuth: true, roles: ["patient", "guardian"] } },
  ],
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
