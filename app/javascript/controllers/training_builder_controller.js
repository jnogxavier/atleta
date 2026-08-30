import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["exerciseList", "searchInput", "searchResults", "exerciseType"]
  static values = { exercises: Array }

  connect() {
    this.exercises = []
    this.searchTimeout = null
  }

  search() {
    clearTimeout(this.searchTimeout)

    const query = this.searchInputTarget.value
    const type = this.exerciseTypeTarget.value

    if (query.length < 2) {
      this.searchResultsTarget.innerHTML = ""
      this.searchResultsTarget.classList.add("hidden")
      return
    }

    this.searchTimeout = setTimeout(() => {
      fetch(`/admin/trainings/search_exercises?query=${encodeURIComponent(query)}&type=${type}`)
        .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`)
          }
          return response.json()
        })
        .then(data => {
          this.displaySearchResults(data, type)
        })
        .catch(error => {
          this.showToast('Erro ao buscar exercícios. Tente novamente.', 'error')
          this.searchResultsTarget.classList.add("hidden")
        })
    }, 300)
  }

  displaySearchResults(exercises, type) {
    if (exercises.length === 0) {
      this.searchResultsTarget.innerHTML = `
        <div class="p-4 text-center text-gray-500">
          Nenhum exercício encontrado
        </div>
      `
      this.searchResultsTarget.classList.remove("hidden")
      return
    }

    const html = exercises.map(exercise => {
      const escapedName = this.escapeHtml(exercise.name)
      const escapedMuscle = this.escapeHtml(exercise.muscle || '')
      const escapedEquipment = this.escapeHtml(exercise.equipment || '')

      return `
      <button type="button"
              class="w-full text-left p-3 hover:bg-gray-50 border-b border-gray-100 transition-colors"
              data-action="click->training-builder#addExercise"
              data-exercise-id="${exercise.id}"
              data-exercise-name="${escapedName}"
              data-exercise-type="${type}"
              data-exercise-muscle="${escapedMuscle}"
              data-exercise-equipment="${escapedEquipment}">
        <div class="font-medium text-gray-900">${escapedName}</div>
        <div class="text-sm text-gray-500">
          ${escapedMuscle ? escapedMuscle + ' • ' : ''}${escapedEquipment}
        </div>
      </button>
    `
    }).join('')

    this.searchResultsTarget.innerHTML = html
    this.searchResultsTarget.classList.remove("hidden")
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = String(text)
    return div.innerHTML
  }

  addExercise(event) {
    const button = event.currentTarget
    const exercise = {
      id: button.dataset.exerciseId,
      name: button.dataset.exerciseName,
      type: button.dataset.exerciseType,
      muscle: button.dataset.exerciseMuscle,
      equipment: button.dataset.exerciseEquipment,
      sets: 3,
      reps: '8-12',
      rest: '60s',
      notes: ''
    }

    this.exercises.push(exercise)
    this.renderExerciseList()

    this.searchInputTarget.value = ""
    this.searchResultsTarget.innerHTML = ""
    this.searchResultsTarget.classList.add("hidden")

    this.showToast(`${exercise.name} adicionado ao treino!`, 'success')
  }

  removeExercise(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.exercises.splice(index, 1)
    this.renderExerciseList()
  }

  updateExercise(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    const field = event.currentTarget.dataset.field
    const value = event.currentTarget.value

    this.exercises[index][field] = value
  }

  renderExerciseList() {
    if (this.exercises.length === 0) {
      this.exerciseListTarget.innerHTML = `
        <div class="text-center py-8 text-gray-500">
          <svg class="h-12 w-12 mx-auto mb-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
          </svg>
          <p>Nenhum exercício adicionado ainda</p>
        </div>
      `
      return
    }

    const html = this.exercises.map((exercise, index) => `
      <div class="bg-white rounded-lg border border-gray-200 p-4 space-y-3">
        <div class="flex items-center justify-between">
          <div>
            <h5 class="font-medium text-gray-900">${exercise.name}</h5>
            <p class="text-sm text-gray-500">
              ${exercise.muscle ? exercise.muscle + ' • ' : ''}${exercise.equipment || ''}
            </p>
          </div>
          <button type="button"
                  data-action="click->training-builder#removeExercise"
                  data-index="${index}"
                  class="text-red-600 hover:text-red-700 p-2">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
          </button>
        </div>

        <input type="hidden" name="${exercise.type}_exercises[${exercise.id}][id]" value="${exercise.id}">

        <div class="grid grid-cols-1 md:grid-cols-4 gap-3">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Séries</label>
            <input type="number"
                   name="${exercise.type}_exercises[${exercise.id}][sets]"
                   value="${exercise.sets}"
                   data-action="input->training-builder#updateExercise"
                   data-index="${index}"
                   data-field="sets"
                   min="1"
                   max="10"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Repetições</label>
            <input type="text"
                   name="${exercise.type}_exercises[${exercise.id}][reps]"
                   value="${exercise.reps}"
                   data-action="input->training-builder#updateExercise"
                   data-index="${index}"
                   data-field="reps"
                   placeholder="ex: 8-12"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Descanso</label>
            <input type="text"
                   name="${exercise.type}_exercises[${exercise.id}][rest]"
                   value="${exercise.rest}"
                   data-action="input->training-builder#updateExercise"
                   data-index="${index}"
                   data-field="rest"
                   placeholder="ex: 60s"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Observações</label>
            <input type="text"
                   name="${exercise.type}_exercises[${exercise.id}][notes]"
                   value="${exercise.notes}"
                   data-action="input->training-builder#updateExercise"
                   data-index="${index}"
                   data-field="notes"
                   placeholder="Notas..."
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-cyan-500">
          </div>
        </div>
      </div>
    `).join('')

    this.exerciseListTarget.innerHTML = html
  }

  showToast(message, type = 'success') {
    if (window.showToast) {
      window.showToast(message, type)
    }
  }
}
