import { Controller } from "@hotwired/stimulus"
import { createFocusTrap, hideBackgroundContent, showBackgroundContent } from "utils/accessibility_utils"

export default class extends Controller {
  static targets = ["container", "form", "title", "content"]
  static values = {
    formAction: String,
    title: String
  }

  connect() {
    this.triggerButton = null
    this.focusTrapCleanup = null

    // Apply modal styling to container if it exists
    if (this.hasContainerTarget) {
      this.applyModalStyling()
    }
  }

  applyModalStyling() {
    if (!this.containerTarget.classList.contains('modal-styled')) {
      this.containerTarget.classList.add('backdrop-blur-sm', 'bg-black/20', 'modal-styled')
    }
  }

  disconnect() {
    if (this.focusTrapCleanup) {
      this.focusTrapCleanup()
    }
  }

  open(event) {
    event.preventDefault()

    const button = event.currentTarget
    const formAction = button.dataset.modalFormActionValue
    const title = button.dataset.modalTitleValue

    if (this.hasFormTarget && formAction) {
      this.formTarget.action = formAction
    }

    if (this.hasTitleTarget && title) {
      this.titleTarget.textContent = title
      this.containerTarget.setAttribute('aria-labelledby', this.titleTarget.id || 'modal-title')
    }

    if (typeof this.setup === 'function') {
      this.setup(button)
    }

    // Save trigger button for focus restoration on close
    this.triggerButton = button

    // Apply default modal styling if not already applied
    if (!this.containerTarget.classList.contains('modal-styled')) {
      this.containerTarget.classList.add('backdrop-blur-sm', 'bg-black/20', 'modal-styled')
    }

    this.containerTarget.classList.remove("hidden")

    // Set up accessibility
    this.containerTarget.setAttribute('role', 'dialog')
    this.containerTarget.setAttribute('aria-modal', 'true')

    // Hide background content from screen readers
    hideBackgroundContent()

    // Set up focus trap
    if (this.focusTrapCleanup) {
      this.focusTrapCleanup()
    }
    this.focusTrapCleanup = createFocusTrap(this.containerTarget)

    // Move focus to modal title or first focusable element
    if (this.hasTitleTarget) {
      this.titleTarget.focus()
    } else {
      const firstFocusable = this.containerTarget.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
      if (firstFocusable) firstFocusable.focus()
    }

    // Set up escape key handler
    this.escapeHandler = (e) => {
      if (e.key === 'Escape') {
        this.close()
      }
    }
    document.addEventListener('keydown', this.escapeHandler)
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    this.containerTarget.classList.add("hidden")
    this.containerTarget.removeAttribute('aria-modal')
    this.containerTarget.removeAttribute('role')

    // Only reset the form if it's actually inside this modal container
    // This prevents resetting forms outside the modal (like the main nutrition plan form)
    if (this.hasFormTarget && this.containerTarget.contains(this.formTarget)) {
      this.formTarget.reset()
    }

    // Clean up accessibility
    showBackgroundContent()

    if (this.focusTrapCleanup) {
      this.focusTrapCleanup()
      this.focusTrapCleanup = null
    }

    if (this.escapeHandler) {
      document.removeEventListener('keydown', this.escapeHandler)
    }

    // Restore focus to trigger button
    if (this.triggerButton) {
      this.triggerButton.focus()
    }
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  handleSubmit(event) {
  }
}
