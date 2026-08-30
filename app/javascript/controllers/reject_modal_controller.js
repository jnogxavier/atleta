import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = ["container", "form", "title", "content", "studentName", "reasonTextarea"]

  setup(button) {
    const registrationId = button.dataset.registrationId
    const studentName = button.dataset.studentName

    if (this.hasFormTarget) {
      this.formTarget.action = `/admin/pending_registrations/${registrationId}/reject`
    }

    if (this.hasStudentNameTarget) {
      this.studentNameTarget.textContent = studentName
    }

    if (this.hasReasonTextareaTarget) {
      this.reasonTextareaTarget.value = ''
    }
  }
}
