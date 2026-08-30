import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.documentElement.classList.add("overflow-hidden")
  }

  close(event) {
    event.preventDefault()
    this.modalTarget.classList.add("hidden")
    document.documentElement.classList.remove("overflow-hidden")
  }

  clickOutside(event) {
    if (event.target === this.modalTarget) {
      this.close(event)
    }
  }

  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close(event)
    }
  }

  connect() {
    this.boundCloseWithKeyboard = this.closeWithKeyboard.bind(this)
    document.addEventListener("keydown", this.boundCloseWithKeyboard)

    if (this.hasModalTarget) {
      this.modalTarget.addEventListener("click", this.clickOutside.bind(this))
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundCloseWithKeyboard)
  }
}
