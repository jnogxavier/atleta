import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = [
    "container",
    "form",
    "title",
    "exerciseId",
    "exerciseTypeField",
    "strengthFields",
    "mobilityFields",
    "coreFields",
    "cardioFields"
  ]

  connect() {
    super.connect()
    this.editingExerciseId = null

    if (this.hasFormTarget) {
      this.markRequiredFields()
      this.showFormFields('strength')
    }
  }

  open(event) {
    if (event) event.preventDefault()

    if (!this.hasTitleTarget || !this.hasFormTarget || !this.hasExerciseTypeFieldTarget || !this.hasContainerTarget) {
      return
    }

    this.editingExerciseId = null
    this.titleTarget.textContent = 'Novo Exercício'
    this.formTarget.reset()

    const exerciseBank = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="exercise-bank"]'),
      'exercise-bank'
    )
    let currentType = exerciseBank ? exerciseBank.currentTypeValue : 'strength'

    if (!currentType || currentType === 'null') {
      currentType = 'strength'
    }

    this.exerciseTypeFieldTarget.value = currentType
    this.showFormFields(currentType)
    this.containerTarget.classList.remove('hidden')
  }

  openNewExerciseModal(event) {
    this.open(event)
  }

  edit(event) {
    if (event) {
      event.preventDefault()
    }

    const exerciseId = event.currentTarget.dataset.exerciseId
    const type = event.currentTarget.dataset.exerciseType

    if (!this.hasTitleTarget || !this.hasFormTarget || !this.hasExerciseTypeFieldTarget || !this.hasContainerTarget) {
      return
    }

    this.loadExercise(type, exerciseId)
  }

  loadExercise(type, exerciseId) {
    const endpoints = {
      strength: '/admin/strength_exercises',
      mobility: '/admin/mobility_exercises',
      core: '/admin/core_exercises',
      cardio: '/admin/cardio_exercises'
    }

    const url = `${endpoints[type]}/${exerciseId}`

    fetch(url, {
      credentials: 'same-origin',
      headers: { 'Accept': 'application/json' }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(exercise => {
      this.editingExerciseId = exerciseId
      this.titleTarget.textContent = 'Editar Exercício'
      this.exerciseIdTarget.value = exerciseId
      this.exerciseTypeFieldTarget.value = type

      this.showFormFields(type)
      this.populateForm(type, exercise)

      this.containerTarget.classList.remove('hidden')
    })
    .catch(error => {})
  }

  populateForm(type, exercise) {
    const fields = this[`${type}FieldsTarget`]

    const nameField = fields.querySelector('[name="name"]')
    if (nameField) nameField.value = exercise.name || ''

    if (type === 'strength') {
      const muscleGroupField = fields.querySelector('[name="muscle_group"]')
      const equipmentField = fields.querySelector('[name="equipment"]')
      if (muscleGroupField) muscleGroupField.value = exercise.muscle_group || ''
      if (equipmentField) equipmentField.value = exercise.equipment || ''
    }

    if (type === 'cardio') {
      const equipmentField = fields.querySelector('[name="equipment"]')
      if (equipmentField) equipmentField.value = exercise.equipment || ''
    }

    const descField = fields.querySelector('[name="description"]')
    if (descField) descField.value = exercise.description || ''
  }

  typeChanged(event) {
    const newType = event.target.value

    const commonValues = this.getCommonFieldValues()

    this.showFormFields(newType)

    this.setCommonFieldValues(newType, commonValues)
  }

  getCommonFieldValues() {
    const values = { name: null, equipment: null, description: null }

    ;['strength', 'mobility', 'core', 'cardio'].forEach(type => {
      const target = `${type}FieldsTarget`
      if (!this.hasTarget(target)) return

      const container = this[target]
      if (!container.classList.contains('hidden')) {
        const nameField = container.querySelector('[name="name"]')
        const equipmentField = container.querySelector('[name="equipment"]')
        const descField = container.querySelector('[name="description"]')

        if (nameField) values.name = nameField.value
        if (equipmentField) values.equipment = equipmentField.value
        if (descField) values.description = descField.value
      }
    })

    return values
  }

  setCommonFieldValues(type, values) {
    const container = this[`${type}FieldsTarget`]

    const nameField = container.querySelector('[name="name"]')
    const equipmentField = container.querySelector('[name="equipment"]')
    const descField = container.querySelector('[name="description"]')

    if (nameField && values.name) nameField.value = values.name
    if (equipmentField && values.equipment) equipmentField.value = values.equipment
    if (descField && values.description) descField.value = values.description
  }

  showFormFields(type) {
    ;['strength', 'mobility', 'core', 'cardio'].forEach(t => {
      const target = `${t}FieldsTarget`
      if (!this.hasTarget(target)) return

      const container = this[target]
      container.classList.add('hidden')

      container.querySelectorAll('[required]').forEach(input => {
        input.removeAttribute('required')
      })
    })

    const selectedTarget = `${type}FieldsTarget`
    if (this.hasTarget(selectedTarget)) {
      const selectedContainer = this[selectedTarget]
      selectedContainer.classList.remove('hidden')

      selectedContainer.querySelectorAll('[data-was-required="true"]').forEach(input => {
        input.setAttribute('required', 'required')
      })
    }
  }

  markRequiredFields() {
    this.formTarget.querySelectorAll('[required]').forEach(input => {
      input.dataset.wasRequired = 'true'
    })
  }

  hasTarget(targetName) {
    return this.constructor.targets.includes(targetName.replace('Target', ''))
  }

  submit(event) {
    event.preventDefault()

    const type = this.exerciseTypeFieldTarget.value
    const visibleFields = this[`${type}FieldsTarget`]
    const exerciseData = {}

    visibleFields.querySelectorAll('input, textarea, select').forEach(input => {
      if (input.name && input.name !== 'id') {
        exerciseData[input.name] = input.value
      }
    })

    this.saveExercise(type, exerciseData)
  }

  saveExercise(type, exerciseData) {

    const endpoints = {
      strength: '/admin/strength_exercises',
      mobility: '/admin/mobility_exercises',
      core: '/admin/core_exercises',
      cardio: '/admin/cardio_exercises'
    }

    const paramKeys = {
      strength: 'strength_exercise',
      mobility: 'mobility_exercise',
      core: 'core_exercise',
      cardio: 'cardio_exercise'
    }

    const url = this.editingExerciseId ?
      `${endpoints[type]}/${this.editingExerciseId}` :
      endpoints[type]
    const method = this.editingExerciseId ? 'PATCH' : 'POST'

    fetch(url, {
      method: method,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({ [paramKeys[type]]: exerciseData })
    })
    .then(response => response.json())
    .then(result => {
      if (result.success) {
        this.showToast(
          this.editingExerciseId ? 'Exercício atualizado!' : 'Exercício criado!',
          'success'
        )
        // Emit event for exercise list to refresh without full reload
        const type = this.exerciseTypeFieldTarget.value
        document.dispatchEvent(new CustomEvent('exercise:created-or-updated', {
          detail: { exercise: result.data, type: type }
        }))

        this.close()
      } else {
        this.showToast('Erro: ' + (result.error || 'Erro desconhecido'), 'error')
      }
    })
    .catch(error => {
      this.showToast('Erro ao salvar exercício: ' + error.message, 'error')
    })
  }

  close(event) {
    if (event) event.preventDefault()

    this.containerTarget.classList.add('hidden')
    this.formTarget.reset()
    this.editingExerciseId = null
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  showToast(message, type) {
    if (typeof window.showToast === 'function') {
      window.showToast(message, type)
    }
  }
}
