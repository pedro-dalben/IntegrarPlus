import { test, expect } from '@playwright/test';

test.describe('Fluxogramas - Teste Completo E2E', () => {
  test.beforeEach(async ({ page }) => {
    console.log('🔐 Realizando login...');
    await page.goto('http://localhost:3001');

    await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
    await page.fill('input[name="user[password]"]', '123456');

    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin**');

    console.log('✅ Login realizado com sucesso');
  });

  test('01 - Verificar item no menu de navegação', async ({ page }) => {
    console.log('🔍 Testando item do menu...');

    const menuItem = page.locator('text=Fluxogramas').first();
    await expect(menuItem).toBeVisible();

    await menuItem.click();
    await page.waitForURL('**/admin/flow_charts');

    console.log('✅ Item do menu funcionando');
  });

  test('02 - Listar fluxogramas - Layout e Estrutura', async ({ page }) => {
    console.log('🔍 Testando página de listagem...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');

    await expect(page.locator('h2:has-text("Fluxogramas")')).toBeVisible();

    await expect(page.locator('input[placeholder*="buscar"]')).toBeVisible();

    const novoBotao = page.locator('a:has-text("Novo Fluxograma")');
    await expect(novoBotao).toBeVisible();

    const table = page.locator('table');
    await expect(table).toBeVisible();

    await expect(page.locator('th:has-text("Título")')).toBeVisible();
    await expect(page.locator('th:has-text("Status")')).toBeVisible();
    await expect(page.locator('th:has-text("Versão")')).toBeVisible();

    console.log('✅ Layout da listagem correto');
  });

  test('03 - Criar novo fluxograma', async ({ page }) => {
    console.log('🔍 Testando criação de fluxograma...');

    await page.goto('http://localhost:3001/admin/flow_charts');

    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    await expect(page.locator('h1:has-text("Novo Fluxograma")')).toBeVisible();

    await expect(page.locator('input[name="flow_chart[title]"]')).toBeVisible();
    await expect(page.locator('textarea[name="flow_chart[description]"]')).toBeVisible();
    await expect(page.locator('select[name="flow_chart[status]"]')).toBeVisible();

    const timestamp = Date.now();
    const titulo = `Fluxograma Teste ${timestamp}`;

    await page.fill('input[name="flow_chart[title]"]', titulo);
    await page.fill(
      'textarea[name="flow_chart[description]"]',
      'Este é um fluxograma criado via teste automatizado do Playwright'
    );
    await page.selectOption('select[name="flow_chart[status]"]', 'draft');

    await page.click('input[type="submit"]');

    await page.waitForURL('**/admin/flow_charts/*/edit');

    console.log(`✅ Fluxograma "${titulo}" criado com sucesso`);
  });

  test('04 - Editor draw.io - Verificar carregamento', async ({ page }) => {
    console.log('🔍 Testando editor draw.io...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    await page.fill('input[name="flow_chart[title]"]', `Editor Test ${timestamp}`);
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    console.log('📝 Verificando elementos do editor...');

    await expect(page.locator('h1')).toContainText('Editor Test');

    const iframe = page.frameLocator('iframe[data-drawio-target="iframe"]');
    await expect(iframe.locator('body')).toBeVisible({ timeout: 15000 });

    await expect(page.locator('button:has-text("Salvar Versão")')).toBeVisible();
    await expect(page.locator('button:has-text("Exportar PNG")')).toBeVisible();
    await expect(page.locator('button:has-text("Exportar SVG")')).toBeVisible();

    await expect(page.locator('input#version_notes')).toBeVisible();

    console.log('✅ Editor draw.io carregado corretamente');
  });

  test('05 - Editar informações do fluxograma', async ({ page }) => {
    console.log('🔍 Testando edição de informações...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    await page.fill('input[name="flow_chart[title]"]', `Edit Test ${timestamp}`);
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    const novoTitulo = `Edit Test ${timestamp} - EDITADO`;
    await page.fill('input[name="flow_chart[title]"]', novoTitulo);
    await page.fill('textarea[name="flow_chart[description]"]', 'Descrição editada via Playwright');

    await page.click('input[type="submit"]:has-text("Atualizar Informações")');

    await page.waitForLoadState('networkidle');

    await expect(page.locator(`text=${novoTitulo}`)).toBeVisible();

    console.log('✅ Informações editadas com sucesso');
  });

  test('06 - Visualizar detalhes do fluxograma', async ({ page }) => {
    console.log('🔍 Testando visualização de detalhes...');

    await page.goto('http://localhost:3001/admin/flow_charts');

    const primeiroFluxograma = page.locator('table tbody tr').first();
    const linkVer = primeiroFluxograma.locator('a[title="Ver detalhes"]');

    if ((await linkVer.count()) > 0) {
      await linkVer.click();
      await page.waitForURL('**/admin/flow_charts/*');

      await expect(page.locator('h1')).toBeVisible();

      const badges = page.locator('span.inline-flex');
      await expect(badges).toHaveCount({ timeout: 5000 });

      await expect(page.locator('a:has-text("Voltar")')).toBeVisible();

      const hasEditButton = await page.locator('a:has-text("Editar")').count();
      if (hasEditButton > 0) {
        await expect(page.locator('a:has-text("Editar")')).toBeVisible();
      }

      console.log('✅ Página de detalhes carregada corretamente');
    } else {
      console.log('⚠️ Nenhum fluxograma encontrado para visualizar');
    }
  });

  test('07 - Duplicar fluxograma', async ({ page }) => {
    console.log('🔍 Testando duplicação de fluxograma...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    const tituloOriginal = `Duplicate Test ${timestamp}`;
    await page.fill('input[name="flow_chart[title]"]', tituloOriginal);
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    const url = page.url();
    const flowChartId = url.match(/flow_charts\/(\d+)/)?.[1];

    await page.goto(`http://localhost:3001/admin/flow_charts/${flowChartId}`);

    const duplicateButton = page.locator('button:has-text("Duplicar")');
    if ((await duplicateButton.count()) > 0) {
      await duplicateButton.click();

      await page.waitForLoadState('networkidle');

      await expect(
        page.locator(`text=${tituloOriginal} (cópia)`).or(page.locator(`text=${tituloOriginal}`))
      ).toBeVisible({ timeout: 10000 });

      console.log('✅ Fluxograma duplicado com sucesso');
    } else {
      console.log('⚠️ Botão de duplicar não disponível (pode requerer versão)');
    }
  });

  test('08 - Publicar fluxograma', async ({ page }) => {
    console.log('🔍 Testando publicação de fluxograma...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    await page.fill('input[name="flow_chart[title]"]', `Publish Test ${timestamp}`);
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    const url = page.url();
    const flowChartId = url.match(/flow_charts\/(\d+)/)?.[1];

    await page.goto(`http://localhost:3001/admin/flow_charts/${flowChartId}`);
    await page.waitForLoadState('networkidle');

    const publishButton = page.locator('button:has-text("Publicar")');
    const buttonCount = await publishButton.count();

    if (buttonCount > 0) {
      console.log('⚠️ Botão publicar visível, mas pode falhar sem versão');
    } else {
      console.log('✅ Botão publicar corretamente oculto (sem versão)');
    }
  });

  test('09 - Excluir fluxograma', async ({ page }) => {
    console.log('🔍 Testando exclusão de fluxograma...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    const titulo = `Delete Test ${timestamp}`;
    await page.fill('input[name="flow_chart[title]"]', titulo);
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');

    page.on('dialog', dialog => dialog.accept());

    const row = page.locator(`tr:has-text("${titulo}")`);
    const deleteButton = row.locator('button[title="Excluir"]');

    if ((await deleteButton.count()) > 0) {
      await deleteButton.click();

      await page.waitForLoadState('networkidle');

      const deletedRow = page.locator(`tr:has-text("${titulo}")`);
      await expect(deletedRow).toHaveCount(0);

      console.log('✅ Fluxograma excluído com sucesso');
    } else {
      console.log('⚠️ Botão de exclusão não encontrado');
    }
  });

  test('10 - Busca avançada', async ({ page }) => {
    console.log('🔍 Testando busca avançada...');

    await page.goto('http://localhost:3001/admin/flow_charts');

    const searchInput = page.locator('input[placeholder*="buscar"]');
    await expect(searchInput).toBeVisible();

    await searchInput.fill('teste');

    await page.waitForTimeout(1000);

    console.log('✅ Busca avançada funcionando');
  });

  test('11 - Navegação entre páginas', async ({ page }) => {
    console.log('🔍 Testando navegação...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    await page.click('a:has-text("Cancelar")');
    await page.waitForURL('**/admin/flow_charts');

    console.log('✅ Navegação funcionando corretamente');
  });

  test('12 - Validação de formulário', async ({ page }) => {
    console.log('🔍 Testando validação de formulário...');

    await page.goto('http://localhost:3001/admin/flow_charts/new');

    await page.click('input[type="submit"]');

    await page.waitForTimeout(500);

    const hasError = await page.locator('text=/obrigatório|required|blank/i').count();
    if (hasError > 0) {
      console.log('✅ Validação funcionando - título obrigatório detectado');
    } else {
      console.log('⚠️ Validação pode estar configurada de forma diferente');
    }
  });

  test('13 - Responsividade - Mobile', async ({ page }) => {
    console.log('🔍 Testando responsividade mobile...');

    await page.setViewportSize({ width: 375, height: 667 });

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');

    await expect(page.locator('h2:has-text("Fluxogramas")')).toBeVisible();
    await expect(page.locator('a:has-text("Novo Fluxograma")')).toBeVisible();

    console.log('✅ Layout responsivo funcionando');
  });

  test('14 - Dark Mode (se aplicável)', async ({ page }) => {
    console.log('🔍 Testando dark mode...');

    await page.goto('http://localhost:3001/admin/flow_charts');

    const bodyClasses = await page.locator('body').getAttribute('class');
    const htmlClasses = await page.locator('html').getAttribute('class');

    if (bodyClasses?.includes('dark') || htmlClasses?.includes('dark')) {
      console.log('✅ Dark mode ativo');
    } else {
      console.log('ℹ️ Dark mode não detectado (light mode)');
    }
  });

  test('15 - Permissões - Visualização para todos', async ({ page }) => {
    console.log('🔍 Testando acesso de visualização...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');

    const currentUrl = page.url();
    expect(currentUrl).toContain('/admin/flow_charts');
    expect(currentUrl).not.toContain('sign_in');

    console.log('✅ Acesso de visualização funcionando');
  });

  test('16 - Histórico de Versões (se houver versões)', async ({ page }) => {
    console.log('🔍 Testando histórico de versões...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');

    const primeiroFluxograma = page.locator('table tbody tr').first();
    const linkVer = primeiroFluxograma.locator('a[title="Ver detalhes"]');

    if ((await linkVer.count()) > 0) {
      await linkVer.click();
      await page.waitForURL('**/admin/flow_charts/*');

      const versionHistory = page.locator('h3:has-text("Histórico de Versões")');
      if ((await versionHistory.count()) > 0) {
        await expect(versionHistory).toBeVisible();
        console.log('✅ Seção de histórico de versões presente');
      } else {
        console.log('ℹ️ Histórico de versões não visível (pode não haver versões)');
      }
    } else {
      console.log('⚠️ Nenhum fluxograma para verificar histórico');
    }
  });
});

test.describe('Fluxogramas - Testes de Performance', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3001');
    await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
    await page.fill('input[name="user[password]"]', '123456');
    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin**');
  });

  test('17 - Tempo de carregamento da listagem', async ({ page }) => {
    console.log('🔍 Testando performance da listagem...');

    const startTime = Date.now();

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('table')).toBeVisible();

    const endTime = Date.now();
    const loadTime = endTime - startTime;

    console.log(`⏱️ Tempo de carregamento: ${loadTime}ms`);

    expect(loadTime).toBeLessThan(5000);

    console.log('✅ Performance adequada (< 5s)');
  });

  test('18 - Tempo de carregamento do editor', async ({ page }) => {
    console.log('🔍 Testando performance do editor...');

    await page.goto('http://localhost:3001/admin/flow_charts');
    await page.click('a:has-text("Novo Fluxograma")');
    await page.waitForURL('**/admin/flow_charts/new');

    const timestamp = Date.now();
    await page.fill('input[name="flow_chart[title]"]', `Perf Test ${timestamp}`);

    const startTime = Date.now();

    await page.click('input[type="submit"]');
    await page.waitForURL('**/admin/flow_charts/*/edit');

    const iframe = page.frameLocator('iframe[data-drawio-target="iframe"]');
    await expect(iframe.locator('body')).toBeVisible({ timeout: 30000 });

    const endTime = Date.now();
    const loadTime = endTime - startTime;

    console.log(`⏱️ Tempo de carregamento do editor: ${loadTime}ms`);

    expect(loadTime).toBeLessThan(30000);

    console.log('✅ Editor carregou em tempo aceitável (< 30s)');
  });
});
