import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeButton", "clearButton"]

  connect() {
    this.currentType = "strength"
  }

  switchType(event) {
    const button = event.currentTarget
    this.currentType = button.dataset.exerciseType

    // Update button styles
    this.typeButtonTargets.forEach(btn => {
      btn.classList.remove("active")
    })
    button.classList.add("active")

    // Clear search input when switching type
    const searchInput = this.element.querySelector('[data-search-target="input"]')
    if (searchInput) {
      searchInput.value = ""
    }

    // Reload exercises with new type
    this.loadExercises()
  }

  clearFilter() {
    this.currentType = "strength"
    this.typeButtonTargets.forEach(btn => {
      btn.classList.remove("active")
      if (btn.dataset.exerciseType === "strength") {
        btn.classList.add("active")
      }
    })

    // Clear search input when clearing filter
    const searchInput = this.element.querySelector('[data-search-target="input"]')
    if (searchInput) {
      searchInput.value = ""
    }

    this.loadExercises()
  }

  loadExercises() {
    // Get search controller from the parent element
    const searchInput = this.element.querySelector('[data-search-target="input"]')
    const searchQuery = searchInput?.value || ""

    // Get the search URL from the parent element's data attribute
    const searchUrl = this.element.dataset.searchUrlValue
    if (!searchUrl) return

    const url = new URL(searchUrl, window.location.origin)
    url.searchParams.set("type", this.currentType)
    if (searchQuery) {
      url.searchParams.set("search", searchQuery)
    }

    fetch(url, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => this.updateExercises(data))
      .catch(error => console.error("Error loading exercises:", error))
  }

  updateExercises(data) {
    const container = this.element.querySelector('[data-search-target="container"]')
    if (container) {
      container.innerHTML = data.html
    }

    const noResults = this.element.querySelector('[data-search-target="noResults"]')
    if (noResults) {
      const hasResults = data.total_count > 0
      noResults.classList.toggle("hidden", hasResults)
    }
  }

  exerciseSaved() {
    // Reload exercises when a new one is saved
    this.loadExercises()
  }

  openNewExerciseModal() {
    const modal = document.querySelector('[data-exercise-form-modal-target="container"]')
    if (modal) {
      modal.classList.remove("hidden")
    }
  }
}
