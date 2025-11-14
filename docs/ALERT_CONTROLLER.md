# Alert Controller - Sistema de Alertas e Modais

Controller Stimulus para criar alertas e modais elegantes, similar ao SweetAlert2.

## ✨ Interceptação Automática

O sistema agora intercepta **automaticamente** todos os alertas nativos do JavaScript e flash messages do Rails, convertendo-os para o sistema customizado:

- ✅ `alert()` → Converte para modal customizado
- ✅ `confirm()` → Converte para modal de confirmação
- ✅ `prompt()` → Converte para modal com input
- ✅ Flash messages Rails (`notice`, `alert`, `warning`, `info`) → Converte automaticamente
- ✅ Turbo Streams → Intercepta e converte

**Não é necessário mudar código existente!** Todos os `alert()` e `confirm()` já existentes funcionarão automaticamente com o novo sistema.
