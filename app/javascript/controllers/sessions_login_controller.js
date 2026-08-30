import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clearSignupStorage(e) {
    sessionStorage.removeItem('signup_active')
    sessionStorage.removeItem('signup_form_data')
    sessionStorage.removeItem('signup_current_step')
  }
}
