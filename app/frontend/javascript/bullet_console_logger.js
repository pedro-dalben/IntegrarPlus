document.addEventListener('DOMContentLoaded', () => {
  const bulletFooter = document.getElementById('bullet-footer');

  if (bulletFooter) {
    const observer = new MutationObserver(mutations => {
      mutations.forEach(mutation => {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          logBulletWarnings();
        }
      });
    });

    observer.observe(bulletFooter, {
      childList: true,
      subtree: true,
    });

    logBulletWarnings();
  }

  function logBulletWarnings() {
    const bulletFooter = document.getElementById('bullet-footer');
    if (!bulletFooter) return;

    // Pega o div com os warnings (ignora summary e styles)
    const warningsDiv = bulletFooter.querySelector('div');
    if (!warningsDiv) return;

    // Pega o HTML e limpa
    let html = warningsDiv.innerHTML;

    // Remove styles e spans de console-message
    html = html.replace(/<style[^>]*>.*?<\/style>/gi, '');
    html = html.replace(/<span id="console-message">.*?<\/span>/gi, '');

    // Converte BR para quebras de linha
    html = html.replace(/<br\s*\/?>/gi, '\n');

    // Remove outras tags HTML
    html = html.replace(/<[^>]+>/g, '');

    // Decodifica HTML entities
    const div = document.createElement('div');
    div.innerHTML = html;
    const warnings = div.textContent || div.innerText || '';

    const lines = warnings
      .split('\n')
      .map(line => line.trim())
      .filter(line => line && line !== 'Uniform Notifier' && line !== 'Bullet Warnings');

    if (lines.length === 0) return;

    console.group(
      '%c🔫 Bullet N+1 Query Detection',
      'color: #ff6b6b; font-weight: bold; font-size: 16px; padding: 4px;'
    );

    console.log('%c' + '━'.repeat(80), 'color: #ff6b6b;');

    lines.forEach(line => {
      // Detectar tipo de alerta
      if (line.includes('USE eager loading') || line.includes('AVOID eager loading')) {
        console.warn('%c⚠️  ' + line, 'color: #ffa500; font-weight: bold; font-size: 13px;');
      } else if (line.includes('Need counter cache')) {
        console.warn('%c🔢 ' + line, 'color: #ff9800; font-weight: bold;');
      } else if (line.includes('Call stack') || line.includes('backtrace')) {
        console.groupCollapsed('%c📍 Call Stack', 'color: #999; font-style: italic;');
        console.log('%c' + line, 'color: #666; font-family: monospace; font-size: 11px;');
        console.groupEnd();
      } else if (line.match(/^\w+\s*=>/)) {
        // Linha com modelo e associações (ex: "Beneficiary => [:anamneses]")
        console.error('%c❌ ' + line, 'color: #ff4444; font-weight: bold; font-size: 13px;');
      } else if (line.includes('Add to your query') || line.includes('Remove from your query')) {
        console.log('%c🔍 ' + line, 'color: #4CAF50; font-weight: bold;');
      } else if (line.includes('.includes') || line.includes('.eager_load')) {
        console.log('%c💡 ' + line, 'color: #4CAF50; font-family: monospace; font-size: 12px;');
      } else if (line.match(/\/app\/.+\.(rb|erb)/)) {
        // Arquivo do projeto
        console.log('%c📂 ' + line, 'color: #2196F3; font-family: monospace;');
      } else if (line.length > 0) {
        console.log(line);
      }
    });

    console.log('%c' + '━'.repeat(80), 'color: #ff6b6b;');
    console.log(
      '%c💡 COPIAR: Clique direito na mensagem → "Copy message"',
      'color: #888; font-style: italic;'
    );
    console.log(
      '%c📋 OU: Selecione a mensagem e Ctrl+C (Cmd+C no Mac)',
      'color: #888; font-style: italic;'
    );
    console.log('%c' + '━'.repeat(80), 'color: #ddd;');
    console.groupEnd();
  }

  document.addEventListener('turbo:load', logBulletWarnings);
  document.addEventListener('turbo:render', logBulletWarnings);
});
