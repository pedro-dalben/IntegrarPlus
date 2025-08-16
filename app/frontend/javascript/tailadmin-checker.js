// TailAdmin Pro JavaScript Checker
// Verifica se todos os componentes estão funcionando corretamente

class TailAdminChecker {
  constructor() {
    this.results = {
      alpine: false,
      tailwind: false,
      vite: false,
      images: false,
      header: false,
      sidebar: false,
      dropdowns: false,
      modals: false,
      charts: false,
      datepickers: false,
      tooltips: false,
      notifications: false
    };
    
    this.errors = [];
    this.warnings = [];
  }

  // Verifica se o Alpine.js está funcionando
  checkAlpine() {
    try {
      if (typeof window.Alpine !== 'undefined') {
        this.results.alpine = true;
        console.log('✅ Alpine.js está carregado');
      } else {
        this.errors.push('Alpine.js não está carregado');
        console.error('❌ Alpine.js não está carregado');
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar Alpine.js: ${error.message}`);
    }
  }

  // Verifica se o Tailwind CSS está funcionando
  checkTailwind() {
    try {
      const testElement = document.createElement('div');
      testElement.className = 'bg-blue-500 text-white p-4 rounded';
      testElement.style.position = 'absolute';
      testElement.style.left = '-9999px';
      testElement.textContent = 'Tailwind Test';
      document.body.appendChild(testElement);
      
      const computedStyle = window.getComputedStyle(testElement);
      const hasTailwind = computedStyle.backgroundColor !== 'rgba(0, 0, 0, 0)' || 
                         computedStyle.padding !== '0px' ||
                         computedStyle.borderRadius !== '0px';
      
      document.body.removeChild(testElement);
      
      if (hasTailwind) {
        this.results.tailwind = true;
        console.log('✅ Tailwind CSS está funcionando');
      } else {
        this.errors.push('Tailwind CSS não está funcionando');
        console.error('❌ Tailwind CSS não está funcionando');
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar Tailwind: ${error.message}`);
    }
  }

  // Verifica se o Vite está funcionando
  checkVite() {
    try {
      if (typeof import.meta !== 'undefined' && import.meta.env) {
        this.results.vite = true;
        console.log('✅ Vite está funcionando');
      } else {
        this.warnings.push('Vite pode não estar funcionando corretamente');
        console.warn('⚠️ Vite pode não estar funcionando corretamente');
      }
    } catch (error) {
      this.warnings.push(`Erro ao verificar Vite: ${error.message}`);
    }
  }

  // Verifica se as imagens estão carregando
  checkImages() {
    try {
      const logoImages = document.querySelectorAll('img[src*="logo"]');
      const userImages = document.querySelectorAll('img[src*="user"]');
      
      let loadedImages = 0;
      let totalImages = logoImages.length + userImages.length;
      
      if (totalImages === 0) {
        this.warnings.push('Nenhuma imagem encontrada para verificar');
        return;
      }

      const checkImage = (img) => {
        return new Promise((resolve) => {
          if (img.complete) {
            resolve(img.naturalWidth > 0);
          } else {
            img.onload = () => resolve(true);
            img.onerror = () => resolve(false);
          }
        });
      };

      Promise.all([...logoImages, ...userImages].map(checkImage)).then((results) => {
        loadedImages = results.filter(Boolean).length;
        
        if (loadedImages === totalImages) {
          this.results.images = true;
          console.log('✅ Todas as imagens estão carregando');
        } else {
          this.warnings.push(`${loadedImages}/${totalImages} imagens carregaram`);
          console.warn(`⚠️ ${loadedImages}/${totalImages} imagens carregaram`);
        }
      });
    } catch (error) {
      this.errors.push(`Erro ao verificar imagens: ${error.message}`);
    }
  }

