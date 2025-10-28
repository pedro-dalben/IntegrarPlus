import { test, expect } from '@playwright/test';

test.describe('Testes de Toggle em Formulários', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000/users/sign_in');
    await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
    await page.fill('input[name="user[password]"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin');
  });

  test('Toggle de escola no formulário de beneficiários funciona', async ({ page }) => {
    await page.goto('http://localhost:3000/admin/beneficiaries');
    await page.waitForLoadState('networkidle');

    await page.click('a[href*="/admin/beneficiaries/new"]');
    await page.waitForLoadState('networkidle');

    const schoolCheckbox = page.locator('input[name="beneficiary[attends_school]"]');
    const schoolFields = page.locator('[data-toggle-fields-target="content"]').first();

    await expect(schoolFields).toBeHidden();

    await schoolCheckbox.check();
    await page.waitForTimeout(100);

    await expect(schoolFields).toBeVisible();

    await schoolCheckbox.uncheck();
    await page.waitForTimeout(100);

    await expect(schoolFields).toBeHidden();
  });

  test('Toggle de escola no formulário de anamnese funciona', async ({ page }) => {
    await page.goto('http://localhost:3000/admin/anamneses');
    await page.waitForLoadState('networkidle');

    await page.click('a[href*="/admin/anamneses/new"]');
    await page.waitForLoadState('networkidle');

    const schoolCheckbox = page.locator('input[name="anamnesis[attends_school]"]');
    const schoolFields = page.locator('[data-toggle-fields-target="content"]').first();

    await expect(schoolFields).toBeHidden();

    await schoolCheckbox.check();
    await page.waitForTimeout(100);

    await expect(schoolFields).toBeVisible();

    await schoolCheckbox.uncheck();
    await page.waitForTimeout(100);

    await expect(schoolFields).toBeHidden();
  });

  test('Toggle de tratamento anterior no formulário de anamnese funciona', async ({ page }) => {
    await page.goto('http://localhost:3000/admin/anamneses/new');
    await page.waitForLoadState('networkidle');

    const treatmentCheckbox = page.locator('input[name="anamnesis[previous_treatment]"]');
    const treatmentFields = page.locator('[data-toggle-fields-target="content"]').nth(1);

    await expect(treatmentFields).toBeHidden();

    await treatmentCheckbox.check();
    await page.waitForTimeout(100);

    await expect(treatmentFields).toBeVisible();
    await expect(page.locator('text=Qual tratamento já realizou?')).toBeVisible();

    await treatmentCheckbox.uncheck();
    await page.waitForTimeout(100);

    await expect(treatmentFields).toBeHidden();
  });

  test('Toggle de tratamento externo no formulário de anamnese funciona', async ({ page }) => {
    await page.goto('http://localhost:3000/admin/anamneses/new');
    await page.waitForLoadState('networkidle');

    const externalCheckbox = page.locator('input[name="anamnesis[continue_external_treatment]"]');
    const externalFields = page.locator('[data-toggle-fields-target="content"]').nth(2);

    await expect(externalFields).toBeHidden();

    await externalCheckbox.check();
    await page.waitForTimeout(100);

    await expect(externalFields).toBeVisible();
    await expect(page.locator('text=Qual tratamento vai continuar?')).toBeVisible();

    await externalCheckbox.uncheck();
    await page.waitForTimeout(100);

    await expect(externalFields).toBeHidden();
  });

  test('Toggles funcionam após navegação Turbo', async ({ page }) => {
    await page.goto('http://localhost:3000/admin/beneficiaries/new');
    await page.waitForLoadState('networkidle');

    await page.click('a[href="/admin"]');
    await page.waitForLoadState('networkidle');

    await page.click('a[href*="/admin/beneficiaries"]');
    await page.waitForLoadState('networkidle');

    await page.click('a[href*="/admin/beneficiaries/new"]');
    await page.waitForLoadState('networkidle');

    const schoolCheckbox = page.locator('input[name="beneficiary[attends_school]"]');
    const schoolFields = page.locator('[data-toggle-fields-target="content"]').first();

    await schoolCheckbox.check();
    await page.waitForTimeout(100);

    await expect(schoolFields).toBeVisible();
  });
});
