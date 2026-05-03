import { useRoute } from "vue-router";

export function useActiveMenu() {
  const route = useRoute();

  const isActive = (item) => {
    const currentPath = route.path;

    if (!item?.matchChildren) {
      return currentPath === item?.to;
    }

    const base = item.matchBase || item.to;
    return currentPath === base || currentPath.startsWith(`${base}/`);
  };

  return { isActive };
}
