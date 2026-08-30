import { Controller } from "@hotwired/stimulus"
import { setupMenuKeyboard } from "utils/accessibility_utils"

export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    this.boundClose = this.close.bind(this)
    this.keyboardCleanup = null

    // Set up ARIA attributes on toggle button
    const toggleButton = this.hasToggleTarget ? this.toggleTarget : this.element.querySelector('button')
    if (toggleButton) {
      toggleButton.setAttribute('aria-haspopup', 'true')
      toggleButton.setAttribute('aria-expanded', 'false')
      if (!toggleButton.getAttribute('aria-label')) {
        toggleButton.setAttribute('aria-label', 'Toggle menu')
      }
    }

    // Set up ARIA on menu
    this.menuTarget.setAttribute('role', 'menu')
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove('hidden')

    // Update ARIA
    const toggleButton = this.hasToggleTarget ? this.toggleTarget : this.element.querySelector('button')
    if (toggleButton) {
      toggleButton.setAttribute('aria-expanded', 'true')
    }

    // Set up menu keyboard navigation
    const menuItems = this.menuTarget.querySelectorAll('[role="menuitem"], a, button')
    if (menuItems.length > 0) {
      menuItems[0].focus()
      if (this.keyboardCleanup) {
        this.keyboardCleanup()
      }
      this.keyboardCleanup = setupMenuKeyboard(
        this.menuTarget,
        () => this.close(),
        (item) => {
          if (item.click) item.click()
          this.close()
        }
      )
    }

    document.addEventListener('click', this.boundClose)
  }

  close() {
    this.menuTarget.classList.add('hidden')

    // Update ARIA
    const toggleButton = this.hasToggleTarget ? this.toggleTarget : this.element.querySelector('button')
    if (toggleButton) {
      toggleButton.setAttribute('aria-expanded', 'false')
      toggleButton.focus()
    }

    // Clean up keyboard navigation
    if (this.keyboardCleanup) {
      this.keyboardCleanup()
      this.keyboardCleanup = null
    }

    document.removeEventListener('click', this.boundClose)
  }

  disconnect() {
    document.removeEventListener('click', this.boundClose)
    if (this.keyboardCleanup) {
      this.keyboardCleanup()
    }
  }
}
