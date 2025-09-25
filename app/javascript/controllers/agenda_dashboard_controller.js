import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["occupancyChart", "utilizationChart", "trendsChart"]

  connect() {
    this.initializeCharts()
  }

  initializeCharts() {
    this.createOccupancyChart()
    this.createUtilizationChart()
    this.createTrendsChart()
  }

  createOccupancyChart() {
    if (this.hasOccupancyChartTarget) {
      this.occupancyChart = new Chart(this.occupancyChartTarget, {
        type: 'line',
        data: {
          labels: [],
          datasets: [{
            label: 'Taxa de Ocupação (%)',
            data: [],
            borderColor: 'rgb(59, 130, 246)',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100,
              ticks: {
                callback: function(value) {
                  return value + '%'
                }
              }
            }
          }
        }
      })

      this.updateOccupancyChart()
    }
  }

  createUtilizationChart() {
    if (this.hasUtilizationChartTarget) {
      this.utilizationChart = new Chart(this.utilizationChartTarget, {
        type: 'bar',
        data: {
          labels: [],
          datasets: [{
            label: 'Utilização (%)',
            data: [],
            backgroundColor: 'rgba(16, 185, 129, 0.8)',
            borderColor: 'rgb(16, 185, 129)',
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100,
              ticks: {
                callback: function(value) {
                  return value + '%'
                }
              }
            }
          }
        }
      })

      this.updateUtilizationChart()
    }
  }

  createTrendsChart() {
    if (this.hasTrendsChartTarget) {
      this.trendsChart = new Chart(this.trendsChartTarget, {
        type: 'line',
        data: {
          labels: [],
          datasets: [{
            label: 'Ocupação (%)',
            data: [],
            borderColor: 'rgb(168, 85, 247)',
            backgroundColor: 'rgba(168, 85, 247, 0.1)',
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              max: 100,
              ticks: {
                callback: function(value) {
                  return value + '%'
                }
              }
            }
          }
        }
      })

      this.updateTrendsChart()
    }
  }

  updateOccupancyChart(event) {
    if (!this.occupancyChart) return

    const period = event?.target?.value || '30_days'

    fetch(`/admin/agenda_dashboard/occupancy_chart?period=${period}`)
      .then(response => response.json())
      .then(data => {
        this.occupancyChart.data.labels = data.map(item => item.date)
        this.occupancyChart.data.datasets[0].data = data.map(item => item.occupancy)
        this.occupancyChart.update()
      })
      .catch(error => {
      })
  }

  updateUtilizationChart() {
    if (!this.utilizationChart) return

    fetch('/admin/agenda_dashboard/utilization_chart')
      .then(response => response.json())
      .then(data => {
        this.utilizationChart.data.labels = data.map(item => item.name)
        this.utilizationChart.data.datasets[0].data = data.map(item => item.utilization)
        this.utilizationChart.update()
      })
      .catch(error => {
      })
  }

  updateTrendsChart(event) {
    if (!this.trendsChart) return

    const period = event?.target?.value || '6_months'

    fetch(`/admin/agenda_dashboard/trends_chart?period=${period}`)
      .then(response => response.json())
      .then(data => {
        this.trendsChart.data.labels = data.map(item => item.month)
        this.trendsChart.data.datasets[0].data = data.map(item => item.occupancy)
        this.trendsChart.update()
      })
      .catch(error => {
      })
  }

  refreshUtilizationChart() {
    this.updateUtilizationChart()
  }
}
