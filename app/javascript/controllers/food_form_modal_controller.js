import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "form", "errors"]

  connect() {}

  open(event) {
    if (event) event.preventDefault()

    if (!this.hasContainerTarget) {
      return
    }

    this.containerTarget.classList.remove("hidden")
    this.loadCategories()
  }

  loadCategories() {
    const categorySelect = document.getElementById("food-category-select")
    if (!categorySelect) return

    fetch("/admin/foods/categories.json")
      .then(response => response.json())
      .then(categories => {
        categorySelect.innerHTML = '<option value="">Sem Categoria</option>'
        categories.forEach(category => {
          const option = document.createElement("option")
          option.value = category
          option.textContent = category
          categorySelect.appendChild(option)
        })
      })
      .catch(error => {})
  }

  submit(event) {
    event.preventDefault()

    const formData = new FormData(this.formTarget)
    const energyValue = formData.get("food[energy_kcal]")
    const proteinValue = formData.get("food[protein_g]")
    const carbsValue = formData.get("food[carbohydrate_g]")

    const foodData = {
      name: formData.get("food[name]"),
      category: formData.get("food[category]"),
      energy_kcal: energyValue ? parseFloat(energyValue) : 0,
      protein_g: proteinValue ? parseFloat(proteinValue) : 0,
      carbohydrate_g: carbsValue ? parseFloat(carbsValue) : 0
    }

    fetch("/admin/foods", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({ food: foodData })
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
      this.showToast("Alimento criado com sucesso!", "success")

      // Dispatch event for nutrition form controller to update its foods list
      document.dispatchEvent(new CustomEvent('food:added', {
        detail: { food: foodData }
      }))

      setTimeout(() => {
        this.close()
      }, 500)
    })
    .catch(error => {
      if (error.data) {
        const errors = Object.values(error.data).flat()
        this.showErrors(errors)
      } else {
        this.showToast("Erro ao criar alimento", "error")
      }
    })
  }

  showErrors(errors) {
    const errorList = this.containerTarget.querySelector("#error-list")
    errorList.innerHTML = ""
    errors.forEach(error => {
      const li = document.createElement("li")
      li.textContent = error
      errorList.appendChild(li)
    })
    this.errorsTarget.classList.remove("hidden")
  }

  close(event) {
    if (event) event.preventDefault()
    this.containerTarget.classList.add("hidden")
    // Only reset the form if it's actually inside this modal container
    if (this.hasFormTarget && this.containerTarget.contains(this.formTarget)) this.formTarget.reset()
    if (this.hasErrorsTarget) this.errorsTarget.classList.add("hidden")
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
