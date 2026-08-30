import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    startDate: String,
    expiresAt: String,
    isActive: Boolean
  }

  connect() {
  }

  get daysRemaining() {
    if (!this.expiresAtValue) return 0

    const now = new Date()
    const expiresAt = new Date(this.expiresAtValue)
    const diffTime = expiresAt - now
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    return Math.max(0, diffDays)
  }

  get totalDays() {
    if (!this.startDateValue || !this.expiresAtValue) return 90

    const startDate = new Date(this.startDateValue)
    const expiresAt = new Date(this.expiresAtValue)
    const diffTime = expiresAt - startDate
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    return Math.max(0, diffDays)
  }

  get progressPercent() {
    const total = this.totalDays
    const remaining = this.daysRemaining
    const elapsed = total - remaining

    return Math.min(100, Math.max(0, (elapsed / total) * 100))
  }
}
