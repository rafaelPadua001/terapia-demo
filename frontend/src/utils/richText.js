export const EMPTY_RICH_TEXT = { type: "doc", content: [] };

const isPlainObject = (value) => value && typeof value === "object" && !Array.isArray(value);

export const createRichTextFromString = (value = "") => {
  const text = String(value || "").trim();
  if (!text) return EMPTY_RICH_TEXT;
  return {
    type: "doc",
    content: [
      {
        type: "paragraph",
        content: [{ type: "text", text }],
      },
    ],
  };
};

export const normalizeRichTextValue = (value) => {
  if (!value) return EMPTY_RICH_TEXT;
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) return EMPTY_RICH_TEXT;
    try {
      const parsed = JSON.parse(trimmed);
      if (isPlainObject(parsed) && parsed.type === "doc") return parsed;
    } catch {
    }
    return createRichTextFromString(trimmed);
  }
  if (isPlainObject(value) && value.type === "doc") return value;
  return EMPTY_RICH_TEXT;
};

const collectNodeText = (node, lines) => {
  if (!node) return;
  if (Array.isArray(node)) {
    node.forEach((item) => collectNodeText(item, lines));
    return;
  }
  if (node.type === "text" && node.text) {
    lines.push(String(node.text));
  }
  if (Array.isArray(node.content)) {
    if (node.type === "paragraph" || node.type === "listItem") {
      const paragraph = [];
      node.content.forEach((item) => collectNodeText(item, paragraph));
      if (paragraph.length) {
        lines.push(paragraph.join(""));
        return;
      }
    }
    node.content.forEach((item) => collectNodeText(item, lines));
  }
};

export const richTextToPlainText = (value) => {
  if (value === null || value === undefined) return "";
  if (typeof value === "string") return value.trim();
  const normalized = normalizeRichTextValue(value);
  const lines = [];
  collectNodeText(normalized.content || [], lines);
  return lines.join("\n").trim();
};

export const isRichTextEmpty = (value) => !richTextToPlainText(value);
