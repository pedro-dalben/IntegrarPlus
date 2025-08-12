class Layouts::AuthComponent < ViewComponent::Base
  def initialize(title: "Entrar")
    @title = title
  end

  def call
    content_tag :div, class: "min-h-screen grid place-items-center bg-gray-50 dark:bg-gray-900" do
      content_tag :div, class: "w-full max-w-md bg-white dark:bg-gray-800 rounded-2xl border p-8", style: "border-color: rgb(var(--t-fg) / 0.06)" do
        safe_join([
          content_tag(:div, class: "flex items-center justify-center mb-6") do
            content_tag(:span, "IP", class: "size-10 grid place-content-center rounded-xl text-white", style: "background: var(--color-brand-600)")
          end,
          content_tag(:h1, @title, class: "text-center text-2xl font-semibold mb-2"),
          content
        ])
      end
    end
  end
end


