const { chromium } = require('playwright');

async function testSimple() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  console.log('🚀 Abrindo navegador...');
  
  try {
    // Navegar para a página
    await page.goto('http://localhost:3000/admin/flow_charts/1/edit');
    await page.waitForLoadState('networkidle');
    
    console.log('✅ Página carregada');
    
    // Capturar logs do console
    page.on('console', msg => {
      console.log('🔍 Console:', msg.text());
    });
    
    // Aguardar um pouco
    await page.waitForTimeout(3000);
    
    console.log('✅ Teste concluído - navegador aberto para inspeção manual');
    console.log('📋 Pressione Ctrl+C para fechar');
    
    // Aguardar indefinidamente
    await new Promise(() => {});
    
  } catch (error) {
    console.error('❌ Erro:', error);
  }
}

testSimple().catch(console.error);
