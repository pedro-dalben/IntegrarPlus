# frozen_string_literal: true

class TabAccessService
  def self.user_can_access_tab?(user, resource, tab_key, action)
    return true if user.respond_to?(:admin?) && user.admin?

    has_relation = user_related_to_resource?(user, resource, tab_key)
    has_permission = user.respond_to?(:permit?) && user.permit?(permission_key(tab_key, action))

    has_relation && has_permission
  end

  def self.user_related_to_resource?(user, resource, _tab_key)
    return true if user.respond_to?(:admin?) && user.admin?
    return true unless resource.is_a?(Beneficiary)
    return false unless user.respond_to?(:professional) && user.professional.present?

    if resource.respond_to?(:professionals)
      resource.professionals.exists?(id: user.professional.id)
    else
      true
    end
  end

  def self.permission_key(tab_key, action)
    "beneficiary.tabs.#{tab_key}.#{action}"
  end
end
