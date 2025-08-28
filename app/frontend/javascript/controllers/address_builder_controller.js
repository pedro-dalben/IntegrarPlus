import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rua", "numero", "bairro", "cidade", "cep", "endereco"]

  connect() {
    this.updateEndereco()
  }

  updateEndereco() {
    const rua = this.ruaTarget.value
    const numero = this.numeroTarget.value
    const bairro = this.bairroTarget.value
    const cidade = this.cidadeTarget.value
    const cep = this.cepTarget.value

    if (rua && numero && bairro && cidade && cep) {
      const enderecoCompleto = `${rua}, ${numero} - ${bairro}, ${cidade} - CEP: ${cep}`
      this.enderecoTarget.value = enderecoCompleto
    }
  }
}
