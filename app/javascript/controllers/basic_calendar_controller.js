import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['container', 'viewSelector'];
  static values = {
    events: Array,
    calendarId: String,
  };

  connect() {
    this.currentView = 'month';
    this.currentDate = new Date();
    this.renderCalendar();
  }

  changeView(event) {
    this.currentView = event.target.value;
    this.renderCalendar();
  }

  renderCalendar() {
    if (!this.containerTarget) return;

    if (this.currentView === 'month') {
      this.renderMonthView();
    } else if (this.currentView === 'week') {
      this.renderWeekView();
    } else if (this.currentView === 'day') {
      this.renderDayView();
    }
  }

  renderMonthView() {
    const year = this.currentDate.getFullYear();
    const month = this.currentDate.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    let html = `
      <div class="calendar-container">
        <div class="calendar-header mb-6">
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white text-center">
            ${this.currentDate.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })}
          </h3>
        </div>
        
        <div class="grid grid-cols-7 gap-1 mb-2">
          ${['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
            .map(
              day =>
                `<div class="text-center text-sm font-semibold text-gray-600 dark:text-gray-400 py-3 bg-gray-50 dark:bg-gray-700 rounded-lg">${day}</div>`
            )
            .join('')}
        </div>
        
        <div class="grid grid-cols-7 gap-1">
    `;

    for (let i = 0; i < 42; i++) {
      const date = new Date(startDate);
      date.setDate(startDate.getDate() + i);

      const isCurrentMonth = date.getMonth() === month;
      const isToday = this.isSameDay(date, new Date());
      const dayEvents = this.getEventsForDay(date);

      html += `
        <div class="h-24 border border-gray-200 dark:border-gray-700 p-2 text-sm rounded-lg transition-colors cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700
            ${!isCurrentMonth ? 'text-gray-400 dark:text-gray-600' : 'text-gray-900 dark:text-white'}
            ${isToday ? 'bg-blue-50 dark:bg-blue-900/20' : ''}">
          <div class="font-medium mb-1 ${isToday ? 'text-blue-600 dark:text-blue-400' : ''}">
            ${date.getDate()}
          </div>
          <div class="space-y-1">
            ${dayEvents
              .slice(0, 2)
              .map(
                event => `
              <div class="text-xs p-1 rounded truncate text-white font-medium" 
                   style="background-color: ${event.color}"
                   title="${event.title} - ${event.professional_name}">
                ${event.title}
              </div>
            `
              )
              .join('')}
            ${dayEvents.length > 2 ? `<div class="text-xs text-gray-500 dark:text-gray-400 font-medium">+${dayEvents.length - 2} mais</div>` : ''}
          </div>
        </div>
      `;
    }

    html += '</div></div>';
    this.containerTarget.innerHTML = html;
  }

  renderWeekView() {
    const weekStart = this.getWeekStart(this.currentDate);
    const weekDays = [];

    for (let i = 0; i < 7; i++) {
      const day = new Date(weekStart);
      day.setDate(weekStart.getDate() + i);
      weekDays.push(day);
    }

    let html = `
      <div class="calendar-container">
        <div class="calendar-header mb-6">
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white text-center">
            Semana de ${weekDays[0].toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })} a ${weekDays[6].toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })}
          </h3>
        </div>
        
        <div class="grid grid-cols-7 gap-4">
    `;

    weekDays.forEach(day => {
      const isToday = this.isSameDay(day, new Date());
      const dayEvents = this.getEventsForDay(day);

      html += `
        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4
            ${isToday ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-white dark:bg-gray-800'}">
          <div class="text-center mb-4">
            <div class="text-sm font-medium text-gray-600 dark:text-gray-400">
              ${day.toLocaleDateString('pt-BR', { weekday: 'short' })}
            </div>
            <div class="text-lg font-bold ${isToday ? 'text-blue-600 dark:text-blue-400' : 'text-gray-900 dark:text-white'}">
              ${day.getDate()}
            </div>
          </div>
          <div class="space-y-2">
            ${dayEvents
              .map(
                event => `
              <div class="p-2 rounded text-xs text-white font-medium" 
                   style="background-color: ${event.color}"
                   title="${event.title} - ${event.professional_name}">
                <div class="font-semibold">${event.title}</div>
                <div class="opacity-90">${event.start_time}</div>
              </div>
            `
              )
              .join('')}
            ${dayEvents.length === 0 ? '<div class="text-xs text-gray-400 text-center py-4">Nenhum evento</div>' : ''}
          </div>
        </div>
      `;
    });

    html += '</div></div>';
    this.containerTarget.innerHTML = html;
  }

  renderDayView() {
    const isToday = this.isSameDay(this.currentDate, new Date());
    const dayEvents = this.getEventsForDay(this.currentDate);

    let html = `
      <div class="calendar-container">
        <div class="calendar-header mb-6">
          <h3 class="text-2xl font-bold text-gray-900 dark:text-white text-center">
            ${this.currentDate.toLocaleDateString('pt-BR', {
              weekday: 'long',
              day: '2-digit',
              month: 'long',
              year: 'numeric',
            })}
          </h3>
        </div>
        
        <div class="grid grid-cols-1 gap-4">
    `;

    // Horários do dia (8h às 18h)
    for (let hour = 8; hour <= 18; hour++) {
      const timeSlot = `${hour.toString().padStart(2, '0')}:00`;
      const hourEvents = dayEvents.filter(
        event => event.start_time && event.start_time.startsWith(timeSlot)
      );

      html += `
        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 bg-white dark:bg-gray-800">
          <div class="flex items-center gap-4">
            <div class="w-16 text-sm font-medium text-gray-600 dark:text-gray-400">
              ${timeSlot}
            </div>
            <div class="flex-1">
              ${
                hourEvents.length > 0
                  ? hourEvents
                      .map(
                        event => `
                <div class="p-3 rounded-lg text-white font-medium mb-2" 
                     style="background-color: ${event.color}">
                  <div class="font-semibold">${event.title}</div>
                  <div class="text-sm opacity-90">${event.professional_name}</div>
                  <div class="text-xs opacity-75">${event.start_time} - ${event.end_time || 'N/A'}</div>
                </div>
              `
                      )
                      .join('')
                  : '<div class="text-sm text-gray-400">Horário livre</div>'
              }
            </div>
          </div>
        </div>
      `;
    }

    html += '</div></div>';
    this.containerTarget.innerHTML = html;
  }

  getEventsForDay(date) {
    return this.eventsValue.filter(event => {
      const eventDate = new Date(event.start);
      return this.isSameDay(eventDate, date);
    });
  }

  getWeekStart(date) {
    const start = new Date(date);
    const day = start.getDay();
    const diff = start.getDate() - day;
    start.setDate(diff);
    return start;
  }

  isSameDay(date1, date2) {
    return (
      date1.getDate() === date2.getDate() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getFullYear() === date2.getFullYear()
    );
  }
}
