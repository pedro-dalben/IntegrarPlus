import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Register controllers
import HeaderController from "./header_controller"
application.register("header", HeaderController)

export { application }
