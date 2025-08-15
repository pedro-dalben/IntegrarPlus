// app/frontend/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyTheme()
  }

  toggle() {
    const html = document.documentElement
    const isDark = html.classList.contains('dark')
    
    if (isDark) {
      this.setTheme('light')
    } else {
      this.setTheme('dark')
    }
  }

  setTheme(theme) {
    const html = document.documentElement
    
    if (theme === 'dark') {
      html.classList.add('dark')
      localStorage.setItem('theme', 'dark')
    } else {
      html.classList.remove('dark')
      localStorage.setItem('theme', 'light')
    }
  }

  applyTheme() {
    const savedTheme = localStorage.getItem('theme')
    
    if (savedTheme) {
      this.setTheme(savedTheme)
    } else {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      this.setTheme(prefersDark ? 'dark' : 'light')
    }
  }
}
