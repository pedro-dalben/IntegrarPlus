import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['container', 'template'];
  static values = { index: Number };

  add(event) {
    event.preventDefault();
  }

  remove(event) {
    event.preventDefault();
  }
}
