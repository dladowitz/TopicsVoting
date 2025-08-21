import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete-modal"
export default class extends Controller {
  static targets = [ "modal" ]

  connect() {
    console.log("Delete Modal Stimulus controller connected!")
  }

  show() {
    this.modalTarget.style.display = "block"
  }

  hide() {
    this.modalTarget.style.display = "none"
  }
}
