class ContractTextBuilder
  def initialize(clause_service = ContractClauseService.new)
    @clause_service = clause_service
  end

  def build_contract_text(contract)
    template = contract_template
    replace_variables(template, contract)
  end

  def build_anexo_text(contract)
    return '' unless contract.job_role

    template = anexo_template
    replace_anexo_variables(template, contract)
  end

  def build_termo_text(contract)
    template = termo_template
    replace_variables(template, contract)
  end

  private

  def contract_template
    <<~TEMPLATE
      **CONTRATO DE PRESTAÇÃO DE SERVIÇOS ESPECIALIZADOS**

      Pelo presente Contrato e na melhor forma de direito, de um lado:

      **CONTRATANTE:** INTEGRAR CENTRO TERAPÊUTICO DA BAIXA MOGIANA LTDA, inscrita no CNPJ sob nº 44.533.956/0001-04, situada à Rua Sergipe, nº 110, bairro Saúde, na cidade de Mogi Mirim/SP, CEP 13800-719, neste ato representada por suas sócias administradoras DANIELA DALBEN MOTA, brasileira, casada, fisioterapeuta, RG nº 23.075.793-5 SSP/SP, CPF nº 266.620.958-00, e GIOVANA GARCIA MOREIRA FRANÇOSO, brasileira, casada, fisioterapeuta, RG nº 33.583.976-9 SSP/SP, CPF nº 218.492.838-00.

      A **CONTRATANTE** poderá atuar também por meio de suas filiais já constituídas ou que venham a ser futuramente abertas, localizadas na cidade de Mogi Mirim/SP ou em outras localidades, conforme necessidade institucional.

      **CONTRATADA (O):** {{contratado_qualificacao_completa}}, doravante denominada apenas **CONTRATADA (O).**

      {{contratado_dados_empresa}}

      **Nacionalidade:** {{contratado_nacionalidade}}

      **Formação Profissional:** {{contratado_formacao}}

      **RG:** {{contratado_rg}}

      **CPF:** {{contratado_cpf}}

      **Nº do Registro do Conselho:** {{contratado_registro_conselho}}

      Celebram o presente **CONTRATO DE PRESTAÇÃO DE SERVIÇOS ESPECIALIZADOS SEM VÍNCULO EMPREGATÍCIO (CLT),** mediante as condições estabelecidas a seguir:

      {{clausulas}}

      {{clausula_17}}

      {{clausulas_finais}}

      Por estarem assim justos e contratados, firmam o presente instrumento, em duas vias de igual teor, na presença de 03 (três) testemunhas, a fim de produzam todos os efeitos legais.

      Mogi Mirim, {{data}}.

      _____________________________
      **INTEGRAR CENTRO TERAPEUTICO DA BAIXA MOGIANA LTDA.**
      **CNPJ 44.533.956/0001-04**

      _____________________________
      **CONTRATADA (O)**
      {{contratado_cnpj_empresa}}

      **Testemunhas:**

      _____________________________ _____________________________

      **Nome:** **Nome:**

      **RG n°** **RG n°**

      **CPF nº** **CPF nº**

      _____________________________

      **Nome:**

      **RG n°**

      **CPF nº**
    TEMPLATE
  end

  def anexo_template
    <<~TEMPLATE
      **ANEXO I - ATRIBUIÇÃO DE CARGO**

      **CONTRATO DE PRESTAÇÃO DE SERVIÇOS CELEBRADO ENTRE**
      **{{contratante_nome}}** E **{{contratado_nome}}**

      **ATRIBUIÇÃO DE CARGO:** {{cargo_nome}}

      {{descricao_cargo}}

      {{local}}, {{data}}

      _____________________________
      **CONTRATANTE**

      _____________________________
      **CONTRATADO**
    TEMPLATE
  end

  def termo_template
    <<~TEMPLATE
      **TERMO DE AUTORIZAÇÃO DE USO DE IMAGEM**

      Eu, **{{contratado_nome}}**, {{contratado_nacionalidade}}, portador do RG nº {{contratado_rg}}, CPF nº {{contratado_cpf}}, autorizo o uso de minha imagem, voz e nome para fins de divulgação institucional, publicidade e materiais promocionais da **{{contratante_nome}}**.

      Esta autorização é concedida de forma gratuita e irrestrita, podendo ser utilizada em qualquer meio de comunicação, incluindo, mas não se limitando a: sites, redes sociais, materiais impressos, vídeos e demais materiais promocionais.

      {{local}}, {{data}}

      _____________________________
      **{{contratado_nome}}**
      **RG:** {{contratado_rg}} | **CPF:** {{contratado_cpf}}
    TEMPLATE
  end

  def replace_variables(text, contract)
    professional = contract.professional
    text = text.gsub('{{contratado_nome}}', professional.full_name || '')
    text = text.gsub('{{contratado_nacionalidade}}', contract.nationality || '')
    text = text.gsub('{{contratado_rg}}', contract.rg || '')
    text = text.gsub('{{contratado_cpf}}', contract.cpf || professional.cpf || '')
    text = text.gsub('{{contratado_endereco_completo}}', format_address(professional.primary_address))
    text = text.gsub('{{contratado_formacao}}', contract.professional_formation || '')
    text = text.gsub('{{contratado_registro_conselho}}', contract.council_registration_number || '')
    
    if contract.pj?
      text = text.gsub('{{contratado_qualificacao_completa}}', "#{professional.full_name || ''}, inscrita no CNPJ sob o nº #{contract.company_cnpj || ''}, situada à #{contract.company_address || ''}, neste ato representada por #{contract.company_represented_by || ''}")
      text = text.gsub('{{contratado_dados_empresa}}', "**CNPJ da empresa:** #{contract.company_cnpj || ''}\n\n**Endereço da empresa:** #{contract.company_address || ''}\n\n**Representada por:** #{contract.company_represented_by || ''}")
      text = text.gsub('{{contratado_cnpj_empresa}}', "**CNPJ #{contract.company_cnpj || ''}**")
    else
      text = text.gsub('{{contratado_qualificacao_completa}}', "#{professional.full_name || ''}, #{contract.nationality || ''}, portador do RG nº #{contract.rg || ''}, CPF nº #{contract.cpf || professional.cpf || ''}, #{format_address(professional.primary_address)}")
      text = text.gsub('{{contratado_dados_empresa}}', '')
      text = text.gsub('{{contratado_cnpj_empresa}}', "**CPF #{contract.cpf || professional.cpf || ''}**")
    end
    
    text = text.gsub('{{clausula_17}}', @clause_service.clause_17_text(contract))
    text = text.gsub('{{clausulas}}', default_clauses)
    final_clauses_text = @clause_service.final_clauses.gsub('{{data_inicio}}', format_date_pt_br(Date.current))
    text = text.gsub('{{clausulas_finais}}', final_clauses_text)
    text = text.gsub('{{local}}', 'Mogi Mirim')
    text = text.gsub('{{data}}', format_date_pt_br(Date.current))
    text
  end

  def replace_anexo_variables(text, contract)
    professional = contract.professional
    job_role = contract.job_role
    text = text.gsub('{{contratado_nome}}', professional.full_name || '')
    text = text.gsub('{{contratante_nome}}', 'Integrar')
    text = text.gsub('{{cargo_nome}}', job_role.name || '')
    text = text.gsub('{{descricao_cargo}}', job_role.description || '')
    text = text.gsub('{{local}}', 'São Paulo')
    text = text.gsub('{{data}}', format_date_pt_br(Date.current))
    text
  end

  def format_date_pt_br(date)
    months = {
      1 => 'janeiro', 2 => 'fevereiro', 3 => 'março', 4 => 'abril',
      5 => 'maio', 6 => 'junho', 7 => 'julho', 8 => 'agosto',
      9 => 'setembro', 10 => 'outubro', 11 => 'novembro', 12 => 'dezembro'
    }
    "#{date.day} de #{months[date.month]} de #{date.year}"
  end

  def format_address(address)
    return '' unless address

    parts = []
    parts << address.street if address.street.present?
    parts << "nº #{address.number}" if address.number.present?
    parts << address.complement if address.complement.present?
    parts << address.neighborhood if address.neighborhood.present?
    parts << "#{address.city}/#{address.state}" if address.city.present? && address.state.present?
    parts << "CEP: #{address.zip_code}" if address.zip_code.present?
    parts.join(', ')
  end

  def default_clauses
    <<~CLAUSES
      **DO OBJETO DO CONTRATO**

      **Cláusula 1ª.** O presente contrato está fundamentado nos princípios e diretrizes da **ciência ABA (Análise do Comportamento Aplicada),** metodologia que norteia os programas terapêuticos e educacionais do **INTEGRAR CENTRO TERAPÊUTICO DA BAIXA MOGIANA LTDA**, instituição certificada com o **Nível 1 de Acreditação em Saúde**, conforme os critérios de qualidade e segurança definidos pelos órgãos competentes. Por meio deste contrato, a **CONTRATADA (O)** se compromete a prestar ao **INTEGRAR CENTRO TERAPÊUTICO DA BAIXA MOGIANA LTDA** os serviços conforme **Anexo I.** Esses serviços são destinados ao atendimento dos beneficiários, bem como ao suporte técnico, educacional e administrativo a familiares, instituições escolares, profissionais da rede de apoio, equipe multiprofissional e outros prestadores de serviço que demandarem relatórios, orientações e/ou acompanhamento, conforme as diretrizes da **CONTRATANTE** priorizando sempre a qualidade e a integração multiprofissional dos serviços ofertados, respeitando os princípios do atendimento integral, que abrangem ações voltadas à promoção da autonomia, bem-estar e funcionalidade dos beneficiários, conforme os objetivos dos programas terapêuticos individualizados. As atribuições específicas a serem contratadas estarão descritas no **Anexo I** deste contrato, elaborado conforme os programas terapêuticos instituídos pela **CONTRATANTE** e baseados na ciência ABA.

      **DO LOCAL DA PRESTAÇÃO DOS SERVIÇOS**

      Os serviços serão prestados nas dependências da **CONTRATANTE**, podendo ser em sua sede, localizada na Rua Sergipe, nº 110, Bairro Saúde, CEP 13.800-719, Mogi Mirim - SP; em suas filiais atualmente existentes ou que venham a ser constituídas; ou ainda em outros ambientes a serem definidos após a avaliação do beneficiário, como residências, escolas, entre outros.

      **Parágrafo Único:** O deslocamento deverá ser realizado com o uso de veículo próprio, **DA CONTRATADA (O)** sempre respeitando a **natureza do contrato de prestação de serviços, sem vínculo empregatício (CLT).**

      **DA PROTEÇÃO DE DADOS PESSOAIS**

      **Cláusula 2ª**. As partes contratantes se submetem à Lei nº 13.709, de 14 de agosto de 2018 (Lei Geral de Proteção de Dados Pessoais - LGPD), uma vez que o cumprimento do objeto contratual exige o comprometimento de sigilo de dados pessoais:

      - Os dados pessoais colhidos para realizar quaisquer tipos de tratamentos deverão ser mínimos, não devendo ser utilizadas informações desnecessárias ou incompatíveis com o tratamento;
      - **A CONTRATADA (O)** se compromete a manter sigilo em relação às informações pessoais dos beneficiários da **CONTRATANTE**, sendo proibido o compartilhamento de quaisquer dados pessoais;
      - O tratamento de dados pessoais de crianças e de adolescentes deverá ser realizado em seu melhor interesse, observando os termos dispostos no artigo 14 da LGPD, bem como da legislação protetiva dos menores;
      - Os dados pessoais deverão ser excluídos após o término do seu tratamento no âmbito e nos limites técnicos das atividades, autorizada a conservação somente para as hipóteses previstas no artigo 16 da LGPD;
      - A **CONTRATADA (O)** jamais poderá compartilhar dados de login e senhas com terceiros, uma vez que são de uso pessoal, sendo, portanto, intransferíveis e de conhecimento exclusivo do próprio usuário, sob pena de ato infracional a ser apurado no Poder Judiciário;
      - A **CONTRATADA (O)** deverá possuir canal de informação seguro para beneficiários e prestadores de serviços, a fim de que possam reportar suas demandas;
      - A **CONTRATADA (O)** está expressamente proibida de copiar, reproduzir ou distribuir documentos, arquivos ou qualquer informação que não seja autorizada pela **CONTRATANTE**;
      - A **CONTRATADA (O)** deverá comunicar, imediatamente, caso ocorra incidente de vazamento de dados;
      - A **CONTRATADA (O)** deverá manter os dados armazenados em banco de dados seguro, garantindo assim confiabilidade de informação, vedando-se o compartilhamento de dados com terceiros;
      - A **CONTRATADA (O)** declara estar ciente de que o tratamento de dados pessoais é parte integrante da execução dos serviços contratados, comprometendo-se a adotar medidas técnicas e administrativas aptas a proteger os dados contra acessos não autorizados, perdas, alterações, comunicação ou qualquer forma de tratamento inadequado ou ilícito, conforme dispõe o artigo 46 da LGPD;
      - A **CONTRATADA (O)** compromete-se a permitir auditorias, quando previamente notificadas pela **CONTRATANTE**, para fins de verificação do cumprimento das obrigações previstas nesta cláusula, bem como a colaborar com eventuais solicitações da Autoridade Nacional de Proteção de Dados (ANPD), se necessário.

      **DA CONFIDENCIALIDADE OPERACIONAL E DA OBRIGATORIEDADE DE EQUIPAMENTO**

      **Cláusula 3ª.** **A CONTRATADA (O)** se compromete a manter absoluto sigilo sobre todas as informações, dados, documentos e procedimentos aos quais tiver acesso nas dependências **da CONTRATANTE** ou no exercício de suas funções, sendo vedada qualquer divulgação, reprodução ou uso para fins não autorizados.

      **Cláusula 4ª.** **A CONTRATADA (O)** obriga-se a realizar a alimentação dos dados assistenciais, administrativos ou operacionais diretamente no sistema utilizado pela **CONTRATANTE**, devendo, para isso, dispor de instrumento eletrônico próprio (celular, tablet ou notebook) com acesso à internet e recursos mínimos para execução das tarefas.

      **Parágrafo único**. O não cumprimento dessa obrigação poderá implicar em rescisão contratual.

      **Cláusula 5ª.** O uso do sistema deve seguir os critérios de sigilo, ética profissional e boas práticas de segurança da informação, estando a **CONTRATADA (O)** sujeita às disposições da Cláusula 2ª deste contrato, bem como à legislação vigente sobre proteção de dados e responsabilidade civil.

      **DAS OBRIGAÇÕES DA CONTRATADA (O)**

      **Cláusula 6ª.** A **CONTRATADA (O)** se responsabiliza por eventuais descumprimentos do **Código de Ética Profissional**, **quando houver**, **ou das normas técnicas e institucionais aplicáveis às tarefas descritas no Anexo I** respondendo exclusivamente pelos atos praticados no exercício de suas atividades;

      **Cláusula 7ª.** A **CONTRATADA (O)** se obriga a fornecer à **CONTRATANTE** todos os dados relativos ao andamento dos serviços pactuados neste contrato, responsabilizando-se pelos documentos que estiverem sob sua guarda, salvo nos casos de comprovado caso fortuito ou força maior;

      **Cláusula 8ª.** Quando aplicável, a **CONTRATADA (O)** deverá manter ativo o seu registro profissional junto ao Conselho de Classe correspondente à sua área de atuação. Para funções que não exigem registro em Conselho, a **CONTRATANTE** poderá estabelecer critérios próprios de qualificação e conduta, nos termos de seu Regimento Interno;

      **Cláusula 9ª.** A **CONTRATADA (O)** deverá arcar com todas as despesas e obrigações de natureza tributária, previdenciária e fiscal relacionadas à prestação dos serviços, conforme sua natureza jurídica e a legislação vigente, **sem qualquer vínculo empregatício (CLT);**

      **Cláusula 10ª.** A **CONTRATADA (O)** deverá respeitar os beneficiários e seus familiares em todos os atendimentos, observando os princípios da ética, dignidade e inclusão;

      **Cláusula 11ª.** A **CONTRATADA (O)** deverá observar e aplicar as diretrizes técnicas, metodológicas e procedimentais adotadas pela **CONTRATANTE**, assegurando que suas atividades estejam alinhadas à metodologia institucional e aos fluxos organizacionais vigentes. Deverá, ainda, seguir o Regimento Interno, os Procedimentos Operacionais Padrão (POPs) e demais normas que orientam o desenvolvimento das atividades, de modo a garantir a coerência, a padronização e a qualidade dos serviços prestados.

      **Cláusula 12ª.** A **CONTRATADA (O)** fará uso de veículo próprio, quando necessário, para a execução de suas atividades, sem que isso gere qualquer ônus adicional à **CONTRATANTE**. Em casos específicos, **previamente autorizados pela CONTRATANTE,** as despesas decorrentes poderão ser reembolsadas, observadas as condições e critérios estabelecidos na política interna de reembolso vigente.

      **Cláusula 13.ª** Todas as atividades descritas no **Anexo I** estarão sujeitas à avaliação pela **CONTRATANTE**, quanto aos aspectos metodológicos, ético-profissionais e aos princípios administrativos que orientam as práticas institucionais da **CONTRATANTE**. Essa avaliação tem por objetivo assegurar a padronização, a qualidade técnica e a conformidade das atividades executadas com as diretrizes e valores institucionais.

      **DO PREÇO E DAS CONDIÇÕES DE PAGAMENTO E REAJUSTES**

      **Cláusula 14ª.** As partes acordam que todas as informações relativas a este contrato, especialmente o valor pactuado para a prestação dos serviços, deverão ser mantidas em sigilo absoluto, sendo vedada sua divulgação a terceiros, ainda que o serviço não venha a ser efetivamente prestado. Tal obrigação decorre dos princípios de boa-fé e lealdade contratual (art. 422 do Código Civil), das normas éticas dos conselhos profissionais competentes e da legislação vigente sobre proteção de dados. A quebra desta confidencialidade configurará violação contratual e poderá ensejar medidas legais e compensatórias cabíveis. Esta obrigação permanecerá válida mesmo após o encerramento deste contrato.

      **Cláusula 15ª.** O valor pactuado poderá ser reajustado anualmente, ou em período inferior, conforme atualização das tabelas de repasse praticadas pelas fontes pagadoras vinculadas à **CONTRATANTE**, sejam elas operadoras de planos de saúde (como por exemplo a Unimed), entes públicos (tais como prefeituras e demais órgãos governamentais), ou conforme política de remuneração própria da **CONTRATANTE** nos casos de atendimentos particulares. Na ausência de tabela ou política específica, poderá ser adotado como referência o Índice Nacional de Preços ao Consumidor Amplo (IPCA), divulgado pelo IBGE, ou outro índice oficial que venha a substituí-lo.

      **Cláusula 16ª.** O pagamento será efetuado mediante - apresentação de nota fiscal/RPA... depósito bancário até o dia 12 (doze) de cada mês. Os reajustes, sejam eles decorrentes de repasses de convênios, contratos públicos ou política interna, serão divulgados por meio de comunicação escrita oficial com antecedência mínima de 30 (trinta) dias antes de sua aplicação, com vigência a partir do mês subsequente à data do aviso.
    CLAUSES
  end
end

