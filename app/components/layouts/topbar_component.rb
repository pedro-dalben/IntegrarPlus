class Layouts::TopbarComponent < ViewComponent::Base
  def initialize(current_professional: nil, title: nil, breadcrumbs: nil)
    @current_professional = current_professional
    @title = title
    @breadcrumbs = breadcrumbs || []
  end

  def call
    content_tag :header, class: "sticky top-0 z-50 bg-white/80 dark:bg-gray-900/80 backdrop-blur border-b", style: "border-color: rgb(var(--t-fg) / 0.06)" do
      content_tag :div, class: "container-app h-16 flex items-center gap-3 justify-between" do
        safe_join([
          content_tag(:div, class: "flex items-center gap-3 min-w-0") do
            safe_join([
              content_tag(:button, class: "inline-flex items-center justify-center size-9 rounded-lg hover:bg-gray-100 dark:hover:bg-white/5 lg:hidden", data: { action: "click->sidebar#open" }) do
                content_tag(:span, "Menu", class: "sr-only") + content_tag(:span, "", class: "size-5 rounded bg-gray-400")
              end,
              content_tag(:div, class: "flex items-center gap-3 min-w-0") do
                safe_join([
                  content_tag(:div, class: "hidden sm:block text-gray-500 text-sm truncate") do
                    safe_join(render_breadcrumbs_inline)
                  end,
                  content_tag(:div, (@title || ""), class: "text-xl md:text-2xl font-semibold tracking-tight truncate")
                ])
              end
            ])
          end,
          content_tag(:div, class: "flex items-center gap-3") do
            safe_join([
              content_tag(:div, class: "relative hidden sm:block") do
                content_tag(:span, "", class: "pointer-events-none absolute inset-y-0 left-0 grid place-items-center w-9 text-gray-400") +
                tag.input(type: :search, placeholder: "Buscar...", class: "h-9 rounded-lg border pl-9 pr-3 text-sm", style: "border-color: rgb(var(--t-fg) / 0.12); background: var(--color-surface)")
              end,
              user_dropdown
            ])
          end
        ])
      end
    end
  end

  private

  def render_breadcrumbs_inline
    return [] if @breadcrumbs.blank?
    @breadcrumbs.map.with_index do |crumb, idx|
      is_last = idx == @breadcrumbs.length - 1
      label = crumb[:label] || crumb[0]
      path = crumb[:path] || crumb[1]
      if is_last || path.blank?
        content_tag(:span, label, class: "text-gray-500", aria: { current: "page" })
      else
        safe_join([
          link_to(label, path, class: "text-gray-500 hover:underline"),
          content_tag(:span, "›", class: "px-1 text-gray-400")
        ])
      end
    end
  end

  def user_dropdown
    content_tag(:div, class: "relative", data: { controller: "menu" }) do
      content_tag(:button, class: "inline-flex items-center gap-2 rounded-lg px-2.5 py-1.5 hover:bg-gray-100 dark:hover:bg-white/5", aria: { haspopup: "menu", expanded: "false" }, data: { action: "click->menu#toggle" }) do
        avatar = content_tag(:div, (initials_for(@current_professional&.try(:full_name)) || "US"), class: "h-8 w-8 rounded-full grid place-content-center bg-brand-50 text-brand-600 text-sm font-medium relative")
        text_block = content_tag(:div, class: "hidden lg:flex flex-col items-start leading-tight") do
          content_tag(:span, (@current_professional&.try(:full_name) || "Usuário"), class: "text-sm font-semibold text-fg") +
          content_tag(:span, (@current_professional&.try(:email) || ""), class: "text-xs text-gray-500")
        end
        avatar + text_block
      end +
      content_tag(:div, class: "absolute right-0 mt-2 w-56 rounded-xl border bg-white dark:bg-gray-800 shadow-xl hidden", data: { menu_target: "panel" }, style: "border-color: rgb(var(--t-fg) / 0.06)") do
        safe_join([
          link_to("Meu Perfil", "#", class: "block px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-white/5"),
          link_to("Sair", "/users/sign_out", data: { turbo_method: :delete }, class: "block px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-white/5")
        ])
      end
    end
  end

  def initials_for(name)
    return "US" if name.blank?
    name.split(/\s+/).first(2).map { |s| s[0] }.join.upcase
  end
end

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
