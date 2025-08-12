class Layouts::SidebarComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(current_professional: nil)
    @current_professional = current_professional
  end

  def call
    content_tag :aside, class: "hidden lg:block w-64 flex-shrink-0 border-r bg-white dark:bg-gray-800", role: "navigation", aria: { label: "Admin navigation" }, style: "border-color: rgb(var(--t-fg) / 0.06)" do
      content_tag :nav, class: "p-4" do
        safe_join(admin_items.map { |item| render_item(item) })
      end
    end +
    content_tag(:div, class: "lg:hidden") do
      content_tag :div, class: "fixed inset-0 z-40 hidden", data: { sidebar_target: "overlay" } do
        content_tag(:div, "", class: "absolute inset-0 bg-gray-900/50")
      end +
      content_tag(:div, class: "fixed inset-y-0 left-0 z-50 w-64 translate-x-[-100%] transition-transform bg-white dark:bg-gray-800 border-r", data: { sidebar_target: "panel" }, style: "border-color: rgb(var(--t-fg) / 0.06)") do
        content_tag :nav, class: "p-4" do
          safe_join(admin_items.map { |item| render_item(item) })
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
      "flex items-center gap-3 rounded-md px-3 py-2 text-sm",
      active ? "bg-gray-100 dark:bg-neutral-800 text-fg" : "hover:bg-gray-100 dark:hover:bg-neutral-800 text-muted"
    ].join(" ")
    link_to item[:path], class: link_classes, data: { turbo: true } do
      safe_join([
        content_tag(:span, "", class: "size-4 rounded-sm bg-gray-400"),
        content_tag(:span, item[:label])
      ])
    end
  end
end
