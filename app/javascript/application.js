import "hotwire_spark"
import "@hotwired/turbo-rails"
import "controllers"
import "tailwindcss/tailwind.css"

// FullCalendar imports
import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list'
import ptBrLocale from '@fullcalendar/core/locales/pt-br'

// Make FullCalendar available globally for any legacy code
window.FullCalendar = {
  Calendar,
  dayGridPlugin,
  timeGridPlugin,
  interactionPlugin,
  listPlugin,
  ptBrLocale
}
