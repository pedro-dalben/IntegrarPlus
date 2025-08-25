import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["userSelect", "groupSelect"]

  connect() {
    this.toggleGranteeType()
  }

  toggleGranteeType() {
    const granteeType = this.element.querySelector('select[name="grantee_type"]').value

    if (granteeType === 'user') {
      this.userSelectTarget.classList.remove('hidden')
      this.groupSelectTarget.classList.add('hidden')
    } else {
      this.userSelectTarget.classList.add('hidden')
      this.groupSelectTarget.classList.remove('hidden')
    }
  }
}
