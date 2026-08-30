/**
 * Global toast notification utility
 * Displays toast messages in a fixed position on the screen
 */

export function showToast(message, type = 'notice') {
  const container = document.querySelector('.flash-messages') || createFlashContainer()

  const messageDiv = document.createElement('div')
  messageDiv.className = `flash-message flash-${type}`
  messageDiv.innerHTML = `
    <p>${escapeHtml(message)}</p>
    <button type="button" class="flash-close" data-action="click->flash#dismiss">&times;</button>
  `

  container.appendChild(messageDiv)

  // Initialize Stimulus controller for this element
  if (window.Stimulus && window.Stimulus.application) {
    window.Stimulus.application.router.refresh()
  }

  // Auto-dismiss after 5 seconds
  setTimeout(() => {
    messageDiv.remove()
  }, 5000)
}

function createFlashContainer() {
  const container = document.createElement('div')
  container.className = 'flash-messages'
  document.body.insertBefore(container, document.body.firstChild)
  return container
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

// Set on window for global access
window.showToast = showToast
