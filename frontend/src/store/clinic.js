import { defineStore } from "pinia";

import { getCurrentClinic } from "../services/clinicService";

const DEFAULT_CLINIC = {
  name: "Minha Clinica",
  logo_url: null,
  subdomain: null,
};

export const useClinicStore = defineStore("clinic", {
  state: () => ({
    name: DEFAULT_CLINIC.name,
    logoUrl: DEFAULT_CLINIC.logo_url,
    subdomain: DEFAULT_CLINIC.subdomain,
    loaded: false,
  }),
  actions: {
    async loadClinic() {
      try {
        const { data } = await getCurrentClinic();
        this.name = data?.name || DEFAULT_CLINIC.name;
        this.logoUrl = data?.logo_url || null;
        this.subdomain = data?.subdomain || null;
      } catch {
        this.name = DEFAULT_CLINIC.name;
        this.logoUrl = null;
        this.subdomain = null;
      } finally {
        this.loaded = true;
      }
    },
  },
});
