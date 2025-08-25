import { test, expect } from '@playwright/test';

test('should test permissions form functionality', async ({ page }) => {
  // Login
  await page.goto('http://localhost:3001');
  await page.fill('input[name="user[email]"]', 'pedrodalbenmorais@gmail.com');
  await page.fill('input[name="user[password]"]', 'password123');
  await page.click('input[type="submit"]');
  await page.waitForLoadState('networkidle');

  // Navegar para página de permissões
  await page.goto('http://localhost:3001/admin/documents/5/document_permissions');

  console.log('Página carregada:', page.url());

  // Verificar se o formulário está presente
  await expect(page.locator('form')).toBeVisible();

  // Verificar se o select de tipo está presente
  const granteeTypeSelect = page.locator('select[name="grantee_type"]');
  await expect(granteeTypeSelect).toBeVisible();

  // Verificar se o campo de usuário está visível inicialmente
  const userSelect = page.locator('select[name="user_id"]');
  await expect(userSelect).toBeVisible();

  // Verificar se o campo de grupo está oculto inicialmente
  const groupSelect = page.locator('select[name="group_id"]');
  await expect(groupSelect).toHaveClass(/hidden/);

  console.log('Estado inicial correto');

  // Testar mudança para grupo
  await granteeTypeSelect.selectOption('group');

  // Aguardar um pouco para o JavaScript executar
  await page.waitForTimeout(1000);

  // Verificar se o campo de usuário ficou oculto
  await expect(userSelect).toHaveClass(/hidden/);

  // Verificar se o campo de grupo ficou visível
  await expect(groupSelect).not.toHaveClass(/hidden/);

  console.log('Mudança para grupo funcionou');

  // Testar mudança de volta para usuário
  await granteeTypeSelect.selectOption('user');

  // Aguardar um pouco para o JavaScript executar
  await page.waitForTimeout(1000);

  // Verificar se o campo de usuário ficou visível
  await expect(userSelect).not.toHaveClass(/hidden/);

  // Verificar se o campo de grupo ficou oculto
  await expect(groupSelect).toHaveClass(/hidden/);

  console.log('Mudança para usuário funcionou');

  // Testar submissão do formulário
  await userSelect.selectOption('1');
  await page.selectOption('select[name="access_level"]', 'visualizar');

  console.log('Formulário preenchido, submetendo...');

  // Submeter formulário
  await page.click('input[type="submit"]');

  // Aguardar redirecionamento
  await page.waitForLoadState('networkidle');

  console.log('URL após submissão:', page.url());

  // Verificar se ainda estamos na página de permissões
  expect(page.url()).toContain('/document_permissions');

  console.log('Teste concluído com sucesso!');
});
