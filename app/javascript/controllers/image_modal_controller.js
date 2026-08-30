import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  open(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    this.modalTarget.classList.remove('hidden')
  }

  close(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    this.modalTarget.classList.add('hidden')
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close(event)
    }
  }
}
