import { Controller } from "@hotwired/stimulus"
import { getFormDataHeaders } from "utils/csrf_utils"

export default class extends Controller {
  static targets = ["step", "stepIndicator", "form"]

  connect() {
    const isActiveSignup = sessionStorage.getItem('signup_active')

    const serverErrorsBlock = document.querySelector('.server-errors')

    if (!serverErrorsBlock && !isActiveSignup) {
      sessionStorage.removeItem('signup_form_data')
      sessionStorage.removeItem('signup_current_step')
    }

    sessionStorage.setItem('signup_active', 'true')

    this.restoreFormState()

    const savedStep = sessionStorage.getItem('signup_current_step')
    let step = savedStep ? parseInt(savedStep) : 1

    if (serverErrorsBlock) {
      const errorFields = this.element.querySelectorAll('.field_with_errors input, .field_with_errors select, .field_with_errors textarea')
      if (errorFields.length > 0) {
        for (let i = 1; i <= 4; i++) {
          const stepElement = this.stepTargets.find(s => s.dataset.step === String(i))
          if (stepElement && stepElement.contains(errorFields[0])) {
            step = i
            sessionStorage.setItem('signup_current_step', String(i))
            break
          }
        }
      }
    }

    if (step < 1 || step > 4) {
      step = 1
      sessionStorage.setItem('signup_current_step', '1')
    }

    this.currentStep = step
    this.uploadedCount = 0
    this.photoUploadsInitialized = false
    this.showStep(this.currentStep)

    // Cache form reference to avoid repeated querySelectorAll
    this.cachedForm = this.element.querySelector('form')
    this.cachedFormFields = null
    this.saveFormStateTimeout = null

    // Bind methods to preserve 'this' context for cleanup
    this.boundSaveFormState = (e) => this.debouncedSaveFormState(e)
    this.boundCheckEmailUniqueness = (emailInput) => () => this.checkEmailUniqueness(emailInput)
    this.boundHandleKeydown = (e) => {
      if (e.key === 'Enter' && e.target.tagName !== 'TEXTAREA' && e.target.type !== 'submit') {
        e.preventDefault()
      }
    }

    this.element.addEventListener('input', this.boundSaveFormState)
    this.element.addEventListener('change', this.boundSaveFormState)

    const emailInput = this.element.querySelector('input[name="user[email_address]"]')
    if (emailInput) {
      emailInput.addEventListener('blur', this.boundCheckEmailUniqueness(emailInput))
    }

    this.element.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    // Clear debounce timeout
    if (this.saveFormStateTimeout) {
      clearTimeout(this.saveFormStateTimeout)
    }

    // Clean up form event listeners to prevent memory leaks
    if (this.boundSaveFormState) {
      this.element.removeEventListener('input', this.boundSaveFormState)
      this.element.removeEventListener('change', this.boundSaveFormState)
    }

    const emailInput = this.element.querySelector('input[name="user[email_address]"]')
    if (emailInput && this.boundCheckEmailUniqueness) {
      emailInput.removeEventListener('blur', this.boundCheckEmailUniqueness(emailInput))
    }

    if (this.boundHandleKeydown) {
      this.element.removeEventListener('keydown', this.boundHandleKeydown)
    }

    // Clean up photo upload listeners
    if (this.photoUploadListeners && this.photoUploadListeners.length > 0) {
      this.photoUploadListeners.forEach(({ fileInput, card, removeBtn, handleChange, handleRemove, handleDragover, handleDragleave, handleDrop }) => {
        fileInput.removeEventListener('change', handleChange)
        if (removeBtn) {
          removeBtn.removeEventListener('click', handleRemove)
        }
        card.removeEventListener('dragover', handleDragover)
        card.removeEventListener('dragleave', handleDragleave)
        card.removeEventListener('drop', handleDrop)
      })
      this.photoUploadListeners = []
    }
  }

