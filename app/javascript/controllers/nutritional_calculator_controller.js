import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "foodSelect",
    "quantityInput",
    "energyDisplay",
    "proteinDisplay",
    "carbsDisplay",
    "fatDisplay"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    if (!this.hasFoodSelectTarget || !this.hasQuantityInputTarget) {
      return
    }

    const selectedOption = this.foodSelectTarget.options[this.foodSelectTarget.selectedIndex]
    const quantity = parseFloat(this.quantityInputTarget.value) || 0

    if (selectedOption && selectedOption.value && quantity > 0) {
      const energyPer100g = parseFloat(selectedOption.dataset.energy) || 0
      const proteinPer100g = parseFloat(selectedOption.dataset.protein) || 0
      const carbsPer100g = parseFloat(selectedOption.dataset.carbs) || 0
      const fatPer100g = parseFloat(selectedOption.dataset.fat) || 0

      const ratio = quantity / 100.0

      if (this.hasEnergyDisplayTarget) {
        this.energyDisplayTarget.value = (energyPer100g * ratio).toFixed(1)
      }
      if (this.hasProteinDisplayTarget) {
        this.proteinDisplayTarget.value = (proteinPer100g * ratio).toFixed(1)
      }
      if (this.hasCarbsDisplayTarget) {
        this.carbsDisplayTarget.value = (carbsPer100g * ratio).toFixed(1)
      }
      if (this.hasFatDisplayTarget) {
        this.fatDisplayTarget.value = (fatPer100g * ratio).toFixed(1)
      }
    } else {
      if (this.hasEnergyDisplayTarget) {
        this.energyDisplayTarget.value = ''
      }
      if (this.hasProteinDisplayTarget) {
        this.proteinDisplayTarget.value = ''
      }
      if (this.hasCarbsDisplayTarget) {
        this.carbsDisplayTarget.value = ''
      }
      if (this.hasFatDisplayTarget) {
        this.fatDisplayTarget.value = ''
      }
    }
  }
}
