import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler, Tooltip, Legend } from "chart.js"

Chart.register(LineController, LineElement, PointElement, LinearScale, CategoryScale, Filler, Tooltip, Legend)

export default class extends Controller {
  static values = { labels: Array, series: Array }

  connect() {
    const ctx = this.element.getContext('2d')
    const labels = this.labelsValue || []
    const data = this.seriesValue || []
    this.chart = new Chart(ctx, {
      type: 'line',
      data: { labels, datasets: [{ label: 'Série', data, tension: 0.35, fill: true, borderColor: 'rgb(70,95,255)', backgroundColor: 'rgba(70,95,255,0.12)' }] },
      options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { grid: { display: false } }, y: { grid: { color: 'rgba(0,0,0,0.06)' } } } }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}


