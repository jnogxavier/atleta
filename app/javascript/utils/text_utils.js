export function normalizeText(text) {
  if (!text) return ''

  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[,\.;:\-\(\)]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
}

export function searchMatch(text, query) {
  return normalizeText(text).includes(normalizeText(query))
}
