class Layouts::AdminComponent < ViewComponent::Base
  include ApplicationHelper
  renders_one :actions

  def initialize(title:, breadcrumbs: nil, hide_sidebar: false)
    @title = title
    @breadcrumbs = breadcrumbs || []
    @hide_sidebar = hide_sidebar
  end

  def call
    content_tag :div, class: "min-h-screen bg-bg text-fg" do
      safe_join([
        render(Layouts::TopbarComponent.new(current_professional: current_user, title: @title, breadcrumbs: @breadcrumbs)),
        content_tag(:div, class: "flex") do
          sidebar_html = @hide_sidebar ? nil : render(Layouts::SidebarComponent.new(current_professional: current_user))
          main_html = content_tag(:main, class: "flex-1 container-app py-6") do
            safe_join([
              render_flash,
              render_breadcrumbs,
              content_tag(:div, class: "flex items-center justify-between mb-6") do
                safe_join([
                  content_tag(:h1, @title, class: "text-2xl sm:text-3xl font-semibold"),
                  (actions ? content_tag(:div, actions, class: "flex items-center gap-2") : "")
                ])
              end,
              content
            ])
          end
          safe_join([ sidebar_html, main_html ].compact)
        end,
        render(Layouts::FooterComponent.new)
      ])
    end
  end

  private

  def render_flash
    return "" if flash.empty?
    content_tag :div, class: "space-y-2 mb-4" do
      flash.map do |type, message|
        color = case type.to_s
        when "notice", "success" then "success"
        when "alert", "danger" then "danger"
        when "warning" then "warning"
        else "info"
        end
        content_tag(:div, class: "p-3 rounded-md bg-#{color} text-white") { message }
      end.join.html_safe
    end
  end

  def render_breadcrumbs
    return "" if @breadcrumbs.blank?
    content_tag :nav, aria: { label: "Breadcrumb" }, class: "mb-4" do
      content_tag :ol, class: "flex flex-wrap items-center gap-2 text-sm text-muted" do
        safe_join(
          @breadcrumbs.map.with_index do |crumb, idx|
            is_last = idx == @breadcrumbs.length - 1
            label = crumb[:label] || crumb[0]
            path = crumb[:path] || crumb[1]
            if is_last || path.blank?
              content_tag(:li, label, class: "text-fg")
            else
              content_tag(:li) do
                link_to(label, path, class: "hover:underline")
              end
            end
          end
        )
      end
    end
  end
end