  async nextStep(event) {
    event.preventDefault()

    const isValid = await this.validateCurrentStep()
    if (!isValid) {
      return
    }

    const saved = await this.saveStepData()
    if (!saved) {
      return
    }

    if (this.currentStep < 4) {
      this.currentStep++
      this.saveCurrentStep()
      this.showStep(this.currentStep)
    }
  }

  previousStep() {
    if (this.currentStep > 1) {
      this.currentStep--
      this.saveCurrentStep()
      this.showStep(this.currentStep)
    }
  }

  saveCurrentStep() {
    sessionStorage.setItem('signup_current_step', this.currentStep)
  }

  debouncedSaveFormState(e) {
    // Cancel previous debounce timeout
    if (this.saveFormStateTimeout) {
      clearTimeout(this.saveFormStateTimeout)
    }
    // Debounce by 500ms to avoid excessive sessionStorage writes
    this.saveFormStateTimeout = setTimeout(() => this.saveFormState(), 500)
  }

  saveFormState() {
    if (!this.cachedForm) return

    // Single optimized query that gets all form fields at once
    const formData = {}
    const form = this.cachedForm

    // Single querySelectorAll for all common input types
    form.querySelectorAll('input, select, textarea').forEach(field => {
      if (!field.name) return

      // Skip file inputs - they can't be serialized and should be preserved in the DOM
      if (field.type === 'file') return

      if (field.type === 'checkbox') {
        if (field.name.endsWith('[]')) {
          if (!formData[field.name]) {
            formData[field.name] = []
          }
          if (field.checked) {
            formData[field.name].push(field.value)
          }
        } else {
          formData[field.name] = field.checked
        }
      } else if (field.type === 'radio') {
        if (field.checked) {
          formData[field.name] = field.value
        }
      } else {
        // Text, email, password, number, time, tel, select, textarea, etc.
        formData[field.name] = field.value
      }
    })

    sessionStorage.setItem('signup_form_data', JSON.stringify(formData))
  }

  restoreFormState() {
    const savedData = sessionStorage.getItem('signup_form_data')
    if (!savedData) return

    try {
      const formData = JSON.parse(savedData)
      const form = this.element.querySelector('form')

      if (form) {
        Object.keys(formData).forEach(name => {
          if (name.endsWith('[]') && Array.isArray(formData[name])) {
            const checkboxes = form.querySelectorAll(`input[type="checkbox"][name="${name}"]`)
            checkboxes.forEach(checkbox => {
              checkbox.checked = formData[name].includes(checkbox.value)
            })
          } else {
            let input

            if (name.includes('[') && name.includes(']')) {
              input = form.querySelector(`input[type="checkbox"][name="${name}"]`)

              if (!input) {
                input = form.querySelector(`input[name="${name}"], select[name="${name}"], textarea[name="${name}"]`)
              }
            } else {
              input = form.querySelector(`input[name="${name}"], select[name="${name}"], textarea[name="${name}"]`)
            }

            if (input) {
              if (input.type === 'checkbox') {
                input.checked = formData[name] === true || formData[name] === 'true' || formData[name] === '1'
              } else {
                input.value = formData[name]
              }
            }
          }
        })
      }
    } catch (error) {
    }
  }

  clearFormState() {
    sessionStorage.removeItem('signup_form_data')
    sessionStorage.removeItem('signup_current_step')
  }

  async handleSubmit(event) {
    event.preventDefault()

    const isValid = await this.validateCurrentStep()
    if (!isValid) {
      return
    }

    const form = this.element.querySelector('form')
    const formData = new FormData(form)

    try {
      const response = await fetch('/signup/finalize', {
        method: 'PATCH',
        headers: getFormDataHeaders(),
        body: formData
      })

      const data = await response.json()

      if (data.success) {
        this.clearFormState()
        sessionStorage.removeItem('signup_active')
        window.location.href = data.redirect_url
      } else {
        this.showErrorCard(
          this.stepTargets.find(step => step.dataset.step === '4'),
          data.errors || ['Erro ao finalizar cadastro']
        )
      }
    } catch (error) {
      this.showErrorCard(
        this.stepTargets.find(step => step.dataset.step === '4'),
        ['Erro ao finalizar cadastro. Por favor, tente novamente.']
      )
    }
  }

