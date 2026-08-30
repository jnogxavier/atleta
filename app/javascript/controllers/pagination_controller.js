import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "paginationControls"]
  static values = {
    url: String,
    type: String,
    perPage: { type: Number, default: 10 }
  }

  currentPage = 1
  currentPagination = null

  connect() {
    this.loadPage(1)
  }

  loadPage(page, additionalParams = {}) {
    this.currentPage = page
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set('page', page)

    Object.entries(additionalParams).forEach(([key, value]) => {
      url.searchParams.set(key, value)
    })

    fetch(url, {
      headers: {
        'Accept': 'application/json'
      }
    })
      .then(response => response.json())
      .then(data => {
        this.currentPagination = data.pagination
        this.renderItems(data)
        this.renderPagination()
      })
      .catch(error => {})
  }

  changePage(event) {
    event.preventDefault()
    const page = parseInt(event.currentTarget.dataset.page)
    this.loadPage(page)
  }

  renderItems(data) {
  }

  renderPagination() {
    if (!this.currentPagination || !this.hasPaginationControlsTarget) {
      return
    }

    const { current_page, total_pages, total_count } = this.currentPagination
    const perPage = this.perPageValue

    if (total_pages <= 1) {
      this.paginationControlsTarget.innerHTML = ''
      return
    }

    const startItem = ((current_page - 1) * perPage) + 1
    const endItem = Math.min(current_page * perPage, total_count)

    let html = `
      <div class="flex items-center justify-between mt-4">
        <div class="text-sm text-gray-600">
          Mostrando ${startItem}-${endItem} de ${total_count} itens
        </div>
        <div class="flex gap-2">
    `

    if (current_page > 1) {
      html += `
        <button data-action="click->pagination#changePage"
                data-page="${current_page - 1}"
                class="px-3 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
        </button>
      `
    } else {
      html += `
        <span class="px-3 py-2 border border-gray-200 text-gray-400 rounded-lg cursor-not-allowed">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
        </span>
      `
    }

    for (let i = 1; i <= total_pages; i++) {
      if (
        i === 1 ||
        i === total_pages ||
        Math.abs(i - current_page) <= 2
      ) {
        const activeClass = i === current_page
          ? 'bg-cyan-500 text-white border-cyan-500'
          : 'border-gray-300 text-gray-700 hover:bg-gray-50'

        html += `
          <button data-action="click->pagination#changePage"
                  data-page="${i}"
                  class="px-3 py-2 border rounded-lg transition-colors ${activeClass}">
            ${i}
          </button>
        `
      } else if (Math.abs(i - current_page) === 3) {
        html += '<span class="px-3 py-2 text-gray-400">...</span>'
      }
    }

    if (current_page < total_pages) {
      html += `
        <button data-action="click->pagination#changePage"
                data-page="${current_page + 1}"
                class="px-3 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </button>
      `
    } else {
      html += `
        <span class="px-3 py-2 border border-gray-200 text-gray-400 rounded-lg cursor-not-allowed">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
          </svg>
        </span>
      `
    }

    html += `
        </div>
      </div>
    `

    this.paginationControlsTarget.innerHTML = html
  }
}
