import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section", "button"]

  connect() {
    this.currentFilter = "all"
  }

  filter(event) {
    const status = event.currentTarget.dataset.taskFilterStatusValue
    this.currentFilter = status

    // Atualiza botões
    this.buttonTargets.forEach(button => {
      const buttonStatus = button.dataset.taskFilterStatusValue
      if (buttonStatus === status) {
        button.classList.remove("text-gray-600", "hover:bg-gray-100", "dark:text-gray-400", "dark:hover:bg-gray-700")
        button.classList.add("bg-blue-100", "text-blue-700", "dark:bg-blue-900", "dark:text-blue-300")
      } else {
        button.classList.remove("bg-blue-100", "text-blue-700", "dark:bg-blue-900", "dark:text-blue-300")
        button.classList.add("text-gray-600", "hover:bg-gray-100", "dark:text-gray-400", "dark:hover:bg-gray-700")
      }
    })

    // Mostra/esconde seções
    this.sectionTargets.forEach(section => {
      const sectionStatus = section.dataset.taskFilterSection
      
      if (status === "all") {
        section.classList.remove("hidden")
      } else if (sectionStatus === status) {
        section.classList.remove("hidden")
      } else {
        section.classList.add("hidden")
      }
    })
  }
}
