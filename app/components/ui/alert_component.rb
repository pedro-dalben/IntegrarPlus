class Ui::AlertComponent < ViewComponent::Base
  def initialize(kind: :info, title: nil, dismissible: false)
    @kind = kind.to_sym
    @title = title
    @dismissible = dismissible
  end

  def call
    content_tag :div, class: classes, role: "alert" do
      safe_join([
        (@title.present? ? content_tag(:div, @title, class: "font-medium mb-1") : nil),
        content
      ].compact)
    end
  end

  private

  def classes
    base = "rounded-lg p-3 text-sm"
    case @kind
    when :success then base + " text-green-700 bg-green-50"
    when :warning then base + " text-yellow-700 bg-yellow-50"
    when :danger  then base + " text-red-700 bg-red-50"
    else base + " text-brand-700" + %( ) + %(style="background-color: var(--color-brand-50);")
    end
  end
end
