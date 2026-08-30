import { Controller } from "@hotwired/stimulus"
import { escapeHtml, sanitizeUrl } from "utils/sanitize_utils"

export default class extends Controller {
  static targets = ["grid", "emptyState", "statusFilter", "typeFilter", "pagination"]
  static values = {
    currentPage: { type: Number, default: 1 }
  }

  connect() {
    this.setupMediaClickHandler()
    if (!this.element.classList.contains('hidden')) {
      this.loadMedia()
    }
  }

  initialize() {
    this.boundTabShowHandler = this.handleTabShow.bind(this)
    window.addEventListener('tab:show', this.boundTabShowHandler)
  }

  disconnect() {
    window.removeEventListener('tab:show', this.boundTabShowHandler)
  }

  setupMediaClickHandler() {
    this.boundMediaClick = this.handleMediaClick.bind(this)
    this.element.addEventListener('click', this.boundMediaClick)
  }

  handleMediaClick(event) {
    const button = event.target.closest('button[data-media-id]')
    if (!button) return

    event.preventDefault()
    const mediaId = button.dataset.mediaId

    // Find the evaluation-modal controller and call its open method
    const modalElement = this.element.querySelector('[data-controller~="evaluation-modal"]')
    if (modalElement && modalElement.controller) {
      modalElement.controller('evaluation-modal').open({ currentTarget: { dataset: { mediaId } } })
    } else {
      // Fallback: directly fetch and display the media
      this.openMediaModal(mediaId)
    }
  }

  openMediaModal(mediaId) {
    fetch(`/admin/evaluation_media/${mediaId}`)
      .then(response => response.json())
      .then(media => {
        const modalElement = this.element.querySelector('[data-controller~="evaluation-modal"]')
        if (modalElement) {
          // Dispatch a custom event with the media data
          const event = new CustomEvent('evaluation:open-modal', {
            detail: { media },
            bubbles: true
          })
          modalElement.dispatchEvent(event)
        }
      })
      .catch(error => console.error('Error loading media:', error))
  }

  handleTabShow(event) {
    if (event.detail.tab === 'evaluations') {
      this.loadMedia()
    }
  }

  studentSelected(event) {
    this.currentPageValue = 1
    this.loadMedia()
  }

  studentCleared(event) {
    this.currentPageValue = 1
    this.loadMedia()
  }

  filterChanged() {
    this.currentPageValue = 1
    this.loadMedia()
  }

  loadMedia(page = null) {
    if (page !== null) {
      this.currentPageValue = page
    }

    const params = new URLSearchParams()

    const studentIdInput = document.getElementById('evaluation_selected_student_id')
    if (studentIdInput?.value) {
      params.append('student_id', studentIdInput.value)
    }

    if (this.hasStatusFilterTarget && this.statusFilterTarget.value) {
      params.append('status', this.statusFilterTarget.value)
    }

    if (this.hasTypeFilterTarget && this.typeFilterTarget.value) {
      params.append('type', this.typeFilterTarget.value)
    }

    fetch(`/admin/evaluation_media?${params}`)
      .then(response => response.json())
      .then(response => {
        this.renderMediaWithPagination(response.data || response)
      })
      .catch(error => {})
  }

  changePage(event) {
    event.preventDefault()
    const page = parseInt(event.currentTarget.dataset.page)
    this.loadMedia(page)
  }

  renderMediaWithPagination(data) {
    if (data.length === 0) {
      this.gridTarget.innerHTML = ''
      this.emptyStateTarget.classList.remove('hidden')
      this.paginationTarget.innerHTML = ''
      return
    }

    this.emptyStateTarget.classList.add('hidden')

    const groupedByStudent = data.reduce((acc, media) => {
      const studentKey = media.student_id || media.student_name
      if (!acc[studentKey]) {
        acc[studentKey] = {
          student_name: media.student_name,
          student_id: media.student_id,
          media: []
        }
      }
      acc[studentKey].media.push(media)
      return acc
    }, {})

    const studentGroups = Object.values(groupedByStudent)
    const itemsPerPage = 5
    const totalPages = Math.ceil(studentGroups.length / itemsPerPage)
    const startIndex = (this.currentPageValue - 1) * itemsPerPage
    const endIndex = startIndex + itemsPerPage
    const paginatedStudents = studentGroups.slice(startIndex, endIndex)

    this.gridTarget.innerHTML = paginatedStudents
      .map(student => this.createStudentCard(student))
      .join('')

    this.renderPagination({ current_page: this.currentPageValue, total_pages: totalPages })
  }

  renderMedia(data) {
    this.renderMediaWithPagination(data)
  }

