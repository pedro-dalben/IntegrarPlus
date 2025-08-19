import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "row"];

  connect() {
    this.filter = this.filter.bind(this);
  }

  filter() {
    const searchTerm = this.inputTarget.value.toLowerCase();
    
    this.rowTargets.forEach(row => {
      const text = row.textContent.toLowerCase();
      if (text.includes(searchTerm)) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }
}
