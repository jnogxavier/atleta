import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modal",
    "form",
    "title",
    "userEmail",
    "confirmButton",
    "reasonTextarea"
  ]

  open(event) {
    event.preventDefault()

    const button = event.currentTarget
    const userId = button.dataset.userId
    const action = button.dataset.statusAction
    const userEmail = button.dataset.userEmail

    this.configureModal(userId, action, userEmail)
    this.modalTarget.classList.remove('hidden')
  }

  close(event) {
    if (event) event.preventDefault()

    this.modalTarget.classList.add('hidden')
    this.reasonTextareaTarget.value = ''
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  configureModal(userId, action, userEmail) {
    if (action === 'deactivate') {
      this.formTarget.action = `/admin/users/${userId}/deactivate`
      this.titleTarget.textContent = 'Desativar Usuário'
      this.confirmButtonTarget.textContent = 'Desativar'
      this.confirmButtonTarget.className = 'flex-1 px-4 py-2 bg-yellow-500 text-white rounded-lg font-medium hover:bg-yellow-600 transition-colors'
      this.reasonTextareaTarget.placeholder = 'Por que este usuário está sendo desativado?'
    } else {
      this.formTarget.action = `/admin/users/${userId}/activate`
      this.titleTarget.textContent = 'Ativar Usuário'
      this.confirmButtonTarget.textContent = 'Ativar'
      this.confirmButtonTarget.className = 'flex-1 px-4 py-2 bg-green-500 text-white rounded-lg font-medium hover:bg-green-600 transition-colors'
      this.reasonTextareaTarget.placeholder = 'Por que este usuário está sendo ativado?'
    }

    this.userEmailTarget.textContent = userEmail
  }
}
