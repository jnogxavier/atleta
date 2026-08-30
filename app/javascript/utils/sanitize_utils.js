/**
 * XSS Prevention Utilities
 * Escape user-generated content before inserting into DOM
 */

/**
 * Escape HTML special characters to prevent XSS
 * @param {string} text - Raw user input text
 * @returns {string} Escaped text safe for HTML insertion
 */
export function escapeHtml(text) {
  if (!text) return ''

  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

/**
 * Sanitize URL to prevent javascript: and data: protocol attacks
 * @param {string} url - URL from user or API
 * @returns {string|null} Safe URL or null if invalid
 */
export function sanitizeUrl(url) {
  if (!url) return null

  try {
    const urlObj = new URL(url, window.location.origin)
    // Only allow http and https protocols
    if (['http:', 'https:'].includes(urlObj.protocol)) {
      return urlObj.toString()
    }
    return null
  } catch (e) {
    // Invalid URL format
    return null
  }
}

/**
 * Create a safe text node for DOM insertion
 * @param {string} text - Text content
 * @returns {Text} Safe text node
 */
export function createSafeTextNode(text) {
  return document.createTextNode(text)
}

/**
 * Create a safe element with attributes
 * @param {string} tagName - HTML tag (e.g., 'div', 'span')
 * @param {object} attributes - Safe attributes { class: 'foo', id: 'bar' }
 * @param {string} textContent - Optional text content (auto-escaped)
 * @returns {Element} Safe element
 */
export function createSafeElement(tagName, attributes = {}, textContent = '') {
  const element = document.createElement(tagName)

  // Only set safe attributes
  const safeAttrs = ['class', 'id', 'data-*', 'aria-*', 'role']
  Object.entries(attributes).forEach(([key, value]) => {
    // Only allow safe attributes, skip event handlers
    if (!key.startsWith('on') && (key.includes('data-') || key.includes('aria-') || safeAttrs.includes(key))) {
      element.setAttribute(key, String(value))
    }
  })

  if (textContent) {
    element.textContent = textContent // Auto-escapes
  }

  return element
}

/**
 * Validate and sanitize data attributes from API responses
 * @param {object} data - Data object from API
 * @param {array} allowedKeys - List of allowed keys
 * @returns {object} Sanitized data with only allowed keys
 */
export function sanitizeApiData(data, allowedKeys) {
  if (!data || typeof data !== 'object') return {}

  const sanitized = {}
  allowedKeys.forEach(key => {
    if (key in data) {
      sanitized[key] = data[key]
    }
  })
  return sanitized
}