  // Verifica se o header está funcionando
  checkHeader() {
    try {
      const header = document.querySelector('header');
      if (!header) {
        this.errors.push('Header não encontrado');
        return;
      }

      const hamburger = header.querySelector('button[class*="hamburger"], button[class*="menu"]');
      const logo = header.querySelector('img[src*="logo"]');
      const userDropdown = header.querySelector('[x-data*="dropdown"], [x-data*="menu"]');

      let headerScore = 0;
      if (hamburger) headerScore++;
      if (logo) headerScore++;
      if (userDropdown) headerScore++;

      if (headerScore >= 2) {
        this.results.header = true;
        console.log('✅ Header está presente e funcional');
      } else {
        this.warnings.push(`Header parcialmente funcional (${headerScore}/3 elementos)`);
        console.warn(`⚠️ Header parcialmente funcional (${headerScore}/3 elementos)`);
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar header: ${error.message}`);
    }
  }

  // Verifica se o sidebar está funcionando
  checkSidebar() {
    try {
      const sidebar = document.querySelector('aside, [class*="sidebar"]');
      if (sidebar) {
        this.results.sidebar = true;
        console.log('✅ Sidebar está presente');
      } else {
        this.warnings.push('Sidebar não encontrado');
        console.warn('⚠️ Sidebar não encontrado');
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar sidebar: ${error.message}`);
    }
  }

