class Layouts::SidebarComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(current_professional: nil)
    @current_professional = current_professional
  end

  def call
    content_tag :aside, class: "hidden lg:block w-64 flex-shrink-0 border-r bg-white dark:bg-gray-800", role: "navigation", aria: { label: "Admin navigation" }, style: "border-color: rgb(var(--t-fg) / 0.06)" do
      content_tag :nav, class: "p-3 space-y-1.5" do
        safe_join([
          content_tag(:div, "MENU", class: "px-2 pt-2 pb-1 text-[11px] uppercase tracking-wider text-gray-400 dark:text-gray-500"),
          safe_join(admin_items.map { |item| render_entry(item) })
        ])
      end
    end +
    content_tag(:div, class: "lg:hidden", data: { controller: "sidebar" }) do
      content_tag :div, class: "fixed inset-0 z-40 hidden", data: { sidebar_target: "overlay", action: "click->sidebar#close" } do
        content_tag(:div, "", class: "absolute inset-0 bg-black/50")
      end +
      content_tag(:div, class: "fixed inset-y-0 left-0 z-50 w-64 translate-x-[-100%] transition-transform bg-white dark:bg-gray-800 border-r", data: { sidebar_target: "panel" }, style: "border-color: rgb(var(--t-fg) / 0.06)") do
        content_tag :nav, class: "p-3 space-y-1.5" do
          safe_join([
            content_tag(:div, "MENU", class: "px-2 pt-2 pb-1 text-[11px] uppercase tracking-wider text-gray-400 dark:text-gray-500"),
            safe_join(admin_items.map { |item| render_entry(item) })
          ])
        end
      end
    end
  end

  private

  def admin_items
    items = AdminNav.items
    items.select { |i| permit?(i[:required_permission]) }
  end

  def current_path
    helpers.request.fullpath
  end

  def render_item(item)
    active = current_path.start_with?(item[:path])
    link_classes = [
      "menu-item group",
      active ? "menu-item-active" : "menu-item-inactive"
    ].join(" ")
    link_to item[:path], class: link_classes, data: { turbo: true } do
      safe_join([
        content_tag(:span, "", class: "size-4 rounded-sm bg-gray-400"),
        content_tag(:span, item[:label], class: "text-theme-sm")
      ])
    end
  end

  def render_entry(item)
    return render_group(item) if item[:children].present?
    render_item(item)
  end

  def render_group(item)
    header = content_tag(:button, class: "menu-item group w-full text-left", data: { controller: "accordion", action: "click->accordion#toggle" }, aria: { expanded: "false" }) do
      safe_join([
        content_tag(:span, "", class: "size-4 rounded-sm bg-gray-400"),
        content_tag(:span, item[:label], class: "text-theme-sm flex-1"),
        content_tag(:svg, content_tag(:path, "", d: "M5.9 11.4L.5 6l1.4-1.4 4 4 4-4L11.3 6z"), class: "w-3 h-3 menu-item-arrow", data: { accordion_target: "icon" })
      ])
    end
    children = content_tag(:div, class: "mt-1 space-y-1 pl-6 hidden", data: { accordion_target: "panel" }) do
      safe_join(item[:children].map { |c| render_item(c) })
    end
    safe_join([ header, children ])
  end
end
