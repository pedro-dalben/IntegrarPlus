import { test, expect } from '@playwright/test';

test.describe('Document Permissions - Documento 5', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001');

    // Login como admin
    await page.fill('input[name="user[email]"]', 'pedrodalbenmorais@gmail.com');
    await page.fill('input[name="user[password]"]', 'password123');
    await page.click('input[type="submit"]');

    // Aguardar login
    await page.waitForLoadState('networkidle');
  });

  test('should access document permissions page for document 5', async ({ page }) => {
    // Navegar diretamente para o documento 5
    await page.goto('http://localhost:3001/admin/documents/5');

    // Verificar se a página carrega
    await expect(page.locator('h1')).toContainText('Teste de Upload');

    // Clicar no link de permissões
    await page.click('text=Permissões');

    // Verificar se chegou na página de permissões
    await expect(page).toHaveURL(/.*\/documents\/5\/document_permissions$/);
    await expect(page.locator('h1')).toContainText('Permissões do Documento');
  });

  test('should add user permission to document 5', async ({ page }) => {
    await page.goto('http://localhost:3001/admin/documents/5/document_permissions');

    // Verificar se a página carrega
    await expect(page.locator('h1')).toContainText('Permissões do Documento');

    // Selecionar tipo de grantee
    await page.selectOption('select[name="grantee_type"]', 'user');

    // Aguardar o campo de usuário aparecer
    await page.waitForSelector('select[name="user_id"]');

    // Selecionar um usuário (primeiro da lista)
    await page.selectOption('select[name="user_id"]', '1');

    // Selecionar nível de acesso
    await page.selectOption('select[name="access_level"]', 'visualizar');

    // Submeter formulário
    await page.click('input[type="submit"]');

    // Verificar se foi redirecionado com sucesso
    await expect(page).toHaveURL(/.*\/documents\/5\/document_permissions$/);

    // Verificar se há mensagem de sucesso
    await expect(page.locator('.alert, .notice')).toContainText('sucesso');
  });

  test('should add group permission to document 5', async ({ page }) => {
    await page.goto('http://localhost:3001/admin/documents/5/document_permissions');

    // Selecionar tipo de grantee
    await page.selectOption('select[name="grantee_type"]', 'group');

    // Aguardar o campo de grupo aparecer
    await page.waitForSelector('select[name="group_id"]');

    // Selecionar um grupo (primeiro da lista)
    await page.selectOption('select[name="group_id"]', '1');

    // Selecionar nível de acesso
    await page.selectOption('select[name="access_level"]', 'comentar');

    // Submeter formulário
    await page.click('input[type="submit"]');

    // Verificar se foi redirecionado com sucesso
    await expect(page).toHaveURL(/.*\/documents\/5\/document_permissions$/);

    // Verificar se há mensagem de sucesso
    await expect(page.locator('.alert, .notice')).toContainText('sucesso');
  });

  test('should show error for invalid form submission', async ({ page }) => {
    await page.goto('http://localhost:3001/admin/documents/5/document_permissions');

    // Tentar submeter sem selecionar nada
    await page.click('input[type="submit"]');

    // Verificar se há mensagem de erro
    await expect(page.locator('.alert, .error')).toBeVisible();
  });

  test('should display existing permissions', async ({ page }) => {
    await page.goto('http://localhost:3001/admin/documents/5/document_permissions');

    // Verificar se as permissões existentes são exibidas
    await expect(page.locator('text=Administrador do Sistema')).toBeVisible();
    await expect(page.locator('text=Administradores')).toBeVisible();
  });
});
