import PaginationController from "controllers/pagination_controller"

export default class extends PaginationController {
  static targets = ["container", "paginationControls", "listContainer"]
  static values = {
    url: String,
    type: String,
    perPage: { type: Number, default: 10 }
  }

  connect() {
  }

  loadByType(event) {
    const type = event.currentTarget.dataset.exerciseType
    this.typeValue = type

    const endpoints = {
      strength: '/strength_exercises',
      mobility: '/mobility_exercises',
      core: '/core_exercises',
      cardio: '/cardio_exercises'
    }

    this.urlValue = endpoints[type]
    this.loadPage(1)
  }

  renderItems(data) {
    if (!this.hasListContainerTarget) {
      return
    }

    const exercises = data.exercises || []

    if (exercises.length === 0) {
      this.listContainerTarget.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhum exercício cadastrado.</p>'
      return
    }

    this.listContainerTarget.innerHTML = exercises.map(exercise => this.renderExercise(exercise)).join('')
  }

  renderExercise(exercise) {
    return `
      <div class="exercise-card flex items-start justify-between p-4 bg-gray-50 rounded-lg border border-gray-200 hover:border-cyan-300 transition-colors" data-name="${this.escapeHtml(exercise.name)}">
        <div class="flex-1">
          <h4 class="font-semibold text-gray-900 mb-1">${this.escapeHtml(exercise.name)}</h4>
          ${exercise.muscle_group ? `<p class="text-sm text-gray-600">Músculo: ${this.escapeHtml(exercise.muscle_group)}</p>` : ''}
          ${exercise.equipment ? `<p class="text-sm text-gray-600">Equipamento: ${this.escapeHtml(exercise.equipment)}</p>` : ''}
          ${exercise.category ? `<p class="text-sm text-gray-600">Categoria: ${this.escapeHtml(exercise.category)}</p>` : ''}
          ${exercise.cardio_type ? `<p class="text-sm text-gray-600">Tipo: ${this.escapeHtml(exercise.cardio_type)}</p>` : ''}
          ${exercise.description ? `<p class="text-sm text-gray-500 mt-2">${this.escapeHtml(exercise.description)}</p>` : ''}
        </div>
        <div class="flex gap-2 ml-4">
          <button onclick="manageVideos('${this.typeValue}', ${exercise.id}, '${this.escapeHtml(exercise.name).replace(/'/g, "\\'")}')" class="px-3 py-1 bg-purple-100 text-purple-700 rounded-lg text-sm font-medium hover:bg-purple-200 flex items-center gap-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
            </svg>
            Vídeos
          </button>
          <button onclick="editExercise('${this.typeValue}', ${exercise.id})" class="px-3 py-1 bg-cyan-100 text-cyan-700 rounded-lg text-sm font-medium hover:bg-cyan-200">
            Editar
          </button>
          <button onclick="deleteExercise('${this.typeValue}', ${exercise.id})" class="px-3 py-1 bg-red-100 text-red-700 rounded-lg text-sm font-medium hover:bg-red-200">
            Excluir
          </button>
        </div>
      </div>
    `
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
      <div class="flex items-center justify-between mt-6 p-4 bg-gray-50 rounded-lg border border-gray-200">
        <div class="text-sm text-gray-600">
          Mostrando ${startItem}-${endItem} de ${total_count} exercícios
        </div>
        <div class="flex gap-2">
    `

    if (current_page > 1) {
      html += `
        <button data-action="click->exercise-pagination#changePage"
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
          <button data-action="click->exercise-pagination#changePage"
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
        <button data-action="click->exercise-pagination#changePage"
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

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
