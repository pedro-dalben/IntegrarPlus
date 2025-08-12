class Ui::FormFieldComponent < ViewComponent::Base
  def initialize(label:, hint: nil, error: nil)
    @label = label
    @hint = hint
    @error = error
  end

  def call
    content_tag :div, class: "space-y-1" do
      safe_join([
        content_tag(:label, @label, class: "block text-sm"),
        content,
        (@hint.present? ? content_tag(:p, @hint, class: "text-xs text-gray-500") : nil),
        (@error.present? ? content_tag(:p, @error, class: "text-xs text-red-600") : nil)
      ].compact)
    end
  end
end
