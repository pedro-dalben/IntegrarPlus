import { test, expect } from '@playwright/test';

test('Teste de Login', async ({ page }) => {
  console.log('🔍 Testando login...');
  
  // Ir para a página inicial
  await page.goto('http://localhost:3000');
  
  // Aguardar carregamento da página
  await page.waitForLoadState('networkidle');
  
  // Verificar se estamos na página de login
  console.log('URL atual:', page.url());
  
  // Aguardar o formulário de login aparecer
  await page.waitForSelector('input[name="user[email]"]', { timeout: 10000 });
  
  // Preencher formulário de login
  await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
  await page.fill('input[name="user[password]"]', 'password123');
  
  // Aguardar e clicar no botão de login usando a referência específica
  await page.waitForSelector('[ref="e53"]', { timeout: 10000 });
  await page.click('[ref="e53"]');
  
  // Aguardar redirecionamento
  await page.waitForURL('**/admin**', { timeout: 15000 });
  
  console.log('✅ Login realizado com sucesso');
  console.log('URL após login:', page.url());
  
  // Verificar se estamos na área admin
  await expect(page.locator('text=Dashboard')).toBeVisible();
  
  console.log('✅ Dashboard carregado com sucesso');
});