  async saveStepData() {
    const form = this.element.querySelector('form')
    const formData = new FormData(form)

    try {
      let url, response

      if (this.currentStep === 2) {
        url = '/signup/update_personal_data'
        response = await fetch(url, {
          method: 'PATCH',
          headers: getFormDataHeaders(),
          body: formData
        })

        const data = await response.json()
        if (!data.success) {
          if (data.errors && data.errors.some(err => err.includes('Email') || err.includes('e-mail'))) {
            this.emailIsValid = false
          }

          this.showErrorCard(
            this.stepTargets.find(step => step.dataset.step === String(this.currentStep)),
            data.errors || ['Erro ao salvar dados pessoais']
          )
          return false
        }
      }

      else if (this.currentStep === 3) {
        url = '/signup/update_anamnese'
        response = await fetch(url, {
          method: 'PATCH',
          headers: getFormDataHeaders(),
          body: formData
        })

        const data = await response.json()
        if (!data.success) {
          this.showErrorCard(
            this.stepTargets.find(step => step.dataset.step === String(this.currentStep)),
            data.errors || ['Erro ao salvar anamnese']
          )
          return false
        }
      }

      return true
    } catch (error) {
      this.showErrorCard(
        this.stepTargets.find(step => step.dataset.step === String(this.currentStep)),
        ['Erro ao salvar dados. Por favor, tente novamente.']
      )
      return false
    }
  }

  async validateCurrentStep() {
    const currentStepElement = this.stepTargets.find(step => step.dataset.step === String(this.currentStep))
    if (!currentStepElement) {
      return false
    }

    this.removeErrorCard(currentStepElement)

    const errors = []

    if (this.currentStep === 1) {
      const termsCheckbox = currentStepElement.querySelector('input[type="checkbox"][name="user[terms_accepted]"]')
      if (termsCheckbox && !termsCheckbox.checked) {
        errors.push('Você deve aceitar os termos para continuar')
      }
    }

    else if (this.currentStep === 2) {
      const requiredFields = currentStepElement.querySelectorAll('input[required], select[required]')
      requiredFields.forEach(field => {
        if (!field.value || !field.value.trim()) {
          const label = this.getFieldLabel(field)
          errors.push(`${label} é obrigatório`)
        }
      })

      const email = currentStepElement.querySelector('input[name="user[email_address]"]')
      if (email && email.value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        if (!emailRegex.test(email.value.trim())) {
          errors.push('E-mail deve ter um formato válido')
        } else {
          const isUnique = await this.checkEmailUniquenessSync(email.value.trim())
          if (!isUnique) {
            errors.push('Este e-mail já está cadastrado')
          }
        }
      }

      const password = currentStepElement.querySelector('input[name="user[password]"]')
      const passwordConfirmation = currentStepElement.querySelector('input[name="user[password_confirmation]"]')

      if (password && password.value && password.value.length < 8) {
        errors.push('A senha deve ter no mínimo 8 caracteres')
      }

      if (password && passwordConfirmation && password.value !== passwordConfirmation.value) {
        errors.push('As senhas não coincidem')
      }
    }

    else if (this.currentStep === 3) {
      const requiredFields = currentStepElement.querySelectorAll('input[required], select[required], textarea[required]')
      requiredFields.forEach(field => {
        if (!field.value || !field.value.trim()) {
          const label = this.getFieldLabel(field)
          errors.push(`${label} é obrigatório`)
        }
      })

      // Check that either audio or text routine description is filled
      const audioInput = currentStepElement.querySelector('input[name="audio_file"]')
      const textInput = currentStepElement.querySelector('textarea[name="user[anamnese_attributes][routine_description]"]')

      const hasAudio = audioInput && audioInput.files && audioInput.files.length > 0
      const hasText = textInput && textInput.value && textInput.value.trim()

      if (!hasAudio && !hasText) {
        errors.push('Você deve fornecer uma descrição de rotina em áudio ou texto')
      }
    }

    else if (this.currentStep === 4) {
      const fileInputs = currentStepElement.querySelectorAll('input[type="file"]')
      let uploadedCount = 0

      fileInputs.forEach(input => {
        if (input.files && input.files.length > 0) {
          uploadedCount++
        }
      })

      if (uploadedCount < 3) {
        errors.push('Todas as 3 fotos são obrigatórias (Frontal, Lateral e Posterior)')
      }
    }

    if (errors.length > 0) {
      this.showErrorCard(currentStepElement, errors)
      return false
    }

    return true
  }

