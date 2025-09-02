import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['specialitySelect', 'specializationSelect'];
  static values = { endpoint: String };

  connect() {
    console.log('DependentSpecializationsController conectado');
    console.log('Targets disponíveis:', {
      hasSpecialitySelect: this.hasSpecialitySelectTarget,
      hasSpecializationSelect: this.hasSpecializationSelectTarget
    });
    
    if (!this.hasSpecialitySelectTarget || !this.hasSpecializationSelectTarget) {
      console.error('Targets não encontrados');
      return;
    }
    
    console.log('Targets encontrados com sucesso');
    this.setupEventListeners();
  }

  setupEventListeners() {
    console.log('Configurando event listeners');
    
    // Usar eventos nativos do select para debug
    this.specialitySelectTarget.addEventListener('change', () => {
      console.log('Evento change nativo disparado');
      this.specialityChanged();
    });
    
    // Também tentar configurar listeners do Tom Select se disponível
    this.waitForTomSelectAndSetupListeners();
  }

  waitForTomSelectAndSetupListeners() {
    const maxAttempts = 20;
    let attempts = 0;
    
    const checkTomSelect = () => {
      attempts++;
      console.log(`Tentativa ${attempts} de configurar listeners do Tom Select`);
      
      const specialityTomSelect = this.specialitySelectTarget.tomselect;
      if (specialityTomSelect) {
        console.log('Tom Select encontrado, configurando listeners');
        
        specialityTomSelect.on('change', () => {
          console.log('Tom Select change event disparado');
          this.specialityChanged();
        });
        
        specialityTomSelect.on('item_add', () => {
          console.log('Item adicionado ao Tom Select');
          this.specialityChanged();
        });
        
        specialityTomSelect.on('item_remove', () => {
          console.log('Item removido do Tom Select');
          this.specialityChanged();
        });
        
        console.log('Listeners do Tom Select configurados com sucesso');
      } else if (attempts < maxAttempts) {
        console.log('Tom Select ainda não inicializado, aguardando...');
        setTimeout(checkTomSelect, 100);
      } else {
        console.warn('Tom Select não foi inicializado após várias tentativas');
      }
    };
    
    checkTomSelect();
  }

  specialityChanged() {
    console.log('Especialidades alteradas, carregando especializações...');
    this.loadSpecializations();
  }

  async loadSpecializations() {
    console.log('Iniciando loadSpecializations');
    
    if (!this.hasSpecialitySelectTarget || !this.hasSpecializationSelectTarget) {
      console.error('Targets não encontrados durante loadSpecializations');
      return;
    }

    const specialityIds = Array.from(this.specialitySelectTarget.selectedOptions).map(
      option => option.value
    );

    console.log('IDs das especialidades selecionadas:', specialityIds);

    if (specialityIds.length === 0) {
      console.log('Nenhuma especialidade selecionada, limpando especializações');
      this.specializationSelectTarget.innerHTML =
        '<option value="">Selecione as especializações...</option>';
      this.reinitializeTomSelect();
      return;
    }

    try {
      const url = new URL('/admin/specializations/by_speciality', window.location.origin);
      specialityIds.forEach(id => url.searchParams.append('speciality_ids[]', id));

      console.log('Fazendo requisição para:', url.toString());

      const response = await fetch(url.toString());

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('Dados recebidos:', data);

      // Limpar opções existentes
      this.specializationSelectTarget.innerHTML = '';
      
      // Adicionar opção padrão
      const defaultOption = document.createElement('option');
      defaultOption.value = '';
      defaultOption.textContent = 'Selecione as especializações...';
      this.specializationSelectTarget.appendChild(defaultOption);

      // Adicionar novas opções
      data.forEach(specialization => {
        const option = document.createElement('option');
        option.value = specialization.id;
        option.textContent = `${specialization.name} (${specialization.speciality_name})`;
        this.specializationSelectTarget.appendChild(option);
      });

      console.log(`Opções atualizadas: ${data.length} especializações adicionadas`);
      console.log('Re-inicializando Tom Select...');
      this.reinitializeTomSelect();
    } catch (error) {
      console.error('Erro ao carregar especializações:', error);
      this.specializationSelectTarget.innerHTML =
        '<option value="">Erro ao carregar especializações</option>';
      this.reinitializeTomSelect();
    }
  }

  reinitializeTomSelect() {
    const tomSelectInstance = this.specializationSelectTarget.tomselect;
    if (tomSelectInstance) {
      console.log('Re-inicializando Tom Select');
      
      // Limpar seleções atuais
      tomSelectInstance.clear();
      
      // Atualizar opções disponíveis
      tomSelectInstance.clearOptions();
      
      // Adicionar opção padrão
      tomSelectInstance.addOption({
        value: '',
        text: 'Selecione as especializações...'
      });
      
      // Adicionar todas as opções do select
      const options = Array.from(this.specializationSelectTarget.options);
      options.forEach(option => {
        if (option.value !== '') {
          tomSelectInstance.addOption({
            value: option.value,
            text: option.textContent
          });
        }
      });
      
      // Forçar atualização da interface
      tomSelectInstance.refreshOptions();
      tomSelectInstance.refreshItems();
      
      console.log('Tom Select re-inicializado com sucesso');
    } else {
      console.warn('Tom Select instance não encontrada para especializações');
    }
  }

  disconnect() {
    console.log('Disconnect do controller');
    const specialityTomSelect = this.specialitySelectTarget.tomselect;
    if (specialityTomSelect) {
      specialityTomSelect.off('change');
      specialityTomSelect.off('item_add');
      specialityTomSelect.off('item_remove');
    }
  }
}
