class Ui::BadgeComponent < ViewComponent::Base
  def initialize(label:, tone: :brand)
    @label = label
    @tone = tone.to_sym
  end

  def call
    content_tag :span, @label, class: classes
  end

  private

  def classes
    base = "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium"
    tones = {
      brand: " text-brand-600" + %( ) + %(style="background-color: var(--color-brand-50);"),
      success: " text-green-700 bg-green-50",
      warning: " text-yellow-700 bg-yellow-50",
      danger: " text-red-700 bg-red-50",
      gray: " text-gray-700 bg-gray-100"
    }
    base + tones.fetch(@tone, tones[:brand])
  end
end
