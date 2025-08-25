import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.detectDeviceType()
  }

  disconnect() {
    // No cleanup needed - we only run once
  }

  detectDeviceType() {
    // Check if device type is already set
    const existingDeviceType = this.getCookieValue('device_type')
    
    if (existingDeviceType) {
      console.log(`Device type already detected: ${existingDeviceType}`)
      return
    }

    // Simple user agent detection for mobile devices
    const userAgent = navigator.userAgent.toLowerCase()
    const isMobile = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent)

    // Set device type in cookie (only once)
    const deviceType = isMobile ? 'mobile' : 'laptop'
    document.cookie = `device_type=${deviceType}; path=/; max-age=86400` // 24 hours

    console.log(`Device detected: ${deviceType} (${isMobile ? 'mobile' : 'desktop'})`)
    
    // Note: Layout switching is now handled server-side based on the cookie
    // No page reload needed - the next page load will use the correct layout
  }

  // Helper method to get cookie value
  getCookieValue(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) return parts.pop().split(';').shift()
    return null
  }
}
