import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner"]

  connect() {
    this.hideSpinnerOnLoad()
  }

  hideSpinnerOnLoad() {
    // Only hide spinner on initial page load, not on Turbo navigation
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", () => {
        this.hideSpinner()
      }, { once: true })
    } else {
      // Page already loaded, hide spinner immediately
      setTimeout(() => this.hideSpinner(), 100)
    }
  }

  hideSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("hidden")
    }
  }
}
