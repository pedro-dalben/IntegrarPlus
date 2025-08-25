import { test, expect } from '@playwright/test';

test('should load login page', async ({ page }) => {
  await page.goto('http://localhost:3001');

  // Verificar se a página carrega
  await expect(page.locator('h1.login-title')).toBeVisible();

  // Verificar se os campos de login estão presentes
  await expect(page.locator('input[name="user[email]"]')).toBeVisible();
  await expect(page.locator('input[name="user[password]"]')).toBeVisible();

  // Verificar se o botão de submit está presente (input type submit)
  const submitButton = page.locator('input[type="submit"]');
  await expect(submitButton).toBeVisible();

  console.log('Página de login carregada com sucesso');

  // Preencher formulário
  await page.fill('input[name="user[email]"]', 'test@example.com');
  await page.fill('input[name="user[password]"]', 'password123');

  console.log('Formulário preenchido');

  // Clicar no botão
  await submitButton.click();

  console.log('Botão clicado');

  // Aguardar qualquer redirecionamento
  await page.waitForLoadState('networkidle');

  console.log('URL após login:', page.url());

  // Verificar se o login foi bem-sucedido (não estamos mais na página de login)
  const currentUrl = page.url();
  expect(currentUrl).not.toContain('/users/sign_in');

  console.log('Login realizado com sucesso');
});