  // Verifica se os dropdowns estão funcionando
  checkDropdowns() {
    try {
      const dropdowns = document.querySelectorAll('[x-data*="dropdown"], [x-data*="menu"], [class*="dropdown"]');
      if (dropdowns.length > 0) {
        this.results.dropdowns = true;
        console.log(`✅ ${dropdowns.length} dropdown(s) encontrado(s)`);
      } else {
        this.warnings.push('Nenhum dropdown encontrado');
        console.warn('⚠️ Nenhum dropdown encontrado');
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar dropdowns: ${error.message}`);
    }
  }

  // Verifica se os modais estão funcionando
  checkModals() {
    try {
      const modals = document.querySelectorAll('[x-data*="modal"], [class*="modal"], [id*="modal"]');
      if (modals.length > 0) {
        this.results.modals = true;
        console.log(`✅ ${modals.length} modal(is) encontrado(s)`);
      } else {
        this.warnings.push('Nenhum modal encontrado');
        console.warn('⚠️ Nenhum modal encontrado');
      }
    } catch (error) {
      this.errors.push(`Erro ao verificar modals: ${error.message}`);
    }
  }

  // Verifica se os charts estão funcionando
  checkCharts() {
    try {
      if (typeof ApexCharts !== 'undefined' || typeof Chart !== 'undefined') {
        this.results.charts = true;
        console.log('✅ Charts (ApexCharts/Chart.js) estão disponíveis');
      } else {
        this.warnings.push('Charts não estão disponíveis');
        console.warn('⚠️ Charts não estão disponíveis');
      }
    } catch (error) {
      this.warnings.push(`Erro ao verificar charts: ${error.message}`);
    }
  }

  // Verifica se os datepickers estão funcionando
  checkDatepickers() {
    try {
      if (typeof flatpickr !== 'undefined') {
        this.results.datepickers = true;
        console.log('✅ Flatpickr está disponível');
      } else {
        this.warnings.push('Flatpickr não está disponível');
        console.warn('⚠️ Flatpickr não está disponível');
      }
    } catch (error) {
      this.warnings.push(`Erro ao verificar datepickers: ${error.message}`);
    }
  }

  // Verifica se os tooltips estão funcionando
  checkTooltips() {
    try {
      if (typeof tippy !== 'undefined' || typeof HSStaticMethods !== 'undefined') {
        this.results.tooltips = true;
        console.log('✅ Tooltips estão disponíveis');
      } else {
        this.warnings.push('Tooltips não estão disponíveis');
        console.warn('⚠️ Tooltips não estão disponíveis');
      }
    } catch (error) {
      this.warnings.push(`Erro ao verificar tooltips: ${error.message}`);
    }
  }

  // Verifica se as notificações estão funcionando
  checkNotifications() {
    try {
      const notifications = document.querySelectorAll('[class*="notification"], [class*="toast"], [class*="alert"]');
      if (notifications.length > 0) {
        this.results.notifications = true;
        console.log(`✅ ${notifications.length} notificação(ões) encontrada(s)`);
      } else {
        this.warnings.push('Nenhuma notificação encontrada');
        console.warn('⚠️ Nenhuma notificação encontrada');
      }
    } catch (error) {
      this.warnings.push(`Erro ao verificar notificações: ${error.message}`);
    }
  }

  // Executa todas as verificações
  async runAllChecks() {
    console.log('🔍 Iniciando verificação do TailAdmin Pro...');
    console.log('=' .repeat(50));

    this.checkAlpine();
    this.checkTailwind();
    this.checkVite();
    this.checkImages();
    this.checkHeader();
    this.checkSidebar();
    this.checkDropdowns();
    this.checkModals();
    this.checkCharts();
    this.checkDatepickers();
    this.checkTooltips();
    this.checkNotifications();

    // Aguarda um pouco para as imagens carregarem
    await new Promise(resolve => setTimeout(resolve, 1000));
    this.checkImages();

    this.generateReport();
  }

  // Gera relatório final
  generateReport() {
    console.log('=' .repeat(50));
    console.log('📊 RELATÓRIO FINAL DO TAILADMIN PRO');
    console.log('=' .repeat(50));

    const totalChecks = Object.keys(this.results).length;
    const passedChecks = Object.values(this.results).filter(Boolean).length;
    const successRate = Math.round((passedChecks / totalChecks) * 100);

    console.log(`✅ Testes aprovados: ${passedChecks}/${totalChecks} (${successRate}%)`);
    console.log('');

    // Mostra resultados detalhados
    Object.entries(this.results).forEach(([check, passed]) => {
      const status = passed ? '✅' : '❌';
      const name = check.charAt(0).toUpperCase() + check.slice(1);
      console.log(`${status} ${name}: ${passed ? 'OK' : 'FALHOU'}`);
    });

    console.log('');

    // Mostra erros
    if (this.errors.length > 0) {
      console.log('🚨 ERROS ENCONTRADOS:');
      this.errors.forEach(error => console.log(`   • ${error}`));
      console.log('');
    }

    // Mostra avisos
    if (this.warnings.length > 0) {
      console.log('⚠️ AVISOS:');
      this.warnings.forEach(warning => console.log(`   • ${warning}`));
      console.log('');
    }

    // Recomendações
    console.log('💡 RECOMENDAÇÕES:');
    if (successRate < 50) {
      console.log('   • Verificar se o Vite está compilando corretamente');
      console.log('   • Verificar se o Alpine.js está sendo importado');
      console.log('   • Verificar se o Tailwind está configurado');
    } else if (successRate < 80) {
      console.log('   • Alguns componentes podem precisar de ajustes');
      console.log('   • Verificar se todas as dependências estão instaladas');
    } else {
      console.log('   • TailAdmin Pro está funcionando bem!');
      console.log('   • Apenas alguns ajustes menores podem ser necessários');
    }

    console.log('=' .repeat(50));

    // Retorna o objeto de resultados para uso programático
    return {
      results: this.results,
      errors: this.errors,
      warnings: this.warnings,
      successRate: successRate
    };
  }
}

// Função global para executar a verificação
window.checkTailAdmin = function() {
  const checker = new TailAdminChecker();
  return checker.runAllChecks();
};

// Executa automaticamente quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', function() {
  console.log('🔍 TailAdmin Checker carregado. Execute checkTailAdmin() para verificar.');
});

// Executa automaticamente quando o Turbo carregar (para Rails)
document.addEventListener('turbo:load', function() {
  console.log('🔍 TailAdmin Checker carregado (Turbo). Execute checkTailAdmin() para verificar.');
});

// Exporta para uso em módulos
if (typeof module !== 'undefined' && module.exports) {
  module.exports = TailAdminChecker;
}
