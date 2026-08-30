import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["filterButton", "videoCard"]

  connect() {
    this.setActiveButton(this.filterButtonTargets[0])
  }

  filter(event) {
    const button = event.currentTarget
    const category = button.dataset.category

    this.setActiveButton(button)

    this.videoCardTargets.forEach(card => {
      const cardCategory = card.dataset.videoCategory

      if (category === 'all' || cardCategory === category) {
        card.classList.remove('hidden')
      } else {
        card.classList.add('hidden')
      }
    })
  }

  setActiveButton(activeButton) {
    this.filterButtonTargets.forEach(button => {
      if (button === activeButton) {
        button.classList.remove('bg-gray-200', 'text-gray-700')
        button.classList.add('bg-purple-500', 'text-white')
      } else {
        button.classList.remove('bg-purple-500', 'text-white')
        button.classList.add('bg-gray-200', 'text-gray-700')
      }
    })
  }

  openVideo(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.videoUrl
    if (url) {
      window.open(url, '_blank')
    }
  }
}
