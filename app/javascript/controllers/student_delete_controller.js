import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  deleteStudent(event) {
    const studentId = event.currentTarget.dataset.studentId
    const studentName = event.currentTarget.dataset.studentName

    // Find the global delete modal controller
    const deleteModalElement = document.querySelector('[data-controller*="delete-modal"]')
    if (!deleteModalElement) {
      alert('Modal de exclusão não encontrado')
      return
    }

    // Get the delete modal controller instance
    const deleteModalController = this.application.getControllerForElementAndIdentifier(
      deleteModalElement,
      'delete-modal'
    )

    if (!deleteModalController) {
      alert('Controlador de modal não encontrado')
      return
    }

    // Create a synthetic button with the data attributes the modal needs
    const syntheticButton = document.createElement('button')
    syntheticButton.dataset.itemName = studentName
    syntheticButton.dataset.itemType = 'aluno'
    syntheticButton.dataset.deletePath = `/admin/students/${studentId}`

    // Call the modal's open method with the synthetic button
    deleteModalController.open({ currentTarget: syntheticButton, preventDefault: () => {} })
  }
}
