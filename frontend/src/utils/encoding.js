import { richTextToPlainText } from "./richText";

export function fixEncoding(text) {
  if (text === null || text === undefined) return "";
  if (typeof text === "object") return richTextToPlainText(text);
  return String(text);
}

const normalizeValue = (value) => {
  if (value === null || value === undefined) return "";
  if (Array.isArray(value)) return value.filter(Boolean).join(", ");
  if (typeof value === "object") return richTextToPlainText(value);
  return String(value).trim();
};

export function formatAnamneseResumo(data) {
  if (!data || typeof data !== "object") return "-";

  const sections = Array.isArray(data.sections) ? data.sections : [];
  const values = data.values && typeof data.values === "object" ? data.values : {};
  const lines = [];

  sections.forEach((section, sectionIndex) => {
    const fields = Array.isArray(section?.fields) ? section.fields : [];
    const sectionLines = [];

    fields.forEach((field, fieldIndex) => {
      const value = normalizeValue(values[`${sectionIndex}-${fieldIndex}`]);
      if (!value) return;
      sectionLines.push(`- ${field.label || "Campo"}: ${value}`);
    });

    if (sectionLines.length) {
      lines.push(`${section?.title || "Secao"}:`);
      lines.push(...sectionLines);
    }
  });

  if (!lines.length) {
    const fallbackValues = Object.values(values).map(normalizeValue).filter(Boolean);
    return fallbackValues.length ? fallbackValues.join(", ") : "-";
  }

  return lines.join("\n");
}

export function formatEvaluationResumo(result) {
  if (!result) return "-";
  if (typeof result === "string") return result;
  if (result.type === "doc") return richTextToPlainText(result) || "-";
  if (result.value) return String(result.value);

  const parts = Object.entries(result)
    .map(([key, value]) => {
      const normalized = normalizeValue(value);
      return normalized ? `${key}: ${normalized}` : "";
    })
    .filter(Boolean);

  return parts.length ? parts.join(", ") : "-";
}
