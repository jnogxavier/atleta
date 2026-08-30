import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]
  static values = {
    default: String,
    storageKey: { type: String, default: "dashboardActiveTab" }
  }

  connect() {
    const savedTab = localStorage.getItem(this.storageKeyValue)
    const defaultTab = savedTab || this.defaultValue || "pending"

    this.switchToTab(defaultTab, true)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    this.switchToTab(tab)
  }

  switchToTab(tab, immediate = false) {
    // Update button active states
    this.buttonTargets.forEach(button => {
      if (button.dataset.tab === tab) {
        button.classList.add("active")
      } else {
        button.classList.remove("active")
      }
    })

    // Show/hide panels
    this.panelTargets.forEach(panel => {
      if (panel.dataset.tab === tab) {
        panel.classList.remove("hidden")
        // Dispatch custom event for any tab-specific initialization
        const event = new CustomEvent('tab:show', {
          detail: { tab: tab },
          bubbles: true
        })
        panel.dispatchEvent(event)
      } else {
        panel.classList.add("hidden")
      }
    })

    localStorage.setItem(this.storageKeyValue, tab)
  }
}
