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

    const warnings = bulletFooter.innerText.trim();
    if (!warnings || warnings.length === 0) return;

    const lines = warnings.split('\n').filter(line => line.trim());

    if (lines.length === 0) return;

    console.group(
      '%c🔫 Bullet N+1 Query Detection',
      'color: #ff6b6b; font-weight: bold; font-size: 14px;'
    );

    lines.forEach(line => {
      if (line.includes('USE eager loading') || line.includes('AVOID eager loading')) {
        console.warn('%c⚠️  ' + line, 'color: #ffa500; font-weight: bold;');
      } else if (line.includes('Call stack')) {
        console.log('%c📍 ' + line, 'color: #666;');
      } else if (line.includes('=>')) {
        console.error('%c❌ ' + line, 'color: #ff4444; font-weight: bold;');
      } else if (line.includes('query:')) {
        console.log('%c🔍 ' + line, 'color: #4CAF50;');
      } else if (line.includes('.rb')) {
        console.log('%c📂 ' + line, 'color: #2196F3; font-family: monospace;');
      } else {
        console.log(line);
      }
    });

    console.log('%c━'.repeat(80), 'color: #ddd;');
    console.log(
      '%c💡 Para copiar: Clique com botão direito na mensagem e selecione "Copy"',
      'color: #888; font-style: italic;'
    );
    console.log(
      '%c📋 Ou use: copy($0) no console após selecionar o elemento',
      'color: #888; font-style: italic;'
    );
    console.groupEnd();
  }

  document.addEventListener('turbo:load', logBulletWarnings);
  document.addEventListener('turbo:render', logBulletWarnings);
});