  getFieldLabel(field) {
    // Search up the DOM tree for a label element
    let currentElement = field.parentElement
    while (currentElement) {
      const label = currentElement.querySelector('label')
      if (label) {
        return label.textContent.replace(' *', '').trim()
      }
      currentElement = currentElement.parentElement
    }
    return field.placeholder || field.name || 'Este campo'
  }

  showErrorCard(stepElement, errors) {
    const requiredInputs = stepElement.querySelectorAll('input[required], select[required], textarea[required]')
    requiredInputs.forEach(input => {
      const isEmailField = input.type === 'email' || input.name.includes('email')
      const isInvalid = !input.value || !input.validity.valid || (isEmailField && this.emailIsValid === false)

      if (isInvalid) {
        input.classList.add('border-error')

        const clearRedBorder = () => {
          if (input.value && input.value.trim()) {
            input.classList.remove('border-error')
            input.removeEventListener('input', clearRedBorder)
            input.removeEventListener('change', clearRedBorder)
          }
        }

        input.addEventListener('input', clearRedBorder)
        input.addEventListener('change', clearRedBorder)
      }
    })

    const errorCard = document.createElement('div')
    errorCard.className = 'mb-6 p-4 bg-red-50 border border-red-200 rounded-xl validation-error-card'

    const errorHeader = document.createElement('h3')
    errorHeader.className = 'text-sm font-semibold text-red-800 mb-2'
    errorHeader.textContent = errors.length === 1
      ? '1 erro impediu o prosseguimento:'
      : `${errors.length} erros impediram o prosseguimento:`

    const errorList = document.createElement('ul')
    errorList.className = 'text-sm text-red-700 list-disc list-inside space-y-1'

    errors.forEach(error => {
      const li = document.createElement('li')
      li.textContent = error
      errorList.appendChild(li)
    })

    errorCard.appendChild(errorHeader)
    errorCard.appendChild(errorList)

    stepElement.insertBefore(errorCard, stepElement.firstChild)

    setTimeout(() => {
      errorCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
    }, 100)
  }

  removeErrorCard(stepElement) {
    const existingCard = stepElement.querySelector('.validation-error-card')
    if (existingCard) {
      existingCard.remove()
    }

    const inputs = stepElement.querySelectorAll('input, select, textarea')
    inputs.forEach(input => {
      input.classList.remove('border-error')
    })
  }

