class Layouts::FooterComponent < ViewComponent::Base
  def call
    content_tag :footer, class: "mt-10 border-t", style: "border-color: rgb(var(--t-fg) / 0.06)" do
      content_tag :div, class: "container-app py-6 text-sm text-gray-500 flex items-center justify-between" do
        safe_join([
          content_tag(:span, "IntegrarPlus © #{Time.current.year}"),
          content_tag(:div, class: "flex items-center gap-4") do
            safe_join([
              link_to("Privacidade", "#", class: "hover:underline"),
              link_to("Termos", "#", class: "hover:underline")
            ])
          end
        ])
      end
    end
  end
end
