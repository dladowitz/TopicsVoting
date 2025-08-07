import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateScreenWidth()
    window.addEventListener('resize', this.updateScreenWidth.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.updateScreenWidth.bind(this))
  }

    updateScreenWidth() {
    const width = window.innerWidth
    document.cookie = `screen_width=${width}; path=/`

    console.log(`Screen width: ${width}px ${width <= 768 ? '(mobile)' : '(laptop)'}`)

    // Only reload if the layout should change
    const currentLayout = document.body.classList.contains('mobile-layout') ? 'mobile' : 'laptop'
    const shouldBeMobile = width <= 768

    if ((shouldBeMobile && currentLayout === 'laptop') || (!shouldBeMobile && currentLayout === 'mobile')) {
      window.location.reload()
    }
  }
}
