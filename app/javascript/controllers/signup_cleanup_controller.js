import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    sessionStorage.removeItem('signup_form_data')
    sessionStorage.removeItem('signup_current_step')
    sessionStorage.removeItem('signup_active')
  }
}
