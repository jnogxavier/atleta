import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "searchResults", "selectedIdInput", "clearButton", "planItem", "plansList", "newPlanButton"]

  connect() {
    this.searchTimeout = null

    this.boundHideResults = this.hideResults.bind(this)
    document.addEventListener('click', this.boundHideResults)
  }

  disconnect() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
    document.removeEventListener('click', this.boundHideResults)
  }

  search(event) {
    // Debounce search by 300ms to avoid too many server requests
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    this.searchTimeout = setTimeout(() => {
      const query = this.searchInputTarget.value
      this.searchStudentsOnServer(query)
    }, 300)
  }

  showAll(event) {
    event.stopPropagation()
    this.showLoading()
    this.searchStudentsOnServer('')
  }

  searchStudentsOnServer(query) {
    const params = new URLSearchParams()
    if (query.length > 0) {
      params.append('q', query)
    }

    fetch(`/admin/students/autocomplete?${params.toString()}`)
      .then(response => response.json())
      .then(students => {
        this.displaySearchResults(students)
      })
      .catch(error => {
        console.error('Error searching students:', error)
        this.searchResultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center text-xs">Erro ao buscar alunos</div>'
        this.searchResultsTarget.classList.remove('hidden')
      })
  }

  showLoading() {
    this.searchResultsTarget.innerHTML = '<div class="p-4 text-center"><div class="inline-block"><div class="animate-spin rounded-full h-5 w-5 border-b-2 border-cyan-500"></div></div></div>'
    this.searchResultsTarget.classList.remove('hidden')
  }

  displaySearchResults(students) {
    if (students.length === 0) {
      this.searchResultsTarget.innerHTML = '<div class="p-4 text-gray-500 text-center">Nenhum aluno encontrado</div>'
    } else {
      this.searchResultsTarget.innerHTML = students.map(student => `
        <div class="p-3 hover:bg-gray-50 cursor-pointer border-b last:border-0 student-result-item"
             data-action="click->nutrition-student-search#selectStudent"
             data-student-id="${student.id}"
             data-student-name="${student.name}">
          <div class="font-medium text-gray-900">${this.escapeHtml(student.name)}</div>
          <div class="text-sm text-gray-500">${this.escapeHtml(student.email)}</div>
        </div>
      `).join('')
    }

    this.searchResultsTarget.classList.remove('hidden')
  }

  selectStudent(event) {
    event.preventDefault()
    event.stopPropagation()

    const studentId = event.currentTarget.dataset.studentId
    const studentName = event.currentTarget.dataset.studentName

    this.selectedIdInputTarget.value = studentId
    this.searchInputTarget.value = studentName
    this.searchResultsTarget.classList.add('hidden')
    this.clearButtonTarget.classList.remove('hidden')

    this.filterPlans(studentId)
  }

  clear(event) {
    event.preventDefault()
    event.stopPropagation()

    this.searchInputTarget.value = ''
    this.selectedIdInputTarget.value = ''
    this.clearButtonTarget.classList.add('hidden')
    this.searchResultsTarget.classList.add('hidden')

    this.filterPlans(null)
  }

  filterPlans(studentId) {
    if (!this.hasPlanItemTarget) return

    this.planItemTargets.forEach(plan => {
      if (!studentId || plan.dataset.studentId === studentId) {
        plan.classList.remove('hidden')
      } else {
        plan.classList.add('hidden')
      }
    })
  }

  hideResults(event) {
    if (!this.element.contains(event.target) && this.hasSearchResultsTarget) {
      this.searchResultsTarget.classList.add('hidden')
    }
  }

  createNewPlan(event) {
    event.preventDefault()

    const studentId = this.selectedIdInputTarget.value
    const baseUrl = '/admin/nutrition_plans/new'

    if (studentId) {
      window.location.href = `${baseUrl}?student_profile_id=${studentId}`
    } else {
      window.location.href = baseUrl
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
