import { test, expect } from '@playwright/test';

test.describe('Document Management System', () => {
  test.beforeEach(async ({ page }) => {
    // Navegar para a página de login
    await page.goto('http://localhost:3000');

    // Fazer login com as credenciais corretas
    await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
    await page.fill('input[name="user[password]"]', 'password123');
    await page.click('input[type="submit"]');

    // Aguardar redirecionamento para o dashboard
    await page.waitForURL('**/admin**');
  });

  test('should navigate to documents section', async ({ page }) => {
    // Verificar se o link de documentos está visível no sidebar
    const documentsLink = page.locator('a[href="/documents"]');
    await expect(documentsLink).toBeVisible();

    // Clicar no link de documentos
    await documentsLink.click();

    // Verificar se chegou na página de documentos
    await expect(page).toHaveURL('**/documents');
    await expect(page.locator('h1')).toContainText('Meus Documentos');
  });

  test('should create a new document', async ({ page }) => {
    // Navegar para documentos
    await page.goto('http://localhost:3000/documents');

    // Clicar no botão "Novo Documento"
    await page.click('text=Novo Documento');

    // Verificar se chegou na página de criação
    await expect(page).toHaveURL('**/documents/new');
    await expect(page.locator('h1')).toContainText('Novo Documento');

    // Preencher o formulário
    await page.fill('input[name="document[title]"]', 'Documento de Teste');
    await page.fill('textarea[name="document[description]"]', 'Descrição do documento de teste');
    await page.selectOption('select[name="document[document_type]"]', 'relatorio');

    // Simular upload de arquivo (criar um arquivo temporário)
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles({
      name: 'test-document.pdf',
      mimeType: 'application/pdf',
      buffer: Buffer.from('fake pdf content'),
    });

    // Submeter o formulário
    await page.click('text=Criar Documento');

    // Verificar se foi redirecionado para a página do documento
    await expect(page).toHaveURL(/\/documents\/\d+/);
    await expect(page.locator('h1')).toContainText('Documento de Teste');
  });

  test('should manage document permissions', async ({ page }) => {
    // Assumindo que já existe um documento criado
    await page.goto('http://localhost:3000/documents');

    // Clicar no primeiro documento da lista
    const firstDocument = page.locator('table tbody tr').first();
    await firstDocument.locator('a[href*="/documents/"]').first().click();

    // Verificar se o botão de permissões está visível
    const permissionsButton = page.locator('text=Permissões');
    await expect(permissionsButton).toBeVisible();

    // Clicar no botão de permissões
    await permissionsButton.click();

    // Verificar se chegou na página de permissões
    await expect(page).toHaveURL(/\/documents\/\d+\/document_permissions/);
    await expect(page.locator('h1')).toContainText('Permissões do Documento');
  });

  test('should add comments to document version', async ({ page }) => {
    // Navegar para um documento específico
    await page.goto('http://localhost:3000/documents');

    // Clicar no primeiro documento
    const firstDocument = page.locator('table tbody tr').first();
    await firstDocument.locator('a[href*="/documents/"]').first().click();

    // Verificar se a seção de comentários está visível
    const commentsSection = page.locator('text=Comentários da Versão');
    await expect(commentsSection).toBeVisible();

    // Preencher e enviar um comentário
    const commentTextarea = page.locator('textarea[placeholder*="comentário"]');
    await commentTextarea.fill('Este é um comentário de teste');

    await page.click('text=Adicionar Comentário');

    // Verificar se o comentário foi adicionado
    await expect(page.locator('text=Este é um comentário de teste')).toBeVisible();
  });

  test('should display document versions correctly', async ({ page }) => {
    // Navegar para um documento
    await page.goto('http://localhost:3000/documents');

    // Clicar no primeiro documento
    const firstDocument = page.locator('table tbody tr').first();
    await firstDocument.locator('a[href*="/documents/"]').first().click();

    // Verificar se a seção de histórico de versões está visível
    const versionsSection = page.locator('text=Histórico de Versões');
    await expect(versionsSection).toBeVisible();

    // Verificar se pelo menos uma versão está listada
    const versionItems = page.locator('.border.border-gray-200.rounded-lg');
    await expect(versionItems).toHaveCount(1);
  });

  test('should download document version', async ({ page }) => {
    // Navegar para um documento
    await page.goto('http://localhost:3000/documents');

    // Clicar no primeiro documento
    const firstDocument = page.locator('table tbody tr').first();
    await firstDocument.locator('a[href*="/documents/"]').first().click();

    // Verificar se o botão de download está visível
    const downloadButton = page.locator('text=Baixar');
    await expect(downloadButton).toBeVisible();

    // Clicar no botão de download (não vamos baixar realmente, apenas verificar se não há erro)
    const downloadPromise = page.waitForEvent('download');
    await downloadButton.click();

    // Aguardar o início do download
    const download = await downloadPromise;
    expect(download).toBeTruthy();
  });

  test('should edit document', async ({ page }) => {
    // Navegar para um documento
    await page.goto('http://localhost:3000/documents');

    // Clicar no primeiro documento
    const firstDocument = page.locator('table tbody tr').first();
    await firstDocument.locator('a[href*="/documents/"]').first().click();

    // Clicar no botão editar
    await page.click('text=Editar');

    // Verificar se chegou na página de edição
    await expect(page).toHaveURL(/\/documents\/\d+\/edit/);
    await expect(page.locator('h1')).toContainText('Editar Documento');

    // Modificar o título
    await page.fill('input[name="document[title]"]', 'Documento Editado');

    // Salvar as alterações
    await page.click('text=Atualizar Documento');

    // Verificar se foi redirecionado de volta para o documento
    await expect(page).toHaveURL(/\/documents\/\d+/);
    await expect(page.locator('h1')).toContainText('Documento Editado');
  });
});
