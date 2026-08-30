import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "card", "noResults", "count"]

  connect() {
    this.updateCount()
  }

  filter() {
    const query = this.normalize(this.queryTarget.value.trim())
    let visibleCount = 0

    this.cardTargets.forEach(card => {
      const searchableText = this.normalize(card.dataset.searchable)
      const matches = searchableText.includes(query)

      if (matches) {
        card.classList.remove("hidden")
        visibleCount++
      } else {
        card.classList.add("hidden")
      }
    })

    this.updateCount(visibleCount)

    if (this.hasNoResultsTarget) {
      if (visibleCount === 0 && query !== "") {
        this.noResultsTarget.classList.remove("hidden")
      } else {
        this.noResultsTarget.classList.add("hidden")
      }
    }
  }

  clear() {
    this.queryTarget.value = ""
    this.filter()
    this.queryTarget.focus()
  }

  updateCount(count = null) {
    if (this.hasCountTarget) {
      const total = count !== null ? count : this.cardTargets.length
      this.countTarget.textContent = total
    }
  }

  normalize(text) {
    return text
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
  }
}