  createStudentCard(student) {
    const totalMedia = student.media.length
    const evaluated = student.media.filter(m => m.evaluated).length
    const pending = totalMedia - evaluated

    const mediaThumbnails = student.media.map(media => {
      const statusBadge = media.evaluated
        ? '<span class="absolute top-2 right-2 px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded-full">✓</span>'
        : '<span class="absolute top-2 right-2 px-2 py-1 bg-yellow-100 text-yellow-800 text-xs font-medium rounded-full">!</span>'

      let thumbnail
      const safeFileUrl = sanitizeUrl(media.file_url)
      if (media.media_type === 'photo' && safeFileUrl) {
        thumbnail = `<img src="${safeFileUrl}" class="w-full h-32 object-cover" alt="${escapeHtml(media.category || '')}">`
      } else if (media.media_type === 'audio') {
        thumbnail = `<div class="w-full h-32 bg-blue-600 flex items-center justify-center">
                      <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 3a9 9 0 100 18 9 9 0 000-18zm0 16a7 7 0 110-14 7 7 0 010 14zm-2-10a1 1 0 11-2 0 1 1 0 012 0zm6 0a1 1 0 11-2 0 1 1 0 012 0zm-3-2a1.5 1.5 0 100 3 1.5 1.5 0 000-3z"></path>
                      </svg>
                    </div>`
      } else {
        thumbnail = `<div class="w-full h-32 bg-gray-800 flex items-center justify-center">
                      <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                    </div>`
      }

      const categoryLabel = media.category
        ? escapeHtml(media.category.charAt(0).toUpperCase() + media.category.slice(1))
        : 'Sem categoria'

      let uploadedDate = 'N/A'
      try {
        if (media.uploaded_at) {
          uploadedDate = new Date(media.uploaded_at).toLocaleDateString('pt-BR')
        }
      } catch (e) {
        console.error('Invalid date:', media.uploaded_at)
      }

      return `
        <button type="button"
                class="relative cursor-pointer hover:opacity-75 transition-opacity rounded-lg overflow-hidden focus:outline-none focus:ring-2 focus:ring-cyan-500"
                data-action="click->evaluation-modal#open"
                data-media-id="${media.id}">
          ${thumbnail}
          ${statusBadge}
          <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-2">
            <p class="text-white text-xs font-medium">${categoryLabel}</p>
            <p class="text-white/80 text-xs">${escapeHtml(uploadedDate)}</p>
          </div>
        </button>
      `
    }).join('')

    return `
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h3 class="text-xl font-bold text-gray-900">${student.student_name}</h3>
            <p class="text-sm text-gray-600 mt-1">${totalMedia} mídia(s) enviada(s)</p>
          </div>
          <div class="flex gap-2">
            ${pending > 0 ? `<span class="px-3 py-1 bg-yellow-100 text-yellow-800 text-sm font-medium rounded-full">${pending} pendente(s)</span>` : ''}
            ${evaluated > 0 ? `<span class="px-3 py-1 bg-green-100 text-green-800 text-sm font-medium rounded-full">${evaluated} avaliado(s)</span>` : ''}
          </div>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          ${mediaThumbnails}
        </div>
      </div>
    `
  }

  renderPagination(pagination) {
    if (!pagination || !this.hasPaginationTarget) {
      return
    }

    const { current_page, total_pages } = pagination

    if (total_pages <= 1) {
      this.paginationTarget.innerHTML = ''
      return
    }

    let html = '<div class="mt-4 flex items-center justify-center gap-2">'

    if (current_page > 1) {
      html += `
        <button data-action="click->evaluation#changePage"
                data-page="${current_page - 1}"
                class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200">
          Anterior
        </button>
      `
    }

    for (let i = 1; i <= total_pages; i++) {
      if (i === 1 || i === total_pages || (i >= current_page - 2 && i <= current_page + 2)) {
        const isActive = i === current_page
        html += `
          <button data-action="click->evaluation#changePage"
                  data-page="${i}"
                  class="px-3 py-1 ${isActive ? 'bg-cyan-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'} rounded-lg text-sm font-medium">
            ${i}
          </button>
        `
      } else if (i === current_page - 3 || i === current_page + 3) {
        html += '<span class="px-2 text-gray-500">...</span>'
      }
    }

    if (current_page < total_pages) {
      html += `
        <button data-action="click->evaluation#changePage"
                data-page="${current_page + 1}"
                class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200">
          Próximo
        </button>
      `
    }

    html += '</div>'
    this.paginationTarget.innerHTML = html
  }

  reload() {
    this.loadMedia()
  }
}
