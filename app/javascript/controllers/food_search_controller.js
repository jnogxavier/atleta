import { Controller } from "@hotwired/stimulus"
import { normalizeText } from "utils/text_utils"

export default class extends Controller {
  static targets = ["searchInput", "searchResults", "hiddenSelect"]

  connect() {
    this.searchTimeout = null

    // If there's a selected food, load its name
    if (this.hiddenSelectTarget.value) {
      const selectedOption = this.hiddenSelectTarget.querySelector(`option[value="${this.hiddenSelectTarget.value}"]`)
      if (selectedOption) {
        this.searchInputTarget.value = selectedOption.textContent
      }
    }

    this.boundHideResults = this.hideResults.bind(this)
    document.addEventListener('click', this.boundHideResults)
  }

  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
    document.removeEventListener('click', this.boundHideResults)
  }

  loadFoodsFromSelect() {
    const foods = []
    const options = this.hiddenSelectTarget.querySelectorAll('option')

    options.forEach(option => {
      if (option.value) {
        foods.push({
          id: option.value,
          name: option.textContent,
          energy: option.dataset.energy || 0,
          protein: option.dataset.protein || 0,
          carbs: option.dataset.carbs || 0,
          fat: option.dataset.fat || 0,
          category: option.dataset.foodCategory || ''
        })
      }
    })

    return foods
  }

  search(event) {
    // Debounce search by 300ms to avoid too many server requests
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    this.searchTimeout = setTimeout(() => {
      const query = this.searchInputTarget.value
      this.searchFoodsOnServer(query)
    }, 300)
  }

  showAll(event) {
    event.stopPropagation()
    this.searchFoodsOnServer('')
  }

  searchFoodsOnServer(query) {
    const params = new URLSearchParams()
    if (query.length > 0) {
      params.append('q', query)
    }

    fetch(`/admin/foods/search?${params.toString()}`)
      .then(response => response.json())
      .then(foods => {
        this.displaySearchResults(foods)
      })
      .catch(error => {
        console.error('Error searching foods:', error)
        this.searchResultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center text-xs">Erro ao buscar alimentos</div>'
        this.searchResultsTarget.classList.remove('hidden')
      })
  }

  displaySearchResults(foods) {
    if (foods.length === 0) {
      this.searchResultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center text-xs">Nenhum alimento encontrado</div>'
    } else {
      this.searchResultsTarget.innerHTML = foods.map(food => {
        const trimmedName = food.name.trim()
        const carbs = food.carbohydrate_g || 0
        const fat = food.fat_g || 0
        return `
        <div class="p-2 hover:bg-gray-50 cursor-pointer border-b last:border-0 food-result-item"
             data-action="click->food-search#selectFood"
             data-food-id="${food.id}"
             data-food-name="${trimmedName}"
             data-food-energy="${food.energy_kcal}"
             data-food-protein="${food.protein_g}"
             data-food-carbs="${carbs}"
             data-food-fat="${fat}"
             data-food-category="${food.category || ''}">
          <div class="font-medium text-gray-900 text-sm">${this.escapeHtml(trimmedName)}</div>
          <div class="text-xs text-gray-500">
            ${parseFloat(food.energy_kcal).toFixed(1)} kcal | ${parseFloat(food.protein_g).toFixed(1)}g prot | ${parseFloat(carbs).toFixed(1)}g carb | ${parseFloat(fat).toFixed(1)}g gord (por 100g)
          </div>
        </div>
      `
      }).join('')
    }

    this.searchResultsTarget.classList.remove('hidden')
  }

  selectFood(event) {
    event.preventDefault()
    event.stopPropagation()

    const foodId = event.currentTarget.dataset.foodId
    const foodName = event.currentTarget.dataset.foodName
    const foodEnergy = event.currentTarget.dataset.foodEnergy
    const foodProtein = event.currentTarget.dataset.foodProtein
    const foodCarbs = event.currentTarget.dataset.foodCarbs
    const foodFat = event.currentTarget.dataset.foodFat
    const foodCategory = event.currentTarget.dataset.foodCategory

    // Create option if it doesn't exist
    let option = this.hiddenSelectTarget.querySelector(`option[value="${foodId}"]`)
    if (!option) {
      option = document.createElement('option')
      option.value = foodId
      option.textContent = foodName
      option.dataset.energy = foodEnergy
      option.dataset.protein = foodProtein
      option.dataset.carbs = foodCarbs
      option.dataset.fat = foodFat
      option.dataset.foodCategory = foodCategory || ''
      this.hiddenSelectTarget.appendChild(option)
    }

    this.hiddenSelectTarget.value = foodId

    this.searchInputTarget.value = foodName

    this.searchResultsTarget.classList.add('hidden')

    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenSelectTarget.dispatchEvent(changeEvent)

    const foodSelectEvent = new CustomEvent('food:selected', {
      detail: {
        foodId: foodId,
        foodName: foodName,
        foodCategory: foodCategory || '',
        foodEnergy: foodEnergy,
        foodProtein: foodProtein,
        foodCarbs: foodCarbs,
        foodFat: foodFat
      },
      bubbles: true
    })
    this.element.dispatchEvent(foodSelectEvent)
  }

  clear(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    this.searchInputTarget.value = ''
    this.hiddenSelectTarget.value = ''
    this.searchResultsTarget.classList.add('hidden')

    const changeEvent = new Event('change', { bubbles: true })
    this.hiddenSelectTarget.dispatchEvent(changeEvent)

    // Clear any dynamically added options if desired
    // (keep original options from server)
  }

  hideResults(event) {
    if (!this.element.contains(event.target)) {
      this.searchResultsTarget.classList.add('hidden')
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
