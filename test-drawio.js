const { chromium } = require('playwright');

async function testDrawio() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('🚀 Abrindo navegador para testar draw.io...');

  try {
    // Navegar para a página de edição
    console.log('📄 Navegando para http://localhost:3000/admin/flow_charts/1/edit');
    await page.goto('http://localhost:3000/admin/flow_charts/1/edit');

    // Aguardar a página carregar
    await page.waitForLoadState('networkidle');
    console.log('✅ Página carregada');

    // Verificar se há redirecionamento para login
    const currentUrl = page.url();
    console.log('📍 URL atual:', currentUrl);

    if (currentUrl.includes('/login')) {
      console.log('🔐 Redirecionado para login - fazendo login...');

      // Fazer login
      await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
      await page.fill('input[name="user[password]"]', 'password');
      await page.click('button[type="submit"]');

      // Aguardar redirecionamento
      await page.waitForLoadState('networkidle');
      console.log('✅ Login realizado');
    }

    // Verificar se estamos na página correta
    const title = await page.locator('h1').first().textContent();
    console.log('📝 Título da página:', title);

    // Verificar se o iframe do draw.io está presente
    const iframe = page.locator('iframe[data-drawio-target="iframe"]');
    const iframeExists = (await iframe.count()) > 0;
    console.log('🖼️ Iframe do draw.io presente:', iframeExists);

    if (iframeExists) {
      console.log('✅ Iframe encontrado');

      // Verificar se o botão de salvar está presente
      const saveButton = page.locator('button[data-action="click->drawio#save"]');
      const saveButtonExists = (await saveButton.count()) > 0;
      console.log('💾 Botão "Salvar Versão" presente:', saveButtonExists);

      if (saveButtonExists) {
        console.log('✅ Botão de salvar encontrado');

        // Capturar logs do console
        const consoleLogs = [];
        page.on('console', msg => {
          consoleLogs.push(msg.text());
          console.log('🔍 Console:', msg.text());
        });

        // Aguardar um pouco para o draw.io carregar
        console.log('⏳ Aguardando draw.io carregar...');
        await page.waitForTimeout(5000);

        // Verificar logs do controller Stimulus
        const hasStimulusLogs = consoleLogs.some(
          log => log.includes('DrawioController connected') || log.includes('Draw.io iframe loaded')
        );

        console.log('🎮 Controller Stimulus funcionando:', hasStimulusLogs);

        // Tentar clicar no botão de salvar
        console.log('🖱️ Clicando no botão "Salvar Versão"...');
        await saveButton.click();

        // Aguardar resposta
        await page.waitForTimeout(3000);

        // Verificar logs de salvamento
        const hasSaveLogs = consoleLogs.some(
          log => log.includes('Save button clicked') || log.includes('Sending message to iframe')
        );

        console.log('💾 Logs de salvamento encontrados:', hasSaveLogs);

        // Verificar se a página foi recarregada
        const newUrl = page.url();
        console.log('🔄 URL após clique:', newUrl);

        console.log('✅ Teste concluído!');
      } else {
        console.log('❌ Botão "Salvar Versão" não encontrado');
      }
    } else {
      console.log('❌ Iframe do draw.io não encontrado');
    }
  } catch (error) {
    console.error('❌ Erro durante o teste:', error);
  }

  // Manter o navegador aberto para inspeção manual
  console.log('🔍 Navegador mantido aberto para inspeção manual...');
  console.log('📋 Pressione Ctrl+C para fechar');

  // Aguardar indefinidamente para inspeção manual
  await new Promise(() => {});
}

testDrawio().catch(console.error);
