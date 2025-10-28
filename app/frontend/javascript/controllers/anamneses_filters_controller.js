import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  async openModal() {
    
    // Obter dados dos profissionais
    const professionals = await this.getProfessionals()
    
    // Criar modal dinamicamente com todos os filtros
    const modalHtml = `
      <div id="dynamic-anamneses-filters-modal" 
           style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 99999; background: rgba(0, 0, 0, 0.5); display: flex; align-items: center; justify-content: center; padding: 20px;">
        <div style="background: white; border-radius: 24px; padding: 24px; max-width: 800px; width: 100%; max-height: 90%; overflow-y: auto; position: relative;">
          <button onclick="this.closest('#dynamic-anamneses-filters-modal').remove()" 
                  style="position: absolute; right: 12px; top: 12px; background: #f3f4f6; border: none; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; cursor: pointer;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M6.04289 16.5413C5.65237 16.9318 5.65237 17.565 6.04289 17.9555C6.43342 18.346 7.06658 18.346 7.45711 17.9555L11.9987 13.4139L16.5408 17.956C16.9313 18.3466 17.5645 18.3466 17.955 17.956C18.3455 17.5655 18.3455 16.9323 17.955 16.5418L13.4129 11.9997L17.955 7.4576C18.3455 7.06707 18.3455 6.43391 17.955 6.04338C17.5645 5.65286 16.9313 5.65286 16.5408 6.04338L11.9987 10.5855L7.45711 6.0439C7.06658 5.65338 6.43342 5.65338 6.04289 6.0439C5.65237 6.43442 5.65237 7.06759 6.04289 7.45811L10.5845 11.9997L6.04289 16.5413Z" fill="#6B7280"/>
            </svg>
          </button>
          
          <h4 style="font-size: 18px; font-weight: 600; color: #1f2937; margin-bottom: 24px;">Filtros Avançados</h4>
          
          <form id="filters-form" style="display: flex; flex-direction: column; gap: 20px;">
            
            <!-- Linha 1: Status e Profissional -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
              <div>
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Status</label>
                <select name="status" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
                  <option value="">Todas</option>
                  <option value="pendente">Pendentes</option>
                  <option value="em_andamento">Em Andamento</option>
                  <option value="concluida">Concluídas</option>
                </select>
              </div>
              
              <div>
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Profissional</label>
                <select name="professional_id" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
                  <option value="">Todos os profissionais</option>
                  ${professionals.map(p => `<option value="${p.id}">${p.name}</option>`).join('')}
                </select>
              </div>
            </div>

            <!-- Linha 2: Motivo de Encaminhamento e Local de Tratamento -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
              <div>
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Motivo de Encaminhamento</label>
                <select name="referral_reason" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
                  <option value="">Todos</option>
                  <option value="aba">ABA</option>
                  <option value="equipe_multi">Equipe Multi</option>
                  <option value="aba_equipe_multi">ABA + Equipe Multi</option>
                </select>
              </div>
              
              <div>
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Local de Tratamento</label>
                <select name="treatment_location" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
                  <option value="">Todos</option>
                  <option value="domiciliar">Domiciliar</option>
                  <option value="clinica">Clínica</option>
                  <option value="domiciliar_clinica">Domiciliar + Clínica</option>
                  <option value="domiciliar_escola">Domiciliar + Escola</option>
                  <option value="domiciliar_clinica_escola">Domiciliar + Clínica + Escola</option>
                </select>
              </div>
            </div>

            <!-- Linha 3: Período -->
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px;">
              <div>
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Período</label>
                <select name="period" id="period-select" onchange="window.toggleDateInputs()" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
                  <option value="">Todos os períodos</option>
                  <option value="today">Hoje</option>
                  <option value="this_week">Esta semana</option>
                  <option value="this_month">Este mês</option>
                  <option value="last_7_days">Últimos 7 dias</option>
                  <option value="last_30_days">Últimos 30 dias</option>
                </select>
              </div>
              
              <div id="start-date-container">
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Data Inicial</label>
                <input type="date" name="start_date" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
              </div>
              
              <div id="end-date-container">
                <label style="display: block; margin-bottom: 6px; font-size: 14px; font-weight: 500; color: #374151;">Data Final</label>
                <input type="date" name="end_date" style="width: 100%; padding: 8px 12px; border: 1px solid #d1d5db; border-radius: 8px; background: white; font-size: 14px;">
              </div>
            </div>

            <!-- Opções Adicionais -->
            <div style="display: flex; align-items: center; gap: 8px;">
              <input type="checkbox" name="include_concluidas" value="true" style="width: 16px; height: 16px;">
              <label style="font-size: 14px; color: #374151;">Incluir anamneses concluídas</label>
            </div>

            <!-- Botões -->
            <div style="display: flex; gap: 12px; justify-content: flex-end; margin-top: 20px;">
              <button type="button" onclick="this.closest('#dynamic-anamneses-filters-modal').remove()" 
                      style="padding: 8px 16px; border: 1px solid #d1d5db; border-radius: 8px; background: white; color: #374151; cursor: pointer; font-size: 14px;">
                Cancelar
              </button>
              <button type="submit" 
                      style="padding: 8px 16px; border: none; border-radius: 8px; background: #3b82f6; color: white; cursor: pointer; font-size: 14px;">
                Aplicar Filtros
              </button>
            </div>
          </form>
        </div>
      </div>
    `
    
    // Adicionar ao body
    document.body.insertAdjacentHTML('beforeend', modalHtml)
    
    // Adicionar event listener para fechar no backdrop
    const modal = document.getElementById('dynamic-anamneses-filters-modal')
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.remove()
      }
    })
    
    // Adicionar event listener para o formulário
    const form = document.getElementById('filters-form')
    form.addEventListener('submit', (e) => {
      e.preventDefault()
      this.applyFilters(form)
      modal.remove()
    })
    
    // Carregar valores atuais dos filtros
    this.loadCurrentFilters(form)
    
    // Tornar a função toggleDateInputs global
    window.toggleDateInputs = () => this.toggleDateInputs()
    
  }

  async getProfessionals() {
    try {
      const response = await fetch('/admin/anamneses/professionals.json')
      const data = await response.json()
      return data.professionals || []
    } catch (error) {
      console.error('Erro ao carregar profissionais:', error)
      // Fallback para dados simulados
      return [
        { id: 1, name: 'Administrador do Sistema' },
        { id: 2, name: 'Dr. Teste' },
        { id: 3, name: 'Dr. Teste Anamnese' }
      ]
    }
  }

  loadCurrentFilters(form) {
    // Carregar parâmetros atuais da URL
    const urlParams = new URLSearchParams(window.location.search)
    
    // Status
    if (urlParams.get('status')) {
      form.querySelector('[name="status"]').value = urlParams.get('status')
    }
    
    // Profissional
    if (urlParams.get('professional_id')) {
      form.querySelector('[name="professional_id"]').value = urlParams.get('professional_id')
    }
    
    // Motivo de Encaminhamento
    if (urlParams.get('referral_reason')) {
      form.querySelector('[name="referral_reason"]').value = urlParams.get('referral_reason')
    }
    
    // Local de Tratamento
    if (urlParams.get('treatment_location')) {
      form.querySelector('[name="treatment_location"]').value = urlParams.get('treatment_location')
    }
    
    // Período
    if (urlParams.get('period')) {
      form.querySelector('[name="period"]').value = urlParams.get('period')
      this.toggleDateInputs()
    }
    
    // Datas
    if (urlParams.get('start_date')) {
      form.querySelector('[name="start_date"]').value = urlParams.get('start_date')
    }
    if (urlParams.get('end_date')) {
      form.querySelector('[name="end_date"]').value = urlParams.get('end_date')
    }
    
    // Incluir Concluídas
    if (urlParams.get('include_concluidas') === 'true') {
      form.querySelector('[name="include_concluidas"]').checked = true
    }
  }

  toggleDateInputs() {
    const periodSelect = document.getElementById('period-select')
    const startDateContainer = document.getElementById('start-date-container')
    const endDateContainer = document.getElementById('end-date-container')
    
    if (periodSelect && startDateContainer && endDateContainer) {
      if (periodSelect.value) {
        startDateContainer.style.display = 'none'
        endDateContainer.style.display = 'none'
      } else {
        startDateContainer.style.display = 'block'
        endDateContainer.style.display = 'block'
      }
    }
  }

  applyFilters(form) {
    const formData = new FormData(form)
    const params = new URLSearchParams()
    
    // Adicionar todos os filtros não vazios
    for (const [key, value] of formData.entries()) {
      if (value && value.trim() !== '') {
        params.append(key, value)
      }
    }
    
    // Manter query de busca se existir
    const currentParams = new URLSearchParams(window.location.search)
    if (currentParams.get('query')) {
      params.append('query', currentParams.get('query'))
    }
    
    // Redirecionar com os novos filtros
    const newUrl = `${window.location.pathname}?${params.toString()}`
    window.location.href = newUrl
  }
}