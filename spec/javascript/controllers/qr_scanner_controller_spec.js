import { Application } from "@hotwired/stimulus"
import QrScannerController from "../../../app/javascript/controllers/qr_scanner_controller"

describe("QrScannerController", () => {
  let application
  let controller
  let element
  let inputTarget
  let modalTarget
  let videoTarget

  beforeEach(() => {
    // Set up our document body
    document.body.innerHTML = `
      <div data-controller="qr-scanner">
        <textarea data-qr-scanner-target="input"></textarea>
        <button data-action="click->qr-scanner#startScanning">Scan QR</button>
        <div class="qr-scanner-modal hidden" data-qr-scanner-target="modal">
          <video data-qr-scanner-target="video"></video>
        </div>
      </div>
    `

    element = document.querySelector('[data-controller="qr-scanner"]')
    inputTarget = element.querySelector('[data-qr-scanner-target="input"]')
    modalTarget = element.querySelector('[data-qr-scanner-target="modal"]')
    videoTarget = element.querySelector('[data-qr-scanner-target="video"]')

    // Initialize Stimulus application and controller
    application = Application.start()
    application.register("qr-scanner", QrScannerController)
  })

  afterEach(() => {
    // Clean up
    document.body.innerHTML = ""
    jest.restoreAllMocks()
  })

  describe("startScanning", () => {
    beforeEach(() => {
      // Mock getUserMedia
      global.navigator.mediaDevices = {
        getUserMedia: jest.fn().mockResolvedValue("fake-stream")
      }
    })

    it("shows the modal when scanning starts", async () => {
      await controller.startScanning()
      expect(modalTarget.classList.contains("hidden")).toBeFalsy()
    })

    it("requests camera access", async () => {
      await controller.startScanning()
      expect(navigator.mediaDevices.getUserMedia).toHaveBeenCalledWith({
        video: { facingMode: "environment" }
      })
    })

    it("handles camera access errors", async () => {
      const consoleSpy = jest.spyOn(console, "error").mockImplementation()
      const alertSpy = jest.spyOn(window, "alert").mockImplementation()

      navigator.mediaDevices.getUserMedia.mockRejectedValue(new Error("Camera access denied"))

      await controller.startScanning()

      expect(consoleSpy).toHaveBeenCalled()
      expect(alertSpy).toHaveBeenCalledWith(
        "Could not access camera. Please ensure camera permissions are granted."
      )
    })
  })

  describe("stopScanning", () => {
    it("hides the modal", () => {
      modalTarget.classList.remove("hidden")
      controller.stopScanning()
      expect(modalTarget.classList.contains("hidden")).toBeTruthy()
    })

    it("stops all video tracks", () => {
      const mockTrack = { stop: jest.fn() }
      videoTarget.srcObject = { getTracks: () => [mockTrack] }

      controller.stopScanning()
      expect(mockTrack.stop).toHaveBeenCalled()
    })
  })

  describe("scanQRCode", () => {
    beforeEach(() => {
      // Mock canvas and context
      const mockContext = {
        drawImage: jest.fn(),
        getImageData: jest.fn().mockReturnValue({
          data: new Uint8ClampedArray(),
          width: 640,
          height: 480
        })
      }
      global.document.createElement = jest.fn().mockReturnValue({
        getContext: () => mockContext
      })

      // Mock jsQR
      global.jsQR = jest.fn()
    })

    it("processes valid BOLT11 invoice QR codes", async () => {
      const validBolt11 = "lnbc1500n1ps..."
      global.jsQR.mockReturnValue({ data: validBolt11 })

      videoTarget.videoWidth = 640
      videoTarget.videoHeight = 480

      await controller.scanQRCode()

      expect(inputTarget.value).toBe(validBolt11)
      expect(modalTarget.classList.contains("hidden")).toBeTruthy()
    })

    it("ignores non-BOLT11 QR codes", async () => {
      global.jsQR.mockReturnValue({ data: "not-a-bolt11-invoice" })

      videoTarget.videoWidth = 640
      videoTarget.videoHeight = 480

      await controller.scanQRCode()

      expect(inputTarget.value).toBe("")
      expect(modalTarget.classList.contains("hidden")).toBeFalsy()
    })
  })
})
