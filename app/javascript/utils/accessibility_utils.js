/**
 * Accessibility utilities for consistent ARIA handling and keyboard support
 */

/**
 * Create a focus trap within a container (useful for modals)
 * Prevents focus from escaping to background content
 */
export function createFocusTrap(container) {
  const focusableElements = container.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )

  const firstElement = focusableElements[0]
  const lastElement = focusableElements[focusableElements.length - 1]

  const handleKeyDown = (event) => {
    if (event.key !== 'Tab') return

    if (event.shiftKey) {
      if (document.activeElement === firstElement) {
        lastElement?.focus()
        event.preventDefault()
      }
    } else {
      if (document.activeElement === lastElement) {
        firstElement?.focus()
        event.preventDefault()
      }
    }
  }

  container.addEventListener('keydown', handleKeyDown)

  // Return cleanup function
  return () => {
    container.removeEventListener('keydown', handleKeyDown)
  }
}

/**
 * Hide background content from screen readers when modal/overlay is open
 */
export function hideBackgroundContent(excludeSelectors = []) {
  const exclusions = ['[data-modal]', '[aria-modal="true"]', ...excludeSelectors]
  const visibleElements = document.querySelectorAll('body > *:not([data-modal]):not([aria-modal="true"])').forEach(el => {
    if (!exclusions.some(selector => el.matches(selector))) {
      el.setAttribute('aria-hidden', 'true')
    }
  })
}

/**
 * Restore background content to be visible to screen readers
 */
export function showBackgroundContent() {
  document.querySelectorAll('[aria-hidden="true"]').forEach(el => {
    if (!el.closest('[data-modal]') && !el.matches('[aria-modal="true"]')) {
      el.removeAttribute('aria-hidden')
    }
  })
}

/**
 * Announce a message to screen readers using a live region
 */
export function announce(message, priority = 'polite') {
  let announcer = document.getElementById('aria-announcer')

  if (!announcer) {
    announcer = document.createElement('div')
    announcer.id = 'aria-announcer'
    announcer.setAttribute('aria-live', priority)
    announcer.setAttribute('aria-atomic', 'true')
    announcer.className = 'sr-only'
    document.body.appendChild(announcer)
  }

  announcer.setAttribute('aria-live', priority)
  announcer.textContent = message

  // Clear after announcement to allow same message again
  setTimeout(() => {
    announcer.textContent = ''
  }, 1000)
}

/**
 * Set up keyboard navigation for dropdown/menu items
 * Supports: ArrowUp, ArrowDown, Home, End, Enter, Escape
 */
export function setupMenuKeyboard(menuElement, onEscape = null, onSelect = null) {
  const items = menuElement.querySelectorAll('[role="option"], [role="menuitem"], li > button')

  const focusItem = (item) => {
    items.forEach(i => i.setAttribute('aria-selected', 'false'))
    item.setAttribute('aria-selected', 'true')
    item.focus()
  }

  const handleKeyDown = (event) => {
    const current = document.activeElement
    const currentIndex = Array.from(items).indexOf(current)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        const nextIndex = currentIndex + 1 < items.length ? currentIndex + 1 : 0
        focusItem(items[nextIndex])
        break

      case 'ArrowUp':
        event.preventDefault()
        const prevIndex = currentIndex - 1 >= 0 ? currentIndex - 1 : items.length - 1
        focusItem(items[prevIndex])
        break

      case 'Home':
        event.preventDefault()
        focusItem(items[0])
        break

      case 'End':
        event.preventDefault()
        focusItem(items[items.length - 1])
        break

      case 'Enter':
      case ' ':
        event.preventDefault()
        if (onSelect) onSelect(current)
        break

      case 'Escape':
        if (onEscape) onEscape()
        break
    }
  }

  items.forEach(item => {
    item.addEventListener('keydown', handleKeyDown)
  })

  // Set initial ARIA attributes
  items.forEach((item, index) => {
    item.setAttribute('role', item.getAttribute('role') || 'option')
    item.setAttribute('aria-selected', index === 0 ? 'true' : 'false')
  })

  // Return cleanup function
  return () => {
    items.forEach(item => {
      item.removeEventListener('keydown', handleKeyDown)
    })
  }
}