  showStep(stepNumber) {
    this.stepTargets.forEach(step => {
      step.classList.add("hidden")
      step.classList.remove("active")
    })

    const currentStepElement = this.stepTargets.find(step => step.dataset.step === String(stepNumber))
    if (currentStepElement) {
      currentStepElement.classList.remove("hidden")
      currentStepElement.classList.add("active")

      if (stepNumber === 4 && !this.photoUploadsInitialized) {
        this.initializePhotoUploads()
      }
    }

    this.stepIndicatorTargets.forEach(indicator => {
      const indicatorStep = parseInt(indicator.dataset.step)
      indicator.classList.remove("active", "completed")

      if (indicatorStep === stepNumber) {
        indicator.classList.add("active")
      } else if (indicatorStep < stepNumber) {
        indicator.classList.add("completed")
      }
    })

    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  initializePhotoUploads() {
    this.photoUploadsInitialized = true
    this.photoUploadListeners = [] // Track listeners for cleanup

    document.querySelectorAll('.file-input').forEach(fileInput => {
      const card = fileInput.closest('.relative')
      const dropContent = card.querySelector('.file-drop-content')
      const filePreview = card.querySelector('.file-preview')
      const previewImage = card.querySelector('.preview-image')
      const removeBtn = card.querySelector('.remove-file-btn')

      const handleChange = () => {
        if (fileInput.files && fileInput.files[0]) {
          const file = fileInput.files[0]
          const wasEmpty = dropContent && !dropContent.classList.contains('hidden')

          // Use createObjectURL instead of FileReader.readAsDataURL for 10x faster preview
          const objectUrl = URL.createObjectURL(file)
          previewImage.src = objectUrl
          dropContent.classList.add('hidden')
          filePreview.classList.remove('hidden')

          if (wasEmpty) {
            this.uploadedCount++
            this.updatePhotoProgress()
          }

          // Store object URL for later cleanup
          previewImage.dataset.objectUrl = objectUrl
        }
      }

      const handleRemove = (e) => {
        e.preventDefault()
        e.stopPropagation()

        // Clean up object URL to free memory
        if (previewImage.dataset.objectUrl) {
          URL.revokeObjectURL(previewImage.dataset.objectUrl)
          delete previewImage.dataset.objectUrl
        }

        fileInput.value = ''
        dropContent.classList.remove('hidden')
        filePreview.classList.add('hidden')
        previewImage.src = ''

        this.uploadedCount--
        this.updatePhotoProgress()
      }

      const handleDragover = (e) => {
        e.preventDefault()
        card.classList.add('border-cyan-500', 'bg-cyan-50')
      }

      const handleDragleave = (e) => {
        e.preventDefault()
        card.classList.remove('border-cyan-500', 'bg-cyan-50')
      }

      const handleDrop = (e) => {
        e.preventDefault()
        card.classList.remove('border-cyan-500', 'bg-cyan-50')

        const files = e.dataTransfer.files
        if (files.length > 0 && files[0].type.startsWith('image/')) {
          fileInput.files = files
          fileInput.dispatchEvent(new Event('change'))
        }
      }

      // Add listeners and track them for cleanup
      fileInput.addEventListener('change', handleChange)
      if (removeBtn) {
        removeBtn.addEventListener('click', handleRemove)
      }
      card.addEventListener('dragover', handleDragover)
      card.addEventListener('dragleave', handleDragleave)
      card.addEventListener('drop', handleDrop)

      this.photoUploadListeners.push({
        fileInput, card, removeBtn,
        handleChange, handleRemove, handleDragover, handleDragleave, handleDrop
      })
    })

    this.updatePhotoProgress()
  }

  updatePhotoProgress() {
    const progressText = document.getElementById('photos-uploaded')
    const progressBar = document.getElementById('progress-bar')

    if (progressText) progressText.textContent = this.uploadedCount
    if (progressBar) progressBar.style.setProperty('--progress-width', `${(this.uploadedCount / 3) * 100}%`)
  }

  async checkEmailUniqueness(emailInput) {
    const email = emailInput.value.trim()
    if (!email) return

    try {
      const response = await fetch(`/check_email?email=${encodeURIComponent(email)}`)
      const data = await response.json()

      // Updated to match email enumeration protection:
      // Endpoint returns { success: true } for valid email format
      // and { error: "..." } for invalid format
      // This prevents revealing whether an email is registered
      if (response.ok && data.success) {
        this.emailIsValid = true
      } else {
        this.emailIsValid = false
      }
    } catch (error) {
      // On network error, don't block registration
      this.emailIsValid = true
    }
  }

  async checkEmailUniquenessSync(email) {
    if (!email) return true

    try {
      const response = await fetch(`/check_email?email=${encodeURIComponent(email)}`)
      const data = await response.json()
      // Returns true if email format is valid (success response)
      // This matches email enumeration protection behavior
      return response.ok && data.success
    } catch (error) {
      // On network error, allow form submission
      return true
    }
  }

}
