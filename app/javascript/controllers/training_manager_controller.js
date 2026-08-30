import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "allTrainingsSection",
    "allTrainingsList",
    "allPagination",
    "studentTrainingsSection",
    "studentTrainingsList",
    "newTrainingBtnGeneral",
    "newTrainingBtnStudent"
  ]

  static values = {
    currentPage: { type: Number, default: 1 }
  }

  connect() {
    this.selectedStudentId = null
    this.selectedStudentName = null

    const activeTab = localStorage.getItem('adminDashboardActiveTab')
    if (activeTab === 'trainings') {
      setTimeout(() => this.loadAllTrainings(), 0)
    } else {
      this.loadAllTrainings()
    }
  }

  initialize() {
    this.boundTabShowHandler = this.handleTabShow.bind(this)
    window.addEventListener('tab:show', this.boundTabShowHandler)
  }

  disconnect() {
    window.removeEventListener('tab:show', this.boundTabShowHandler)
  }

  handleTabShow(event) {
    if (event.detail.tab === 'trainings') {
      this.loadAllTrainings()
    }
  }

  studentSelected(event) {
    this.selectedStudentId = event.detail.id
    this.selectedStudentName = event.detail.display

    this.allTrainingsSectionTarget.classList.add('hidden')
    this.studentTrainingsSectionTarget.classList.remove('hidden')

    if (this.hasNewTrainingBtnStudentTarget) {
      this.newTrainingBtnStudentTarget.classList.remove('hidden')
    }

    this.loadStudentTrainings()
  }

  studentCleared(event) {
    this.selectedStudentId = null
    this.selectedStudentName = null

    this.studentTrainingsSectionTarget.classList.add('hidden')
    this.allTrainingsSectionTarget.classList.remove('hidden')

    if (this.hasNewTrainingBtnStudentTarget) {
      this.newTrainingBtnStudentTarget.classList.add('hidden')
    }

    this.loadAllTrainings()
  }

  loadAllTrainings(page = null) {
    if (page !== null) {
      this.currentPageValue = page
    }

    fetch(`/admin/trainings?page=${this.currentPageValue}`, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      return response.json()
    })
    .then(data => {
      const trainings = data.trainings || data
      const totalPages = data.total_pages || Math.ceil(trainings.length / 10)

      this.renderAllTrainings(trainings)
      this.renderPagination(totalPages, this.currentPageValue)
    })
    .catch(error => {
      this.showToast('Erro ao carregar treinos', 'error')
    })
  }

  loadStudentTrainings() {
    if (!this.selectedStudentId) return

    fetch(`/admin/trainings?student_id=${this.selectedStudentId}`, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => {
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      return response.json()
    })
    .then(trainings => {
      this.renderStudentTrainings(trainings)
    })
    .catch(error => {
      this.showToast('Erro ao carregar treinos do aluno', 'error')
    })
  }

  renderAllTrainings(trainings) {
    if (trainings.length === 0) {
      this.allTrainingsListTarget.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhum treino cadastrado.</p>'
      return
    }

    this.allTrainingsListTarget.innerHTML = trainings.map(training => this.createTrainingCard(training, true)).join('')
  }

  renderStudentTrainings(trainings) {
    if (trainings.length === 0) {
      this.studentTrainingsListTarget.innerHTML = '<p class="text-gray-500 text-center py-8">Nenhum treino cadastrado para este aluno.</p>'
      return
    }

    this.studentTrainingsListTarget.innerHTML = trainings.map(training => this.createTrainingCard(training, false)).join('')
  }

  createTrainingCard(training, showStudentName = false) {
    const statusBadge = training.active
      ? '<span class="ml-2 px-2 py-0.5 bg-green-100 text-green-700 rounded text-xs font-medium">Ativo</span>'
      : '<span class="ml-2 px-2 py-0.5 bg-gray-100 text-gray-700 rounded text-xs font-medium">Inativo</span>'

    const studentInfo = showStudentName && training.student_name
      ? `Aluno: ${training.student_name} • `
      : ''

    const dayInfo = training.day ? `Dia: ${training.day}` : ''
    const descInfo = training.description ? ` • ${training.description}` : ''

    return `
      <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg border border-gray-200 hover:border-cyan-300 transition-colors">
        <div class="flex-1">
          <h4 class="font-semibold text-gray-900">${training.name}</h4>
          <p class="text-sm text-gray-600 mt-1">
            ${studentInfo}${dayInfo}${descInfo}${statusBadge}
          </p>
        </div>
        <div class="flex gap-2">
          <a href="/student/trainings/${training.id}"
             target="_blank"
             class="p-2 text-gray-600 hover:text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
            </svg>
          </a>
          <button data-action="click->training-manager#view"
                  data-training-id="${training.id}"
                  class="p-2 text-gray-600 hover:text-gray-700 hover:bg-gray-50 rounded-lg transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
            </svg>
          </button>
          <button data-action="click->training-manager#edit"
                  data-training-id="${training.id}"
                  class="p-2 text-cyan-600 hover:text-cyan-700 hover:bg-cyan-50 rounded-lg transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
            </svg>
          </button>
          <button data-action="click->training-manager#deleteTraining"
                  data-training-id="${training.id}"
                  data-training-name="${this.escapeHtml(training.name)}"
                  class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>
      </div>
    `
  }

  renderPagination(totalPages, currentPage) {
    if (totalPages <= 1) {
      this.allPaginationTarget.innerHTML = ''
      return
    }

    let html = ''

    if (currentPage > 1) {
      html += `
        <button data-action="click->training-manager#changePage"
                data-page="${currentPage - 1}"
                class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200">
          Anterior
        </button>
      `
    }

    for (let i = 1; i <= totalPages; i++) {
      if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
        const isActive = i === currentPage
        html += `
          <button data-action="click->training-manager#changePage"
                  data-page="${i}"
                  class="px-3 py-1 ${isActive ? 'bg-cyan-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'} rounded-lg text-sm font-medium">
            ${i}
          </button>
        `
      } else if (i === currentPage - 3 || i === currentPage + 3) {
        html += '<span class="px-2 text-gray-500">...</span>'
      }
    }

    if (currentPage < totalPages) {
      html += `
        <button data-action="click->training-manager#changePage"
                data-page="${currentPage + 1}"
                class="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-200">
          Próximo
        </button>
      `
    }

    this.allPaginationTarget.innerHTML = html
  }

  changePage(event) {
    const page = parseInt(event.currentTarget.dataset.page)
    this.loadAllTrainings(page)
  }

  view(event) {
    const trainingId = event.currentTarget.dataset.trainingId
    this.dispatch('view', { detail: { trainingId, studentId: this.selectedStudentId } })
  }

  edit(event) {
    const trainingId = event.currentTarget.dataset.trainingId
    this.dispatch('edit', { detail: { trainingId, studentId: this.selectedStudentId } })
  }

  delete(event) {
    const trainingId = event.currentTarget.dataset.trainingId
    const trainingName = event.currentTarget.dataset.trainingName

    if (!confirm(`Tem certeza que deseja excluir ${trainingName}?`)) return

    fetch(`/admin/trainings/${trainingId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(result => {
      if (result.success) {
        this.showToast('Treino excluído com sucesso!', 'success')

        if (this.selectedStudentId) {
          this.loadStudentTrainings()
        } else {
          this.loadAllTrainings()
        }
      } else {
        this.showToast('Erro ao excluir treino', 'error')
      }
    })
    .catch(error => {
      this.showToast('Erro ao excluir treino', 'error')
    })
  }

  deleteTraining(event) {
    const trainingId = event.currentTarget.dataset.trainingId
    const trainingName = event.currentTarget.dataset.trainingName

    // Find the global delete modal controller
    const deleteModalElement = document.querySelector('[data-controller*="delete-modal"]')
    if (!deleteModalElement) {
      this.showToast('Modal de exclusão não encontrado', 'error')
      return
    }

    // Get the delete modal controller instance
    const deleteModalController = this.application.getControllerForElementAndIdentifier(
      deleteModalElement,
      'delete-modal'
    )

    if (!deleteModalController) {
      this.showToast('Controlador de modal não encontrado', 'error')
      return
    }

    // Create a synthetic button with the data attributes the modal needs
    const syntheticButton = document.createElement('button')
    syntheticButton.dataset.itemName = trainingName
    syntheticButton.dataset.itemType = 'treino'
    syntheticButton.dataset.deletePath = `/admin/trainings/${trainingId}`

    // Call the modal's open method with the synthetic button
    deleteModalController.open({ currentTarget: syntheticButton, preventDefault: () => {} })
  }

  newTraining(event) {
    event.preventDefault()
    this.dispatch('new', {
      detail: {
        studentId: this.selectedStudentId,
        studentName: this.selectedStudentName
      }
    })
  }

  trainingSaved() {
    if (this.selectedStudentId) {
      this.loadStudentTrainings()
    } else {
      this.loadAllTrainings()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  showToast(message, type) {
    if (typeof window.showToast === 'function') {
      window.showToast(message, type)
    }
  }
}
