import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.element.addEventListener('input', (e) => {
      const inputType = this.element.dataset.inputType
      if (inputType === 'cpf') {
        this.formatCPF(e.target)
      } else if (inputType === 'phone') {
        this.formatPhone(e.target)
      }
    })
  }

  formatCPF(input) {
    // Remove all non-digits
    let value = input.value.replace(/\D/g, '')

    // Limit to 11 digits
    value = value.substring(0, 11)

    // Apply format: XXX.XXX.XXX-XX
    if (value.length > 0) {
      value = value.replace(/(\d{3})(\d)/, '$1.$2')
    }
    if (value.length > 7) {
      value = value.replace(/(\d{3})\.(\d{3})(\d)/, '$1.$2.$3')
    }
    if (value.length > 11) {
      value = value.replace(/(\d{3})\.(\d{3})\.(\d{3})(\d)/, '$1.$2.$3-$4')
    }

    input.value = value
  }

  formatPhone(input) {
    // Remove all non-digits
    let value = input.value.replace(/\D/g, '')

    // Limit to 11 digits
    value = value.substring(0, 11)

    // Apply format: (XX) XXXXX-XXXX
    if (value.length > 0) {
      value = '(' + value
    }
    if (value.length > 3) {
      value = value.replace(/(\(\d{2})(\d)/, '$1) $2')
    }
    if (value.length > 9) {
      value = value.replace(/(\(\d{2}\) \d{5})(\d)/, '$1-$2')
    }

    input.value = value
  }
}
