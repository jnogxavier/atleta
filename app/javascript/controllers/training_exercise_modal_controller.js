import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = [
    "container",
    "searchInput",
    "searchResults"
  ]

  connect() {
    super.connect()
    this.currentType = null
    this.allExercises = []
  }

  initialize() {
    this.boundOpenModalHandler = this.handleOpenModal.bind(this)
    window.addEventListener('training-form:open-exercise-modal', this.boundOpenModalHandler)
  }

  disconnect() {
    window.removeEventListener('training-form:open-exercise-modal', this.boundOpenModalHandler)
  }

  handleOpenModal(event) {
    this.openForType(event.detail.type)
  }

  openForType(type) {
    this.currentType = type
    this.searchInputTarget.value = ''
    this.loadExercises(type)
    this.containerTarget.classList.remove('hidden')
  }

  loadExercises(type) {
    this.currentType = type
    this.performSearch('')
  }

  search() {
    const query = this.searchInputTarget.value.trim()
    this.performSearch(query)
  }

  performSearch(query) {
    const endpoints = {
      strength: '/admin/strength_exercises',
      mobility: '/admin/mobility_exercises',
      core: '/admin/core_exercises',
      cardio: '/admin/cardio_exercises'
    }

    const searchUrl = new URL(endpoints[this.currentType] + '/search', window.location.origin)
    searchUrl.searchParams.set('search', query)
    searchUrl.searchParams.set('for_modal', 'true')

    fetch(searchUrl.toString(), {
      credentials: 'same-origin',
      headers: { 'Accept': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
      this.allExercises = Array.isArray(data) ? data : (data.exercises || [])
      this.renderExercises(this.allExercises)
    })
    .catch(error => {
      console.error('Error fetching exercises:', error)
    })
  }

  renderExercises(exercises) {
    if (exercises.length === 0) {
      this.searchResultsTarget.innerHTML = `
        <div class="text-center py-8 text-gray-500">
          <p>Nenhum exercício encontrado</p>
        </div>
      `
      return
    }

    this.searchResultsTarget.innerHTML = exercises.map(ex => this.createExerciseCard(ex)).join('')
  }

  createExerciseCard(exercise) {
    return `
      <div class="p-3 border-b border-gray-200 hover:bg-gray-50 cursor-pointer"
           data-action="click->training-exercise-modal#selectExercise"
           data-exercise-id="${exercise.id}"
           data-exercise-name="${this.escapeHtml(exercise.name)}"
           data-exercise-data='${JSON.stringify(exercise).replace(/'/g, "&apos;")}'>
        <h5 class="font-medium text-gray-900">${exercise.name}</h5>
        ${exercise.muscle_group ? `<p class="text-sm text-gray-600">Músculo: ${exercise.muscle_group}</p>` : ''}
        ${exercise.equipment ? `<p class="text-sm text-gray-600">Equipamento: ${exercise.equipment}</p>` : ''}
        ${exercise.description ? `<p class="text-sm text-gray-500 mt-1">${exercise.description}</p>` : ''}
      </div>
    `
  }

  selectExercise(event) {
    const exerciseData = JSON.parse(event.currentTarget.dataset.exerciseData)

    const exercise = {
      id: exerciseData.id,
      name: exerciseData.name,
      muscle_group: exerciseData.muscle_group,
      equipment: exerciseData.equipment,
      sets: this.currentType === 'strength' || this.currentType === 'core' ? 3 : null,
      repetitions: this.currentType === 'strength' || this.currentType === 'core' ? 12 : null,
      duration: this.currentType === 'mobility' || this.currentType === 'cardio' ? '30s' : null,
      rest_time: this.currentType === 'strength' ? '60s' : null,
      intensity: this.currentType === 'cardio' ? 'Moderada' : null,
      notes: ''
    }

    const trainingFormController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="training-form"]'),
      'training-form'
    )

    if (trainingFormController) {
      trainingFormController.addExercise({
        detail: {
          exercise: exercise,
          type: this.currentType
        }
      })
    }

    this.close()
  }

  close(event) {
    if (event) event.preventDefault()
    this.containerTarget.classList.add('hidden')
    this.currentType = null
    this.allExercises = []
    this.searchInputTarget.value = ''
    this.searchResultsTarget.innerHTML = ''
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
