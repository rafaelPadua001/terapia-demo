const onlyDigits = (value = "") => value.replace(/\D/g, "");

export const normalizeCpf = (value) => {
  const digits = onlyDigits(value || "");
  return digits.length ? digits : null;
};

export const formatCpf = (value) => {
  const digits = onlyDigits(value || "").slice(0, 11);
  const part1 = digits.slice(0, 3);
  const part2 = digits.slice(3, 6);
  const part3 = digits.slice(6, 9);
  const part4 = digits.slice(9, 11);
  let output = part1;
  if (part2) output += `.${part2}`;
  if (part3) output += `.${part3}`;
  if (part4) output += `-${part4}`;
  return output;
};

export const isValidCpf = (value) => {
  const digits = onlyDigits(value || "");
  if (digits.length !== 11) return false;
  if (/^(\d)\1+$/.test(digits)) return false;

  const calcCheckDigit = (base) => {
    let sum = 0;
    for (let i = 0; i < base.length; i += 1) {
      sum += Number(base[i]) * (base.length + 1 - i);
    }
    const remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  };

  const first = calcCheckDigit(digits.slice(0, 9));
  const second = calcCheckDigit(digits.slice(0, 9) + first);
  return digits === `${digits.slice(0, 9)}${first}${second}`;
};

export const formatCpfInput = (value) => formatCpf(value);

