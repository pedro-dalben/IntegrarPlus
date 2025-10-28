module Ui
  class LoadingSpinnerComponent < ViewComponent::Base
    def initialize(size: :medium, color: :primary, fixed: false)
      @size = size
      @color = color
      @fixed = fixed
    end

    private

    def spinner_classes
      base = "animate-spin rounded-full border-t-2 border-b-2"
      size_class = size_classes
      color_class = color_classes
      
      "#{base} #{size_class} #{color_class}"
    end

    def size_classes
      case @size
      when :small then "h-4 w-4"
      when :medium then "h-8 w-8"
      when :large then "h-12 w-12"
      when :xlarge then "h-16 w-16"
      else "h-8 w-8"
      end
    end

    def color_classes
      case @color
      when :primary then "border-brand-600"
      when :white then "border-white"
      when :gray then "border-gray-600"
      else "border-brand-600"
      end
    end

    def container_classes
      classes = ["flex items-center justify-center"]
      classes << "fixed inset-0 z-50 bg-black bg-opacity-25" if @fixed
      classes.join(" ")
    end
  end
end

