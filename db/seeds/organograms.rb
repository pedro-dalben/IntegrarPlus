# frozen_string_literal: true

# Seeds para Organogramas
puts "Criando organogramas de exemplo..."

# Encontrar um usuário para ser o criador
admin_user = User.joins(:groups).where(groups: { is_admin: true }).first || User.first

if admin_user.nil?
  puts "  ⚠️  Nenhum usuário encontrado. Pule a criação de organogramas."
  return
end

# Organograma 1 - Empresa Pequena
organogram1 = Organogram.find_or_create_by(name: "Organograma - Empresa Tecnologia") do |org|
  org.created_by = admin_user
  org.data = {
    nodes: [
      {
        id: "ceo",
        text: "João Silva",
        title: "CEO",
        type: "card",
        data: {
          department: "Diretoria",
          email: "joao.silva@empresa.com",
          phone: "11999990001"
        }
      },
      {
        id: "cto",
        text: "Maria Santos",
        title: "CTO",
        parent: "ceo",
        type: "card",
        data: {
          department: "Tecnologia",
          email: "maria.santos@empresa.com",
          phone: "11999990002"
        }
      },
      {
        id: "cfo",
        text: "Pedro Oliveira",
        title: "CFO",
        parent: "ceo",
        type: "card",
        data: {
          department: "Financeiro",
          email: "pedro.oliveira@empresa.com",
          phone: "11999990003"
        }
      },
      {
        id: "dev_lead",
        text: "Ana Costa",
        title: "Tech Lead",
        parent: "cto",
        type: "card",
        data: {
          department: "Desenvolvimento",
          email: "ana.costa@empresa.com",
          phone: "11999990004"
        }
      },
      {
        id: "dev1",
        text: "Carlos Lima",
        title: "Desenvolvedor Sênior",
        parent: "dev_lead",
        type: "card",
        data: {
          department: "Desenvolvimento",
          email: "carlos.lima@empresa.com",
          phone: "11999990005"
        }
      },
      {
        id: "dev2",
        text: "Fernanda Rocha",
        title: "Desenvolvedora Pleno",
        parent: "dev_lead",
        type: "card",
        data: {
          department: "Desenvolvimento",
          email: "fernanda.rocha@empresa.com",
          phone: "11999990006"
        }
      },
      {
        id: "qa_lead",
        text: "Roberto Alves",
        title: "QA Lead",
        parent: "cto",
        type: "card",
        data: {
          department: "Qualidade",
          email: "roberto.alves@empresa.com",
          phone: "11999990007"
        }
      },
      {
        id: "qa1",
        text: "Juliana Mendes",
        title: "QA Analyst",
        parent: "qa_lead",
        type: "card",
        data: {
          department: "Qualidade",
          email: "juliana.mendes@empresa.com",
          phone: "11999990008"
        }
      },
      {
        id: "finance1",
        text: "Marcos Fernandes",
        title: "Analista Financeiro",
        parent: "cfo",
        type: "card",
        data: {
          department: "Financeiro",
          email: "marcos.fernandes@empresa.com",
          phone: "11999990009"
        }
      },
      {
        id: "hr1",
        text: "Luciana Gomes",
        title: "Gerente de RH",
        parent: "ceo",
        type: "card",
        data: {
          department: "Recursos Humanos",
          email: "luciana.gomes@empresa.com",
          phone: "11999990010"
        }
      }
    ],
    links: []
  }
  org.settings = {
    layout: "org",
    theme: "default",
    zoom: 1
  }
  org.published_at = 1.week.ago
end

puts "  ✓ Organograma '#{organogram1.name}' criado (#{organogram1.nodes_count} nós)"

# Organograma 2 - Estrutura Simples (não publicado)
organogram2 = Organogram.find_or_create_by(name: "Organograma - Departamento TI") do |org|
  org.created_by = admin_user
  org.data = {
    nodes: [
      {
        id: "ti_manager",
        text: "Sandra Pereira",
        title: "Gerente de TI",
        type: "card",
        data: {
          department: "Tecnologia da Informação",
          email: "sandra.pereira@empresa.com",
          phone: "11999991001"
        }
      },
      {
        id: "dev_team",
        text: "Equipe Desenvolvimento",
        title: "Desenvolvedores",
        parent: "ti_manager",
        type: "card",
        data: {
          department: "Desenvolvimento",
          email: "dev-team@empresa.com"
        }
      },
      {
        id: "infra_team",
        text: "Equipe Infraestrutura",
        title: "DevOps/Infraestrutura",
        parent: "ti_manager",
        type: "card",
        data: {
          department: "Infraestrutura",
          email: "infra-team@empresa.com"
        }
      },
      {
        id: "support_team",
        text: "Equipe Suporte",
        title: "Suporte Técnico",
        parent: "ti_manager",
        type: "card",
        data: {
          department: "Suporte",
          email: "support@empresa.com"
        }
      }
    ],
    links: []
  }
  org.settings = {
    layout: "org",
    theme: "default",
    zoom: 1.2
  }
  # Este não está publicado (rascunho)
