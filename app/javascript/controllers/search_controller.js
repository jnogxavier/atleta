import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container", "noResults"]
  static values = {
    url: String,
    debounceDelay: Number
  }

  connect() {
    this.timeout = null
    this.debounceDelayValue = this.debounceDelayValue || 300
  }

  handlePaginationLink(e) {
    e.preventDefault()

    const href = e.currentTarget.getAttribute('href')
    if (!href) return

    const url = new URL(href, window.location.origin)
    const searchParam = url.searchParams.get('search')

    if (searchParam) {
      this.fetchPage(href)
    } else {
      window.location.href = href
    }
  }

  fetchPage(url) {
    fetch(url, {
      headers: { 'Accept': 'application/json' }
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(data => this.updateResults(data))
      .catch(error => {
        logError('search_controller#fetchPage', error, { url })
        showErrorToast('Erro ao carregar página. Tente novamente.', 'Busca')
      })
  }

  filter(event) {
    const query = this.inputTarget.value.trim()

    // If no URL is provided, fall back to client-side filtering
    if (!this.urlValue) {
      this.clientSideFilter(query)
      return
    }

    // Server-side search with debounce
    clearTimeout(this.timeout)

    if (query.length === 0) {
      this.performSearch("")
      return
    }

    this.timeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceDelayValue)
  }

  performSearch(query) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('search', query)
    url.searchParams.set('page', '1')

    // For exercises, search all types by passing type=all
    if (this.urlValue.includes('strength_exercises') || this.urlValue.includes('mobility_exercises') ||
        this.urlValue.includes('core_exercises') || this.urlValue.includes('cardio_exercises')) {
      url.searchParams.set('type', 'all')
    }

    fetch(url, {
      headers: { 'Accept': 'application/json' }
    })
      .then(response => response.json())
      .then(data => this.updateResults(data))
      .catch(error => console.error('Search error:', error))
  }

  updateResults(data) {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = data.html
    }

    if (this.hasNoResultsTarget) {
      const hasResults = data.total_count > 0
      this.noResultsTarget.classList.toggle('hidden', hasResults)
    }

    // Update pagination if provided
    if (data.pagination_html) {
      const paginationContainer = document.querySelector('[data-search-target="pagination"]')
      if (paginationContainer) {
        paginationContainer.innerHTML = data.pagination_html
      }
    }
  }

  clientSideFilter(query) {
    const normalizedQuery = this.normalizeText(query)
    let visibleCount = 0

    document.querySelectorAll('[data-search-target="item"]').forEach(item => {
      const searchableText = this.normalizeText(item.dataset.searchable || "")
      const matches = searchableText.includes(normalizedQuery)

      if (matches || query === "") {
        item.classList.remove("hidden")
        visibleCount++
      } else {
        item.classList.add("hidden")
      }
    })

    // Show/hide no results message
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.classList.toggle('hidden', visibleCount > 0 || query === "")
    }
  }

  normalizeText(text) {
    return text
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
  }

  clearSearch() {
    this.inputTarget.value = ""
    this.filter()
  }
}
