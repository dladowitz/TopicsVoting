import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Only show animation if we have content
    if (this.element.textContent.trim()) {
      // Add class to trigger animation
      this.element.classList.add('show-notification')

      // Remove the notification after animation
      setTimeout(() => {
        this.element.remove()
      }, 3000)
    }
  }
}