/**
 * Set up keyboard navigation for tabs
 */
export function setupTabsKeyboard(tabElements, onTabChange) {
  const handleKeyDown = (event) => {
    const tabs = tabElements
    const currentIndex = tabs.indexOf(document.activeElement)

    let newIndex
    switch (event.key) {
      case 'ArrowLeft':
      case 'ArrowUp':
        event.preventDefault()
        newIndex = currentIndex - 1 < 0 ? tabs.length - 1 : currentIndex - 1
        tabs[newIndex].focus()
        break

      case 'ArrowRight':
      case 'ArrowDown':
        event.preventDefault()
        newIndex = currentIndex + 1 >= tabs.length ? 0 : currentIndex + 1
        tabs[newIndex].focus()
        break

      case 'Home':
        event.preventDefault()
        tabs[0].focus()
        break

      case 'End':
        event.preventDefault()
        tabs[tabs.length - 1].focus()
        break
    }
  }

  tabElements.forEach((tab, index) => {
    tab.setAttribute('role', 'tab')
    tab.setAttribute('aria-selected', index === 0 ? 'true' : 'false')
    tab.setAttribute('tabindex', index === 0 ? '0' : '-1')
    tab.addEventListener('keydown', handleKeyDown)
    tab.addEventListener('click', () => {
      tabElements.forEach(t => {
        t.setAttribute('aria-selected', 'false')
        t.setAttribute('tabindex', '-1')
      })
      tab.setAttribute('aria-selected', 'true')
      tab.setAttribute('tabindex', '0')
      if (onTabChange) onTabChange(index, tab)
    })
  })

  // Return cleanup function
  return () => {
    tabElements.forEach(tab => {
      tab.removeEventListener('keydown', handleKeyDown)
    })
  }
}

/**
 * Make icon-only buttons accessible
 */
export function makeIconButtonAccessible(button, label) {
  if (!button.getAttribute('aria-label') && !button.textContent.trim()) {
    button.setAttribute('aria-label', label)
  }

  // Ensure it's keyboard accessible
  if (!button.getAttribute('tabindex') && button.tagName !== 'BUTTON') {
    button.setAttribute('role', 'button')
    button.setAttribute('tabindex', '0')
  }
}

/**
 * Link a label to a form input if not already linked
 */
export function linkLabel(inputId, labelText) {
  let label = document.querySelector(`label[for="${inputId}"]`)

  if (!label) {
    label = document.createElement('label')
    label.setAttribute('for', inputId)
    label.textContent = labelText
  }

  return label
}

/**
 * Mark a form field as required for screen readers
 */
export function markFieldRequired(input) {
  input.setAttribute('aria-required', 'true')
  input.required = true

  const label = document.querySelector(`label[for="${input.id}"]`)
  if (label && !label.querySelector('.required-indicator')) {
    const indicator = document.createElement('span')
    indicator.className = 'required-indicator'
    indicator.setAttribute('aria-label', 'obrigatório')
    indicator.textContent = '*'
    label.appendChild(indicator)
  }
}

/**
 * Add error message to form field with proper ARIA
 */
export function setFieldError(input, errorMessage) {
  const errorId = `${input.id}-error`
  let errorElement = document.getElementById(errorId)

  if (!errorElement) {
    errorElement = document.createElement('div')
    errorElement.id = errorId
    errorElement.className = 'field-error'
    input.parentNode.insertBefore(errorElement, input.nextSibling)
  }

  errorElement.textContent = errorMessage
  input.setAttribute('aria-invalid', 'true')
  input.setAttribute('aria-describedby', errorId)
}

/**
 * Clear error message from form field
 */
export function clearFieldError(input) {
  const errorId = `${input.id}-error`
  const errorElement = document.getElementById(errorId)

  if (errorElement) {
    errorElement.textContent = ''
  }

  input.setAttribute('aria-invalid', 'false')
  input.removeAttribute('aria-describedby')
}
