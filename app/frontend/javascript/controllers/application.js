import { Application } from '@hotwired/stimulus';

const application = Application.start();

// Configure Stimulus development experience
window.Stimulus = application;

// Registros manuais de todos os controllers
import HeaderController from './header_controller';
import SidebarController from './sidebar_controller';
import DropdownController from './dropdown_controller';
import SearchController from './search_controller';
import RowController from './row_controller';
import MaskController from './mask_controller';
import TimeHhmmController from './time_hhmm_controller';
import ContractFieldsController from './contract_fields_controller';
import CpfMaskController from './cpf_mask_controller';
import CepMaskController from './cep_mask_controller';
import CepController from './cep_controller';
import TomSelectController from './tom_select_controller';
import DependentSpecializationsController from './dependent_specializations_controller';
import NestedFormController from './nested_form_controller';
import AddressBuilderController from './address_builder_controller';
import InputMaskController from './input_mask_controller';
import CalendarController from './calendar_controller';
import DashboardCalendarController from './dashboard_calendar_controller';
import WizardController from '../../../javascript/controllers/agendas/wizard_controller';
import ProfessionalsController from '../../../javascript/controllers/agendas/professionals_controller';
import WorkingHoursController from '../../../javascript/controllers/agendas/working_hours_controller';
import ReviewController from '../../../javascript/controllers/agendas/review_controller';
import AgendaSchedulerController from '../../../javascript/controllers/agenda_scheduler_controller';

application.register('header', HeaderController);
application.register('sidebar', SidebarController);
application.register('dropdown', DropdownController);
application.register('search', SearchController);
application.register('row', RowController);
application.register('mask', MaskController);
application.register('time-hhmm', TimeHhmmController);
application.register('contract-fields', ContractFieldsController);
application.register('cpf-mask', CpfMaskController);
application.register('cep-mask', CepMaskController);
application.register('cep', CepController);
application.register('tom-select', TomSelectController);
application.register('dependent-specializations', DependentSpecializationsController);
application.register('nested-form', NestedFormController);
application.register('address-builder', AddressBuilderController);
application.register('input-mask', InputMaskController);
application.register('calendar', CalendarController);
application.register('dashboard-calendar', DashboardCalendarController);
application.register('agendas-wizard', WizardController);
application.register('agendas-professionals', ProfessionalsController);
application.register('agendas-working-hours', WorkingHoursController);
application.register('agendas-review', ReviewController);
application.register('agenda-scheduler', AgendaSchedulerController);

export { application };
