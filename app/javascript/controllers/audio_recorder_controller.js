import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startButton", "stopButton", "recordingStatus", "playback", "audioInput", "timer", "audioElement", "progressBar", "progressContainer", "currentTime", "duration", "playButton", "audioSource"]
  static values = { maxDuration: 300 } // 5 minutes

  connect() {
    this.mediaRecorder = null
    this.audioChunks = []
    this.isRecording = false
    this.timerInterval = null
    this.audioBlob = null
    this.isPlaying = false
    this.recordingTime = 0
    this.progressInterval = null
  }

  async startRecording(e) {
    e.preventDefault()

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      this.mediaRecorder = new MediaRecorder(stream, { mimeType: "audio/webm" })
      this.audioChunks = []
      this.isRecording = true
      this.recordingTime = 0

      this.mediaRecorder.ondataavailable = (event) => {
        this.audioChunks.push(event.data)
      }

      this.mediaRecorder.onstop = () => {
        this.audioBlob = new Blob(this.audioChunks, { type: "audio/webm" })
        this.saveAudioFile()
        this.showPlayback()
      }

      this.mediaRecorder.start()
      this.swapButtons(true)
      this.updateUI("recording")
      this.startTimer()
    } catch (error) {
      alert("Erro ao acessar o microfone: " + error.message)
    }
  }

  stopRecording(e) {
    e?.preventDefault()

    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop()
      this.mediaRecorder.stream.getTracks().forEach((track) => track.stop())
      this.isRecording = false
      this.stopTimer()
      this.swapButtons(false)
      if (this.hasRecordingStatusTarget) {
        this.recordingStatusTarget.classList.add("hidden")
      }
    }
  }

  deleteRecording(e) {
    e.preventDefault()

    this.audioBlob = null
    this.audioChunks = []
    this.audioInputTarget.value = ""

    this.updateUI("idle")
    this.resetUI()
    this.swapButtons(false)
  }


  playRecording(e) {
    e?.preventDefault()

    if (!this.audioBlob) return

    if (this.isPlaying) {
      this.audioElementTarget.pause()
      this.isPlaying = false
      this.stopProgressTracking()
      this.updatePlayButton()
      return
    }

    const audio = this.audioElementTarget
    audio.src = URL.createObjectURL(this.audioBlob)
    this.isPlaying = true

    audio.addEventListener("ended", () => {
      this.isPlaying = false
      this.stopProgressTracking()
      this.updatePlayButton()
      this.resetProgressBar()
    }, { once: true })

    this.updatePlayButton()
    this.startProgressTracking()
    audio.play()
  }

  updatePlayButton() {
    if (this.isPlaying) {
      this.playButtonTarget.innerHTML = '<span>⏸️</span><span>Pausar</span>'
    } else {
      this.playButtonTarget.innerHTML = '<span>▶️</span><span>Reproduzir</span>'
    }
  }

  startTimer() {
    this.timerInterval = setInterval(() => {
      this.recordingTime++
      const minutes = Math.floor(this.recordingTime / 60)
      const secs = this.recordingTime % 60
      const timeStr = `${String(minutes).padStart(2, "0")}:${String(secs).padStart(2, "0")}`

      if (this.hasTimerTarget) {
        this.timerTarget.textContent = timeStr
      }

      if (this.recordingTime >= this.maxDurationValue) {
        this.stopRecording()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
    if (this.hasTimerTarget) {
      this.timerTarget.textContent = "00:00"
    }
  }

  saveAudioFile() {
    const fileName = `recording_${Date.now()}.webm`
    const dataTransfer = new DataTransfer()
    const file = new File([this.audioBlob], fileName, { type: "audio/webm" })
    dataTransfer.items.add(file)
    this.audioInputTarget.files = dataTransfer.files
  }

  showPlayback() {
    if (this.hasPlaybackTarget) {
      this.playbackTarget.classList.remove("hidden")
      // Set audio source if audioSource target exists
      if (this.hasAudioSourceTarget && this.audioBlob) {
        const blobUrl = URL.createObjectURL(this.audioBlob)
        this.audioSourceTarget.src = blobUrl
        // Get the audio element and reload it
        const audioElement = this.audioSourceTarget.closest('audio')
        if (audioElement) {
          audioElement.load()
        }
      }
    }
  }

  resetUI() {
    if (this.hasPlaybackTarget) {
      this.playbackTarget.classList.add("hidden")
    }
    if (this.hasRecordingStatusTarget) {
      this.recordingStatusTarget.classList.add("hidden")
    }
  }

  updateUI(status) {
    if (status === "recording") {
      if (this.hasRecordingStatusTarget) {
        this.recordingStatusTarget.classList.remove("hidden")
      }
    } else if (status === "idle") {
      this.resetUI()
    }
  }

  swapButtons(isRecording) {
    if (isRecording) {
      this.startButtonTarget.classList.add("hidden")
      this.stopButtonTarget.classList.remove("hidden")
    } else {
      this.startButtonTarget.classList.remove("hidden")
      this.stopButtonTarget.classList.add("hidden")
    }
  }

  startProgressTracking() {
    const audio = this.audioElementTarget
    const updateProgress = () => {
      if (audio.duration) {
        const percentage = (audio.currentTime / audio.duration) * 100
        this.progressBarTarget.style.setProperty('--progress-width', `${percentage}%`)
        this.updateTimeDisplay()
      }
      // Continue animating while audio is playing
      if (!audio.paused) {
        this.progressAnimationFrame = requestAnimationFrame(updateProgress)
      }
    }
    this.progressAnimationFrame = requestAnimationFrame(updateProgress)
  }

  stopProgressTracking() {
    if (this.progressAnimationFrame) {
      cancelAnimationFrame(this.progressAnimationFrame)
      this.progressAnimationFrame = null
    }
  }

  resetProgressBar() {
    this.progressBarTarget.style.setProperty('--progress-width', "0%")
    this.currentTimeTarget.textContent = "0:00"
    this.durationTarget.textContent = "0:00"
  }

  updateTimeDisplay() {
    const audio = this.audioElementTarget
    this.currentTimeTarget.textContent = this.formatTime(audio.currentTime)
    this.durationTarget.textContent = this.formatTime(audio.duration)
  }

  formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return "0:00"
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${String(secs).padStart(2, "0")}`
  }
}
