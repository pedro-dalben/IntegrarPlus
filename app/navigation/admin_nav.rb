module AdminNav
  module_function

  def items
    [
      { label: "Dashboard", path: "/admin", icon: "bi-speedometer2", required_permission: "dashboard.view" },
      { label: "Profissionais", path: "/admin/professionals", icon: "bi-people", required_permission: "professionals.read" },
      { label: "Grupos", path: "/admin/groups", icon: "bi-collection", required_permission: "groups.manage" },
      { label: "Formas de Contratação", path: "/admin/contract_types", icon: "bi-briefcase", required_permission: "settings.read" },
      { label: "Especialidades", path: "/admin/specialities", icon: "bi-clipboard2-pulse", required_permission: "settings.read" },
      { label: "Especializações", path: "/admin/specializations", icon: "bi-award", required_permission: "settings.read" },
      { label: "Catálogo de UI", path: "/admin/ui", icon: "bi-layers", required_permission: "settings.read" }
    ]
  end
end
