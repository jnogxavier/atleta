import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = ["container", "form", "title", "content", "message", "confirmBtn"]

  setup(button) {
    const itemName = button.dataset.itemName || "este item"
    const itemType = button.dataset.itemType || "item"
    const deletePath = button.dataset.deletePath

    if (!deletePath) {
      return
    }

    // Store the delete path
    this.pendingDeletePath = deletePath

    // Set the message
    const message = `Tem certeza que deseja remover ${itemType} "${itemName}"? Esta ação não pode ser desfeita.`
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = message
    }
  }

  confirm(event) {
    if (event) event.preventDefault()

    if (!this.pendingDeletePath) return

    const confirmBtn = this.confirmBtnTarget
    confirmBtn.disabled = true
    confirmBtn.textContent = "Removendo..."

    fetch(this.pendingDeletePath, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "application/json"
      }
    })
      .then(response => {
        if (response.ok) {
          this.close()
          this.dispatch('deleted', { detail: { path: this.pendingDeletePath } })
          window.location.reload()
        } else {
          throw new Error("Failed to delete")
        }
      })
      .catch(error => {
        console.error("Delete failed:", error)
        alert("Erro ao remover item")
        confirmBtn.disabled = false
        confirmBtn.textContent = "Remover"
      })
  }
}
