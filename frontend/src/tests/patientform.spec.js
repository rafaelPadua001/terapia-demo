import { describe, it, expect } from "vitest";
import { mount } from "@vue/test-utils";
import PatientForm from "../components/forms/PatientForm.vue";


describe("PatientForm", () => {
  it("emite submit", async () => {
    const wrapper = mount(PatientForm);
    await wrapper.find("form").trigger("submit.prevent");
    expect(wrapper.emitted()).toHaveProperty("submit");
  });
});

