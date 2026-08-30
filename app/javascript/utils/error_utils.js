/**
 * Error handling utilities for consistent error reporting across the app
 */

/**
 * Show error message to user via toast or default alert
 * @param {string} message - Error message to display
 * @param {string} title - Optional error title
 * @param {string} type - Error type ('error', 'warning', 'info')
 */
export function showErrorToast(message, title = null, type = 'error') {
  if (typeof window.showToast === 'function') {
    // Use existing toast if available
    const fullMessage = title ? `${title}: ${message}` : message
    window.showToast(fullMessage, type)
  } else {
    // Fallback to console error
    console.error(`[${type.toUpperCase()}]${title ? ' ' + title + ':' : ''}`, message)
  }
}

/**
 * Log error for debugging with consistent format
 * @param {string} context - Where error occurred (e.g., 'signup_form_controller')
 * @param {Error} error - Error object
 * @param {object} additionalData - Optional additional context
 */
export function logError(context, error, additionalData = {}) {
  const errorInfo = {
    context,
    message: error?.message || String(error),
    stack: error?.stack || '',
    timestamp: new Date().toISOString(),
    ...additionalData
  }

  console.error('[Application Error]', errorInfo)

  // In production, could send to error tracking service
  if (window.Sentry) {
    window.Sentry.captureException(error, { contexts: { custom: additionalData } })
  }
}

/**
 * Handle fetch/HTTP errors with consistent format
 * @param {Response} response - Fetch response object
 * @param {string} context - Operation context
 * @returns {Promise} Resolves with parsed error data or rejects with error
 */
export async function handleFetchError(response, context) {
  try {
    const contentType = response.headers.get('content-type')

    if (contentType?.includes('application/json')) {
      const data = await response.json()
      const errorMessage = data.errors?.[0] || data.message || `HTTP ${response.status}`
      logError(context, new Error(errorMessage), { status: response.status, data })
      return { success: false, errors: data.errors || [errorMessage], status: response.status }
    } else {
      const text = await response.text()
      const errorMessage = text || `HTTP ${response.status}`
      logError(context, new Error(errorMessage), { status: response.status })
      return { success: false, errors: [errorMessage], status: response.status }
    }
  } catch (parseError) {
    const errorMessage = `HTTP ${response.status}: Failed to parse error response`
    logError(context, parseError, { status: response.status, parseError: parseError.message })
    return { success: false, errors: [errorMessage], status: response.status }
  }
}

/**
 * Safely parse JSON with error handling
 * @param {string} jsonString - JSON string to parse
 * @param {string} context - Operation context for logging
 * @returns {object|null} Parsed object or null if parsing failed
 */
export function safeJsonParse(jsonString, context) {
  try {
    return JSON.parse(jsonString)
  } catch (error) {
    logError(context, error, { input: jsonString.substring(0, 100) })
    return null
  }
}

/**
 * Validate response has expected structure before using
 * @param {object} data - Data object to validate
 * @param {string[]} requiredFields - Array of required field names
 * @param {string} context - Operation context for logging
 * @returns {boolean} True if all required fields present
 */
export function validateResponseStructure(data, requiredFields, context) {
  if (!data || typeof data !== 'object') {
    logError(context, new Error('Response is not an object'), { data })
    return false
  }

  const missing = requiredFields.filter(field => !(field in data))

  if (missing.length > 0) {
    logError(context, new Error(`Missing required fields: ${missing.join(', ')}`), { data, missing })
    return false
  }

  return true
}

/**
 * Wrap async function with comprehensive error handling
 * @param {Function} asyncFn - Async function to wrap
 * @param {string} context - Operation context
 * @param {Function} errorCallback - Custom error handler
 * @returns {Function} Wrapped function
 */
export function withErrorHandling(asyncFn, context, errorCallback = null) {
  return async (...args) => {
    try {
      return await asyncFn(...args)
    } catch (error) {
      logError(context, error)

      if (errorCallback) {
        errorCallback(error)
      } else {
        showErrorToast(error.message || 'Ocorreu um erro. Tente novamente.', context)
      }

      throw error
    }
  }
}
