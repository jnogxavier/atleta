import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String,
    successMessage: { type: String, default: "Copiado com sucesso!" },
    errorMessage: { type: String, default: "Erro ao copiar" }
  }

  async copy(event) {
    event.preventDefault()

    try {
      await navigator.clipboard.writeText(this.textValue)
      this.showToast(this.successMessageValue, 'success')
    } catch (error) {
      this.showToast(this.errorMessageValue, 'error')
    }
  }

  showToast(message, type) {
    if (typeof window.showToast === 'function') {
      window.showToast(message, type)
    } else {
      const event = new CustomEvent('toast:show', {
        detail: { message, type },
        bubbles: true
      })
      window.dispatchEvent(event)
    }
  }
}
