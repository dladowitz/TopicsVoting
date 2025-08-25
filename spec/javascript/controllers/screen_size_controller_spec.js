import { Application } from "@hotwired/stimulus"
import ScreenSizeController from "../../../app/javascript/controllers/screen_size_controller"

describe("ScreenSizeController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("screen-size", ScreenSizeController)
    
    // Mock document.cookie
    Object.defineProperty(document, 'cookie', {
      writable: true,
      value: ''
    })
    
    // Mock navigator.userAgent
    Object.defineProperty(navigator, 'userAgent', {
      writable: true,
      value: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    
    element = document.createElement('div')
    element.setAttribute('data-controller', 'screen-size')
    document.body.appendChild(element)
    
    controller = application.getControllerForElementAndIdentifier(element, 'screen-size')
  })

  afterEach(() => {
    application.stop()
    document.body.removeChild(element)
  })

  describe("device detection", () => {
    it("should detect desktop device", () => {
      // Mock desktop user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=laptop')
    })

    it("should detect mobile device", () => {
      // Mock mobile user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=mobile')
    })

    it("should detect Android device", () => {
      // Mock Android user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=mobile')
    })
  })

  describe("layout detection", () => {
    it("should detect mobile layout", () => {
      document.body.classList.add('mobile-layout')
      
      const result = controller.detectDeviceType()
      
      expect(document.body.classList.contains('mobile-layout')).toBe(true)
    })

    it("should detect laptop layout", () => {
      document.body.classList.add('laptop-layout')
      
      const result = controller.detectDeviceType()
      
      expect(document.body.classList.contains('laptop-layout')).toBe(true)
    })
  })
})