end

puts "  ✓ Organograma '#{organogram2.name}' criado (#{organogram2.nodes_count} nós)"

# Organograma 3 - Estrutura Hospitalar
organogram3 = Organogram.find_or_create_by(name: "Organograma - Hospital") do |org|
  org.created_by = admin_user
  org.data = {
    nodes: [
      {
        id: "director",
        text: "Dr. José Carlos",
        title: "Diretor Geral",
        type: "card",
        data: {
          department: "Diretoria",
          email: "diretor@hospital.com",
          phone: "11888880001"
        }
      },
      {
        id: "clinical_director",
        text: "Dra. Maria Fernanda",
        title: "Diretora Clínica",
        parent: "director",
        type: "card",
        data: {
          department: "Clínica",
          email: "maria.fernanda@hospital.com",
          phone: "11888880002"
        }
      },
      {
        id: "admin_director",
        text: "Carlos Eduardo",
        title: "Diretor Administrativo",
        parent: "director",
        type: "card",
        data: {
          department: "Administrativo",
          email: "carlos.eduardo@hospital.com",
          phone: "11888880003"
        }
      },
      {
        id: "nursing_coord",
        text: "Enfª. Ana Beatriz",
        title: "Coordenadora de Enfermagem",
        parent: "clinical_director",
        type: "card",
        data: {
          department: "Enfermagem",
          email: "ana.beatriz@hospital.com",
          phone: "11888880004"
        }
      },
      {
        id: "emergency_coord",
        text: "Dr. Ricardo Mendes",
        title: "Coordenador Emergência",
        parent: "clinical_director",
        type: "card",
        data: {
          department: "Emergência",
          email: "ricardo.mendes@hospital.com",
          phone: "11888880005"
        }
      },
      {
        id: "surgery_coord",
        text: "Dr. Paulo Henrique",
        title: "Coordenador Cirurgia",
        parent: "clinical_director",
        type: "card",
        data: {
          department: "Cirurgia",
          email: "paulo.henrique@hospital.com",
          phone: "11888880006"
        }
      },
      {
        id: "finance_coord",
        text: "Lúcia Andrade",
        title: "Coordenadora Financeiro",
        parent: "admin_director",
        type: "card",
        data: {
          department: "Financeiro",
          email: "lucia.andrade@hospital.com",
          phone: "11888880007"
        }
      },
      {
        id: "hr_coord",
        text: "Roberto Silva",
        title: "Coordenador RH",
        parent: "admin_director",
        type: "card",
        data: {
          department: "Recursos Humanos",
          email: "roberto.silva@hospital.com",
          phone: "11888880008"
        }
      }
    ],
    links: []
  }
  org.settings = {
    layout: "org",
    theme: "default",
    zoom: 0.8
  }
  org.published_at = 3.days.ago
end

puts "  ✓ Organograma '#{organogram3.name}' criado (#{organogram3.nodes_count} nós)"

# Criar alguns membros de exemplo para o primeiro organograma
puts "Criando membros de organograma..."

members_data = [
  {
    external_id: "emp001",
    name: "João Silva",
    role_title: "CEO",
    department: "Diretoria",
    email: "joao.silva@empresa.com",
    phone: "11999990001"
  },
  {
    external_id: "emp002",
    name: "Maria Santos",
    role_title: "CTO",
    department: "Tecnologia",
    email: "maria.santos@empresa.com",
    phone: "11999990002"
  },
  {
    external_id: "emp003",
    name: "Pedro Oliveira",
    role_title: "CFO",
    department: "Financeiro",
    email: "pedro.oliveira@empresa.com",
    phone: "11999990003"
  }
]

members_data.each do |member_data|
  member = organogram1.organogram_members.find_or_create_by(external_id: member_data[:external_id]) do |m|
    m.name = member_data[:name]
    m.role_title = member_data[:role_title]
    m.department = member_data[:department]
    m.email = member_data[:email]
    m.phone = member_data[:phone]
    m.meta = { imported_at: Time.current }
  end

  puts "  ✓ Membro '#{member.name}' criado"
end

puts "✅ Seeds de organogramas criados com sucesso!"
puts "   - #{Organogram.count} organogramas total"
puts "   - #{Organogram.published.count} organogramas publicados"
puts "   - #{OrganogramMember.count} membros total"
