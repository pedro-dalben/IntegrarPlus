class Layouts::TopbarComponent < ViewComponent::Base
  def initialize(current_professional: nil)
    @current_professional = current_professional
  end

  def call
    content_tag :header, class: "sticky top-0 z-50 bg-bg border-b border-gray-200 dark:border-neutral-700" do
      content_tag :div, class: "container-app h-14 flex items-center justify-between" do
        safe_join([
          content_tag(:div, class: "flex items-center gap-3") do
            safe_join([
              content_tag(:button, class: "inline-flex items-center justify-center size-8 rounded-md hover:bg-gray-100 dark:hover:bg-neutral-800 lg:hidden", aria: { label: "Abrir menu" }, data: { controller: "sidebar", action: "click->sidebar#toggle" }) do
                content_tag(:span, "☰", class: "sr-only") + content_tag(:span, "", class: "size-5 bg-gray-800 rounded-sm")
              end,
              link_to("IntegrarPlus", "/admin", class: "font-semibold")
            ])
          end,
          content_tag(:div, class: "flex items-center gap-2") do
            safe_join([
              content_tag(:button, class: "btn", aria: { label: "Alternar tema" }, data: { controller: "theme", action: "click->theme#toggle" }) do
                "Tema"
              end,
              content_tag(:div, class: "relative", data: { controller: "menu" }) do
                content_tag(:button, class: "inline-flex items-center gap-2 rounded-md px-3 py-1.5 hover:bg-gray-100 dark:hover:bg-neutral-800", aria: { haspopup: "menu", expanded: "false" }, data: { action: "click->menu#toggle" }) do
                  content_tag(:span, (@current_professional&.email || "Usuário"), class: "text-sm")
                end +
                content_tag(:div, class: "absolute right-0 mt-2 w-48 rounded-md bg-surface shadow-md hidden", data: { menu_target: "panel" }) do
                  safe_join([
                    link_to("Minha conta", "#", class: "block px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-neutral-800"),
                    link_to("Sair", "/users/sign_out", data: { turbo_method: :delete }, class: "block px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-neutral-800")
                  ])
                end
              end
            ])
          end
        ])
      end
    end
  end
end
