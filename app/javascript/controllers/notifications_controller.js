import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "badge"]

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.hasPanelTarget) {
      this.panelTarget.classList.toggle("hidden")

      if (!this.panelTarget.classList.contains("hidden")) {
        setTimeout(() => {
          document.addEventListener("click", this.handleClickOutside.bind(this), { once: true })
        }, 0)
      }
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("hidden")
    }
  }

  async markAsRead(event) {
    event.preventDefault()
    const notificationId = event.currentTarget.dataset.notificationId
    const url = event.currentTarget.dataset.url

    try {
      await fetch(`/admin/notifications/${notificationId}/mark_as_read`, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Content-Type': 'application/json'
        }
      })

      if (this.hasBadgeTarget) {
        const currentCount = parseInt(this.badgeTarget.textContent)
        const newCount = Math.max(0, currentCount - 1)

        if (newCount === 0) {
          this.badgeTarget.classList.add("hidden")
        } else {
          this.badgeTarget.textContent = newCount > 9 ? '9+' : newCount
        }
      }

      event.currentTarget.closest('[data-notification-item]').remove()

      if (url && url !== '#') {
        window.location.href = url
      }
    } catch (error) {
    }
  }

  async markAllAsRead(event) {
    event.preventDefault()

    try {
      await fetch('/admin/notifications/mark_all_as_read', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Content-Type': 'application/json'
        }
      })

      if (this.hasBadgeTarget) {
        this.badgeTarget.classList.add("hidden")
      }

      location.reload()
    } catch (error) {
    }
  }
}
