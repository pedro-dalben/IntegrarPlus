class Ui::ButtonComponent < ViewComponent::Base
  def initialize(label: nil, href: nil, variant: :primary, size: :md, icon: nil, icon_right: false, disabled: false, data: {})
    @label = label
    @href = href
    @variant = variant.to_sym
    @size = size.to_sym
    @icon = icon
    @icon_right = icon_right
    @disabled = disabled
    @data = data
  end

  def call
    content = safe_join([ icon_html, label_html ].compact)
    content = safe_join([ label_html, icon_html ].compact) if @icon_right
    if @href.present? && !@disabled
      link_to @href, class: classes, data: @data do
        content
      end
    else
      tag.button content, type: :button, class: classes, disabled: @disabled, data: @data
    end
  end

  private

  def classes
    [
      "inline-flex items-center gap-2 rounded-lg font-medium transition focus:outline-none",
      size_classes,
      variant_classes,
      (@disabled ? "opacity-60 cursor-not-allowed" : nil)
    ].compact.join(" ")
  end

  def size_classes
    case @size
    when :sm then "px-2.5 py-1.5 text-sm"
    when :lg then "px-4.5 py-3 text-base"
    else "px-3.5 py-2.5 text-sm"
    end
  end

  def variant_classes
    case @variant
    when :secondary
      "border text-fg" + inline_border + inline_bg_surface
    when :outline
      "border text-brand-600" + inline_border_brand + " bg-transparent"
    when :ghost
      "text-brand-600 hover:bg-brand-50"
    when :danger
      "text-white" + inline_bg("--color-error-600")
    when :link
      "text-brand-600 hover:underline px-0 py-0"
    else
      "text-white" + inline_bg("--color-brand-600")
    end
  end

  def inline_bg(var)
    " " + %(style="background-color: var(#{var});")
  end

  def inline_bg_surface
    %( bg-white dark:bg-gray-800)
  end

  def inline_border
    %( ) + %(style="border-color: rgb(var(--t-fg) / 0.12)")
  end

  def inline_border_brand
    %( ) + %(style="border-color: var(--color-brand-600)")
  end

  def icon_html
    return nil if @icon.blank?
    content_tag(:i, "", class: [ "bi", @icon ].join(" "))
  end

  def label_html
    return content unless @label.present?
    content_tag(:span, @label)
  end
end
