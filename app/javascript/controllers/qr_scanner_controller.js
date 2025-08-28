import { Controller } from "@hotwired/stimulus"
import jsQR from "jsqr"

export default class extends Controller {
  static targets = ["input", "modal", "video"]

  connect() {
    this.scanner = null
  }

    async startScanning() {
    try {
      this.modalTarget.classList.remove('hidden')
      const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } })
      this.videoTarget.srcObject = stream
      this.videoTarget.play()

      // Start scanning when video metadata is loaded
      this.videoTarget.addEventListener('loadedmetadata', () => {
        this.scanQRCode()
      })
    } catch (error) {
      console.error('Error accessing camera:', error)
      alert('Could not access camera. Please ensure camera permissions are granted.')
    }
  }

  stopScanning() {
    if (this.videoTarget.srcObject) {
      const tracks = this.videoTarget.srcObject.getTracks()
      tracks.forEach(track => track.stop())
    }
    this.modalTarget.classList.add('hidden')
  }

    async scanQRCode() {
    try {
      // For testing purposes, we'll try to scan even without video stream
      const canvas = document.createElement('canvas')
      const context = canvas.getContext('2d')

      // Set default dimensions if video is not ready
      canvas.width = this.videoTarget.videoWidth || 640
      canvas.height = this.videoTarget.videoHeight || 480

      // Only try to draw video if we have a stream
      if (this.videoTarget.srcObject) {
        context.drawImage(this.videoTarget, 0, 0, canvas.width, canvas.height)
      }

      const imageData = context.getImageData(0, 0, canvas.width, canvas.height)
      const code = jsQR(imageData.data, imageData.width, imageData.height)

      if (code && code.data.toLowerCase().startsWith('lnbc')) {
        this.inputTarget.value = code.data
        this.stopScanning()
        return true
      }

      // If we have a video stream, continue scanning
      if (this.videoTarget.srcObject) {
        requestAnimationFrame(() => this.scanQRCode())
      }

      return false
    } catch (error) {
      console.error('Error scanning QR code:', error)
      return false
    }
  }
}
