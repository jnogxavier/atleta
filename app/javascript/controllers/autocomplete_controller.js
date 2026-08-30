import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hiddenInput", "clearButton"]
  static values = {
    url: String,
    searchFields: { type: Array, default: ["name"] },
    displayField: { type: String, default: "name" },
    secondaryField: String,
    statusField: String,
    statusActiveText: { type: String, default: "Ativo" },
    statusInactiveText: { type: String, default: "Inativo" },
    serverSearch: { type: Boolean, default: false }
  }

  connect() {
    this.items = []
    this.itemsLoaded = false
    this.isLoadingItems = false
    this.setupClickOutside()
    if (!this.serverSearchValue) {
      this.loadItemsOnce()
    }
  }

  disconnect() {
    this.teardownClickOutside()
  }

  loadItemsOnce() {
    if (this.itemsLoaded || this.isLoadingItems) return
    this.loadItems()
  }

  loadItems() {
    if (!this.urlValue) return
    if (this.itemsLoaded) return

    this.isLoadingItems = true

    fetch(this.urlValue, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => response.json())
    .then(items => {
      this.items = items
      this.itemsLoaded = true
      this.isLoadingItems = false
    })
    .catch(error => {
      this.isLoadingItems = false
    })
  }

  filter() {
    const query = this.inputTarget.value.trim()

    if (this.serverSearchValue) {
      this.searchOnServer(query)
    } else {
      if (!this.itemsLoaded && !this.isLoadingItems) {
        this.loadItems()
      }
      this.filterItems(query)
    }
  }

  showAll() {
    if (this.serverSearchValue) {
      this.showLoading()
      this.searchOnServer('')
    } else {
      if (!this.itemsLoaded && !this.isLoadingItems) {
        this.loadItems()
      }
      if (this.items.length > 0) {
        this.filterItems('')
      }
    }
  }

  searchOnServer(query) {
    this.showLoading()
    const params = new URLSearchParams()
    if (query.length > 0) {
      params.append('q', query)
    }

    fetch(`${this.urlValue}?${params.toString()}`)
      .then(response => response.json())
      .then(items => {
        this.renderResults(items)
      })
      .catch(error => {
        console.error('Error searching items:', error)
        this.resultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center">Erro ao buscar</div>'
        this.resultsTarget.classList.remove('hidden')
      })
  }

  showLoading() {
    this.resultsTarget.innerHTML = '<div class="p-4 text-center"><div class="inline-block"><div class="animate-spin rounded-full h-5 w-5 border-b-2 border-cyan-500"></div></div></div>'
    this.resultsTarget.classList.remove('hidden')
  }

  filterItems(query) {
    const normalizedQuery = this.normalizeText(query)

    const filtered = this.items.filter(item => {
      return this.searchFieldsValue.some(field => {
        const value = this.getNestedValue(item, field)
        return value && this.normalizeText(value).includes(normalizedQuery)
      })
    })

    this.renderResults(filtered)
  }

  renderResults(items) {
    if (items.length === 0) {
      this.resultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center">Nenhum resultado encontrado</div>'
    } else {
      this.resultsTarget.innerHTML = items.map(item => this.createResultItem(item)).join('')
      this.attachResultClickHandlers()
    }
    this.resultsTarget.classList.remove('hidden')
  }

  createResultItem(item) {
    const displayValue = this.getNestedValue(item, this.displayFieldValue)
    const secondaryValue = this.secondaryFieldValue ? this.getNestedValue(item, this.secondaryFieldValue) : null
    const statusValue = this.statusFieldValue ? this.getNestedValue(item, this.statusFieldValue) : null

    const escapedDisplayValue = this.escapeHtml(displayValue)
    const escapedSecondaryValue = secondaryValue ? this.escapeHtml(secondaryValue) : null

    const statusBadge = statusValue !== null ? (
      statusValue
        ? `<span class="px-2 py-0.5 bg-green-100 text-green-700 rounded text-xs font-medium">${this.statusActiveTextValue}</span>`
        : `<span class="px-2 py-0.5 bg-gray-100 text-gray-600 rounded text-xs font-medium">${this.statusInactiveTextValue}</span>`
    ) : ''

    return `
      <div class="p-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0 autocomplete-result-item"
           data-item-id="${item.id}"
           data-item-display="${escapedDisplayValue}">
        <div class="flex items-center justify-between">
          <div class="flex-1">
            <div class="font-medium text-gray-900">${escapedDisplayValue}</div>
            ${escapedSecondaryValue ? `<div class="text-sm text-gray-600">${escapedSecondaryValue}</div>` : ''}
          </div>
          ${statusBadge}
        </div>
      </div>
    `
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = String(text)
    return div.innerHTML
  }

  normalizeText(text) {
    return text
      .toString()
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
  }

  attachResultClickHandlers() {
    this.resultsTarget.querySelectorAll('.autocomplete-result-item').forEach(item => {
      item.addEventListener('click', () => this.selectItem(item))
    })
  }

  selectItem(element) {
    const itemId = element.dataset.itemId
    const itemDisplay = element.dataset.itemDisplay

    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = itemId
    }
    this.inputTarget.value = itemDisplay
    this.resultsTarget.classList.add('hidden')

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.remove('hidden')
    }

    this.dispatch('selected', { detail: { id: itemId, display: itemDisplay } })
  }

  clear(event) {
    if (event) event.preventDefault()

    this.inputTarget.value = ''
    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.value = ''
    }
    this.resultsTarget.classList.add('hidden')

    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.classList.add('hidden')
    }

    this.dispatch('cleared')
  }

  setupClickOutside() {
    this.clickOutsideHandler = (e) => {
      if (!this.element.contains(e.target)) {
        this.resultsTarget.classList.add('hidden')
      }
    }
    document.addEventListener('click', this.clickOutsideHandler)
  }

  teardownClickOutside() {
    if (this.clickOutsideHandler) {
      document.removeEventListener('click', this.clickOutsideHandler)
    }
  }

  getNestedValue(obj, path) {
    return path.split('.').reduce((current, prop) => current?.[prop], obj)
  }
}
