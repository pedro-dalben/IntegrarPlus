import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bell", "count", "list", "dropdown"]
  static values = { 
    userId: String,
    unreadCount: Number
  }

  connect() {
    this.setupWebSocket()
    this.loadUnreadCount()
    this.setupPeriodicRefresh()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  }

  setupWebSocket() {
    this.cable = createConsumer()
    this.subscription = this.cable.subscriptions.create(
      { channel: "NotificationChannel" },
      {
        received: (data) => {
          this.handleNotification(data)
        }
      }
    )
  }

  handleNotification(data) {
    switch (data.type) {
      case 'notification':
        this.showNotificationToast(data)
        this.updateUnreadCount()
        break
      case 'notification_count':
        this.updateCountDisplay(data.count)
        break
      case 'notification_read':
        this.updateUnreadCount()
        break
    }
  }

  showNotificationToast(notification) {
    const toast = this.createToastElement(notification)
    document.body.appendChild(toast)
    
    // Mostrar toast
    const bsToast = new bootstrap.Toast(toast)
    bsToast.show()
    
    // Remover elemento após esconder
    toast.addEventListener('hidden.bs.toast', () => {
      toast.remove()
    })
  }

  createToastElement(notification) {
    const toast = document.createElement('div')
    toast.className = 'toast position-fixed top-0 end-0 m-3'
    toast.style.zIndex = '9999'
    toast.setAttribute('role', 'alert')
    toast.setAttribute('aria-live', 'assertive')
    toast.setAttribute('aria-atomic', 'true')
    
    const iconClass = this.getIconClass(notification.icon)
    const colorClass = this.getColorClass(notification.color)
    
    toast.innerHTML = `
      <div class="toast-header">
        <i class="feather ${iconClass} text-${colorClass} me-2"></i>
        <strong class="me-auto">${notification.title}</strong>
        <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
      </div>
      <div class="toast-body">
        ${notification.message}
      </div>
    `
    
    return toast
  }

  getIconClass(icon) {
    const iconMap = {
      'calendar-plus': 'calendar-plus',
      'calendar-edit': 'calendar-edit',
      'calendar-check': 'calendar-check',
      'bell': 'bell',
      'calendar-x': 'calendar-x',
      'calendar-clock': 'calendar-clock',
      'check-circle': 'check-circle',
      'user-x': 'user-x',
      'alert-triangle': 'alert-triangle',
      'trending-down': 'trending-down',
      'alert-circle': 'alert-circle',
      'file-text': 'file-text',
      'bar-chart': 'bar-chart',
      'pie-chart': 'pie-chart'
    }
    return iconMap[icon] || 'bell'
  }

  getColorClass(color) {
    const colorMap = {
      'green': 'success',
      'blue': 'primary',
      'yellow': 'warning',
      'red': 'danger',
      'orange': 'warning',
      'purple': 'info',
      'indigo': 'info',
      'gray': 'secondary'
    }
    return colorMap[color] || 'secondary'
  }

  loadUnreadCount() {
    fetch('/admin/notifications/unread_count')
      .then(response => response.json())
      .then(data => {
        this.updateCountDisplay(data.count)
      })
      .catch(error => {
        console.error('Error loading unread count:', error)
      })
  }

  updateUnreadCount() {
    this.loadUnreadCount()
  }

  updateCountDisplay(count) {
    if (this.hasCountTarget) {
      this.countTarget.textContent = count
      this.countTarget.classList.toggle('d-none', count === 0)
    }
  }

  markAsRead(event) {
    const notificationId = event.target.dataset.notificationId
    
    fetch(`/admin/notifications/${notificationId}/mark_as_read`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        this.updateUnreadCount()
        this.updateNotificationElement(notificationId, true)
      }
    })
    .catch(error => {
      console.error('Error marking notification as read:', error)
    })
  }

  markAsUnread(event) {
    const notificationId = event.target.dataset.notificationId
    
    fetch(`/admin/notifications/${notificationId}/mark_as_unread`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        this.updateUnreadCount()
        this.updateNotificationElement(notificationId, false)
      }
    })
    .catch(error => {
      console.error('Error marking notification as unread:', error)
    })
  }

  updateNotificationElement(notificationId, isRead) {
    const notificationElement = document.querySelector(`[data-notification-id="${notificationId}"]`)
    if (notificationElement) {
      if (isRead) {
        notificationElement.classList.add('list-group-item-light')
        notificationElement.classList.add('text-muted')
        const badge = notificationElement.querySelector('.badge')
        if (badge) badge.remove()
      } else {
        notificationElement.classList.remove('list-group-item-light')
        notificationElement.classList.remove('text-muted')
        // Adicionar badge de "Nova" se não existir
        if (!notificationElement.querySelector('.badge')) {
          const title = notificationElement.querySelector('h6')
          if (title) {
            const badge = document.createElement('span')
            badge.className = 'badge bg-primary ms-2'
            badge.textContent = 'Nova'
            title.appendChild(badge)
          }
        }
      }
    }
  }

  setupPeriodicRefresh() {
    // Atualizar contador a cada 30 segundos
    this.refreshInterval = setInterval(() => {
      this.loadUnreadCount()
    }, 30000)
  }

  toggleDropdown(event) {
    event.preventDefault()
    if (this.hasDropdownTarget) {
      const dropdown = new bootstrap.Dropdown(this.dropdownTarget)
      dropdown.toggle()
    }
  }

  // Método para testar notificações (apenas em desenvolvimento)
  testNotification() {
    if (Rails.env === 'development') {
      const testNotification = {
        type: 'notification',
        id: Date.now(),
        title: 'Notificação de Teste',
        message: 'Esta é uma notificação de teste do sistema.',
        icon: 'bell',
        color: 'blue',
        created_at: new Date().toISOString()
      }
      this.handleNotification(testNotification)
    }
  }
}
