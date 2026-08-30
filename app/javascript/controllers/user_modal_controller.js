import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = [
    "container",
    "form",
    "title",
    "email",
    "confirmButton",
    "reasonTextarea",
    "roleLabel",
    "statusContent",
    "deleteContent",
    "deleteForm",
    "deleteEmail",
    "method",
    "reasonSection"
  ]

  connect() {
  }

  setup(button) {
    const userId = button.dataset.userId
    const action = button.dataset.modalAction
    const userEmail = button.dataset.userEmail
    const userRole = button.dataset.userRole

    if (action === 'activate' || action === 'deactivate') {
      this.showStatusModal()
      this.setupStatusModal(userId, action, userEmail)
    } else if (action === 'delete') {
      this.showDeleteModal()
      this.setupDeleteModal(userId, userEmail, userRole)
    }
  }

  showStatusModal() {
    if (this.hasStatusContentTarget) {
      this.statusContentTarget.classList.remove('hidden')
    }
    if (this.hasDeleteContentTarget) {
      this.deleteContentTarget.classList.add('hidden')
    }
  }

  showDeleteModal() {
    if (this.hasStatusContentTarget) {
      this.statusContentTarget.classList.add('hidden')
    }
    if (this.hasDeleteContentTarget) {
      this.deleteContentTarget.classList.remove('hidden')
    }
  }

  setupStatusModal(userId, action, userEmail) {
    if (this.hasEmailTarget) {
      this.emailTarget.textContent = userEmail
    }

    if (this.hasFormTarget) {
      this.formTarget.action = `/admin/users/${userId}/${action}`
    }

    if (this.hasTitleTarget) {
      this.titleTarget.textContent = action === 'deactivate' ? 'Desativar Usuário' : 'Ativar Usuário'
    }

    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.textContent = action === 'deactivate' ? 'Desativar' : 'Ativar'

      const colorClass = action === 'deactivate'
        ? 'bg-yellow-500 hover:bg-yellow-600'
        : 'bg-green-500 hover:bg-green-600'

      this.confirmButtonTarget.className = `flex-1 px-4 py-2 ${colorClass} text-white rounded-lg font-medium transition-colors`
    }

    if (this.hasReasonTextareaTarget) {
      this.reasonTextareaTarget.placeholder = action === 'deactivate'
        ? 'Por que este usuário está sendo desativado?'
        : 'Por que este usuário está sendo ativado?'
      this.reasonTextareaTarget.value = ''
    }
  }

  setupDeleteModal(userId, userEmail, userRole) {
    if (this.hasDeleteEmailTarget) {
      this.deleteEmailTarget.textContent = userEmail
    }

    if (this.hasRoleLabelTarget) {
      const roleLabels = {
        'student': 'aluno',
        'partner': 'parceiro'
      }
      this.roleLabelTarget.textContent = roleLabels[userRole] || 'usuário'
    }

    if (this.hasDeleteFormTarget) {
      this.deleteFormTarget.action = `/admin/users/${userId}`
    }
  }

  close(event) {
    super.close(event)

    if (this.hasReasonTextareaTarget) {
      this.reasonTextareaTarget.value = ''
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
