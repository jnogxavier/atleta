import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["studentFields", "partnerFields", "adminFields"]

  connect() {
    this.updateFieldsVisibility()
  }

  handleRoleChange(e) {
    this.updateFieldsVisibility()
  }

  updateFieldsVisibility() {
    const roleSelect = this.element.querySelector('select[name*="role"]')
    if (!roleSelect) return

    const role = roleSelect.value

    // Hide all fields first
    this.studentFieldsTarget.classList.add('hidden')
    this.partnerFieldsTarget.classList.add('hidden')
    this.adminFieldsTarget.classList.add('hidden')

    // Show the appropriate fields
    switch (role) {
      case 'student':
        this.studentFieldsTarget.classList.remove('hidden')
        break
      case 'partner':
        this.partnerFieldsTarget.classList.remove('hidden')
        break
      case 'admin':
        this.adminFieldsTarget.classList.remove('hidden')
        break
    }
  }
}
