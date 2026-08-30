/**
 * Centralized CSRF token utilities
 * Replaces 12+ manual implementations across controllers
 */

/**
 * Get CSRF token from meta tag
 * @returns {string|null} The CSRF token, or null if not found
 */
export function getCsrfToken() {
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  if (!token) {
    console.warn('CSRF token not found in meta tags')
  }
  return token
}

/**
 * Get default headers for API requests with CSRF protection
 * @param {Object} additionalHeaders - Optional additional headers
 * @returns {Object} Headers object ready for fetch()
 */
export function getApiHeaders(additionalHeaders = {}) {
  return {
    'X-CSRF-Token': getCsrfToken(),
    'Accept': 'application/json',
    ...additionalHeaders
  }
}

/**
 * Get headers for JSON POST/PATCH requests with CSRF
 * @param {Object} additionalHeaders - Optional additional headers
 * @returns {Object} Headers object with Content-Type
 */
export function getJsonHeaders(additionalHeaders = {}) {
  return {
    'X-CSRF-Token': getCsrfToken(),
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...additionalHeaders
  }
}

/**
 * Get headers for FormData requests (file uploads) with CSRF
 * @param {Object} additionalHeaders - Optional additional headers
 * @returns {Object} Headers object (no Content-Type, let browser set it)
 */
export function getFormDataHeaders(additionalHeaders = {}) {
  return {
    'X-CSRF-Token': getCsrfToken(),
    'Accept': 'application/json',
    ...additionalHeaders
  }
}
