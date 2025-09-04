import { Controller } from "@hotwired/stimulus"

console.log("🔧 Carregando WizardController...")

export default class extends Controller {
  static targets = ["step", "previousBtn", "nextBtn", "activateBtn"]
  
  static values = { currentStep: String }

  connect() {
    console.log("🔧 WizardController conectado")
    this.currentStepValue = "metadata"
    this.updateNavigation()
    console.log("🔧 Navegação atualizada, step atual:", this.currentStepValue)
  }

  nextStep() {
    console.log("🔧 nextStep chamado, step atual:", this.currentStepValue)
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    if (currentIndex < steps.length - 1) {
      this.currentStepValue = steps[currentIndex + 1]
      console.log("🔧 Mudando para step:", this.currentStepValue)
      this.showStep(this.currentStepValue)
      this.updateNavigation()
    }
  }

  previousStep() {
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    if (currentIndex > 0) {
      this.currentStepValue = steps[currentIndex - 1]
      this.showStep(this.currentStepValue)
      this.updateNavigation()
    }
  }

  showStep(stepName) {
    this.stepTargets.forEach(step => {
      if (step.dataset.step === stepName) {
        step.classList.remove("hidden")
      } else {
        step.classList.add("hidden")
      }
    })
  }

  updateNavigation() {
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    // Update previous button
    if (currentIndex === 0) {
      this.previousBtnTarget.classList.add("hidden")
    } else {
      this.previousBtnTarget.classList.remove("hidden")
    }
    
    // Update next button
    if (currentIndex === steps.length - 1) {
      this.nextBtnTarget.classList.add("hidden")
      if (this.hasActivateBtnTarget) {
        this.activateBtnTarget.classList.remove("hidden")
      }
    } else {
      this.nextBtnTarget.classList.remove("hidden")
      if (this.hasActivateBtnTarget) {
        this.activateBtnTarget.classList.add("hidden")
      }
    }
  }

  currentStepValueChanged() {
    this.updateNavigation()
  }
}
