import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details", "icon"]

  toggle() {
    const isHidden = this.detailsTarget.classList.contains('hidden')

    if (isHidden) {
      this.detailsTarget.classList.remove('hidden')
      this.iconTarget.classList.add('rotate-180')
    } else {
      this.detailsTarget.classList.add('hidden')
      this.iconTarget.classList.remove('rotate-180')
    }
  }
}
