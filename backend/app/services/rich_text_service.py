from __future__ import annotations

from typing import Any


EMPTY_RICH_TEXT = {"type": "doc", "content": []}


def rich_text_from_string(value: str | None) -> dict[str, Any]:
    text = str(value or "").strip()
    if not text:
        return EMPTY_RICH_TEXT.copy()
    return {
        "type": "doc",
        "content": [
            {
                "type": "paragraph",
                "content": [{"type": "text", "text": text}],
            }
        ],
    }


def normalize_rich_text(value: Any) -> dict[str, Any]:
    if isinstance(value, dict) and value.get("type") == "doc":
        return value
    if isinstance(value, str):
        return rich_text_from_string(value)
    if value is None:
        return EMPTY_RICH_TEXT.copy()
    return rich_text_from_string(str(value))


def rich_text_to_plain_text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value.strip()
    if not isinstance(value, dict):
        return str(value).strip()

    pieces: list[str] = []

    def walk(node: Any) -> None:
        if isinstance(node, list):
            for item in node:
                walk(item)
            return
        if not isinstance(node, dict):
            return
        if node.get("type") == "text" and node.get("text"):
            pieces.append(str(node["text"]))
        content = node.get("content")
        if isinstance(content, list):
            for item in content:
                walk(item)
            if node.get("type") in {"paragraph", "listItem"} and pieces and pieces[-1] != "\n":
                pieces.append("\n")

    walk(value.get("content", []))
    return "".join(pieces).replace("\n\n", "\n").strip()


def normalize_anamnese_data(data: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(data, dict):
        return data

    sections = data.get("sections") if isinstance(data.get("sections"), list) else []
    values = data.get("values") if isinstance(data.get("values"), dict) else {}
    normalized_values = dict(values)

    for section_index, section in enumerate(sections):
        fields = section.get("fields") if isinstance(section, dict) else []
        if not isinstance(fields, list):
            continue
        for field_index, field in enumerate(fields):
            if not isinstance(field, dict) or field.get("type") != "textarea":
                continue
            key = f"{section_index}-{field_index}"
            normalized_values[key] = normalize_rich_text(normalized_values.get(key))

    return {**data, "values": normalized_values}
