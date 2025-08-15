# frozen_string_literal: true

module Ui
  class AvatarUploadComponent < ViewComponent::Base
    def initialize(user:, size: 'md')
      @user = user
      @size = size
    end

    def call
      content_tag :div, class: 'avatar-upload' do
        safe_join([
                    avatar_display,
                    upload_form
                  ])
      end
    end

    private

    def avatar_display
      content_tag :div, class: "avatar-display #{size_classes}" do
        if @user.avatar.attached?
          helpers.image_tag(@user.avatar, alt: 'Avatar', class: 'rounded-full object-cover')
        else
          content_tag(:div, initials_for(@user.full_name),
                      class: 'rounded-full bg-blue-500 text-white flex items-center justify-center font-medium')
        end
      end
    end

    def upload_form
      content_tag :form,
                  action: avatar_path,
                  method: 'patch',
                  enctype: 'multipart/form-data',
                  class: 'upload-form',
                  data: { turbo: true } do
        safe_join([
                    content_tag(:input, '',
                                type: 'file',
                                name: 'user[avatar]',
                                accept: 'image/*',
                                class: 'hidden',
                                id: 'avatar-input',
                                data: { action: 'change->avatar#upload' }),
                    content_tag(:label, 'Alterar Avatar',
                                for: 'avatar-input',
                                class: 'cursor-pointer text-sm text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300')
                  ])
      end
    end

    def size_classes
      case @size
      when 'sm' then 'w-8 h-8'
      when 'md' then 'w-12 h-12'
      when 'lg' then 'w-16 h-16'
      when 'xl' then 'w-20 h-20'
      else 'w-12 h-12'
      end
    end

    def initials_for(name)
      return 'US' if name.blank?

      name.split(/\s+/).first(2).pluck(0).join.upcase
    end
  end
end
