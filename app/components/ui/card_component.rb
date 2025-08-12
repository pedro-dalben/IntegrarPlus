class Ui::CardComponent < ViewComponent::Base
  def initialize(title: nil, actions: nil)
    @title = title
    @actions = actions
  end

  def call
    content_tag :div, class: "rounded-xl border p-5", style: "border-color: rgb(var(--t-fg) / 0.06); background: var(--color-surface)" do
      safe_join([
        header,
        content
      ].compact)
    end
  end

  private

  def header
    return nil if @title.blank? && @actions.blank?
    content_tag :div, class: "flex items-center justify-between mb-4" do
      safe_join([
        (@title.present? ? content_tag(:h3, @title, class: "text-lg font-semibold") : nil),
        (@actions.present? ? content_tag(:div, @actions, class: "flex items-center gap-2") : nil)
      ].compact)
    end
  end
end
