import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mealsContainer"]
  static values = {
    mealIndex: Number,
    foods: Array
  }

  connect() {
    this.mealFoodIndices = {}
    this.initializeExistingMeals()

    const form = this.element.querySelector('form') || this.element.closest('form')

    if (form) {
      this.boundSubmit = this.handleFormSubmit.bind(this)
      form.addEventListener('submit', this.boundSubmit, true)
    }

    // Listen for newly created foods
    this.boundAddFood = this.addNewFood.bind(this)
    document.addEventListener('food:added', this.boundAddFood)

    // Listen for deleted foods
    this.boundRemoveFood = this.removeDeletedFood.bind(this)
    document.addEventListener('food:deleted', this.boundRemoveFood)
  }

  disconnect() {
    document.removeEventListener('food:added', this.boundAddFood)
    document.removeEventListener('food:deleted', this.boundRemoveFood)
    const form = this.element.querySelector('form') || this.element.closest('form')
    if (form && this.boundSubmit) {
      form.removeEventListener('submit', this.boundSubmit, true)
    }
  }

  handleFormSubmit(event) {
    // Form submission is handled by Turbo
  }

  addNewFood(event) {
    const food = event.detail.food
    if (food && !this.foodsValue.some(f => f.id === food.id)) {
      const newFood = {
        id: food.id,
        name: food.name,
        energy_kcal: food.energy_kcal,
        protein_g: food.protein_g,
        carbohydrate_g: food.carbohydrate_g || 0,
        category: food.category || ''
      }
      this.foodsValue = [...this.foodsValue, newFood]
    }
  }

  removeDeletedFood(event) {
    const foodId = event.detail.foodId
    if (foodId) {
      this.foodsValue = this.foodsValue.filter(f => f.id !== foodId)
    }
  }

  buildFoodOptions() {
    return this.foodsValue.map(food => {
      const carbs = food.carbohydrate_g || 0
      const energy = food.energy_kcal || 0
      const protein = food.protein_g || 0
      const fat = food.fat_g || 0
      return `<option value="${food.id}" data-energy="${energy}" data-protein="${protein}" data-carbs="${carbs}" data-fat="${fat}">${this.escapeHtml(food.name)}</option>`
    }).join('')
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  initializeExistingMeals() {
    this.element.querySelectorAll('.meal-item').forEach((mealItem, idx) => {
      const foodsContainer = mealItem.querySelector('.foods-container')
      if (foodsContainer) {
        this.mealFoodIndices[idx] = foodsContainer.querySelectorAll('.food-item').length
      }
    })
  }

  addMeal(event) {
    event.preventDefault()

    const currentMealIndex = this.mealIndexValue

    fetch(`/admin/nutrition_plans/meal_field?meal_index=${currentMealIndex}`)
      .then(response => {
        if (!response.ok) throw new Error('Failed to fetch meal field')
        return response.json()
      })
      .then(data => {
        const div = document.createElement('div')
        div.innerHTML = data.html
        const mealItem = div.firstElementChild

        this.mealsContainerTarget.appendChild(mealItem)

        this.mealFoodIndices[currentMealIndex] = 0
        this.mealIndexValue++
      })
      .catch(error => {})
  }

  addFood(event) {
    event.preventDefault()

    const button = event.currentTarget
    const mealItem = button.closest('.meal-item')
    const mealIdx = mealItem.dataset.mealIndex
    const foodsContainer = mealItem.querySelector('.foods-container')

    if (!this.mealFoodIndices[mealIdx]) {
      this.mealFoodIndices[mealIdx] = 0
    }

    const foodCount = this.mealFoodIndices[mealIdx]
    const template = document.getElementById('food-template')
    const clone = template.content.cloneNode(true)

    const foodSelect = clone.querySelector('select')
    foodSelect.name = `nutrition_plan[meals_attributes][${mealIdx}][meal_foods_attributes][${foodCount}][food_id]`

    foodSelect.innerHTML = `<option value="">Selecione um alimento</option>${this.buildFoodOptions()}`

    const quantityInput = clone.querySelector('input[type="number"]')
    quantityInput.name = `nutrition_plan[meals_attributes][${mealIdx}][meal_foods_attributes][${foodCount}][quantity_grams]`

    foodsContainer.appendChild(clone)
    this.mealFoodIndices[mealIdx]++
  }

  removeMeal(event) {
    event.preventDefault()

    const button = event.currentTarget
    const mealItem = button.closest('.meal-item')

    // Get meal type for confirmation message
    const mealTypeSelect = mealItem.querySelector('select[name*="meal_type"]')
    const mealType = mealTypeSelect ? mealTypeSelect.options[mealTypeSelect.selectedIndex]?.text || 'Refeição' : 'Refeição'

    if (!confirm(`Tem certeza que deseja remover a refeição "${mealType}"? Esta ação não pode ser desfeita.`)) {
      return
    }

    const destroyField = mealItem.querySelector('.destroy-field')

    if (destroyField) {
      destroyField.value = '1'
      mealItem.classList.add('hidden')
    } else {
      mealItem.remove()
    }
  }

  removeFood(event) {
    event.preventDefault()

    const button = event.currentTarget
    const foodItem = button.closest('.food-item')

    // Get food name for confirmation message
    const foodSelect = foodItem.querySelector('select[name*="food_id"]')
    const foodName = foodSelect ? foodSelect.options[foodSelect.selectedIndex]?.text || 'Alimento' : 'Alimento'

    if (!confirm(`Tem certeza que deseja remover o alimento "${foodName}"? Esta ação não pode ser desfeita.`)) {
      return
    }

    const destroyField = foodItem.querySelector('.destroy-field')

    if (destroyField) {
      destroyField.value = '1'
      foodItem.classList.add('hidden')
    } else {
      foodItem.remove()
    }
  }
}
