import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["userSelect", "groupSelect"]

  connect() {
    console.log('🔗 Permissions controller connected')
    console.log('User select target:', this.hasUserSelectTarget)
    console.log('Group select target:', this.hasGroupSelectTarget)
    
    // Aguardar um pouco para o Tom Select inicializar
    setTimeout(() => {
      this.toggleGranteeType()
    }, 200)
  }

  toggleGranteeType() {
    console.log('🔄 toggleGranteeType called')
    const granteeTypeSelect = this.element.querySelector('select[name="grantee_type"]')
    
    if (!granteeTypeSelect) {
      console.log('❌ Grantee type select not found')
      return
    }
    
    const granteeType = granteeTypeSelect.value
    console.log('📋 Grantee type:', granteeType)

    if (granteeType === 'user') {
      console.log('👤 Showing user select')
      this.userSelectTarget.style.display = 'block'
      this.groupSelectTarget.style.display = 'none'
    } else if (granteeType === 'group') {
      console.log('👥 Showing group select')
      this.userSelectTarget.style.display = 'none'
      this.groupSelectTarget.style.display = 'block'
    }
    
    console.log('✅ Toggle completed')
  }
}
