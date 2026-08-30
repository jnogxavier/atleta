import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "editor",
    "form",
    "trainingId",
    "studentId",
    "studentInput",
    "studentAutocomplete",
    "name",
    "active",
    "activeLabel",
    "inactiveLabel",
    "day",
    "description",
    "notes",
    "strengthList",
    "mobilityList",
    "coreList",
    "cardioList",
    "submitBtn",
    "cancelBtn"
  ]

  static values = {
    allStudents: { type: Array, default: [] }
  }

  connect() {
    this.currentTrainingId = null
    this.viewMode = false
    this.exercises = {
      strength: {},
      mobility: {},
      core: {},
      cardio: {}
    }
  }

  initialize() {
    this.boundNewHandler = this.handleNew.bind(this)
    this.boundEditHandler = this.handleEdit.bind(this)
    this.boundViewHandler = this.handleView.bind(this)

    window.addEventListener('training-manager:new', this.boundNewHandler)
    window.addEventListener('training-manager:edit', this.boundEditHandler)
    window.addEventListener('training-manager:view', this.boundViewHandler)
  }

  disconnect() {
    window.removeEventListener('training-manager:new', this.boundNewHandler)
    window.removeEventListener('training-manager:edit', this.boundEditHandler)
    window.removeEventListener('training-manager:view', this.boundViewHandler)
  }

  formStudentSelected(event) {
    this.studentIdTarget.value = event.detail.id
  }

  formStudentCleared(event) {
    this.studentIdTarget.value = ''
  }

  handleNew(event) {
    const { studentId, studentName } = event.detail
    this.newTraining(studentId, studentName)
  }

  handleEdit(event) {
    const { trainingId } = event.detail
    this.editTraining(trainingId)
  }

  handleView(event) {
    const { trainingId } = event.detail
    this.viewTraining(trainingId)
  }

  newTraining(studentId = null, studentName = null) {
    this.viewMode = false
    this.currentTrainingId = null
    this.formTarget.reset()
    this.trainingIdTarget.value = ''
    this.activeTarget.checked = true
    this.updateActiveLabel()

    this.clearAllExercises()

    this.enableStudentSelector()
    this.studentIdTarget.value = studentId || ''

    if (studentName && this.hasStudentInputTarget) {
      this.studentInputTarget.value = studentName
    }

    this.setEditableMode()
    this.showEditor()
  }

  editTraining(trainingId) {
    this.loadAndShowTraining(trainingId, false)
  }

  viewTraining(trainingId) {
    this.loadAndShowTraining(trainingId, true)
  }

  loadAndShowTraining(trainingId, isViewMode) {
    this.viewMode = isViewMode
    this.currentTrainingId = trainingId

    // Single fetch for both view and edit modes
    fetch(`/admin/trainings/${trainingId}`, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => response.json())
    .then(training => {
      this.populateForm(training)
      if (isViewMode) {
        this.setReadOnlyMode()
      } else {
        this.setEditableMode()
      }
      this.showEditor()
    })
    .catch(error => {
      this.showToast('Erro ao carregar treino', 'error')
    })
  }

  populateForm(training) {
    this.trainingIdTarget.value = training.id
    this.studentIdTarget.value = training.student_profile_id || ''
    this.nameTarget.value = training.name || ''
    this.activeTarget.checked = training.active !== false
    this.dayTarget.value = training.day || ''
    this.descriptionTarget.value = training.description || ''
    this.notesTarget.value = training.notes || ''
    this.updateActiveLabel()

    this.clearAllExercises()
    this.loadExercises('strength', training.strength_exercises || [])
    this.loadExercises('mobility', training.mobility_exercises || [])
    this.loadExercises('core', training.core_exercises || [])
    this.loadExercises('cardio', training.cardio_exercises || [])

    this.disableStudentSelector(training.student_name)
  }

  loadExercises(type, exercises) {
    exercises.forEach((ex, index) => {
      this.exercises[type][ex.id] = {
        id: ex.id,
        name: ex.name,
        sets: ex.sets,
        reps: ex.reps,
        rest: ex.rest,
        duration: ex.duration,
        intensity: ex.intensity,
        notes: ex.notes
      }
    })
    this.renderExercises(type)
  }

  renderExercises(type) {
    const listTarget = this[`${type}ListTarget`]
    const exercises = Object.values(this.exercises[type])

    if (exercises.length === 0) {
      listTarget.innerHTML = this.viewMode
        ? '<p class="text-gray-500 text-sm">Nenhum exercício adicionado</p>'
        : '<p class="text-gray-500 text-sm">Nenhum exercício adicionado</p>'
      return
    }

    listTarget.innerHTML = exercises.map(ex => this.createExerciseRow(ex, type)).join('')
  }

  createExerciseRow(exercise, type) {
    // Common HTML snippets
    const removeBtn = this.viewMode ? '' : this.createRemoveButton(exercise.id, type)
    const inputClass = this.viewMode ? 'bg-gray-100' : ''
    const readonly = this.viewMode ? 'readonly' : ''
    const exerciseIndex = Object.keys(this.exercises[type]).indexOf(exercise.id.toString()) + 1

    // Render based on exercise type
    switch(type) {
      case 'strength':
      case 'core':
        return this.createStrengthCoreRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex)
      case 'mobility':
        return this.createMobilityRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex)
      case 'cardio':
        return this.createCardioRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex)
      default:
        return ''
    }
  }

  createRemoveButton(exerciseId, type) {
    return `<button type="button"
              data-action="click->training-form#removeExercise"
              data-exercise-id="${exerciseId}"
              data-exercise-type="${type}"
              class="text-red-500 hover:text-red-700">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>`
  }

  createStrengthCoreRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex) {
    const notesSection = exercise.notes || !this.viewMode ? `<div class="mt-2">
      <label class="block text-xs text-gray-600 mb-1">Observações</label>
      <input type="text" name="${type}_exercises[${exercise.id}][notes]" value="${exercise.notes || ''}" placeholder="Ex: Executar lentamente..." class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
    </div>` : ''

    return `<div class="exercise-item p-3 bg-gray-50 rounded-lg border border-gray-200">
      <div class="flex items-start justify-between mb-2">
        <h5 class="font-semibold text-gray-900">${exercise.name}</h5>
        ${removeBtn}
      </div>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
        <div>
          <label class="block text-xs text-gray-600 mb-1">Séries</label>
          <input type="number" name="${type}_exercises[${exercise.id}][sets]" value="${exercise.sets || 3}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Reps</label>
          <input type="text" name="${type}_exercises[${exercise.id}][reps]" value="${exercise.reps || ''}" placeholder="8-12" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Descanso (s)</label>
          <input type="number" name="${type}_exercises[${exercise.id}][rest]" value="${exercise.rest || 60}" min="0" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Ordem</label>
          <input type="number" name="${type}_exercises[${exercise.id}][order]" value="${exerciseIndex}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
      </div>
      ${notesSection}
    </div>`
  }

  createMobilityRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex) {
    const notesSection = exercise.notes || !this.viewMode ? `<div class="mt-2">
      <label class="block text-xs text-gray-600 mb-1">Observações</label>
      <input type="text" name="${type}_exercises[${exercise.id}][notes]" value="${exercise.notes || ''}" placeholder="Ex: Manter a posição..." class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
    </div>` : ''

    return `<div class="exercise-item p-3 bg-gray-50 rounded-lg border border-gray-200">
      <div class="flex items-start justify-between mb-2">
        <h5 class="font-semibold text-gray-900">${exercise.name}</h5>
        ${removeBtn}
      </div>
      <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
        <div>
          <label class="block text-xs text-gray-600 mb-1">Séries</label>
          <input type="number" name="${type}_exercises[${exercise.id}][sets]" value="${exercise.sets || 3}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Duração (s)</label>
          <input type="number" name="${type}_exercises[${exercise.id}][duration]" value="${exercise.duration || 60}" min="0" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Ordem</label>
          <input type="number" name="${type}_exercises[${exercise.id}][order]" value="${exerciseIndex}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
      </div>
      ${notesSection}
    </div>`
  }

  createCardioRow(exercise, type, removeBtn, inputClass, readonly, exerciseIndex) {
    const intensityField = this.viewMode
      ? `<input type="text" value="${exercise.intensity || ''}" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>`
      : `<select name="${type}_exercises[${exercise.id}][intensity]" class="w-full px-2 py-1 text-sm border border-gray-300 rounded">
          <option value="">Selecione</option>
          <option value="low" ${exercise.intensity === 'low' ? 'selected' : ''}>Leve</option>
          <option value="moderate" ${exercise.intensity === 'moderate' ? 'selected' : ''}>Moderada</option>
          <option value="high" ${exercise.intensity === 'high' ? 'selected' : ''}>Alta</option>
        </select>`

    const notesSection = exercise.notes || !this.viewMode ? `<div class="mt-2">
      <label class="block text-xs text-gray-600 mb-1">Observações</label>
      <input type="text" name="${type}_exercises[${exercise.id}][notes]" value="${exercise.notes || ''}" placeholder="Ex: Manter ritmo constante..." class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
    </div>` : ''

    return `<div class="exercise-item p-3 bg-gray-50 rounded-lg border border-gray-200">
      <div class="flex items-start justify-between mb-2">
        <h5 class="font-semibold text-gray-900">${exercise.name}</h5>
        ${removeBtn}
      </div>
      <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
        <div>
          <label class="block text-xs text-gray-600 mb-1">Duração (min)</label>
          <input type="number" name="${type}_exercises[${exercise.id}][duration]" value="${exercise.duration || 30}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Intensidade</label>
          ${intensityField}
        </div>
        <div>
          <label class="block text-xs text-gray-600 mb-1">Ordem</label>
          <input type="number" name="${type}_exercises[${exercise.id}][order]" value="${exerciseIndex}" min="1" class="w-full px-2 py-1 text-sm border border-gray-300 rounded ${inputClass}" ${readonly}>
        </div>
      </div>
      ${notesSection}
    </div>`
  }

  addExercise(event) {
    const { exercise, type } = event.detail

    this.exercises[type][exercise.id] = {
      id: exercise.id,
      name: exercise.name,
      sets: 3,
      reps: exercise.reps || '',
      rest: 60,
      duration: exercise.duration || 60,
      intensity: exercise.intensity || '',
      notes: ''
    }

    this.renderExercises(type)
  }

  removeExercise(event) {
    const exerciseId = event.currentTarget.dataset.exerciseId
    const type = event.currentTarget.dataset.exerciseType

    delete this.exercises[type][exerciseId]
    this.renderExercises(type)
  }

  clearAllExercises() {
    this.exercises = {
      strength: {},
      mobility: {},
      core: {},
      cardio: {}
    }
    this.renderExercises('strength')
    this.renderExercises('mobility')
    this.renderExercises('core')
    this.renderExercises('cardio')
  }

  openExerciseModal(event) {
    const type = event.currentTarget.dataset.exerciseType
    this.dispatch('open-exercise-modal', { detail: { type } })
  }

  submit(event) {
    console.log('SUBMIT CALLED', event)
    event.preventDefault()

    const studentId = this.studentIdTarget.value

    if (!studentId || studentId === '') {
      this.showToast('Por favor, selecione um aluno antes de salvar o treino', 'error')
      return
    }

    const formData = new FormData(this.formTarget)
    const data = {}

    for (const [key, value] of formData.entries()) {
      const match = key.match(/^(\w+)_exercises\[(\d+)\]\[(\w+)\]$/)
      if (match) {
        const [, type, id, field] = match
        const exercisesKey = `${type}_exercises`
        if (!data[exercisesKey]) data[exercisesKey] = {}
        if (!data[exercisesKey][id]) data[exercisesKey][id] = {}
        data[exercisesKey][id][field] = value
      } else {
        data[key] = value
      }
    }

    console.log('Training data to save:', data)

    data.active = this.activeTarget.checked
    data.student_profile_id = studentId

    const url = this.currentTrainingId
      ? `/admin/trainings/${this.currentTrainingId}`
      : '/admin/trainings'
    const method = this.currentTrainingId ? 'PATCH' : 'POST'

    fetch(url, {
      method: method,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }
      return response.json()
    })
    .then(result => {
      console.log('Server response:', result)
      if (result.success) {
        this.showToast(
          this.currentTrainingId ? 'Treino atualizado!' : 'Treino criado!',
          'success'
        )
        this.cancel()
        this.dispatch('saved')
      } else {
        this.showToast('Erro ao salvar treino: ' + (result.error || 'Erro desconhecido'), 'error')
      }
    })
    .catch(error => {
      console.error('Training save error:', error)
      this.showToast('Erro ao salvar treino: ' + error.message, 'error')
    })
  }

  cancel(event) {
    if (event) event.preventDefault()
    this.hideEditor()
    this.formTarget.reset()
    this.clearAllExercises()
    this.setEditableMode()
  }

  showEditor() {
    this.editorTarget.classList.remove('hidden')
    // Scroll with offset to show the Aluno input
    const editorTop = this.editorTarget.offsetTop - 50
    window.scrollTo({ top: editorTop, behavior: 'smooth' })
  }

  hideEditor() {
    this.editorTarget.classList.add('hidden')
  }

  setEditableMode() {
    this.nameTarget.readOnly = false
    this.activeTarget.disabled = false
    this.dayTarget.readOnly = false
    this.descriptionTarget.readOnly = false
    this.notesTarget.readOnly = false

    document.querySelectorAll('.add-exercise-btn').forEach(btn => btn.classList.remove('hidden'))
    if (this.hasSubmitBtnTarget) this.submitBtnTarget.classList.remove('hidden')
    if (this.hasCancelBtnTarget) this.cancelBtnTarget.textContent = 'Cancelar'
  }

  setReadOnlyMode() {
    this.nameTarget.readOnly = true
    this.activeTarget.disabled = true
    this.dayTarget.readOnly = true
    this.descriptionTarget.readOnly = true
    this.notesTarget.readOnly = true

    document.querySelectorAll('.add-exercise-btn').forEach(btn => btn.classList.add('hidden'))
    if (this.hasSubmitBtnTarget) this.submitBtnTarget.classList.add('hidden')
    if (this.hasCancelBtnTarget) this.cancelBtnTarget.textContent = 'Fechar'
  }

  enableStudentSelector() {
    if (!this.hasStudentInputTarget) return

    this.studentInputTarget.value = ''

    this.studentInputTarget.disabled = false
    this.studentInputTarget.readOnly = false

    this.studentInputTarget.classList.remove('bg-gray-100', 'cursor-not-allowed', 'text-gray-500')
    this.studentInputTarget.classList.add('cursor-text')
  }

  disableStudentSelector(studentName = '') {
    if (!this.hasStudentInputTarget) return

    this.studentInputTarget.value = studentName

    this.studentInputTarget.disabled = true
    this.studentInputTarget.readOnly = true

    this.studentInputTarget.classList.add('bg-gray-100', 'cursor-not-allowed', 'text-gray-500')
    this.studentInputTarget.classList.remove('cursor-text')
  }

  updateActiveLabel() {
    if (!this.hasActiveLabelTarget || !this.hasInactiveLabelTarget) return

    if (this.activeTarget.checked) {
      this.activeLabelTarget.classList.remove('hidden')
      this.inactiveLabelTarget.classList.add('hidden')
    } else {
      this.activeLabelTarget.classList.add('hidden')
      this.inactiveLabelTarget.classList.remove('hidden')
    }
  }

  showToast(message, type) {
    if (typeof window.showToast === 'function') {
      window.showToast(message, type)
    }
  }
}
