import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const imageUrl = this.element.dataset.backgroundImage
    if (imageUrl) {
      this.element.style.setProperty('--bg-image', `url("${imageUrl}")`)
      this.element.classList.add('has-background-image')
    }
  }
}
