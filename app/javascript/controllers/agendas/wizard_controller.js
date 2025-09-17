import { Controller } from "@hotwired/stimulus"

console.log("🔧 Carregando WizardController...")

export default class extends Controller {
  static targets = ["step", "previousBtn", "nextBtn", "activateBtn", "tab", "currentStepInput"]
  
  static values = { currentStep: String }

  connect() {
    console.log("🔧 WizardController conectado")
    // Permite inicializar pelo valor vindo do HTML (ex.: edit com ?step=...)
    if (!this.hasCurrentStepValue || !this.currentStepValue) {
      this.currentStepValue = "metadata"
    }
    this.showStep(this.currentStepValue)
    this.updateNavigation()
    this.updateTabs()
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
      this.updateTabs()
      this.updateStepInput()
    }
  }

  previousStep() {
    const steps = ["metadata", "professionals", "working_hours", "review"]
    const currentIndex = steps.indexOf(this.currentStepValue)
    
    if (currentIndex > 0) {
      this.currentStepValue = steps[currentIndex - 1]
      this.showStep(this.currentStepValue)
      this.updateNavigation()
      this.updateTabs()
      this.updateStepInput()
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

  updateTabs() {
    if (!this.hasTabTarget) return
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.step === this.currentStepValue
      tab.classList.toggle('border-blue-500', active)
      tab.classList.toggle('border-transparent', !active)
      const span = tab.querySelector('span')
      if (span) {
        span.classList.toggle('text-blue-600', active)
        span.classList.toggle('dark:text-blue-400', active)
        span.classList.toggle('text-gray-500', !active)
        span.classList.toggle('dark:text-gray-400', !active)
      }
    })
  }

  currentStepValueChanged() {
    this.updateNavigation()
    this.updateTabs()
    this.updateStepInput()
  }

  goToStep(event) {
    event.preventDefault()
    const target = event.currentTarget
    if (!target) return
    const step = target.dataset.step
    if (!step) return
    this.currentStepValue = step
    this.showStep(step)
    this.updateNavigation()
    this.updateTabs()
    this.updateStepInput()
  }

  updateStepInput() {
    if (this.hasCurrentStepInputTarget) {
      this.currentStepInputTarget.value = this.currentStepValue
    } else {
      const input = this.element.querySelector('input[name="step"]')
      if (input) input.value = this.currentStepValue
    }
  }
}
