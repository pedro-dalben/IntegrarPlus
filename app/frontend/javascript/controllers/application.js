import { Application } from '@hotwired/stimulus';

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
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

application.register('header', HeaderController);
application.register('sidebar', SidebarController);
application.register('dropdown', DropdownController);
application.register('search', SearchController);
application.register('row', RowController);
application.register('mask', MaskController);
application.register('time-hhmm', TimeHhmmController);
application.register('contract-fields', ContractFieldsController);

export { application };
