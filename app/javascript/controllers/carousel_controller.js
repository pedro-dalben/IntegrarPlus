import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.container = this.element.querySelector('.flex.space-x-8')
    this.currentIndex = 0
    this.itemWidth = 320 // w-80 = 320px
    this.gap = 32 // space-x-8 = 32px
    this.visibleItems = this.getVisibleItems()
  }

  getVisibleItems() {
    const containerWidth = this.element.offsetWidth
    return Math.floor(containerWidth / (this.itemWidth + this.gap))
  }

  next() {
    const maxIndex = this.container.children.length - this.visibleItems
    if (this.currentIndex < maxIndex) {
      this.currentIndex++
      this.scrollToIndex()
    }
  }

  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.scrollToIndex()
    }
  }

  scrollToIndex() {
    const scrollAmount = this.currentIndex * (this.itemWidth + this.gap)
    this.container.style.transform = `translateX(-${scrollAmount}px)`
  }
}
