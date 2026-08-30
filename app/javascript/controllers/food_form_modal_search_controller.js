import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "clearButton",
    "foodName",
    "foodCategory",
    "foodEnergy",
    "foodProtein",
    "foodCarbs",
    "foodFat",
    "errors",
    "form",
    "submitButton",
    "selectedFoodId",
    "searchSection",
    "formSection",
    "createModeButton",
    "editModeButton"
  ]

  connect() {
    this.selectedFoodId = null
    this.originalTitle = this.titleTarget.textContent
    this.boundFoodSelected = this.handleFoodSelected.bind(this)
    document.addEventListener('food:selected', this.boundFoodSelected)
    this.mode = "create" // Default to create mode
  }

  disconnect() {
    document.removeEventListener('food:selected', this.boundFoodSelected)
  }

  toggleCreateMode(event) {
    event.preventDefault()
    this.mode = "create"
    this.searchSectionTarget.classList.add("hidden")
    this.formSectionTarget.classList.remove("hidden")
    this.createModeButtonTarget.classList.add("bg-cyan-500", "text-white")
    this.createModeButtonTarget.classList.remove("border", "border-gray-300", "text-gray-700", "bg-gray-100")
    this.editModeButtonTarget.classList.remove("bg-cyan-500", "text-white")
    this.editModeButtonTarget.classList.add("border", "border-gray-300", "text-gray-700", "hover:bg-gray-100")
    this.submitButtonTarget.classList.remove("hidden")
    this.submitButtonTarget.textContent = "Criar Alimento"
    this.clearSelection()
  }

  toggleEditMode(event) {
    event.preventDefault()
    this.mode = "edit"
    this.searchSectionTarget.classList.remove("hidden")
    this.formSectionTarget.classList.add("hidden")
    this.editModeButtonTarget.classList.add("bg-cyan-500", "text-white")
    this.editModeButtonTarget.classList.remove("border", "border-gray-300", "text-gray-700", "hover:bg-gray-100")
    this.createModeButtonTarget.classList.remove("bg-cyan-500", "text-white")
    this.createModeButtonTarget.classList.add("border", "border-gray-300", "text-gray-700", "hover:bg-gray-100")
    this.submitButtonTarget.classList.add("hidden")
    this.clearForm()
    this.hideClearButton()
    this.titleTarget.textContent = this.originalTitle
  }

  onFoodSelected(event) {
    // This method is triggered when a food is selected from the search dropdown
    // The form will be populated by the food:selected event
  }

  handleFoodSelected(event) {
    if (!event.detail) return

    const { foodId, foodName, foodCategory, foodEnergy, foodProtein, foodCarbs, foodFat } = event.detail
    this.selectedFoodId = foodId
    this.selectedFoodIdTarget.value = foodId
    this.populateForm(foodName, foodCategory, foodEnergy, foodProtein, foodCarbs, foodFat)
    this.formSectionTarget.classList.remove("hidden")
    this.showClearButton()
    this.submitButtonTarget.textContent = "Salvar Alimento"
    this.submitButtonTarget.classList.remove("hidden")
    this.titleTarget.textContent = `Editando: ${foodName}`
  }

  selectFood(event) {
    event.preventDefault()
    event.stopPropagation()

    const foodId = event.detail?.foodId
    const foodName = event.detail?.foodName
    const foodCategory = event.detail?.foodCategory
    const foodEnergy = event.detail?.foodEnergy
    const foodProtein = event.detail?.foodProtein
    const foodCarbs = event.detail?.foodCarbs

    if (!foodId) return

    this.selectedFoodId = foodId
    this.populateForm(foodName, foodCategory, foodEnergy, foodProtein, foodCarbs)
    this.showClearButton()
    this.updateButtonText()
    this.titleTarget.textContent = `Editando: ${foodName}`
  }

  populateForm(name, category, energy, protein, carbs, fat) {
    this.foodNameTarget.value = name || ""
    this.foodCategoryTarget.value = category || ""
    this.foodEnergyTarget.value = energy || ""
    this.foodProteinTarget.value = protein || ""
    this.foodCarbsTarget.value = carbs || ""
    this.foodFatTarget.value = fat || ""
  }

  clearForm() {
    this.foodNameTarget.value = ""
    this.foodCategoryTarget.value = ""
    this.foodEnergyTarget.value = ""
    this.foodProteinTarget.value = ""
    this.foodCarbsTarget.value = ""
    this.foodFatTarget.value = ""
  }

  showClearButton() {
    this.clearButtonTarget.classList.remove("hidden")
  }

  hideClearButton() {
    this.clearButtonTarget.classList.add("hidden")
  }

  updateButtonText() {
    if (this.selectedFoodId) {
      this.submitButtonTarget.textContent = "Atualizar Alimento"
    } else {
      this.submitButtonTarget.textContent = "Criar Alimento"
    }
  }

  submitForm(event) {
    event.preventDefault()

    // Clear previous errors
    this.errorsTarget.classList.add("hidden")

    const formData = {
      food: {
        name: this.foodNameTarget.value,
        category: this.foodCategoryTarget.value,
        energy_kcal: this.foodEnergyTarget.value ? parseFloat(this.foodEnergyTarget.value) : 0,
        protein_g: this.foodProteinTarget.value ? parseFloat(this.foodProteinTarget.value) : 0,
        carbohydrate_g: this.foodCarbsTarget.value ? parseFloat(this.foodCarbsTarget.value) : 0,
        fat_g: this.foodFatTarget.value ? parseFloat(this.foodFatTarget.value) : 0
      }
    }

    const method = this.selectedFoodId ? "PATCH" : "POST"
    const url = this.selectedFoodId ? `/admin/foods/${this.selectedFoodId}` : "/admin/foods"
    const successMessage = this.selectedFoodId ? "Alimento atualizado com sucesso!" : "Alimento criado com sucesso!"

    fetch(url, {
      method: method,
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify(formData)
    })
    .then(response => {
      if (response.ok) {
        return response.json()
      } else {
        return response.json().then(data => {
          throw { response, data }
        })
      }
    })
    .then(data => {
      this.showToast(successMessage, "success")

      // Update the hidden select with the new food
      if (!this.selectedFoodId) {
        const hiddenSelect = document.querySelector('[data-food-search-target="hiddenSelect"]')
        if (hiddenSelect) {
          const option = document.createElement('option')
          option.value = data.id
          option.textContent = data.name
          option.dataset.energy = data.energy_kcal || 0
          option.dataset.protein = data.protein_g || 0
          option.dataset.carbs = data.carbohydrate_g || 0
          option.dataset.foodCategory = data.category || ''
          hiddenSelect.appendChild(option)

          // Emit event to refresh food-search controller
          document.dispatchEvent(new CustomEvent('foods:updated'))
        }
      }

      // Dispatch event for nutrition form controller to update its foods list
      if (!this.selectedFoodId) {
        document.dispatchEvent(new CustomEvent('food:added', {
          detail: { food: data }
        }))
      }

      this.resetModalState()
      // Emit event for parent controller to refresh list without full reload
      document.dispatchEvent(new CustomEvent('food:created-or-updated', {
        detail: { food: data }
      }))
      // Close modal after short delay to show success message
      setTimeout(() => {
        const closeButton = document.querySelector('[data-food-form-modal-target="container"]')
        if (closeButton) closeButton.classList.add('hidden')
      }, 500)
    })
    .catch(error => {
      if (error.data) {
        const errors = Object.values(error.data).flat()
        this.showErrors(errors)
      } else {
        this.showToast("Erro ao salvar alimento", "error")
      }
    })
  }

  deleteSelected(event) {
    event.preventDefault()

    if (!this.selectedFoodId) return

    const foodName = this.foodNameTarget.value || 'Alimento'
    if (!confirm(`Tem certeza que deseja remover o alimento "${foodName}"? Esta ação não pode ser desfeita.`)) return

    fetch(`/admin/foods/${this.selectedFoodId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "application/json"
      }
    })
    .then(response => {
      if (response.ok) {
        return response.json()
      } else {
        throw new Error("Erro ao deletar alimento")
      }
    })
    .then(data => {
      this.showToast("Alimento removido com sucesso!", "success")

      // Remove the deleted food from the hidden select
      const hiddenSelect = document.querySelector('[data-food-search-target="hiddenSelect"]')
      if (hiddenSelect) {
        const optionToRemove = hiddenSelect.querySelector(`option[value="${this.selectedFoodId}"]`)
        if (optionToRemove) {
          optionToRemove.remove()
        }
        // Notify food-search controller to refresh
        document.dispatchEvent(new CustomEvent('foods:updated'))
      }

      this.resetModalState()
      // Emit event for parent controller to refresh list without full reload
      document.dispatchEvent(new CustomEvent('food:deleted', {
        detail: { foodId: this.selectedFoodId }
      }))
      // Close modal after short delay to show success message
      setTimeout(() => {
        const closeButton = document.querySelector('[data-food-form-modal-target="container"]')
        if (closeButton) closeButton.classList.add('hidden')
      }, 500)
    })
    .catch(error => {
      this.showToast("Erro ao remover alimento", "error")
    })
  }

  clearSelection(event) {
    if (event && event.preventDefault) {
      event.preventDefault()
    }
    this.selectedFoodId = null
    this.selectedFoodIdTarget.value = ""
    this.clearForm()
    this.hideClearButton()
    this.updateButtonText()
    this.submitButtonTarget.classList.remove("hidden")
    this.titleTarget.textContent = this.originalTitle

    const searchInput = this.element.querySelector('[data-food-search-target="searchInput"]')
    if (searchInput) {
      searchInput.value = ""
    }
  }

  resetModalState() {
    this.selectedFoodId = null
    this.selectedFoodIdTarget.value = ""
    this.clearForm()
    this.hideClearButton()
    this.updateButtonText()
    this.submitButtonTarget.classList.remove("hidden")
    this.formSectionTarget.classList.add("hidden")
    this.searchSectionTarget.classList.add("hidden")
    this.titleTarget.textContent = this.originalTitle
    this.mode = "create"
  }

  showErrors(errors) {
    const errorList = this.errorsTarget.querySelector("#error-list")
    errorList.innerHTML = ""
    errors.forEach(error => {
      const li = document.createElement("li")
      li.textContent = error
      errorList.appendChild(li)
    })
    this.errorsTarget.classList.remove("hidden")
  }

  showToast(message, type) {
    if (typeof window.showToast === "function") {
      window.showToast(message, type)
    }
  }
}
