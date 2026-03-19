const onlyDigits = (value = "") => value.replace(/\D/g, "");

export const normalizePhone = (value) => {
  const digits = onlyDigits(value || "");
  return digits.length ? digits : null;
};

export const formatPhone = (value) => {
  const digits = onlyDigits(value || "");
  if (!digits) return "";
  const ddd = digits.slice(0, 2);
  const part1 = digits.length > 10 ? digits.slice(2, 7) : digits.slice(2, 6);
  const part2 = digits.length > 10 ? digits.slice(7, 11) : digits.slice(6, 10);
  let output = ddd ? `(${ddd}) ` : "";
  if (part1) output += part1;
  if (part2) output += `-${part2}`;
  return output.trim();
};

export const formatPhoneInput = (value) => formatPhone(value);
