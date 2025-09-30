# Seeds para notícias da homepage
puts 'Criando notícias de exemplo...'

news_data = [
  {
    title: 'Nova funcionalidade de relatórios avançados',
    content: 'Estamos felizes em anunciar o lançamento da nova funcionalidade de relatórios avançados no IntegrarPlus. Agora você pode gerar relatórios personalizados com dados em tempo real, gráficos interativos e exportação em múltiplos formatos. Esta funcionalidade foi desenvolvida com base no feedback dos nossos usuários e promete revolucionar a forma como você analisa os dados da sua operadora.',
    author: 'Equipe IntegrarPlus',
    published: true,
    published_at: 1.day.ago
  },
  {
    title: 'Atualização de segurança e performance',
    content: 'Realizamos uma importante atualização do sistema que inclui melhorias significativas na segurança e performance. As principais mudanças incluem: criptografia aprimorada para proteção de dados, otimização do banco de dados para consultas mais rápidas, e implementação de novas medidas de segurança contra ataques. O sistema agora está ainda mais seguro e rápido para todos os usuários.',
    author: 'Equipe Técnica',
    published: true,
    published_at: 3.days.ago
  },
  {
    title: 'Workshop de capacitação para novos usuários',
    content: 'Estamos organizando um workshop online gratuito para capacitar novos usuários do IntegrarPlus. O evento será realizado no próximo mês e abordará tópicos como: configuração inicial do sistema, principais funcionalidades, dicas de produtividade e boas práticas. As vagas são limitadas e as inscrições já estão abertas. Não perca esta oportunidade de maximizar o uso da plataforma!',
    author: 'Equipe de Suporte',
    published: true,
    published_at: 1.week.ago
  },
  {
    title: 'Integração com novos sistemas de saúde',
    content: 'Expandimos nossa capacidade de integração com sistemas de saúde. Agora o IntegrarPlus é compatível com mais de 15 sistemas diferentes, incluindo os principais ERPs do mercado de saúde. Isso significa que você pode conectar seus dados existentes de forma mais fácil e eficiente, reduzindo o tempo de implementação e aumentando a produtividade da sua equipe.',
    author: 'Equipe de Desenvolvimento',
    published: true,
    published_at: 2.weeks.ago
  },
  {
    title: 'Melhorias na interface do usuário',
    content: 'Lançamos uma nova versão da interface do usuário com design mais moderno e intuitivo. As principais melhorias incluem: navegação simplificada, novos ícones e cores, responsividade aprimorada para dispositivos móveis, e acessibilidade melhorada. A nova interface foi desenvolvida com foco na experiência do usuário e promete tornar o uso do sistema ainda mais agradável e eficiente.',
    author: 'Equipe de UX/UI',
    published: true,
    published_at: 3.weeks.ago
  },
  {
    title: 'Suporte 24/7 agora disponível',
    content: 'Estamos felizes em anunciar que agora oferecemos suporte técnico 24 horas por dia, 7 dias por semana. Nossa equipe de suporte está sempre disponível para ajudar com qualquer dúvida ou problema que você possa ter. Você pode entrar em contato através do chat online, e-mail ou telefone. Estamos comprometidos em oferecer o melhor suporte possível para garantir o sucesso da sua operadora.',
    author: 'Equipe de Suporte',
    published: true,
    published_at: 1.month.ago
  }
]

news_data.each do |news_attrs|
  news = News.find_or_create_by(title: news_attrs[:title]) do |n|
    n.content = news_attrs[:content]
    n.author = news_attrs[:author]
    n.published = news_attrs[:published]
    n.published_at = news_attrs[:published_at]
  end

  puts "Notícia criada: #{news.title}"
end

puts '✅ Notícias criadas com sucesso!'


