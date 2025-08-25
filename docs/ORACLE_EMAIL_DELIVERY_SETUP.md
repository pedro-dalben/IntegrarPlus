# Configuração Oracle Email Delivery - Guia de Produção

## Resumo
Este documento descreve como configurar o Oracle Email Delivery (SMTP) no Rails para envio de e-mails em produção.

## Configurações Implementadas

### 1. Action Mailer (config/initializers/action_mailer.rb)
- Configuração SMTP para Oracle Email Delivery
- STARTTLS habilitado
- Autenticação PLAIN
- URLs corretas para links em e-mails

### 2. Devise
- Mailer sender configurado com variável de ambiente
- Templates personalizados para reset de senha

### 3. Sistema de Convites
- URLs dinâmicas baseadas em variáveis de ambiente
- Templates HTML personalizados

## Variáveis de Ambiente Necessárias

### Desenvolvimento (.env)
```bash
# === Oracle Email Delivery (SMTP) ===
OCI_SMTP_HOST="smtp.email.sa-saopaulo-1.oci.oraclecloud.com"
OCI_SMTP_PORT="587"
OCI_SMTP_USERNAME="seu_username_smtp"
OCI_SMTP_PASSWORD="sua_senha_smtp"

# === Domínio / remetente ===
MAIL_DOMAIN="integrarplus.com.br"
MAIL_FROM="contato@integrarplus.com.br"

# === Host da aplicação ===
APP_HOST="localhost:3001"
APP_PROTOCOL="http"
```

### Produção
```bash
# === Oracle Email Delivery (SMTP) ===
OCI_SMTP_HOST="smtp.email.sa-saopaulo-1.oci.oraclecloud.com"
OCI_SMTP_PORT="587"
OCI_SMTP_USERNAME="ocid1.user.oc1..SEU_USER_SMTP@ocid1.tenancy.oc1..SEU_TENANCY_SMTP.om.com"
OCI_SMTP_PASSWORD="SUA_SENHA_SMTP_GERADA"

# === Domínio / remetente ===
MAIL_DOMAIN="integrarplus.com.br"
MAIL_FROM="contato@integrarplus.com.br"

# === Host da aplicação ===
APP_HOST="app.integrarplus.com.br"  # Seu domínio real
APP_PROTOCOL="https"
```

## Configuração em Produção

### 1. Variáveis de Ambiente
Configure as variáveis acima no seu ambiente de produção:

**Docker/Docker Compose:**
```yaml
environment:
  - OCI_SMTP_HOST=smtp.email.sa-saopaulo-1.oci.oraclecloud.com
  - OCI_SMTP_PORT=587
  - OCI_SMTP_USERNAME=seu_username
  - OCI_SMTP_PASSWORD=sua_senha
  - MAIL_DOMAIN=integrarplus.com.br
  - MAIL_FROM=contato@integrarplus.com.br
  - APP_HOST=app.integrarplus.com.br
  - APP_PROTOCOL=https
```

**Kubernetes:**
```yaml
env:
  - name: OCI_SMTP_HOST
    value: "smtp.email.sa-saopaulo-1.oci.oraclecloud.com"
  - name: OCI_SMTP_USERNAME
    valueFrom:
      secretKeyRef:
        name: email-secrets
        key: smtp-username
  - name: OCI_SMTP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: email-secrets
        key: smtp-password
```

**Heroku/Railway/Render:**
Configure as variáveis no painel de controle da plataforma.

### 2. DNS (já configurado)
- **SPF:** `v=spf1 include:rp.oracleemaildelivery.com -all`
- **DKIM:** `integrarplus202508._domainkey` → `integrarplus202508.dkim.gru1.oracleemaildelivery.com`
- **DMARC:** `v=DMARC1; p=quarantine; rua=mailto:postmaster@integrarplus.com.br`

### 3. Credenciais Oracle
1. Acesse o Console da Oracle Cloud
2. Vá para Identity & Security → Users
3. Selecione o usuário SMTP
4. Gere SMTP Credentials
5. Use o username e password gerados

## Testes

### Teste Básico
```bash
# No servidor de produção
rake emails:test[seu@email.com]
```

### Diagnóstico Completo
```bash
rake emails:diagnostic
```

### Teste de Convite
```ruby
# No console Rails
user = User.find_by(email: "usuario@exemplo.com")
invite = user.invites.create!
InviteMailer.invite_email(invite).deliver_now
```

## Monitoramento

### Logs do Rails
Monitore os logs para erros de SMTP:
```bash
tail -f log/production.log | grep -i smtp
```

### Verificação de Entrega
Após enviar e-mails, verifique nos cabeçalhos:
- `spf=pass`
- `dkim=pass header.s=integrarplus202508`
- `dmarc=pass`

### Métricas Oracle
- Acesse o painel da Oracle Email Delivery
- Monitore taxa de entrega e bounces
- Verifique status do DKIM

## Troubleshooting

### Erro: "Authentication failed"
- Verifique username/password SMTP
- Confirme que as credenciais não expiraram

### Erro: "Connection timeout"
- Verifique firewall/security groups
- Confirme porta 587 aberta

### E-mails caindo em spam
- Aguarde warm-up da reputação (alguns dias)
- Verifique se DKIM está "Active" na Oracle
- Confirme configurações SPF/DMARC

### Links quebrados em e-mails
- Verifique `APP_HOST` e `APP_PROTOCOL`
- Confirme que o domínio está acessível

## Segurança

1. **Nunca commite credenciais** no código
2. Use **secrets management** em produção
3. **Rotacione credenciais** periodicamente
4. **Monitore logs** para tentativas de abuso
5. Configure **rate limiting** se necessário

## Comandos Úteis

```bash
# Testar configuração SMTP manualmente
swaks --server smtp.email.sa-saopaulo-1.oci.oraclecloud.com:587 \
      --tls --auth PLAIN \
      --auth-user "seu_username" \
      --auth-password "sua_senha" \
      --from "contato@integrarplus.com.br" \
      --to "teste@exemplo.com"

# Verificar DNS
dig TXT integrarplus.com.br
dig TXT _dmarc.integrarplus.com.br
dig CNAME integrarplus202508._domainkey.integrarplus.com.br
```
