import ModalController from "controllers/modal_controller"

export default class extends ModalController {
  static targets = [
    "container",
    "studentName",
    "uploadDate",
    "mediaContainer",
    "category",
    "type",
    "description",
    "adminNotes",
    "evaluatedCheckbox",
    "audioPlayer",
    "audioElement",
    "audioSource"
  ]

  connect() {
    super.connect()
    this.currentMediaId = null
    this.setupCustomEventListener()
  }

  setupCustomEventListener() {
    this.boundCustomEvent = this.handleCustomEvent.bind(this)
    this.element.addEventListener('evaluation:open-modal', this.boundCustomEvent)
  }

  handleCustomEvent(event) {
    const media = event.detail.media
    this.populateModal(media)

    this.containerTarget.classList.remove('hidden')
    this.currentMediaId = media.id
  }

  open(event) {
    if (event && event.preventDefault) {
      event.preventDefault()
    }

    const mediaId = event?.currentTarget?.dataset?.mediaId || event?.mediaId

    if (!mediaId) {
      console.warn('No media ID provided to open method')
      return
    }

    this.loadMedia(mediaId)
  }

  loadMedia(mediaId) {
    this.currentMediaId = mediaId

    fetch(`/admin/evaluation_media/${mediaId}`)
      .then(response => response.json())
      .then(media => {
        this.populateModal(media)

        this.containerTarget.classList.remove('hidden')
      })
      .catch(error => {})
  }

  populateModal(media) {
    if (this.hasStudentNameTarget) {
      this.studentNameTarget.textContent = media.student_name
    }
    if (this.hasUploadDateTarget) {
      this.uploadDateTarget.textContent = `Enviado em ${new Date(media.uploaded_at).toLocaleDateString('pt-BR')}`
    }

    const categoryLabel = media.category
      ? media.category.charAt(0).toUpperCase() + media.category.slice(1)
      : 'Sem categoria'

    if (this.hasCategoryTarget) {
      this.categoryTarget.textContent = categoryLabel
    }
    if (this.hasTypeTarget) {
      if (media.media_type === 'photo') {
        this.typeTarget.textContent = 'Foto'
      } else if (media.media_type === 'audio') {
        this.typeTarget.textContent = 'Áudio'
      } else {
        this.typeTarget.textContent = 'Vídeo'
      }
    }
    if (this.hasDescriptionTarget) {
      this.descriptionTarget.textContent = media.description || 'Sem descrição'
    }

    if (this.hasAdminNotesTarget) {
      this.adminNotesTarget.value = media.admin_notes || ''
    }
    if (this.hasEvaluatedCheckboxTarget) {
      this.evaluatedCheckboxTarget.checked = media.evaluated
    }

    this.displayMedia(media, categoryLabel)
  }

  displayMedia(media, categoryLabel) {
    if (!this.hasMediaContainerTarget) return

    if (media.media_type === 'photo') {
      this.mediaContainerTarget.innerHTML = `
        <img src="${media.file_url}"
             class="w-full max-h-96 object-contain"
             alt="${categoryLabel}">
      `
      this.hideAudioPlayer()
    } else if (media.media_type === 'audio') {
      this.mediaContainerTarget.innerHTML = ''
      this.showAudioPlayer(media.file_url)
    } else {
      const youtubeId = this.extractYouTubeId(media.file_url)
      if (youtubeId) {
        this.mediaContainerTarget.innerHTML = `
          <iframe width="100%"
                  height="400"
                  src="https://www.youtube.com/embed/${youtubeId}"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen>
          </iframe>
        `
      } else {
        this.mediaContainerTarget.innerHTML = `
          <a href="${media.file_url}"
             target="_blank"
             class="block p-8 text-center text-cyan-500 hover:text-cyan-600">
            Abrir vídeo em nova aba
          </a>
        `
      }
      this.hideAudioPlayer()
    }
  }

  showAudioPlayer(audioUrl) {
    if (!this.hasAudioPlayerTarget) return

    if (this.hasAudioSourceTarget) {
      this.audioSourceTarget.src = audioUrl
    }

    if (this.hasAudioElementTarget) {
      this.audioElementTarget.load()
    }

    this.audioPlayerTarget.classList.remove('hidden')
  }

  hideAudioPlayer() {
    if (this.hasAudioPlayerTarget) {
      this.audioPlayerTarget.classList.add('hidden')
    }
  }

  save(event) {
    event.preventDefault()

    if (!this.currentMediaId) return

    const adminNotes = this.hasAdminNotesTarget ? this.adminNotesTarget.value : ''
    const evaluated = this.hasEvaluatedCheckboxTarget ? this.evaluatedCheckboxTarget.checked : false

    fetch(`/admin/evaluation_media/${this.currentMediaId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        admin_notes: adminNotes,
        evaluated: evaluated
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.close()
        this.dispatch('saved')
      }
    })
    .catch(error => {})
  }

  close(event) {
    if (event) event.preventDefault()

    this.containerTarget.classList.add('hidden')
    this.currentMediaId = null
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  extractYouTubeId(url) {
    const regex = /(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/
    const match = url.match(regex)
    return match ? match[1] : null
  }
}
