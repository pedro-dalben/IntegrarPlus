# frozen_string_literal: true

class AnamnesisPdfService
  include PdfHeaderFooter

  def initialize(anamnesis)
    @anamnesis = anamnesis
    @beneficiary = anamnesis.beneficiary
    @portal_intake = anamnesis.portal_intake
  end

  def generate
    pdf = create_pdf_with_header_footer
    pdf.font_size 10

    render_title(pdf)
    render_header_info(pdf)
    render_identification(pdf)
    render_filiation(pdf)
    render_family_composition(pdf)
    render_referral(pdf)
    render_gestational_history(pdf)
    render_birth(pdf)
    render_postnatal(pdf)
    render_feeding(pdf)
    render_psychomotor(pdf)
    render_sphincter(pdf)
    render_language(pdf)
    render_sleep(pdf)
    render_social_behavior(pdf)
    render_education(pdf)
    render_health(pdf)
    render_general_info(pdf)
    render_signature(pdf)

    pdf
  end

  private

  def render_title(pdf)
    pdf.text 'ANAMNESE INICIAL', size: 16, style: :bold, align: :center
    pdf.move_down 15
  end

  def render_header_info(pdf)
    pdf.text "Data: #{format_date(@anamnesis.performed_at)}          " \
             "E-mail: #{@anamnesis.session_email || '_______________'}          " \
             "Início: #{format_time(@anamnesis.start_time)}"
    pdf.move_down 15
  end

  def render_identification(pdf)
    section_title(pdf, 'I - Identificação')

    data = beneficiary_data
    pdf.text "Nome: #{data[:name]}"
    pdf.text "CPF: #{data[:cpf]}"
    pdf.text "Data de nascimento: #{data[:birth_date]}          Idade: #{data[:age]}"
    pdf.text "Naturalidade: #{@anamnesis.birthplace || '_______________'}          Estado: #{@anamnesis.birth_state || '___'}"
    pdf.text "Endereço: #{data[:address]}"
    pdf.text "Número: #{data[:number]}          Complemento: #{data[:complement]}"
    pdf.text "Município: #{data[:city]}          CEP: #{data[:zip_code]}"
    pdf.text "Telefones: #{data[:phones]}"
    pdf.text "Religião: #{@anamnesis.religion || '_______________'}"
    pdf.text "Médico Responsável: #{@anamnesis.responsible_doctor || '_______________'}"
    pdf.move_down 10
  end

  def render_filiation(pdf)
    section_title(pdf, 'II - Filiação')

    pdf.text "Pai: #{@anamnesis.father_name || '_______________'}          Data de nascimento: #{format_date(@anamnesis.father_birth_date)}"
    pdf.text "CPF: #{@anamnesis.father_cpf || '_______________'}          Escolaridade: #{@anamnesis.father_education || '_______________'}"
    pdf.text "Profissão: #{@anamnesis.father_profession || '_______________'}          Local de Trabalho: #{@anamnesis.father_workplace || '_______________'}"

    pdf.move_down 5

    pdf.text "Mãe: #{@anamnesis.mother_name || '_______________'}          Data de nascimento: #{format_date(@anamnesis.mother_birth_date)}"
    pdf.text "CPF: #{@anamnesis.mother_cpf || '_______________'}          Escolaridade: #{@anamnesis.mother_education || '_______________'}"
    pdf.text "Profissão: #{@anamnesis.mother_profession || '_______________'}          Local de Trabalho: #{@anamnesis.mother_workplace || '_______________'}"
    pdf.move_down 10
  end

  def render_family_composition(pdf)
    pdf.text 'Composição Familiar:', style: :bold
    pdf.move_down 5

    family = @anamnesis.family_composition_array
    if family.any?
      table_data = [%w[Nome Parentesco Idade Sexo Escolaridade]]
      family.each do |member|
        table_data << [
          member['name'] || '',
          member['relationship'] || '',
          member['age'] || '',
          member['gender'] || '',
          member['education'] || ''
        ]
      end
      pdf.table(table_data, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        cells.padding = 4
        cells.size = 9
      end
    else
      pdf.table([%w[Nome Parentesco Idade Sexo Escolaridade]] + Array.new(5) { ['', '', '', '', ''] },
                header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'DDDDDD'
        cells.padding = 4
        cells.size = 9
      end
    end
    pdf.move_down 10
  end

  def render_referral(pdf)
    section_title(pdf, 'III - Sobre o Encaminhamento/Procura')

    pdf.text "Motivo do Encaminhamento: #{@anamnesis.referral_reason_label || '_______________'}"
    pdf.text "Local do Atendimento: #{@anamnesis.treatment_location_label || '_______________'}"
    pdf.text "Horas do Pacote: #{@anamnesis.referral_hours || '___'} horas"
    pdf.text "Possui Liminar: #{@anamnesis.injunction? ? 'Sim' : 'Não'}"
    pdf.move_down 8

    pdf.text 'Queixa principal:', style: :bold
    pdf.text @anamnesis.main_complaint.presence || '_______________________________________________'
    pdf.move_down 5
    pdf.text 'Desde quando percebeu?', style: :bold
    pdf.text @anamnesis.complaint_noticed_since.presence || '_______________________________________________'
    pdf.move_down 10
  end

  def render_gestational_history(pdf)
    section_title(pdf, 'IV - Histórico Gestacional')

    pdf.text "• Foi uma gravidez planejada/desejada? #{yes_no(@anamnesis.pregnancy_planned)}"
    pdf.text "• Realizou o Pré-Natal? #{yes_no(@anamnesis.prenatal_care)}"
    pdf.text "• Idade da mãe na época em que a criança nasceu: #{@anamnesis.mother_age_at_birth || '___'}"
    pdf.text "• Abortos: #{yes_no(@anamnesis.had_miscarriages)}   Quantos: #{@anamnesis.miscarriages_count || '___'}   #{@anamnesis.miscarriages_type || ''}"
    pdf.text "• Sofreu algum traumatismo (tombos, susto)? #{yes_no(@anamnesis.pregnancy_trauma)}"
    pdf.text "• Apresentou alguma doença durante a gravidez? #{yes_no(@anamnesis.pregnancy_illness)}   Qual? #{@anamnesis.pregnancy_illness_description || '___'}"
    pdf.text "• Tomou algum medicamento? #{yes_no(@anamnesis.pregnancy_medication)}   Qual? #{@anamnesis.pregnancy_medication_description || '___'}"
    pdf.text "• Ingestão de drogas: #{yes_no(@anamnesis.pregnancy_drugs)}   Qual? #{@anamnesis.pregnancy_drugs_description || '___'}"
    pdf.text "• Álcool: #{yes_no(@anamnesis.pregnancy_alcohol)}"
    pdf.text "• Tabagismo: #{yes_no(@anamnesis.pregnancy_smoking)}   Quantos cigarros por dia? #{@anamnesis.cigarettes_per_day || '___'}"
    pdf.move_down 10
  end

  def render_birth(pdf)
    section_title(pdf, 'V - Parto')

    pdf.text "Tipo: #{@anamnesis.birth_type_label || '___'}   #{@anamnesis.birth_location_type_label || '___'}"
    pdf.text "#{@anamnesis.birth_term_label || '_______________'}"
    pdf.text "Tomou anestesia? #{yes_no(@anamnesis.had_anesthesia)}   Qual? #{@anamnesis.anesthesia_type_label || '___'}"
    pdf.text "Posição da criança no parto: #{@anamnesis.baby_position_label || '_______________'}"
    pdf.text "Circunvolução de cordão: #{yes_no(@anamnesis.cord_around_neck)}          Cianótico: #{yes_no(@anamnesis.cyanotic)}"
    pdf.text "Chorou ao nascer? #{yes_no(@anamnesis.cried_at_birth)}"
    pdf.text "Apgar: 1º #{@anamnesis.apgar_1min || '___'}   5º #{@anamnesis.apgar_5min || '___'}"
    pdf.text "Nº de dias no hospital - Mãe: #{@anamnesis.mother_hospital_days || '___'}   Criança: #{@anamnesis.baby_hospital_days || '___'}"
    pdf.text "Peso: #{@anamnesis.birth_weight || '___'} kg          Altura: #{@anamnesis.birth_height || '___'} cm"
    pdf.text "Precisou ficar na incubadora e/ou oxigênio? #{yes_no(@anamnesis.needed_incubator)}"
    pdf.text "Precisou ficar na U.T.I.? #{yes_no(@anamnesis.needed_icu)}   Por quê? #{@anamnesis.icu_reason || '___'}"
    pdf.text "Outras intercorrências: #{@anamnesis.birth_complications || '_______________'}"
    pdf.move_down 10
  end

  def render_postnatal(pdf)
    section_title(pdf, 'VI - Dados Pós Nascimento')

    pdf.text "Como era a saúde quando bebê? Ficava doente com frequência?"
    pdf.text @anamnesis.baby_health.presence || '_______________________________________________'
    pdf.text "Problemas respiratórios e/ou outros de saúde geral?"
    pdf.text @anamnesis.respiratory_problems.presence || '_______________________________________________'
    pdf.text "Como era seu comportamento de maneira geral?"
    pdf.text @anamnesis.general_behavior_baby.presence || '_______________________________________________'
    pdf.move_down 10
  end

  def render_feeding(pdf)
    section_title(pdf, 'VII - Alimentação')

    pdf.text "Natural: #{yes_no(@anamnesis.breastfed)}   Até quando? #{@anamnesis.breastfed_until || '___'}"
    pdf.text "Mamadeira: #{yes_no(@anamnesis.bottle_fed)}   Até quando? #{@anamnesis.bottle_fed_until || '___'}"
    pdf.text "Como se manifestava o contato físico e/ou ocular do bebê durante as mamadas?"
    pdf.text @anamnesis.feeding_contact.presence || '_______________________________________________'
    pdf.text "Faz todas as refeições diariamente? #{yes_no(@anamnesis.daily_meals)}"
    pdf.text "Quais são seus alimentos prediletos? #{@anamnesis.favorite_foods || '_______________'}"
    pdf.text "Rejeita algum alimento? #{@anamnesis.rejected_foods || '_______________'}"
    pdf.text "Vômito frequente? #{yes_no(@anamnesis.frequent_vomiting)}"
    pdf.text "Como se comporta durante as refeições? #{@anamnesis.meal_behavior || '_______________'}"
    pdf.text "Tem horário para se alimentar? #{yes_no(@anamnesis.fixed_meal_schedule)}"
    pdf.text "Come sozinho(a)? #{yes_no(@anamnesis.eats_alone)}"
    pdf.text "Dificuldade para mastigar ou deglutir? #{yes_no(@anamnesis.chewing_difficulty)}"
    pdf.text "Apresenta baba? #{yes_no(@anamnesis.drools)}   Quando? #{@anamnesis.drools_when || '___'}"
    pdf.text "OBS: #{@anamnesis.feeding_notes || '_______________'}" if @anamnesis.feeding_notes.present?
    pdf.move_down 10
  end

  def render_psychomotor(pdf)
    section_title(pdf, 'VIII - Desenvolvimento Psicomotor')

    pdf.text "Firmou a cabeça? #{yes_no(@anamnesis.held_head)}   Quando? #{@anamnesis.held_head_age || '___'}"
    pdf.text "Rolou #{yes_no(@anamnesis.rolled_over)}   Bilateral? #{yes_no(@anamnesis.rolled_bilateral)}   OBS: #{@anamnesis.rolled_notes || '___'}"
    pdf.text "Sentou sem apoio? #{yes_no(@anamnesis.sat_unsupported)}   Quando? #{@anamnesis.sat_unsupported_age || '___'}"
    pdf.text "Engatinhou? #{yes_no(@anamnesis.crawled)}   Quando? #{@anamnesis.crawled_age || '___'}   Como? #{@anamnesis.crawled_how || '___'}"
    pdf.text "Quando ficou em pé? #{@anamnesis.stood_age || '_______________'}"
    pdf.text "Quando iniciou marcha? #{@anamnesis.walked_age || '_______________'}"
    pdf.text "Subiu e desceu degrau? #{yes_no(@anamnesis.climbed_stairs)}   Quando? #{@anamnesis.climbed_stairs_age || '___'}"
    pdf.text "Agachou e levantou? #{yes_no(@anamnesis.squatted)}   Quando? #{@anamnesis.squatted_age || '___'}"
    pdf.text "Fez uso de andador? #{yes_no(@anamnesis.used_walker)}   Quando? #{@anamnesis.used_walker_age || '___'}"
    pdf.text "Tem algum problema de coordenação motora? #{yes_no(@anamnesis.motor_coordination_problem)}   Qual? #{@anamnesis.motor_coordination_description || '___'}"
    pdf.text "Apresenta dificuldade em manipular objetos? #{yes_no(@anamnesis.object_manipulation_difficulty)}"
    pdf.move_down 10
  end

  def render_sphincter(pdf)
    section_title(pdf, 'IX - Controle de esfíncter')

    pdf.text "Quando controlou esfíncter vesical:"
    pdf.text "  Diurno? #{@anamnesis.bladder_control_day || '_______________'}"
    pdf.text "  Noturno? #{@anamnesis.bladder_control_night || '_______________'}"
    pdf.text "Quando controlou esfíncter anal:"
    pdf.text "  Diurno? #{@anamnesis.bowel_control_day || '_______________'}"
    pdf.text "  Noturno? #{@anamnesis.bowel_control_night || '_______________'}"
    pdf.move_down 10
  end

  def render_language(pdf)
    section_title(pdf, 'X - Linguagem')

    pdf.text "Balbuciou? #{yes_no(@anamnesis.babbled)}   Qual a idade? #{@anamnesis.babbled_age || '___'}"
    pdf.text "Quando iniciou a fala? #{@anamnesis.speech_started_age || '_______________'}"
    pdf.text "Fala compreensível? #{yes_no(@anamnesis.understandable_speech)}   Desde quando? #{@anamnesis.understandable_since || '___'}"
    pdf.text "Dificuldade (gagueira, troca letras, outras)? #{yes_no(@anamnesis.speech_difficulties)}   Qual? #{@anamnesis.speech_difficulties_description || '___'}"
    pdf.text "Repete o que ouve (ecolalia)? #{yes_no(@anamnesis.echolalia)}"
    pdf.text "Algum problema de audição? #{yes_no(@anamnesis.hearing_problems)}   Qual? #{@anamnesis.hearing_problems_description || '___'}"
    pdf.text "A criança responde quando chamada em outro ambiente? #{yes_no(@anamnesis.responds_from_distance)}"
    pdf.text "A criança se assusta facilmente? #{yes_no(@anamnesis.easily_startled)}"
    pdf.text "Faz uso da linguagem gestual? #{yes_no(@anamnesis.uses_gestures)}   Como? #{@anamnesis.gestures_description || '___'}"
    pdf.text "Utiliza o outro como ferramenta? #{yes_no(@anamnesis.uses_other_as_tool)}"
    pdf.text "Utiliza palavras em contexto? #{yes_no(@anamnesis.words_in_context)}"
    pdf.text "A criança compartilha de assuntos gerais e/ou interesses? #{yes_no(@anamnesis.shares_interests)}"
    pdf.text "Alguma vez a criança parou de falar após já ter aprendido? #{yes_no(@anamnesis.stopped_speaking)}   Quando? #{@anamnesis.stopped_speaking_when || '___'}"
    pdf.text "A criança compreende o que lhe é dito? #{yes_no(@anamnesis.understands_speech)}"
    pdf.text "Como comunica seus desejos? #{@anamnesis.communicates_desires || '_______________'}"
    pdf.text "Quando a criança não é compreendida, como reage? #{@anamnesis.reaction_not_understood || '_______________'}"
    pdf.text "Como a família reage diante desses comportamentos? #{@anamnesis.family_reaction_communication || '_______________'}"
    pdf.move_down 10
  end

  def render_sleep(pdf)
    section_title(pdf, 'XI - Sono')

    pdf.text "A criança tem rotina para dormir? #{yes_no(@anamnesis.sleep_routine)}   Como ocorre? #{@anamnesis.sleep_routine_description || '___'}"
    pdf.text "Cama individual? #{yes_no(@anamnesis.individual_bed)}   #{@anamnesis.individual_bed_description || ''}"
    pdf.text "Como é o sono (agitado, calmo, bruxismo, grita, é sonâmbulo, insônia)?"
    pdf.text @anamnesis.sleep_quality.presence || '_______________________________________________'
    pdf.text "Apresenta enurese noturna? #{yes_no(@anamnesis.nocturnal_enuresis)}"
    pdf.move_down 10
  end

  def render_social_behavior(pdf)
    section_title(pdf, 'XII - Comportamento Social e Ludicidade')

    pdf.text "Que tipo de brincadeira prefere? #{@anamnesis.preferred_play || '_______________'}"
    pdf.text "Como brinca? #{@anamnesis.how_plays || '_______________'}"
    pdf.text "Durante a brincadeira apresenta reação de proteção? #{@anamnesis.protective_reaction_play || '_______________'}"
    pdf.text "Quais brinquedos gosta? #{@anamnesis.favorite_toys || '_______________'}"
    pdf.text "Assiste TV? #{yes_no(@anamnesis.watches_tv)}   Como assiste? #{@anamnesis.watches_tv_how || '___'}"
    pdf.text "Quais são seus programas, desenhos e/ou DVD preferidos? #{@anamnesis.favorite_programs || '_______________'}"
    pdf.text "Gosta de vê-los várias vezes? #{yes_no(@anamnesis.watches_repeatedly)}"
    pdf.text "Brinca com outras crianças? #{yes_no(@anamnesis.plays_with_others)}   Como? #{@anamnesis.plays_with_others_how || '___'}"
    pdf.text "Briga com os colegas ou deixa-os quando seus desejos não são atendidos? #{@anamnesis.fights_with_peers || '_______________'}"
    pdf.text "Defende-se de agressão? #{yes_no(@anamnesis.defends_from_aggression)}   De que forma? #{@anamnesis.defense_method || '___'}"
    pdf.text "Como reage a proibições e frustrações? #{@anamnesis.reaction_prohibitions || '_______________'}"
    pdf.text "Como se comporta no relacionamento com estranhos? #{@anamnesis.behavior_with_strangers || '_______________'}"
    pdf.text "Tem noção do perigo? #{yes_no(@anamnesis.danger_awareness)}   #{@anamnesis.danger_awareness_description || ''}"
    pdf.text "Como reage frente a situações novas (hiperativo, tímido, ansioso)? #{@anamnesis.new_situations_reaction || '_______________'}"
    pdf.text "Obedece a ordens? #{yes_no(@anamnesis.obeys_orders)}"
    pdf.text "É afetivo ou reage a carinhos? #{@anamnesis.shows_affection || '_______________'}"
    pdf.text "Apresenta comportamentos agressivos ou destrutivos? #{yes_no(@anamnesis.aggressive_behavior)}   #{@anamnesis.aggressive_behavior_description || ''}"
    pdf.text "Como a família reage frente à presença da crise comportamental? #{@anamnesis.family_crisis_reaction || '_______________'}"
    pdf.move_down 10
  end

  def render_education(pdf)
    section_title(pdf, 'XIII - Escolaridade')

    pdf.text "Frequentou ou frequenta alguma escola? #{yes_no(@anamnesis.attends_school)}   Qual? #{@anamnesis.school_name || '_______________'}"
    pdf.text "Período: #{@anamnesis.school_period_label || '___'}   Telefone: #{@anamnesis.school_phone || '_______________'}"
    pdf.text "Com que idade ingressou? #{@anamnesis.school_enrollment_age || '_______________'}"
    pdf.text "Tem professor(a) de apoio? #{yes_no(@anamnesis.has_support_teacher)}"
    pdf.text "Utiliza algum mecanismo pedagógico ou terapêutico no contra turno? #{@anamnesis.after_school_activities || '_______________'}"
    pdf.text "Quais dificuldades encontradas no ambiente escolar?"
    pdf.text @anamnesis.school_difficulties.presence || '_______________________________________________'
    pdf.text "O que a família espera da escola, ou como entende esse trabalho?"
    pdf.text @anamnesis.family_school_expectations.presence || '_______________________________________________'
    pdf.move_down 10
  end

  def render_health(pdf)
    section_title(pdf, 'XIV - Saúde')

    pdf.text "Quais doenças já teve? #{@anamnesis.previous_illnesses || '_______________'}"
    pdf.text "Internações? #{yes_no(@anamnesis.hospitalizations)}   Causas? #{@anamnesis.hospitalization_causes || '_______________'}"
    pdf.text "Apresenta epilepsia? #{yes_no(@anamnesis.has_epilepsy)}   Qual frequência? #{@anamnesis.epilepsy_frequency || '___'}"
    pdf.text "Medicamentos usados? #{@anamnesis.current_medications || '_______________'}"
    pdf.text "Exames já realizados? #{@anamnesis.exams_done || '_______________'}"
    pdf.text "Exames a realizar: #{@anamnesis.exams_to_do || '_______________'}"
    pdf.text "Tem alergia? #{yes_no(@anamnesis.has_allergies)}   Qual(is)? #{@anamnesis.allergies_description || '_______________'}"

    pdf.move_down 5
    pdf.text 'Presença de doenças ou deficiências na família:', style: :bold
    conditions = @anamnesis.family_conditions_array
    FAMILY_CONDITIONS.each do |cond|
      checked = conditions.include?(cond[:key]) ? '(X)' : '(  )'
      pdf.text "#{checked} #{cond[:label]}"
    end

    pdf.text "Internações em Hospital Psiquiátrico? #{yes_no(@anamnesis.psychiatric_hospitalization)}   Quem? #{@anamnesis.psychiatric_hospitalization_who || '___'}"
    pdf.move_down 10
  end

  def render_general_info(pdf)
    section_title(pdf, 'XV - Informações Gerais')
    pdf.text @anamnesis.general_information.presence || '_______________________________________________'
    pdf.move_down 30
  end

  def render_signature(pdf)
    pdf.move_down 20

    signature_width = 180
    page_width = pdf.bounds.width
    left_x = (page_width / 2) - signature_width - 30
    right_x = (page_width / 2) + 30

    pdf.stroke do
      pdf.horizontal_line left_x, left_x + signature_width, at: pdf.cursor
      pdf.horizontal_line right_x, right_x + signature_width, at: pdf.cursor
    end

    pdf.move_down 5

    professional_name = @anamnesis.professional.full_name
    council_code = @anamnesis.professional.professional&.council_code

    pdf.font_size 9 do
      pdf.text_box professional_name,
                   at: [left_x, pdf.cursor],
                   width: signature_width,
                   align: :center

      if council_code.present?
        pdf.text_box council_code,
                     at: [left_x, pdf.cursor - 12],
                     width: signature_width,
                     align: :center
      end

      pdf.text_box 'Responsável Legal',
                   at: [right_x, pdf.cursor],
                   width: signature_width,
                   align: :center
    end

    pdf.move_down 30

    pdf.font_size 8 do
      pdf.text "Documento gerado em #{Time.current.strftime('%d/%m/%Y às %H:%M')}", align: :center, color: '666666'
    end
  end

  def section_title(pdf, title)
    pdf.move_down 8
    pdf.fill_color 'E8E8E8'
    pdf.fill_rectangle [0, pdf.cursor + 5], pdf.bounds.width, 20
    pdf.fill_color '000000'
    pdf.text title, style: :bold, size: 11
    pdf.move_down 8
  end

  def beneficiary_data
    if @beneficiary.present?
      {
        name: @beneficiary.name,
        cpf: @beneficiary.cpf,
        birth_date: @beneficiary.birth_date&.strftime('%d/%m/%Y'),
        age: @beneficiary.age,
        address: @beneficiary.address,
        number: @beneficiary.address_number,
        complement: @beneficiary.address_complement,
        city: @beneficiary.city,
        zip_code: @beneficiary.zip_code,
        phones: [@beneficiary.phone, @beneficiary.secondary_phone].compact.join(' / ')
      }
    elsif @portal_intake.present?
      {
        name: @portal_intake.nome || @portal_intake.beneficiary_name,
        cpf: @portal_intake.cpf,
        birth_date: @portal_intake.data_nascimento&.strftime('%d/%m/%Y'),
        age: calculate_age(@portal_intake.data_nascimento),
        address: @portal_intake.endereco,
        number: '',
        complement: '',
        city: '',
        zip_code: '',
        phones: @portal_intake.telefone_responsavel
      }
    else
      Hash.new('_______________')
    end
  end

  def calculate_age(birth_date)
    return '___' unless birth_date

    ((Time.current - birth_date.to_time) / 1.year).floor
  end

  def format_date(date)
    return '___/___/______' if date.blank?

    date.strftime('%d/%m/%Y')
  end

  def format_time(time)
    return '___:___' if time.blank?

    time.strftime('%H:%M')
  end

  def yes_no(value)
    case value
    when true then '( X ) SIM  (   ) NÃO'
    when false then '(   ) SIM  ( X ) NÃO'
    else '(   ) SIM  (   ) NÃO'
    end
  end

  FAMILY_CONDITIONS = Anamnesis::FAMILY_CONDITIONS
end




