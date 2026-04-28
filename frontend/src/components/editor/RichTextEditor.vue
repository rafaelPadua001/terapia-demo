<template>
  <div class="editor-shell">
    <div v-if="editor && !readonly" class="editor-toolbar">
      <v-btn size="small" variant="text" :class="{ active: editor.isActive('paragraph') }" @click="setParagraph">
        Paragrafo
      </v-btn>
      <v-btn size="small" variant="text" :class="{ active: editor.isActive('bold') }" @click="toggleBold">
        Negrito
      </v-btn>
      <v-btn size="small" variant="text" :class="{ active: editor.isActive('italic') }" @click="toggleItalic">
        Italico
      </v-btn>
      <v-btn size="small" variant="text" :class="{ active: editor.isActive('bulletList') }" @click="toggleBulletList">
        Lista
      </v-btn>
    </div>
    <EditorContent v-if="editor" :editor="editor" class="editor-content" />
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, watch } from "vue";
import { EditorContent, useEditor } from "@tiptap/vue-3";
import StarterKit from "@tiptap/starter-kit";
import { normalizeRichTextValue } from "../../utils/richText";

const props = defineProps({
  modelValue: {
    type: [Object, String],
    default: "",
  },
  readonly: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update:modelValue"]);

const normalizedContent = computed(() => normalizeRichTextValue(props.modelValue));

const editor = useEditor({
  content: normalizedContent.value,
  editable: !props.readonly,
  extensions: [StarterKit],
  onUpdate: ({ editor: instance }) => {
    emit("update:modelValue", instance.getJSON());
  },
});

const syncContent = (value) => {
  if (!editor.value) return;
  const next = normalizeRichTextValue(value);
  const current = editor.value.getJSON();
  if (JSON.stringify(current) !== JSON.stringify(next)) {
    editor.value.commands.setContent(next, false);
  }
};

watch(() => props.modelValue, syncContent, { deep: true });
watch(() => props.readonly, (value) => editor.value?.setEditable(!value));

const setParagraph = () => editor.value?.chain().focus().setParagraph().run();
const toggleBold = () => editor.value?.chain().focus().toggleBold().run();
const toggleItalic = () => editor.value?.chain().focus().toggleItalic().run();
const toggleBulletList = () => editor.value?.chain().focus().toggleBulletList().run();

onBeforeUnmount(() => {
  editor.value?.destroy();
});
</script>

<style scoped>
.editor-shell {
  border: 1px solid rgba(0, 0, 0, 0.16);
  border-radius: 12px;
  overflow: hidden;
  background: #fff;
}

.editor-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  padding: 10px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  background: #f8faf9;
}

.editor-toolbar .active {
  background: rgba(27, 94, 91, 0.12);
}

.editor-content :deep(.ProseMirror) {
  min-height: 160px;
  padding: 14px;
  outline: none;
  white-space: pre-wrap;
}

.editor-content :deep(ul) {
  padding-left: 1.25rem;
}

.editor-content :deep(p) {
  margin: 0 0 0.75rem;
}

.editor-content :deep(p:last-child) {
  margin-bottom: 0;
}
</style>
