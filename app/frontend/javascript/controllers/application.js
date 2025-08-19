import { Application } from "@hotwired/stimulus";

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus   = application;

// Auto-register (opcional) ou registros manuais
import HeaderController from "./header_controller";
import SidebarController from "./sidebar_controller";

application.register("header", HeaderController);
application.register("sidebar", SidebarController);

export { application };
