import { test, expect } from '@playwright/test';

test.describe('Sistema de Agendas', () => {
  test.beforeEach(async ({ page }) => {
    // Login no sistema
    await page.goto('/users/sign_in');
    await page.fill('input[name="user[email]"]', 'admin@example.com');
    await page.fill('input[name="user[password]"]', 'password');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/admin');
  });

  test('deve permitir criar nova agenda', async ({ page }) => {
    await page.goto('/admin/agendas/new');

    // Preencher dados básicos
    await page.fill('input[name="agenda[name]"]', 'Agenda de Teste');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.selectOption('select[name="agenda[default_visibility]"]', 'restricted');
    await page.fill('input[name="agenda[slot_duration_minutes]"]', '50');
    await page.fill('input[name="agenda[buffer_minutes]"]', '10');

    // Clicar em próximo
    await page.click('button[type="submit"]');

    // Verificar se foi redirecionado para a próxima etapa
    await expect(page).toHaveURL(/\/admin\/agendas\/\d+\/edit\?step=professionals/);
  });

  test('deve permitir vincular profissionais à agenda', async ({ page }) => {
    await page.goto('/admin/agendas/new');

    // Preencher dados básicos e ir para etapa de profissionais
    await page.fill('input[name="agenda[name]"]', 'Agenda de Teste');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.click('button[type="submit"]');

    // Aguardar carregamento dos profissionais
    await page.waitForSelector('[data-agendas-professionals-target="availableList"]');

    // Buscar profissional
    await page.fill('[data-agendas-professionals-target="searchInput"]', 'Dr.');
    await page.waitForTimeout(1000); // Aguardar busca AJAX

    // Selecionar primeiro profissional disponível
    const firstProfessional = page.locator('.professional-item').first();
    await firstProfessional.click();

    // Verificar se profissional foi adicionado à lista de selecionados
    await expect(page.locator('[data-agendas-professionals-target="selectedList"]')).toContainText(
      'Dr.'
    );

    // Clicar em próximo
    await page.click('button[type="submit"]');

    // Verificar se foi redirecionado para próxima etapa
    await expect(page).toHaveURL(/step=working_hours/);
  });

  test('deve permitir configurar horários de funcionamento', async ({ page }) => {
    await page.goto('/admin/agendas/new');

    // Preencher dados e ir para etapa de horários
    await page.fill('input[name="agenda[name]"]', 'Agenda de Teste');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.click('button[type="submit"]');

    // Etapa de profissionais (pular se necessário)
    await page.click('button[type="submit"]');

    // Configurar horários
    await page.check('input[data-day="1"]'); // Segunda-feira
    await page.check('input[data-day="2"]'); // Terça-feira

    // Adicionar período para segunda-feira
    await page.click('button[data-action="click->agendas-working-hours#addPeriod"][data-day="1"]');

    // Preencher horário
    await page.fill('input[data-day="1"][data-field="start_time"]', '08:00');
    await page.fill('input[data-day="1"][data-field="end_time"]', '17:00');

    // Clicar em próximo
    await page.click('button[type="submit"]');

    // Verificar se foi redirecionado para etapa de revisão
    await expect(page).toHaveURL(/step=review/);
  });

  test('deve permitir agendar anamnese e exibir no dashboard', async ({ page }) => {
    // Primeiro, criar uma agenda
    await page.goto('/admin/agendas/new');
    await page.fill('input[name="agenda[name]"]', 'Agenda de Anamnese');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.click('button[type="submit"]');

    // Pular etapas de profissionais e horários
    await page.click('button[type="submit"]');
    await page.click('button[type="submit"]');

    // Ativar agenda
    await page.click('button[type="submit"]');

    // Ir para portal de intakes
    await page.goto('/admin/portal_intakes');

    // Criar um intake
    await page.click('a[href*="/admin/portal_intakes/new"]');
    await page.fill('input[name="portal_intake[beneficiary_name]"]', 'João Silva');
    await page.fill('input[name="portal_intake[plan_name]"]', 'Plano Premium');
    await page.fill('input[name="portal_intake[card_code]"]', '123456');
    await page.click('button[type="submit"]');

    // Agendar anamnese
    const intakeLink = page.locator('a[href*="/schedule_anamnesis"]').first();
    await intakeLink.click();

    // Selecionar agenda e profissional
    await page.selectOption('select[name="agenda_id"]', '1');
    await page.selectOption('select[name="professional_id"]', '1');

    // Selecionar data e horário
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const dateString = tomorrow.toISOString().split('T')[0];

    await page.fill('input[name="scheduled_date"]', dateString);
    await page.selectOption('select[name="scheduled_time"]', '09:00');

    // Confirmar agendamento
    await page.click('button[type="submit"]');

    // Verificar se foi redirecionado com sucesso
    await expect(page).toHaveURL(/\/admin\/portal_intakes\/\d+/);
    await expect(page.locator('.alert-success')).toContainText('Anamnese agendada com sucesso');

    // Verificar no dashboard
    await page.goto('/admin');

    // Verificar se evento aparece no calendário
    await expect(page.locator('.unified-calendar')).toContainText('Anamnese - João Silva');
  });

  test('deve exibir eventos no dashboard corretamente', async ({ page }) => {
    await page.goto('/admin');

    // Verificar se calendário está presente
    await expect(page.locator('.unified-calendar')).toBeVisible();

    // Verificar se métricas estão sendo exibidas
    await expect(page.locator('text=Total de Eventos')).toBeVisible();
    await expect(page.locator('text=Eventos Hoje')).toBeVisible();
    await expect(page.locator('text=Próximos Eventos')).toBeVisible();

    // Verificar se lista de eventos está presente
    await expect(page.locator('text=Eventos da Semana')).toBeVisible();
  });

  test('deve permitir busca de profissionais via AJAX', async ({ page }) => {
    await page.goto('/admin/agendas/new');
    await page.fill('input[name="agenda[name]"]', 'Agenda de Teste');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.click('button[type="submit"]');

    // Aguardar carregamento dos profissionais
    await page.waitForSelector('[data-agendas-professionals-target="availableList"]');

    // Testar busca
    await page.fill('[data-agendas-professionals-target="searchInput"]', 'Dr.');

    // Aguardar resposta da busca
    await page.waitForTimeout(1000);

    // Verificar se resultados foram filtrados
    const professionalItems = page.locator('.professional-item');
    await expect(professionalItems).toHaveCount.greaterThan(0);
  });

  test('deve validar seleção de profissionais obrigatória', async ({ page }) => {
    await page.goto('/admin/agendas/new');
    await page.fill('input[name="agenda[name]"]', 'Agenda de Teste');
    await page.selectOption('select[name="agenda[service_type]"]', 'anamnese');
    await page.click('button[type="submit"]');

    // Tentar prosseguir sem selecionar profissionais
    await page.click('button[type="submit"]');

    // Verificar se permanece na mesma página
    await expect(page).toHaveURL(/step=professionals/);

    // Verificar se alerta de validação está presente
    await expect(page.locator('.ta-alert-warning')).toContainText(
      'É necessário selecionar pelo menos um profissional'
    );
  });
});
