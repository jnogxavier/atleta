import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "option", "hiddenField"]

  connect() {
    this.filteredOptions = []
    this.selectedIndex = -1
    this.setupClickOutside()
  }

  disconnect() {
    document.removeEventListener('click', this.clickOutside)
  }

  setupClickOutside() {
    this.clickOutside = (e) => {
      if (!this.element.contains(e.target)) {
        this.hideDropdown()
      }
    }
    document.addEventListener('click', this.clickOutside)
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()
    this.selectedIndex = -1

    this.optionTargets.forEach(option => {
      const text = option.textContent.toLowerCase()
      const value = option.dataset.value

      if (text.includes(query) || value.includes(query)) {
        option.classList.remove('hidden')
      } else {
        option.classList.add('hidden')
      }
    })

    this.showDropdown()
  }

  showDropdown() {
    this.dropdownTarget.classList.remove('hidden')
  }

  hideDropdown() {
    this.dropdownTarget.classList.add('hidden')
  }

  selectOption(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const text = option.textContent.trim()

    this.inputTarget.value = text
    this.hiddenFieldTarget.value = value
    this.hideDropdown()

    this.hiddenFieldTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }

  handleKeydown(event) {
    const visibleOptions = this.optionTargets.filter(opt => !opt.classList.contains('hidden'))

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, visibleOptions.length - 1)
        this.highlightOption(visibleOptions)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightOption(visibleOptions)
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0 && visibleOptions[this.selectedIndex]) {
          visibleOptions[this.selectedIndex].click()
        }
        break
      case 'Escape':
        this.hideDropdown()
        break
    }
  }

  highlightOption(visibleOptions) {
    this.optionTargets.forEach(opt => opt.classList.remove('bg-cyan-100'))
    if (visibleOptions[this.selectedIndex]) {
      visibleOptions[this.selectedIndex].classList.add('bg-cyan-100')
      visibleOptions[this.selectedIndex].scrollIntoView({ block: 'nearest' })
    }
  }

  focusInput() {
    this.showDropdown()
  }
}
