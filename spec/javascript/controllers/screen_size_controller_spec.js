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
    it("should detect desktop device and set cookie", () => {
      // Mock desktop user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=laptop')
    })

    it("should detect mobile device and set cookie", () => {
      // Mock mobile user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=mobile')
    })

    it("should detect Android device and set cookie", () => {
      // Mock Android user agent
      Object.defineProperty(navigator, 'userAgent', {
        value: 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36'
      })
      
      controller.detectDeviceType()
      
      expect(document.cookie).toContain('device_type=mobile')
    })

    it("should not set cookie if device type already exists", () => {
      // Set existing cookie
      document.cookie = 'device_type=laptop; path=/'
      
      controller.detectDeviceType()
      
      // Should not change the existing cookie
      expect(document.cookie).toContain('device_type=laptop')
      expect(document.cookie).not.toContain('device_type=mobile')
    })
  })

  describe("cookie helper", () => {
    it("should get cookie value correctly", () => {
      document.cookie = 'device_type=laptop; path=/'
      
      const result = controller.getCookieValue('device_type')
      
      expect(result).toBe('laptop')
    })

    it("should return null for non-existent cookie", () => {
      const result = controller.getCookieValue('nonexistent')
      
      expect(result).toBeNull()
    })
  })
})
