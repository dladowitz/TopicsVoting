import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.detectDeviceType()
  }

  disconnect() {
    // No cleanup needed - we only run once
  }

  detectDeviceType() {
    // Simple user agent detection for mobile devices
    const userAgent = navigator.userAgent.toLowerCase()
    const isMobile = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent)
    
    // Set device type in cookie (only once)
    const deviceType = isMobile ? 'mobile' : 'laptop'
    document.cookie = `device_type=${deviceType}; path=/; max-age=86400` // 24 hours
    
    console.log(`Device detected: ${deviceType} (${isMobile ? 'mobile' : 'desktop'})`)
    
    // Check if layout needs to change
    const currentLayout = document.body.classList.contains('mobile-layout') ? 'mobile' : 'laptop'
    
    if (deviceType !== currentLayout) {
      console.log(`Layout mismatch detected. Current: ${currentLayout}, Should be: ${deviceType}`)
      window.location.reload()
    }
  }
}
