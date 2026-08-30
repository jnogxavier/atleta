import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = [
    "container",
    "exerciseName",
    "exerciseId",
    "exerciseType",
    "form",
    "formWrapper",
    "formHeading",
    "submitButton",
    "videosList",
    "title",
    "url",
    "category",
    "duration",
    "description"
  ]

  connect() {
    super.connect()
    this.currentExerciseId = null
    this.currentExerciseType = null
  }

  open(event) {
    event.preventDefault()

    const button = event.currentTarget
    const exerciseId = button.dataset.exerciseId
    const exerciseType = button.dataset.exerciseType
    const exerciseName = button.dataset.exerciseName

    this.currentExerciseId = exerciseId
    this.currentExerciseType = exerciseType

    this.exerciseNameTarget.textContent = exerciseName
    this.exerciseIdTarget.value = exerciseId
    this.exerciseTypeTarget.value = exerciseType

    this.loadVideos()
    this.containerTarget.classList.remove('hidden')
  }

  loadVideos() {
    const typeMapping = {
      strength: 'StrengthExercise',
      mobility: 'MobilityExercise',
      core: 'CoreExercise',
      cardio: 'CardioExercise'
    }

    const videoableType = typeMapping[this.currentExerciseType]

    fetch(`/admin/videos?videoable_type=${videoableType}&videoable_id=${this.currentExerciseId}`, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(videos => {
      this.renderVideos(videos)
    })
    .catch(error => {
      this.videosListTarget.innerHTML = '<p class="text-gray-500 text-center py-4">Erro ao carregar vídeos</p>'
    })
  }

  renderVideos(videos) {
    // Show/hide form based on whether video exists
    const hasVideo = videos.length > 0
    this.formWrapperTarget.classList.toggle('hidden', hasVideo)

    if (videos.length === 0) {
      this.videosListTarget.innerHTML = `
        <div class="text-center py-8 text-gray-500">
          <svg class="h-12 w-12 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
          </svg>
          <p>Nenhum vídeo adicionado</p>
        </div>
      `
      return
    }

    // Only display the first video (one per exercise)
    const video = videos[0]
    this.videosListTarget.innerHTML = this.createVideoCard(video)
  }

  createVideoCard(video) {
    const exerciseName = this.exerciseNameTarget.textContent
    const isYouTube = video.url && (video.url.includes('youtube.com') || video.url.includes('youtu.be'))

    return `
      <div class="flex items-start gap-4 p-4 bg-white border border-gray-200 rounded-lg">
        <div class="relative w-32 h-20 flex-shrink-0">
          ${video.thumbnail_url ?
            `<img src="${video.thumbnail_url}" alt="${exerciseName}" class="w-full h-full object-cover rounded">` :
            `<div class="w-full h-full bg-gray-100 rounded flex items-center justify-center">
              <svg class="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>`
          }
          ${isYouTube ?
            `<div class="absolute bottom-1 right-1 bg-red-600 rounded px-1.5 py-0.5 flex items-center gap-1">
              <svg class="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
              </svg>
            </div>` :
            ''
          }
        </div>
        <div class="flex-1">
          <h5 class="font-semibold text-gray-900">${exerciseName}</h5>
          <p class="text-sm text-gray-600 mt-1">Técnica</p>
          ${video.description ? `<p class="text-sm text-gray-500 mt-2">${video.description}</p>` : ''}
          <a href="${video.url}" target="_blank" class="text-sm text-cyan-600 hover:text-cyan-700 mt-2 inline-block">Ver vídeo →</a>
        </div>
        <div class="flex gap-2 flex-shrink-0">
          <button data-action="click->video-modal#editVideo"
                  data-video-id="${video.id}"
                  data-video-url="${video.url}"
                  data-video-description="${video.description || ''}"
                  class="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg text-sm font-medium hover:bg-blue-200">
            Editar
          </button>
          <button data-action="click->video-modal#delete"
                  data-video-id="${video.id}"
                  class="px-3 py-1 bg-red-100 text-red-700 rounded-lg text-sm font-medium hover:bg-red-200">
            Excluir
          </button>
        </div>
      </div>
    `
  }

  submitVideo(event) {
    event.preventDefault()

    const typeMapping = {
      strength: 'StrengthExercise',
      mobility: 'MobilityExercise',
      core: 'CoreExercise',
      cardio: 'CardioExercise'
    }

    const videoId = this.formTarget.dataset.videoId
    const isEdit = !!videoId
    const method = isEdit ? 'PATCH' : 'POST'
    const url = isEdit ? `/admin/videos/${videoId}` : '/admin/videos'

    const data = {
      url: this.urlTarget.value,
      description: this.descriptionTarget.value
    }

    // Only add these for new videos
    if (!isEdit) {
      data.videoable_type = typeMapping[this.currentExerciseType]
      data.videoable_id = this.currentExerciseId
    }

    fetch(url, {
      method: method,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(result => {
      if (result.success) {
        const message = isEdit ? 'Vídeo atualizado com sucesso!' : 'Vídeo adicionado com sucesso!'
        this.showToast(message, 'success')
        this.formTarget.reset()
        delete this.formTarget.dataset.videoId

        // Reset form heading and button text
        this.formHeadingTarget.textContent = 'Adicionar Vídeo'
        this.submitButtonTarget.textContent = 'Adicionar Vídeo'

        this.loadVideos()
      } else {
        this.showToast('Erro ao salvar vídeo: ' + (result.error || 'Erro desconhecido'), 'error')
      }
    })
    .catch(error => {
      this.showToast('Erro ao salvar vídeo: ' + error.message, 'error')
    })
  }

  editVideo(event) {
    event.preventDefault()

    const button = event.currentTarget
    const videoId = button.dataset.videoId
    const videoUrl = button.dataset.videoUrl
    const videoDescription = button.dataset.videoDescription

    // Populate form with current video data
    this.urlTarget.value = videoUrl
    this.descriptionTarget.value = videoDescription

    // Store the video ID for update
    this.formTarget.dataset.videoId = videoId

    // Change heading and button text for edit mode
    this.formHeadingTarget.textContent = 'Editar Vídeo'
    this.submitButtonTarget.textContent = 'Salvar'

    // Show the form (toggle it to visible)
    this.formWrapperTarget.classList.remove('hidden')

    // Scroll to form
    this.formWrapperTarget.scrollIntoView({ behavior: 'smooth' })
  }

  delete(event) {
    if (!confirm('Tem certeza que deseja excluir este vídeo?')) return

    const videoId = event.currentTarget.dataset.videoId

    fetch(`/admin/videos/${videoId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(result => {
      if (result.success) {
        this.showToast('Vídeo excluído com sucesso!', 'success')
        this.loadVideos()
      }
    })
    .catch(error => {
      this.showToast('Erro ao excluir vídeo', 'error')
    })
  }

  close(event) {
    if (event) event.preventDefault()

    this.containerTarget.classList.add('hidden')
    this.formTarget.reset()
    this.currentExerciseId = null
    this.currentExerciseType = null
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  showToast(message, type) {
    if (typeof window.showToast === 'function') {
      window.showToast(message, type)
    }
  }
}
