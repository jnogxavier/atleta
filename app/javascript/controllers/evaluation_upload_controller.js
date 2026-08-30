import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitBtn"]
  static values = { maxPhotos: { type: Number, default: 3 } }

  connect() {
    this.uploadedCount = 0
    this.photoUploadListeners = []
    this.initializePhotoUploads()
  }

  disconnect() {
    this.photoUploadListeners.forEach(({ fileInput, removeBtn, card, handleChange, handleRemove, handleDragover, handleDragleave, handleDrop }) => {
      fileInput.removeEventListener('change', handleChange)
      if (removeBtn) removeBtn.removeEventListener('click', handleRemove)
      card.removeEventListener('dragover', handleDragover)
      card.removeEventListener('dragleave', handleDragleave)
      card.removeEventListener('drop', handleDrop)
    })
  }

  initializePhotoUploads() {
    document.querySelectorAll('.file-input').forEach(fileInput => {
      const card = fileInput.closest('.relative')
      const dropContent = card.querySelector('.file-drop-content')
      const filePreview = card.querySelector('.file-preview')
      const previewImage = card.querySelector('.preview-image')
      const removeBtn = card.querySelector('.remove-file-btn')

      const handleChange = () => {
        if (fileInput.files && fileInput.files[0]) {
          const file = fileInput.files[0]
          const wasEmpty = dropContent && !dropContent.classList.contains('hidden')

          const objectUrl = URL.createObjectURL(file)
          previewImage.src = objectUrl
          dropContent.classList.add('hidden')
          filePreview.classList.remove('hidden')

          if (wasEmpty) {
            this.uploadedCount++
            this.updatePhotoProgress()
          }

          previewImage.dataset.objectUrl = objectUrl
        }
      }

      const handleRemove = (e) => {
        e.preventDefault()
        e.stopPropagation()

        if (previewImage.dataset.objectUrl) {
          URL.revokeObjectURL(previewImage.dataset.objectUrl)
          delete previewImage.dataset.objectUrl
        }

        fileInput.value = ''
        dropContent.classList.remove('hidden')
        filePreview.classList.add('hidden')
        previewImage.src = ''

        this.uploadedCount--
        this.updatePhotoProgress()
      }

      const handleDragover = (e) => {
        e.preventDefault()
        card.classList.add('border-cyan-500', 'bg-cyan-50')
      }

      const handleDragleave = (e) => {
        e.preventDefault()
        card.classList.remove('border-cyan-500', 'bg-cyan-50')
      }

      const handleDrop = (e) => {
        e.preventDefault()
        card.classList.remove('border-cyan-500', 'bg-cyan-50')

        const files = e.dataTransfer.files
        if (files.length > 0 && files[0].type.startsWith('image/')) {
          fileInput.files = files
          fileInput.dispatchEvent(new Event('change'))
        }
      }

      fileInput.addEventListener('change', handleChange)
      if (removeBtn) {
        removeBtn.addEventListener('click', handleRemove)
      }
      card.addEventListener('dragover', handleDragover)
      card.addEventListener('dragleave', handleDragleave)
      card.addEventListener('drop', handleDrop)

      this.photoUploadListeners.push({
        fileInput, card, removeBtn,
        handleChange, handleRemove, handleDragover, handleDragleave, handleDrop
      })
    })

    this.updatePhotoProgress()
  }

  updatePhotoProgress() {
    const progressText = document.getElementById('evaluation-photos-uploaded')
    const progressBar = document.getElementById('evaluation-progress-bar')

    if (progressText) {
      progressText.textContent = this.uploadedCount
    }
    if (progressBar) {
      const percentage = (this.uploadedCount / this.maxPhotosValue) * 100
      progressBar.style.setProperty('--progress-width', `${percentage}%`)
    }

    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = this.uploadedCount === 0
    }
  }
}
