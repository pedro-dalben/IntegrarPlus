import { test, expect } from '@playwright/test';

test.describe('Admin Flows - Teste Completo', () => {
  test.beforeEach(async ({ page }) => {
    // Login antes de cada teste
    await page.goto('http://localhost:3000');

    // Preencher login
    await page.fill('input[name="user[email]"]', 'admin@integrarplus.com');
    await page.fill('input[name="user[password]"]', 'password123');
    await page.click('button[type="submit"]');

    // Aguardar redirecionamento para admin
    await page.waitForURL('**/admin**');
  });

  test('Teste Completo - Grupos', async ({ page }) => {
    console.log('🔍 Iniciando teste de Grupos...');

    // Navegar para Grupos
    await page.click('text=Grupos');
    await page.waitForURL('**/admin/groups');

    // Verificar layout da tabela
    await expect(page.locator('table')).toBeVisible();
    await expect(page.locator('th:has-text("Nome")')).toBeVisible();
    await expect(page.locator('th:has-text("Descrição")')).toBeVisible();
    await expect(page.locator('th:has-text("Tipo")')).toBeVisible();

    // Verificar botão "Novo Grupo"
    const novoBotao = page.locator('a:has-text("Novo Grupo")');
    await expect(novoBotao).toBeVisible();
    await expect(novoBotao).toHaveClass(/bg-blue-600/);

    // Criar novo grupo
    await novoBotao.click();
    await page.waitForURL('**/admin/groups/new');

    // Verificar layout da página new
    await expect(page.locator('h1:has-text("Novo Grupo")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Preencher formulário
    await page.fill('input[name="group[name]"]', 'Grupo Teste Playwright');
    await page.fill('textarea[name="group[description]"]', 'Descrição do grupo teste');

    // Selecionar algumas permissões
    await page.check('input[value="1"]'); // Primeira permissão
    await page.check('input[value="2"]'); // Segunda permissão

    // Salvar
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/groups');

    // Verificar se foi criado
    await expect(page.locator('text=Grupo Teste Playwright')).toBeVisible();
    console.log('✅ Grupo criado com sucesso');

    // Ver detalhes
    await page.click('text=Grupo Teste Playwright');
    await page.waitForURL('**/admin/groups/*');

    // Verificar layout da página show
    await expect(page.locator('h1:has-text("Detalhes do Grupo")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();
    await expect(page.locator('button:has-text("Editar Grupo")')).toBeVisible();

    // Verificar seções
    await expect(page.locator('h2:has-text("Informações do Grupo")')).toBeVisible();
    await expect(page.locator('h2:has-text("Permissões")')).toBeVisible();
    await expect(page.locator('h2:has-text("Membros")')).toBeVisible();

    // Editar grupo
    await page.click('button:has-text("Editar Grupo")');
    await page.waitForURL('**/admin/groups/*/edit');

    // Verificar layout da página edit
    await expect(page.locator('h1:has-text("Editar Grupo")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Modificar nome
    await page.fill('input[name="group[name]"]', 'Grupo Teste Editado');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/groups');

    // Verificar se foi editado
    await expect(page.locator('text=Grupo Teste Editado')).toBeVisible();
    console.log('✅ Grupo editado com sucesso');

    // Excluir grupo
    await page.click('text=Grupo Teste Editado');
    await page.waitForURL('**/admin/groups/*');

    // Ir para a tabela
    await page.click('button:has-text("Voltar")');
    await page.waitForURL('**/admin/groups');

    // Encontrar e excluir o grupo
    const row = page.locator('tr:has-text("Grupo Teste Editado")');
    await row.locator('i.bi-trash').click();

    // Confirmar exclusão
    page.on('dialog', dialog => dialog.accept());
    await page.waitForURL('**/admin/groups');

    // Verificar se foi excluído
    await expect(page.locator('text=Grupo Teste Editado')).not.toBeVisible();
    console.log('✅ Grupo excluído com sucesso');
  });

  test('Teste Completo - Profissionais', async ({ page }) => {
    console.log('🔍 Iniciando teste de Profissionais...');

    // Navegar para Profissionais
    await page.click('text=Profissionais');
    await page.waitForURL('**/admin/professionals');

    // Verificar layout da tabela
    await expect(page.locator('table')).toBeVisible();
    await expect(page.locator('th:has-text("Profissional")')).toBeVisible();
    await expect(page.locator('th:has-text("Email")')).toBeVisible();
    await expect(page.locator('th:has-text("Status")')).toBeVisible();

    // Verificar botão "Novo Profissional"
    const novoBotao = page.locator('a:has-text("Novo Profissional")');
    await expect(novoBotao).toBeVisible();
    await expect(novoBotao).toHaveClass(/bg-blue-600/);

    // Criar novo profissional
    await novoBotao.click();
    await page.waitForURL('**/admin/professionals/new');

    // Verificar layout da página new
    await expect(page.locator('h1:has-text("Novo Profissional")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Preencher formulário
    await page.fill('input[name="professional[full_name]"]', 'Profissional Teste Playwright');
    await page.fill('input[name="professional[email]"]', 'profissional.teste@playwright.com');
    await page.fill('input[name="professional[cpf]"]', '123.456.789-00');
    await page.fill('input[name="professional[phone]"]', '(11) 99999-9999');

    // Salvar
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/professionals');

    // Verificar se foi criado
    await expect(page.locator('text=Profissional Teste Playwright')).toBeVisible();
    console.log('✅ Profissional criado com sucesso');

    // Ver detalhes
    await page.click('text=Profissional Teste Playwright');
    await page.waitForURL('**/admin/professionals/*');

    // Verificar layout da página show
    await expect(page.locator('h1:has-text("Detalhes do Profissional")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();
    await expect(page.locator('button:has-text("Editar Profissional")')).toBeVisible();

    // Verificar seções
    await expect(page.locator('h2:has-text("Dados Pessoais")')).toBeVisible();
    await expect(page.locator('h2:has-text("Acesso e Status")')).toBeVisible();

    // Editar profissional
    await page.click('button:has-text("Editar Profissional")');
    await page.waitForURL('**/admin/professionals/*/edit');

    // Verificar layout da página edit
    await expect(page.locator('h1:has-text("Editar Profissional")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Modificar nome
    await page.fill('input[name="professional[full_name]"]', 'Profissional Teste Editado');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/professionals');

    // Verificar se foi editado
    await expect(page.locator('text=Profissional Teste Editado')).toBeVisible();
    console.log('✅ Profissional editado com sucesso');

    // Excluir profissional
    const row = page.locator('tr:has-text("Profissional Teste Editado")');
    await row.locator('i.bi-trash').click();

    // Confirmar exclusão
    page.on('dialog', dialog => dialog.accept());
    await page.waitForURL('**/admin/professionals');

    // Verificar se foi excluído
    await expect(page.locator('text=Profissional Teste Editado')).not.toBeVisible();
    console.log('✅ Profissional excluído com sucesso');
  });

  test('Teste Completo - Especialidades', async ({ page }) => {
    console.log('🔍 Iniciando teste de Especialidades...');

    // Navegar para Especialidades
    await page.click('text=Especialidades');
    await page.waitForURL('**/admin/specialities');

    // Verificar layout da tabela
    await expect(page.locator('table')).toBeVisible();
    await expect(page.locator('th:has-text("Nome")')).toBeVisible();
    await expect(page.locator('th:has-text("Criado em")')).toBeVisible();

    // Verificar botão "Nova Especialidade"
    const novoBotao = page.locator('a:has-text("Nova Especialidade")');
    await expect(novoBotao).toBeVisible();
    await expect(novoBotao).toHaveClass(/bg-blue-600/);

    // Criar nova especialidade
    await novoBotao.click();
    await page.waitForURL('**/admin/specialities/new');

    // Verificar layout da página new
    await expect(page.locator('h1:has-text("Nova Especialidade")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Preencher formulário
    await page.fill('input[name="speciality[name]"]', 'Especialidade Teste Playwright');
    await page.fill('textarea[name="speciality[description]"]', 'Descrição da especialidade teste');

    // Salvar
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/specialities');

    // Verificar se foi criada
    await expect(page.locator('text=Especialidade Teste Playwright')).toBeVisible();
    console.log('✅ Especialidade criada com sucesso');

    // Ver detalhes
    await page.click('text=Especialidade Teste Playwright');
    await page.waitForURL('**/admin/specialities/*');

    // Verificar layout da página show
    await expect(page.locator('h1:has-text("Detalhes da Especialidade")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();
    await expect(page.locator('button:has-text("Editar Especialidade")')).toBeVisible();

    // Editar especialidade
    await page.click('button:has-text("Editar Especialidade")');
    await page.waitForURL('**/admin/specialities/*/edit');

    // Verificar layout da página edit
    await expect(page.locator('h1:has-text("Editar Especialidade")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Modificar nome
    await page.fill('input[name="speciality[name]"]', 'Especialidade Teste Editada');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/specialities');

    // Verificar se foi editada
    await expect(page.locator('text=Especialidade Teste Editada')).toBeVisible();
    console.log('✅ Especialidade editada com sucesso');

    // Excluir especialidade
    const row = page.locator('tr:has-text("Especialidade Teste Editada")');
    await row.locator('i.bi-trash').click();

    // Confirmar exclusão
    page.on('dialog', dialog => dialog.accept());
    await page.waitForURL('**/admin/specialities');

    // Verificar se foi excluída
    await expect(page.locator('text=Especialidade Teste Editada')).not.toBeVisible();
    console.log('✅ Especialidade excluída com sucesso');
  });

  test('Teste Completo - Especializações', async ({ page }) => {
    console.log('🔍 Iniciando teste de Especializações...');

    // Navegar para Especializações
    await page.click('text=Especializações');
    await page.waitForURL('**/admin/specializations');

    // Verificar layout da tabela
    await expect(page.locator('table')).toBeVisible();
    await expect(page.locator('th:has-text("Nome")')).toBeVisible();
    await expect(page.locator('th:has-text("Especialidades")')).toBeVisible();

    // Verificar botão "Nova Especialização"
    const novoBotao = page.locator('a:has-text("Nova Especialização")');
    await expect(novoBotao).toBeVisible();
    await expect(novoBotao).toHaveClass(/bg-blue-600/);

    // Criar nova especialização
    await novoBotao.click();
    await page.waitForURL('**/admin/specializations/new');

    // Verificar layout da página new
    await expect(page.locator('h1:has-text("Nova Especialização")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Preencher formulário
    await page.fill('input[name="specialization[name]"]', 'Especialização Teste Playwright');
    await page.fill(
      'textarea[name="specialization[description]"]',
      'Descrição da especialização teste'
    );

    // Salvar
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/specializations');

    // Verificar se foi criada
    await expect(page.locator('text=Especialização Teste Playwright')).toBeVisible();
    console.log('✅ Especialização criada com sucesso');

    // Ver detalhes
    await page.click('text=Especialização Teste Playwright');
    await page.waitForURL('**/admin/specializations/*');

    // Verificar layout da página show
    await expect(page.locator('h1:has-text("Detalhes da Especialização")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();
    await expect(page.locator('button:has-text("Editar Especialização")')).toBeVisible();

    // Editar especialização
    await page.click('button:has-text("Editar Especialização")');
    await page.waitForURL('**/admin/specializations/*/edit');

    // Verificar layout da página edit
    await expect(page.locator('h1:has-text("Editar Especialização")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Modificar nome
    await page.fill('input[name="specialization[name]"]', 'Especialização Teste Editada');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/specializations');

    // Verificar se foi editada
    await expect(page.locator('text=Especialização Teste Editada')).toBeVisible();
    console.log('✅ Especialização editada com sucesso');

    // Excluir especialização
    const row = page.locator('tr:has-text("Especialização Teste Editada")');
    await row.locator('i.bi-trash').click();

    // Confirmar exclusão
    page.on('dialog', dialog => dialog.accept());
    await page.waitForURL('**/admin/specializations');

    // Verificar se foi excluída
    await expect(page.locator('text=Especialização Teste Editada')).not.toBeVisible();
    console.log('✅ Especialização excluída com sucesso');
  });

  test('Teste Completo - Tipos de Contrato', async ({ page }) => {
    console.log('🔍 Iniciando teste de Tipos de Contrato...');

    // Navegar para Tipos de Contrato
    await page.click('text=Tipos de Contrato');
    await page.waitForURL('**/admin/contract_types');

    // Verificar layout da tabela
    await expect(page.locator('table')).toBeVisible();
    await expect(page.locator('th:has-text("Nome")')).toBeVisible();
    await expect(page.locator('th:has-text("Descrição")')).toBeVisible();

    // Verificar botão "Novo Tipo de Contrato"
    const novoBotao = page.locator('a:has-text("Novo Tipo de Contrato")');
    await expect(novoBotao).toBeVisible();
    await expect(novoBotao).toHaveClass(/bg-blue-600/);

    // Criar novo tipo de contrato
    await novoBotao.click();
    await page.waitForURL('**/admin/contract_types/new');

    // Verificar layout da página new
    await expect(page.locator('h1:has-text("Novo Tipo de Contrato")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Preencher formulário
    await page.fill('input[name="contract_type[name]"]', 'Tipo Contrato Teste Playwright');
    await page.fill(
      'textarea[name="contract_type[description]"]',
      'Descrição do tipo de contrato teste'
    );

    // Salvar
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/contract_types');

    // Verificar se foi criado
    await expect(page.locator('text=Tipo Contrato Teste Playwright')).toBeVisible();
    console.log('✅ Tipo de Contrato criado com sucesso');

    // Ver detalhes
    await page.click('text=Tipo Contrato Teste Playwright');
    await page.waitForURL('**/admin/contract_types/*');

    // Verificar layout da página show
    await expect(page.locator('h1:has-text("Detalhes do Tipo de Contrato")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();
    await expect(page.locator('button:has-text("Editar Tipo de Contrato")')).toBeVisible();

    // Editar tipo de contrato
    await page.click('button:has-text("Editar Tipo de Contrato")');
    await page.waitForURL('**/admin/contract_types/*/edit');

    // Verificar layout da página edit
    await expect(page.locator('h1:has-text("Editar Tipo de Contrato")')).toBeVisible();
    await expect(page.locator('button:has-text("Voltar")')).toBeVisible();

    // Modificar nome
    await page.fill('input[name="contract_type[name]"]', 'Tipo Contrato Teste Editado');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin/contract_types');

    // Verificar se foi editado
    await expect(page.locator('text=Tipo Contrato Teste Editado')).toBeVisible();
    console.log('✅ Tipo de Contrato editado com sucesso');

    // Excluir tipo de contrato
    const row = page.locator('tr:has-text("Tipo Contrato Teste Editado")');
    await row.locator('i.bi-trash').click();

    // Confirmar exclusão
    page.on('dialog', dialog => dialog.accept());
    await page.waitForURL('**/admin/contract_types');

    // Verificar se foi excluído
    await expect(page.locator('text=Tipo Contrato Teste Editado')).not.toBeVisible();
    console.log('✅ Tipo de Contrato excluído com sucesso');
  });

  test('Verificação de Layout e Consistência Visual', async ({ page }) => {
    console.log('🔍 Verificando consistência visual...');

    const sections = [
      { name: 'Grupos', url: '/admin/groups' },
      { name: 'Profissionais', url: '/admin/professionals' },
      { name: 'Especialidades', url: '/admin/specialities' },
      { name: 'Especializações', url: '/admin/specializations' },
      { name: 'Tipos de Contrato', url: '/admin/contract_types' },
    ];

    for (const section of sections) {
      console.log(`📋 Verificando ${section.name}...`);

      await page.goto(`http://localhost:3000${section.url}`);

      // Verificar botão "Novo" (deve ser azul)
      const novoBotao = page
        .locator('a')
        .filter({ hasText: /Novo|Nova/ })
        .first();
      if (await novoBotao.isVisible()) {
        await expect(novoBotao).toHaveClass(/bg-blue-600/);
        console.log(`✅ Botão "Novo" em ${section.name} tem cor azul correta`);
      }

      // Verificar botão "Voltar" (deve ter classes específicas)
      const voltarBotao = page.locator('button:has-text("Voltar")').first();
      if (await voltarBotao.isVisible()) {
        await expect(voltarBotao).toHaveClass(/ta-btn-secondary/);
        console.log(`✅ Botão "Voltar" em ${section.name} tem classes corretas`);
      }

      // Verificar ícones de ação na tabela
      const acoes = page.locator('i.bi-eye, i.bi-pencil, i.bi-trash');
      if ((await acoes.count()) > 0) {
        console.log(`✅ Ícones de ação em ${section.name} estão presentes`);

        // Verificar cores dos ícones
        const olho = page.locator('i.bi-eye').first();
        if (await olho.isVisible()) {
          await expect(olho).toHaveClass(/text-brand-600/);
        }

        const lapis = page.locator('i.bi-pencil').first();
        if (await lapis.isVisible()) {
          await expect(lapis).toHaveClass(/text-gray-600/);
        }

        const lixeira = page.locator('i.bi-trash').first();
        if (await lixeira.isVisible()) {
          await expect(lixeira).toHaveClass(/text-red-600/);
        }
      }

      // Verificar estrutura da tabela
      const tabela = page.locator('table');
      if (await tabela.isVisible()) {
        await expect(tabela).toHaveClass(/w-full/);
        console.log(`✅ Tabela em ${section.name} tem estrutura correta`);
      }
    }

    console.log('✅ Verificação de consistência visual concluída');
  });
});
