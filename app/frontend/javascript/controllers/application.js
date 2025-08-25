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

application.register('header', HeaderController);
application.register('sidebar', SidebarController);
application.register('dropdown', DropdownController);
application.register('search', SearchController);
application.register('row', RowController);

export { application };
