# 🚀 Guia de Seeds - IntegrarPlus

## 📋 Visão Geral

Este guia explica como usar os seeds do projeto IntegrarPlus de forma segura, evitando problemas de autenticação e garantindo que todos os dados necessários sejam criados corretamente.

## ⚠️ Problemas Comuns e Soluções

### 1. **Erro de Autenticação (Senha Inválida)**
**Sintoma:** Usuário não consegue fazer login mesmo com credenciais corretas
**Causa:** Problemas na criptografia da senha ou usuário não confirmado
**Solução:** Executar seeds novamente ou recriar usuário manualmente

### 2. **Usuário Admin Não Confirmado**
**Sintoma:** Login falha com erro de confirmação
**Causa:** Usuário criado sem `confirmed_at`
**Solução:** Seeds agora confirmam automaticamente o usuário admin

## 🔧 Como Executar os Seeds

### **Desenvolvimento**
```bash
# Executar seeds básicos
bin/rails db:seed

# Executar seeds específicos
bin/rails db:seed:replant  # Limpa e recria tudo
```

### **Produção**
```bash
# Executar seeds em produção
RAILS_ENV=production bin/rails db:seed

# Verificar se funcionou
RAILS_ENV=production bin/rails console
# No console: User.find_by(email: 'admin@integrarplus.com').valid_password?('123456')
```

## 📊 O que os Seeds Criam

### **Dados Padrão**
- ✅ **Tipos de Contrato:** CLT, PJ, Autônomo
- ✅ **Especialidades:** Fonoaudiologia, Psicologia, Terapia Ocupacional
- ✅ **Especializações:** Subáreas de cada especialidade
- ✅ **Grupos:** Administradores, Coordenadores, Profissionais, etc.
- ✅ **Usuário Admin:** admin@integrarplus.com / 123456

### **Verificações Automáticas**
- 🔍 Validação da senha do usuário admin
- 🔍 Confirmação automática do usuário
- 🔍 Recriação automática se houver problemas
- 🔍 Relatórios detalhados de status

## 🛡️ Segurança

### **Credenciais Padrão**
- **Email:** admin@integrarplus.com
- **Senha:** 123456
- **⚠️ IMPORTANTE:** Altere a senha após o primeiro login!

### **Ambiente de Produção**
- Seeds funcionam em todos os ambientes
- Usuário admin é criado automaticamente
- Confirmação é feita automaticamente

## 🔍 Troubleshooting

### **Seeds Falharam**
```bash
# Verificar logs
tail -f log/production.log

# Executar seeds novamente
RAILS_ENV=production bin/rails db:seed

# Verificar usuário manualmente
RAILS_ENV=production bin/rails console
admin_user = User.find_by(email: 'admin@integrarplus.com')
puts "Status: #{admin_user&.active ? 'Ativo' : 'Inativo'}"
puts "Confirmado: #{admin_user&.confirmed_at ? 'Sim' : 'Não'}"
puts "Senha válida: #{admin_user&.valid_password?('123456') ? 'Sim' : 'Não'}"
```

### **Usuário Admin Não Funciona**
```ruby
# No console Rails
admin_user = User.find_by(email: 'admin@integrarplus.com')

# Recriar usuário
admin_user.destroy! if admin_user
admin_professional = Professional.find_by(email: 'admin@integrarplus.com')
admin_user = User.create!(
  email: 'admin@integrarplus.com',
  password: '123456',
  password_confirmation: '123456',
  professional: admin_professional,
  active: true,
  confirmed_at: Time.current
)

# Verificar se funcionou
puts "Senha válida: #{admin_user.valid_password?('123456')}"
```

## 📝 Logs de Seeds

Os seeds agora geram logs detalhados:
```
✅ Usuário admin criado: admin@integrarplus.com com senha: 123456
✅ Senha do usuário admin validada com sucesso
✅ Profissional admin associado ao grupo: Administradores

🎉 Seeds executados com sucesso!
📋 Usuário admin disponível:
   Email: admin@integrarplus.com
   Senha: 123456
   Status: Ativo
   Confirmado: Sim
   Senha válida: Sim
```

## 🚨 Problemas Conhecidos

### **1. Chave Mestra (master.key)**
- **Problema:** `ActiveSupport::MessageEncryptor::InvalidMessage`
- **Solução:** Verificar se `RAILS_MASTER_KEY` está definida no `.env`

### **2. Módulo Confirmable**
- **Problema:** Usuário não confirmado
- **Solução:** Seeds agora confirmam automaticamente

### **3. Criptografia de Senha**
- **Problema:** Senha não validada
- **Solução:** Seeds verificam e recriam usuário se necessário

## 📞 Suporte

Se os seeds continuarem falhando:
1. Verifique os logs do Rails
2. Confirme que as variáveis de ambiente estão corretas
3. Execute os seeds em modo verbose
4. Consulte este guia para troubleshooting específico
