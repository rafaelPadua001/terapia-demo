import { describe, it, expect } from "vitest";
import { mount } from "@vue/test-utils";
import StatusChip from "../components/StatusChip.vue";


describe("StatusChip", () => {
  it("renderiza o status", () => {
    const wrapper = mount(StatusChip, { props: { status: "approved" } });
    expect(wrapper.text()).toContain("Aprovado");
  });
});

