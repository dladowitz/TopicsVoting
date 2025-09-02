import { Application } from "@hotwired/stimulus"
import TopicsController from "../../../app/javascript/controllers/topics_controller"

describe("TopicsController", () => {
  let application
  let controller
  let element
  let satsReceivedElement

  beforeEach(() => {
    // Set up our document body with a mock topic
    document.body.innerHTML = `
      <div data-controller="topics">
        <div class="topic-list-item" data-topic-id="1">
          <div class="sats-info">
            <div class="sats-received" data-sats="11">12</div>
          </div>
        </div>
        <div class="topic-list-item" data-topic-id="2">
          <div class="sats-info">
            <div class="sats-received" data-sats="22">23</div>
          </div>
        </div>
      </div>
    `

    // Get references to elements
    element = document.querySelector('[data-controller="topics"]')
    satsReceivedElement = element.querySelector('.sats-received')

    // Initialize Stimulus application and controller
    application = Application.start()
    application.register("topics", TopicsController)

    // Mock localStorage
    global.localStorage = {
      getItem: jest.fn(),
      setItem: jest.fn()
    }
  })

  afterEach(() => {
    // Clean up
    document.body.innerHTML = ""
    jest.restoreAllMocks()
  })

  describe("animateLightning", () => {
    let controller
    let topic1SatsElement
    let topic2SatsElement

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(
        element,
        "topics"
      )
      topic1SatsElement = element.querySelector('[data-topic-id="1"] .sats-received')
      topic2SatsElement = element.querySelector('[data-topic-id="2"] .sats-received')

      // Mock showCanvasLightning to avoid actual canvas operations
      controller.showCanvasLightning = jest.fn()
    })

    it("adds and removes lightning class after animation", () => {
      // Initial state - no lightning class
      expect(topic1SatsElement.classList.contains('lightning')).toBeFalsy()

      // Trigger animation
      controller.animateLightning(topic1SatsElement)

      // Lightning class should be added
      expect(topic1SatsElement.classList.contains('lightning')).toBeTruthy()

      // Simulate animation end
      topic1SatsElement.dispatchEvent(new Event('animationend'))

      // Lightning class should be removed
      expect(topic1SatsElement.classList.contains('lightning')).toBeFalsy()
    })

    it("only animates the topic that received payment", () => {
      // Trigger animation for first topic
      controller.animateLightning(topic1SatsElement)

      // First topic should have lightning class
      expect(topic1SatsElement.classList.contains('lightning')).toBeTruthy()
      // Second topic should not have lightning class
      expect(topic2SatsElement.classList.contains('lightning')).toBeFalsy()

      // Simulate animation end for first topic
      topic1SatsElement.dispatchEvent(new Event('animationend'))

      // First topic's lightning class should be removed
      expect(topic1SatsElement.classList.contains('lightning')).toBeFalsy()

      // Trigger animation for second topic
      controller.animateLightning(topic2SatsElement)

      // Now second topic should have lightning class
      expect(topic2SatsElement.classList.contains('lightning')).toBeTruthy()
      // First topic should still not have lightning class
      expect(topic1SatsElement.classList.contains('lightning')).toBeFalsy()
    })

    it("removes existing lightning class before adding it again", () => {
      // Add lightning class manually
      topic1SatsElement.classList.add('lightning')

      // Trigger animation
      controller.animateLightning(topic1SatsElement)

      // Should still have exactly one lightning class
      expect(topic1SatsElement.classList.contains('lightning')).toBeTruthy()
      expect(topic1SatsElement.className.split(/\s+/).filter(c => c === 'lightning').length).toBe(1)
    })
  })
})
