import { Application } from "@hotwired/stimulus"
import { registerControllers } from "stimulus-vite-helpers"

const application = Application.start()
const controllers = import.meta.globEager("./**/*_controller.js")
registerControllers(application, controllers)

import "./stylesheets/application.css"

document.addEventListener("turbo:load", () => {
  initializeComponents()
})

document.addEventListener("turbo:render", () => {
  initializeComponents()
})

function initializeComponents() {
  initializeTooltips()
  initializeModals()
  initializeDropdowns()
  initializeTabs()
  initializeAccordions()
  initializeAlerts()
  initializeForms()
  initializeTables()
  initializeCharts()
  initializeMaps()
  initializeSliders()
  initializeCarousels()
  initializeLightboxes()
  initializeGalleries()
  initializeVideos()
  initializeAudio()
  initializeAnimations()
  initializeTransitions()
  initializeEffects()
  initializeUtilities()
}

function initializeTooltips() {
  const tooltipElements = document.querySelectorAll('[data-tooltip]')
  tooltipElements.forEach(element => {
    if (!element.hasAttribute('data-tooltip-initialized')) {
      element.setAttribute('data-tooltip-initialized', 'true')
    }
  })
}

function initializeModals() {
  const modalTriggers = document.querySelectorAll('[data-modal-target]')
  modalTriggers.forEach(trigger => {
    if (!trigger.hasAttribute('data-modal-initialized')) {
      trigger.setAttribute('data-modal-initialized', 'true')
    }
  })
}

function initializeDropdowns() {
  const dropdownTriggers = document.querySelectorAll('[data-dropdown-target]')
  dropdownTriggers.forEach(trigger => {
    if (!trigger.hasAttribute('data-dropdown-initialized')) {
      trigger.setAttribute('data-dropdown-initialized', 'true')
    }
  })
}

function initializeTabs() {
  const tabTriggers = document.querySelectorAll('[data-tab-target]')
  tabTriggers.forEach(trigger => {
    if (!trigger.hasAttribute('data-tab-initialized')) {
      trigger.setAttribute('data-tab-initialized', 'true')
    }
  })
}

function initializeAccordions() {
  const accordionTriggers = document.querySelectorAll('[data-accordion-target]')
  accordionTriggers.forEach(trigger => {
    if (!trigger.hasAttribute('data-accordion-initialized')) {
      trigger.setAttribute('data-accordion-initialized', 'true')
    }
  })
}

function initializeAlerts() {
  const alertElements = document.querySelectorAll('[data-alert]')
  alertElements.forEach(alert => {
    if (!alert.hasAttribute('data-alert-initialized')) {
      alert.setAttribute('data-alert-initialized', 'true')
    }
  })
}

function initializeForms() {
  const formElements = document.querySelectorAll('form[data-form]')
  formElements.forEach(form => {
    if (!form.hasAttribute('data-form-initialized')) {
      form.setAttribute('data-form-initialized', 'true')
    }
  })
}

function initializeTables() {
  const tableElements = document.querySelectorAll('table[data-table]')
  tableElements.forEach(table => {
    if (!table.hasAttribute('data-table-initialized')) {
      table.setAttribute('data-table-initialized', 'true')
    }
  })
}

function initializeCharts() {
  const chartElements = document.querySelectorAll('[data-chart]')
  chartElements.forEach(chart => {
    if (!chart.hasAttribute('data-chart-initialized')) {
      chart.setAttribute('data-chart-initialized', 'true')
    }
  })
}

function initializeMaps() {
  const mapElements = document.querySelectorAll('[data-map]')
  mapElements.forEach(map => {
    if (!map.hasAttribute('data-map-initialized')) {
      map.setAttribute('data-map-initialized', 'true')
    }
  })
}

function initializeSliders() {
  const sliderElements = document.querySelectorAll('[data-slider]')
  sliderElements.forEach(slider => {
    if (!slider.hasAttribute('data-slider-initialized')) {
      slider.setAttribute('data-slider-initialized', 'true')
    }
  })
}

function initializeCarousels() {
  const carouselElements = document.querySelectorAll('[data-carousel]')
  carouselElements.forEach(carousel => {
    if (!carousel.hasAttribute('data-carousel-initialized')) {
      carousel.setAttribute('data-carousel-initialized', 'true')
    }
  })
}

function initializeLightboxes() {
  const lightboxElements = document.querySelectorAll('[data-lightbox]')
  lightboxElements.forEach(lightbox => {
    if (!lightbox.hasAttribute('data-lightbox-initialized')) {
      lightbox.setAttribute('data-lightbox-initialized', 'true')
    }
  })
}

function initializeGalleries() {
  const galleryElements = document.querySelectorAll('[data-gallery]')
  galleryElements.forEach(gallery => {
    if (!gallery.hasAttribute('data-gallery-initialized')) {
      gallery.setAttribute('data-gallery-initialized', 'true')
    }
  })
}

function initializeVideos() {
  const videoElements = document.querySelectorAll('[data-video]')
  videoElements.forEach(video => {
    if (!video.hasAttribute('data-video-initialized')) {
      video.setAttribute('data-video-initialized', 'true')
    }
  })
}

function initializeAudio() {
  const audioElements = document.querySelectorAll('[data-audio]')
  audioElements.forEach(audio => {
    if (!audio.hasAttribute('data-audio-initialized')) {
      audio.setAttribute('data-audio-initialized', 'true')
    }
  })
}

function initializeAnimations() {
  const animationElements = document.querySelectorAll('[data-animation]')
  animationElements.forEach(animation => {
    if (!animation.hasAttribute('data-animation-initialized')) {
      animation.setAttribute('data-animation-initialized', 'true')
    }
  })
}

function initializeTransitions() {
  const transitionElements = document.querySelectorAll('[data-transition]')
  transitionElements.forEach(transition => {
    if (!transition.hasAttribute('data-transition-initialized')) {
      transition.setAttribute('data-transition-initialized', 'true')
    }
  })
}

function initializeEffects() {
  const effectElements = document.querySelectorAll('[data-effect]')
  effectElements.forEach(effect => {
    if (!effect.hasAttribute('data-effect-initialized')) {
      effect.setAttribute('data-effect-initialized', 'true')
    }
  })
}

function initializeUtilities() {
  const utilityElements = document.querySelectorAll('[data-utility]')
  utilityElements.forEach(utility => {
    if (!utility.hasAttribute('data-utility-initialized')) {
      utility.setAttribute('data-utility-initialized', 'true')
    }
  })
}
