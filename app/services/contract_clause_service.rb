class ContractClauseService
  def clause_17_text(contract)
    if contract.fechado?
      clause_17_fechado(contract)
    elsif contract.por_hora?
      clause_17_por_hora(contract)
    else
      ''
    end
  end

  def clause_17_caput(contract)
    if contract.fechado?
      monthly_value = contract.monthly_value || 0
      "**O CONTRATANTE** pagará ao **CONTRATADO** o valor de R$ #{format_currency(monthly_value)} (#{number_to_words(monthly_value)}), considerando a natureza dos serviços prestados, a formação profissional, a experiência clínica e as especificidades técnicas exigidas para a função desempenhada."
    elsif contract.por_hora?
      hourly_value = contract.hourly_value || 0
      "**O CONTRATANTE** pagará ao **CONTRATADO** o valor de R$ #{format_currency(hourly_value)} (#{number_to_words(hourly_value)}) por hora de serviço efetivamente realizada, considerando a natureza dos serviços prestados, a formação profissional, a experiência clínica e as especificidades técnicas exigidas para a função desempenhada."
    else
      ''
    end
  end

  def clause_17_paragraphs(contract)
    if contract.fechado?
      [
        clause_17_paragraph_1_fechado(contract),
        clause_17_paragraph_2_fechado(contract),
        clause_17_paragraph_3
      ]
    elsif contract.por_hora?
      [
        clause_17_paragraph_3
      ]
    else
      []
    end
  end

  def final_clauses
    <<~CLAUSES
      **Cláusula 18ª**. Este contrato vigorará pelo prazo determinado por 12 (doze) meses, a contar de {{data_inicio}}, podendo ser prorrogado por igual período, mediante comum acordo entre as partes, desde que expressamente formalizado por escrito. **Este instrumento substitui integralmente qualquer contrato anterior e eventuais termos aditivos firmados entre as partes**, sendo este o único vínculo contratual vigente entre a **CONTRATANTE** e a **CONTRATADA (O)**.

      **DO INADIMPLEMENTO**

      **Cláusula 19ª.** Em caso de inadimplemento por parte da **CONTRATANTE**, no que tange ao pagamento do serviço prestado, deverá incidir sobre o valor pendente multa pecuniária de 2% (dois por cento) e juros de mora de 1% (um por cento) ao mês como correção monetária.

      **Parágrafo único.** Em caso de cobrança judicial, devem ser acrescidas custas processuais e 20% de honorários advocatícios.

      **Cláusula 20ª.** No caso do descumprimento de qualquer das cláusulas do presente instrumento, a parte infratora deverá pagar uma multa de 10% (dez por cento) do valor total do contrato para a outra parte.

      **DA RESCISÃO IMOTIVADA**

      **Cláusula 21ª**. Poderá o presente instrumento ser rescindido por qualquer uma das partes, em qualquer momento, sem que haja qualquer tipo de motivo relevante, desde que observada prévia comunicação por escrito, com antecedência mínima de 30 (trinta) dias.

      **Cláusula 22ª.** A **CONTRATANTE** poderá rescindir este contrato, por motivo justificado, nas seguintes situações:

      a) violação à Lei Geral de Proteção de Dados (Lei nº 13.709/2018) ou a outras normas de confidencialidade e segurança da informação;  
      b) descumprimento de normas éticas, técnicas ou institucionais que comprometam a qualidade ou a integridade dos serviços prestados;  
      c) reincidência em advertência formal emitida pela **CONTRATANTE;**  
      d) descumprimento de cláusulas contratuais relevantes ou a prática de condutas que causem prejuízo material, técnico ou reputacional à **CONTRATANTE.**

      **DO PRAZO**

      **Cláusula 23ª.** A **CONTRATADA (O)** assume o compromisso de realizar os serviços de acordo com as necessidades da **CONTRATANTE**, nos termos das cláusulas contratuais. O prazo de execução seguirá conforme **cláusula 21ª,** respeitando o cronograma estabelecido com a **CONTRATANTE**.

      **DAS CONDIÇÕES GERAIS**

      **Cláusula 24ª.** Em decorrência da natureza jurídica deste contrato não caracteriza em hipótese alguma, vínculo empregatício.

      **Cláusula 25º.** Todos os materiais técnicos, relatórios, protocolos, documentos, registros ou quaisquer conteúdos produzidos no âmbito deste contrato constituem **propriedade exclusiva da CONTRATANTE**, sendo **vedada à CONTRATADA (O)** a reprodução, reutilização, divulgação ou utilização desses materiais **sem prévia e expressa autorização da CONTRATANTE**. Fica igualmente vedado à **CONTRATADA** (O) **transferir, ceder ou subcontratar** total ou parcialmente os serviços previstos neste instrumento, sob pena de **rescisão imediata do contrato**, sem prejuízo das demais medidas legais cabíveis.

      **Cláusula 26º** A **CONTRATANTE** é legítima titular e/ou usuária de informações, documentos, metodologias e/ou tecnologias, sistemas, _softwares_, equipamentos relativos a tecnologias por ela própria desenvolvidas ou adquiridas de terceiros, de interesse de sua atividade, dentre outros objetos, materiais ou componentes que integram a metodologia de trabalho e instalações, relação de pacientes/clientes, processos administrativos ou organizacionais, redes de computadores, sistemas digitais de comunicação interna e/ou externa.

      **Cláusula 27ª.** O presente instrumento é celebrado, em caráter irretratável, podendo, inclusive, ser registrado em cartório.

      **DO FORO**

      **Cláusula 28ª.** Para dirimir quaisquer controvérsias oriundas do presente contrato, as partes elegem o foro da comarca de Mogi Mirim, Estado de São Paulo, com renúncia expressa a qualquer outro, por mais privilegiado que seja.
    CLAUSES
  end

  def number_to_words(value)
    return 'zero' if value.nil? || value.zero?

    integer_part = value.to_i
    decimal_part = ((value - integer_part) * 100).round

    words = []
    words << number_to_words_helper(integer_part)
    words << 'reais' if integer_part > 0

    if decimal_part > 0
      words << 'e'
      words << number_to_words_helper(decimal_part)
      words << 'centavos'
    end

    words.join(' ')
  end

  def number_to_words_helper(number)
    return 'zero' if number.zero?

    units = ['', 'um', 'dois', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove']
    teens = ['dez', 'onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito', 'dezenove']
    tens = ['', '', 'vinte', 'trinta', 'quarenta', 'cinquenta', 'sessenta', 'setenta', 'oitenta', 'noventa']
    hundreds = ['', 'cento', 'duzentos', 'trezentos', 'quatrocentos', 'quinhentos', 'seiscentos', 'setecentos', 'oitocentos', 'novecentos']

    return units[number] if number < 10
    return teens[number - 10] if number < 20

    if number < 100
      ten = number / 10
      unit = number % 10
      return tens[ten] if unit.zero?
      return "#{tens[ten]} e #{units[unit]}"
    end

    if number < 1000
      hundred = number / 100
      remainder = number % 100
      return hundreds[hundred] if remainder.zero?
      return "#{hundreds[hundred]} e #{number_to_words_helper(remainder)}"
    end

    if number < 1_000_000
      thousand = number / 1000
      remainder = number % 1000
      thousand_word = thousand == 1 ? 'mil' : "#{number_to_words_helper(thousand)} mil"
      return thousand_word if remainder.zero?
      return "#{thousand_word} e #{number_to_words_helper(remainder)}"
    end

    number.to_s
  end

  private

  def clause_17_fechado(contract)
    text = "Cláusula 17ª. #{clause_17_caput(contract)}\n\n"
    paragraphs = clause_17_paragraphs(contract)
    text += paragraphs.join("\n\n")
    text
  end

  def clause_17_por_hora(contract)
    text = "Cláusula 17ª. #{clause_17_caput(contract)}\n\n"
    paragraphs = clause_17_paragraphs(contract)
    text += paragraphs.join("\n\n")
    text
  end

  def clause_17_paragraph_1_fechado(contract)
    workload_hours = contract.professional.workload_hours || 32
    workload_words = number_to_words_helper(workload_hours.to_i)
    "**Parágrafo 1º.** O valor pactuado refere-se ao cumprimento, ao longo do mês, de uma carga horária semanal de **#{workload_hours.to_i} (#{workload_words}) horas**, previamente disponibilizadas pela **CONTRATADA** e acordadas entre as partes."
  end

  def clause_17_paragraph_2_fechado(contract)
    overtime_value = contract.has_overtime_value? ? format_currency(contract.overtime_hour_value) : '17,00'
    overtime_words = contract.has_overtime_value? ? number_to_words_helper(contract.overtime_hour_value.to_i) : 'dezessete'
    "**Parágrafo 2º.** Em casos excepcionais, previamente autorizados pela **CONTRATANTE**, a **CONTRATADA (O)** poderá, por disponibilidade espontânea, realizar carga horária superior à previamente acordada, fazendo jus ao recebimento do valor de **R$ #{overtime_value} (#{overtime_words} reais)** por hora adicional efetivamente prestada. Da mesma forma, nas situações em que a carga horária acordada não for integralmente cumprida, será aplicado desconto proporcional, considerando o mesmo valor de **R$ #{overtime_value} (#{overtime_words} reais)** por hora não realizada, conforme as condições de pagamento estabelecidas neste contrato."
  end

  def clause_17_paragraph_3
    "**Parágrafo 3º.:** Os valores contratados poderão variar entre os diferentes profissionais prestadores de serviço, tendo em vista os seguintes critérios objetivos, aplicáveis a cada caso:

- Grau de especialização e certificações técnicas;
- Tempo de experiência na área e no método aplicado;
- Nível de complexidade dos atendimentos realizados;
- Disponibilidade de horário, flexibilidade e carga horária semanal;
- Responsabilidade técnica sobre casos específicos ou participação em coordenação de equipe;
- Indicadores de produtividade e qualidade dos serviços.

Tal diferenciação não configura vínculo empregatício ou equiparação salarial entre os prestadores, sendo legítima no modelo de prestação de serviços por Pessoa Jurídica, respeitando a autonomia e independência técnica dos contratados."
  end

  def format_currency(value)
    return '0,00' if value.nil? || value.zero?

    parts = value.to_s.split('.')
    integer_part = parts[0]
    decimal_part = parts[1] || '00'
    decimal_part = decimal_part.ljust(2, '0')[0..1]

    integer_part = integer_part.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    "#{integer_part},#{decimal_part}"
  end
end

