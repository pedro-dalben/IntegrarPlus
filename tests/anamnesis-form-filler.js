// Script para preencher completamente o formulário de anamnese
// Execute este script no console do navegador quando estiver na página do formulário

(function() {
  console.log('🚀 Iniciando preenchimento completo do formulário de anamnese...');
  
  let filled = 0;
  let errors = [];
  
  function fillField(name, value) {
    try {
      const field = document.querySelector(`input[name="${name}"], textarea[name="${name}"]`);
      if (field) {
        field.value = value;
        field.dispatchEvent(new Event('input', { bubbles: true }));
        field.dispatchEvent(new Event('change', { bubbles: true }));
        filled++;
        return true;
      }
    } catch (e) {
      errors.push(`Erro ao preencher ${name}: ${e.message}`);
    }
    return false;
  }
  
  function fillSelect(name, value) {
    try {
      const select = document.querySelector(`select[name="${name}"]`);
      if (select) {
        select.value = value;
        select.dispatchEvent(new Event('change', { bubbles: true }));
        filled++;
        return true;
      }
    } catch (e) {
      errors.push(`Erro ao selecionar ${name}: ${e.message}`);
    }
    return false;
  }
  
  function clickRadio(name, value) {
    try {
      const radios = document.querySelectorAll(`input[name="${name}"]`);
      if (radios && radios.length > 0) {
        const target = Array.from(radios).find(r => {
          if (value === true || value === 'true') return r.value === 'true' || r.value === '1' || !r.value;
          return r.value === String(value) || r.value === 'false' || r.value === '0';
        });
        
        if (target) {
          target.click();
          filled++;
          return true;
        } else {
          // Fallback: clicar no primeiro ou segundo
          if (value === true || value === 'true') radios[0].click();
          else if (radios.length > 1) radios[1].click();
          filled++;
          return true;
        }
      }
    } catch (e) {
      errors.push(`Erro ao clicar radio ${name}: ${e.message}`);
    }
    return false;
  }
  
  // Campos obrigatórios
  fillSelect('anamnesis[referral_reason]', 'aba');
  fillSelect('anamnesis[treatment_location]', 'domiciliar');
  fillField('anamnesis[referral_hours]', '20');
  
  // Seção I - Identificação
  fillField('anamnesis[birthplace]', 'São Paulo');
  fillField('anamnesis[birth_state]', 'SP');
  fillField('anamnesis[religion]', 'Católica');
  
  // Seção II - Filiação - Pai
  fillField('anamnesis[father_name]', 'João Silva Santos');
  fillField('anamnesis[father_birth_date]', '15/05/1980');
  fillField('anamnesis[father_cpf]', '12345678900');
  fillSelect('anamnesis[father_education]', 'Ensino Superior Completo');
  fillField('anamnesis[father_profession]', 'Engenheiro');
  fillField('anamnesis[father_workplace]', 'Empresa XYZ Ltda');
  
  // Seção II - Filiação - Mãe
  fillField('anamnesis[mother_name]', 'Maria Silva Santos');
  fillField('anamnesis[mother_birth_date]', '20/08/1985');
  fillField('anamnesis[mother_cpf]', '98765432100');
  fillSelect('anamnesis[mother_education]', 'Ensino Superior Completo');
  fillField('anamnesis[mother_profession]', 'Médica');
  fillField('anamnesis[mother_workplace]', 'Hospital ABC');
  
  // Seção III - Encaminhamento
  fillField('anamnesis[main_complaint]', 'Dificuldades na comunicação e interação social, com comportamentos repetitivos');
  fillField('anamnesis[complaint_noticed_since]', 'Há aproximadamente 2 anos, desde os 3 anos de idade');
  
  // Seção IV - Gestacional
  clickRadio('anamnesis[pregnancy_planned]', true);
  clickRadio('anamnesis[prenatal_care]', true);
  fillField('anamnesis[mother_age_at_birth]', '28');
  clickRadio('anamnesis[had_miscarriages]', false);
  clickRadio('anamnesis[pregnancy_trauma]', false);
  clickRadio('anamnesis[pregnancy_illness]', false);
  clickRadio('anamnesis[pregnancy_medication]', false);
  clickRadio('anamnesis[pregnancy_drugs]', false);
  clickRadio('anamnesis[pregnancy_alcohol]', false);
  clickRadio('anamnesis[pregnancy_smoking]', false);
  
  // Seção V - Parto
  fillSelect('anamnesis[birth_type]', 'cesarea');
  fillSelect('anamnesis[birth_location_type]', 'hospitalar');
  fillSelect('anamnesis[birth_term]', 'termo');
  clickRadio('anamnesis[had_anesthesia]', true);
  fillSelect('anamnesis[anesthesia_type]', 'epidural');
  fillSelect('anamnesis[baby_position]', 'cefalico');
  clickRadio('anamnesis[cried_at_birth]', true);
  clickRadio('anamnesis[cord_around_neck]', false);
  clickRadio('anamnesis[cyanotic]', false);
  fillField('anamnesis[apgar_1min]', '9');
  fillField('anamnesis[apgar_5min]', '10');
  fillField('anamnesis[mother_hospital_days]', '3');
  fillField('anamnesis[baby_hospital_days]', '2');
  fillField('anamnesis[birth_weight]', '3.250');
  fillField('anamnesis[birth_height]', '49.5');
  clickRadio('anamnesis[needed_incubator]', false);
  clickRadio('anamnesis[needed_icu]', false);
  fillField('anamnesis[birth_complications]', 'Nenhuma');
  
  // Seção VI - Pós Nascimento
  fillField('anamnesis[baby_health]', 'Boa saúde, não ficava doente com frequência, apenas resfriados ocasionais');
  fillField('anamnesis[respiratory_problems]', 'Nenhum problema respiratório');
  fillField('anamnesis[general_behavior_baby]', 'Bebê calmo e tranquilo, dormia bem, se alimentava normalmente');
  
  // Seção VII - Alimentação
  clickRadio('anamnesis[breastfed]', true);
  fillField('anamnesis[breastfed_until]', '6 meses');
  clickRadio('anamnesis[bottle_fed]', true);
  fillField('anamnesis[bottle_fed_until]', '1 ano');
  fillField('anamnesis[feeding_contact]', 'Bom contato visual e físico durante as mamadas, demonstrando satisfação');
  clickRadio('anamnesis[daily_meals]', true);
  clickRadio('anamnesis[frequent_vomiting]', false);
  fillField('anamnesis[favorite_foods]', 'Frutas, legumes, carnes e massas');
  fillField('anamnesis[rejected_foods]', 'Nenhum alimento rejeitado');
  fillField('anamnesis[meal_behavior]', 'Come bem, com apetite, sem problemas comportamentais durante as refeições');
  clickRadio('anamnesis[fixed_meal_schedule]', true);
  clickRadio('anamnesis[eats_alone]', true);
  clickRadio('anamnesis[chewing_difficulty]', false);
  clickRadio('anamnesis[drools]', false);
  
  // Seção VIII - Psicomotor
  clickRadio('anamnesis[held_head]', true);
  fillField('anamnesis[held_head_age]', '3 meses');
  clickRadio('anamnesis[rolled_over]', true);
  clickRadio('anamnesis[sat_unsupported]', true);
  fillField('anamnesis[sat_unsupported_age]', '6 meses');
  clickRadio('anamnesis[crawled]', true);
  fillField('anamnesis[crawled_age]', '8 meses');
  fillField('anamnesis[crawled_how]', 'Engatinhava normalmente');
  fillField('anamnesis[stood_age]', '10 meses');
  fillField('anamnesis[walked_age]', '12 meses');
  clickRadio('anamnesis[climbed_stairs]', true);
  fillField('anamnesis[climbed_stairs_age]', '15 meses');
  clickRadio('anamnesis[squatted]', true);
  fillField('anamnesis[squatted_age]', '16 meses');
  clickRadio('anamnesis[used_walker]', false);
  clickRadio('anamnesis[motor_coordination_problem]', false);
  clickRadio('anamnesis[object_manipulation_difficulty]', false);
  
  // Seção IX - Esfíncter
  fillField('anamnesis[bladder_control_day]', '2 anos');
  fillField('anamnesis[bladder_control_night]', '3 anos');
  fillField('anamnesis[bowel_control_day]', '2 anos');
  fillField('anamnesis[bowel_control_night]', '2 anos e meio');
  
  // Seção X - Linguagem
  clickRadio('anamnesis[babbled]', true);
  fillField('anamnesis[babbled_age]', '6 meses');
  fillField('anamnesis[speech_started_age]', '12 meses');
  clickRadio('anamnesis[understandable_speech]', true);
  fillField('anamnesis[understandable_since]', '18 meses');
  clickRadio('anamnesis[speech_difficulties]', false);
  clickRadio('anamnesis[echolalia]', false);
  clickRadio('anamnesis[responds_from_distance]', true);
  clickRadio('anamnesis[easily_startled]', false);
  clickRadio('anamnesis[hearing_problems]', false);
  clickRadio('anamnesis[uses_gestures]', true);
  clickRadio('anamnesis[uses_other_as_tool]', false);
  clickRadio('anamnesis[words_in_context]', true);
  clickRadio('anamnesis[shares_interests]', true);
  clickRadio('anamnesis[understands_speech]', true);
  clickRadio('anamnesis[stopped_speaking]', false);
  fillField('anamnesis[communicates_desires]', 'Verbalmente e com gestos, consegue expressar desejos e necessidades');
  fillField('anamnesis[reaction_not_understood]', 'Fica frustrada quando não é compreendida e tenta explicar melhor ou usar gestos');
  fillField('anamnesis[family_reaction_communication]', 'Família é paciente e ajuda a criança a se expressar, sempre tentando entender');
  
  // Seção XI - Sono
  clickRadio('anamnesis[sleep_routine]', true);
  fillField('anamnesis[sleep_routine_description]', 'Banho, jantar e leitura de história antes de dormir');
  clickRadio('anamnesis[individual_bed]', true);
  fillField('anamnesis[sleep_quality]', 'Sono calmo e tranquilo, dorme bem durante a noite toda');
  clickRadio('anamnesis[nocturnal_enuresis]', false);
  
  // Seção XII - Social
  fillField('anamnesis[preferred_play]', 'Jogos de construção, leitura de livros e brincadeiras com bonecas');
  fillField('anamnesis[how_plays]', 'Brinca sozinha com concentração, organizando e criando histórias');
  fillField('anamnesis[protective_reaction_play]', 'Sim, apresenta reação de proteção quando alguém tenta pegar seus brinquedos');
  fillField('anamnesis[favorite_toys]', 'Blocos de montar, livros, bonecas e quebra-cabeças');
  clickRadio('anamnesis[watches_tv]', true);
  fillField('anamnesis[watches_tv_how]', 'Assiste com atenção, especialmente desenhos educativos');
  fillField('anamnesis[favorite_programs]', 'Desenhos animados educativos e programas infantis');
  clickRadio('anamnesis[watches_repeatedly]', true);
  clickRadio('anamnesis[plays_with_others]', true);
  fillField('anamnesis[plays_with_others_how]', 'Brinca bem com outras crianças quando em contexto familiar');
  fillField('anamnesis[fights_with_peers]', 'Raramente, apenas quando frustrada ou quando não consegue algo que deseja');
  clickRadio('anamnesis[defends_from_aggression]', true);
  fillField('anamnesis[defense_method]', 'Defende-se verbalmente ou chama um adulto');
  fillField('anamnesis[reaction_prohibitions]', 'Aceita proibições quando explicadas, mas pode ficar frustrada');
  fillField('anamnesis[behavior_with_strangers]', 'Inicialmente tímida, mas depois se adapta');
  clickRadio('anamnesis[danger_awareness]', true);
  fillField('anamnesis[new_situations_reaction]', 'Ansiosa inicialmente, mas se adapta bem após um tempo');
  clickRadio('anamnesis[obeys_orders]', true);
  fillField('anamnesis[shows_affection]', 'É afetiva e gosta de receber carinho, demonstra afeto pela família');
  clickRadio('anamnesis[aggressive_behavior]', false);
  fillField('anamnesis[family_crisis_reaction]', 'Família conversa e acalma a criança, tentando entender a causa do comportamento');
  
  // Seção XIII - Escolaridade
  const attendsSchoolCheckbox = document.querySelector('input[name="anamnesis[attends_school]"]');
  if (attendsSchoolCheckbox) {
    attendsSchoolCheckbox.checked = true;
    attendsSchoolCheckbox.dispatchEvent(new Event('change', { bubbles: true }));
    filled++;
    
    // Aguardar campos aparecerem
    setTimeout(() => {
      fillField('anamnesis[school_name]', 'Escola Municipal ABC');
      fillSelect('anamnesis[school_period]', 'manha');
      fillField('anamnesis[school_phone]', '1133334444');
      fillField('anamnesis[school_enrollment_age]', '4 anos');
      clickRadio('anamnesis[has_support_teacher]', false);
      fillField('anamnesis[after_school_activities]', 'Aulas de reforço no contra turno');
      fillField('anamnesis[school_difficulties]', 'Dificuldade em matemática e concentração em algumas atividades');
      fillField('anamnesis[family_school_expectations]', 'Melhorar aprendizado e socialização com colegas');
    }, 500);
  }
  
  // Seção XIV - Saúde
  fillField('anamnesis[previous_illnesses]', 'Nenhuma doença grave, apenas resfriados e gripes ocasionais');
  clickRadio('anamnesis[hospitalizations]', false);
  clickRadio('anamnesis[has_epilepsy]', false);
  fillField('anamnesis[current_medications]', 'Nenhum medicamento em uso no momento');
  fillField('anamnesis[exams_done]', 'Hemograma completo e exame físico geral, todos normais');
  fillField('anamnesis[exams_to_do]', 'Nenhum exame agendado no momento');
  clickRadio('anamnesis[has_allergies]', false);
  
  // Checkboxes de doenças familiares
  const hasCheckbox = document.querySelector('input[name="anamnesis[family_conditions][]"][value="has"]');
  if (hasCheckbox) {
    hasCheckbox.checked = true;
    hasCheckbox.dispatchEvent(new Event('change', { bubbles: true }));
    filled++;
  }
  
  clickRadio('anamnesis[psychiatric_hospitalization]', false);
  
  // Seção XV - Informações Gerais
  fillField('anamnesis[general_information]', 'Criança apresenta bom desenvolvimento geral, com algumas dificuldades específicas em comunicação e socialização que estão sendo trabalhadas através de terapia. Família está engajada no processo terapêutico.');
  
  console.log(`✅ Preenchidos ${filled} campos`);
  if (errors.length > 0) {
    console.warn('⚠️ Erros encontrados:', errors);
  }
  
  return {
    filled,
    errors,
    message: 'Formulário preenchido com sucesso! Revise e clique em "Criar Anamnese"'
  };
})();



