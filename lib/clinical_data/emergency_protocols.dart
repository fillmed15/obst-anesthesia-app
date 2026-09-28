import 'package:flutter/material.dart';

import '../models/models.dart';

abstract final class EmergencyProtocols {
  static const all = <EmergencyProtocol>[
    EmergencyProtocol(
      title: 'Bloqueio neuroaxial alto/total',
      subtitle: 'Reconhecer • ventilar • sustentar circulação',
      icon: Icons.airline_seat_flat_angled,
      referenceIds: [],
      reviewPending: true,
      steps: [
        EmergencyStep('RECONHECER', ['Dispneia, dificuldade para falar, fraqueza de membros superiores', 'Hipotensão/bradicardia, perda de consciência ou apneia']),
        EmergencyStep('AÇÃO IMEDIATA', ['Pedir ajuda e interromper administração neuroaxial', 'Oxigênio 100%; ventilação assistida e via aérea conforme necessidade'], danger: true),
        EmergencyStep('SUPORTE', ['Deslocamento uterino à esquerda', 'Tratar hipotensão/bradicardia e iniciar RCP se indicado', 'Preparar conversão para anestesia geral e possível parto urgente']),
        EmergencyStep('STATUS', ['Sequência validada conceitualmente; doses específicas aguardam revisão formal.']),
      ],
    ),
    EmergencyProtocol(
      title: 'LAST',
      subtitle: 'Toxicidade sistêmica por anestésico local',
      icon: Icons.bolt,
      referenceIds: ['asra-last-2020'],
      steps: [
        EmergencyStep('RECONHECER', ['Alteração neurológica súbita, convulsão, arritmia ou colapso após anestésico local']),
        EmergencyStep('AÇÃO IMEDIATA', ['Pedir ajuda; interromper anestésico local', 'Garantir via aérea e oxigenação; tratar convulsão', 'Iniciar emulsão lipídica 20% conforme checklist ASRA disponível no ⓘ Evidência'], danger: true),
        EmergencyStep('RESSUSCITAÇÃO MODIFICADA', ['Usar doses menores de epinefrina; evitar vasopressina, bloqueadores de canal de cálcio, betabloqueadores e mais anestésico local', 'Considerar circulação extracorpórea precocemente em instabilidade refratária']),
        EmergencyStep('ESCALONAR', ['Monitorizar após estabilidade e transferir para cuidado intensivo', 'Dose máxima e esquema completo devem ser conferidos no checklist ASRA']),
      ],
    ),
    EmergencyProtocol(
      title: 'Hemorragia pós-parto',
      subtitle: 'Bundle de primeira resposta',
      icon: Icons.bloodtype_outlined,
      referenceIds: ['who-pph-2025'],
      steps: [
        EmergencyStep('ATIVAR', ['Chamar equipe e protocolo de hemorragia', 'Quantificar perda, monitorizar, obter acesso venoso e exames'], danger: true),
        EmergencyStep('PRIMEIRA RESPOSTA', ['Massagem uterina', 'Uterotônico', 'Ácido tranexâmico', 'Fluidos IV', 'Examinar trato genital e causa do sangramento']),
        EmergencyStep('ESCALONAR', ['Hemocomponentes guiados por clínica/laboratório', 'Tamponamento, radiologia intervencionista ou cirurgia conforme causa e resposta']),
        EmergencyStep('NOTA', ['Doses de uterotônicos devem seguir o protocolo institucional; não automatizadas neste build.']),
      ],
    ),
    EmergencyProtocol(
      title: 'Eclâmpsia',
      subtitle: 'Convulsão na gestação/puerpério',
      icon: Icons.monitor_heart_outlined,
      referenceIds: [],
      reviewPending: true,
      steps: [
        EmergencyStep('AÇÃO IMEDIATA', ['Pedir ajuda; proteger contra trauma', 'Decúbito lateral, via aérea, oxigênio e monitorização', 'Magnésio é terapia de primeira linha — esquema institucional'], danger: true),
        EmergencyStep('DEPOIS DA CRISE', ['Tratar hipertensão grave', 'Avaliar causas alternativas e toxicidade por magnésio', 'Planejar parto após estabilização materna']),
        EmergencyStep('STATUS', ['Doses e critérios aguardam revisão ACOG/WHO/FEBRASGO.']),
      ],
    ),
    EmergencyProtocol(
      title: 'Hipotensão grave pós-raqui',
      subtitle: 'Perfusão materna e fetal',
      icon: Icons.trending_down,
      referenceIds: [],
      reviewPending: true,
      steps: [
        EmergencyStep('AÇÃO IMEDIATA', ['Deslocamento uterino à esquerda', 'Oxigênio e avaliação rápida do nível do bloqueio', 'Vasopressor e fluido conforme contexto'], danger: true),
        EmergencyStep('BUSCAR CAUSA', ['Simpatectomia', 'Bloqueio alto', 'Hemorragia', 'Reação medicamentosa ou causa cardíaca']),
        EmergencyStep('STATUS', ['Algoritmo e doses de vasopressor aguardam consenso obstétrico formal.']),
      ],
    ),
    EmergencyProtocol(
      title: 'Falha de via aérea obstétrica',
      subtitle: 'OAA/DAS',
      icon: Icons.masks_outlined,
      referenceIds: ['oaa-das-airway-2015'],
      steps: [
        EmergencyStep('OTIMIZAR', ['Pedir ajuda; limitar tentativas e corrigir posição/técnica', 'Priorizar oxigenação e usar o operador mais experiente'], danger: true),
        EmergencyStep('INTUBAÇÃO FALHOU', ['Declarar falha', 'Inserir dispositivo supraglótico de 2ª geração', 'Decidir acordar versus prosseguir conforme urgência materno-fetal e ventilação']),
        EmergencyStep('NÃO INTUBA / NÃO OXIGENA', ['Acesso cervical de emergência conforme algoritmo local']),
      ],
    ),
    EmergencyProtocol(
      title: 'PCR materna',
      subtitle: 'AHA 2025',
      icon: Icons.favorite_border,
      referenceIds: ['aha-pregnancy-arrest-2025'],
      steps: [
        EmergencyStep('BLS / ALS', ['RCP de alta qualidade e desfibrilação quando indicada', 'Deslocamento uterino manual contínuo se fundo uterino ≥ umbigo', 'Acesso IV acima do diafragma'], danger: true),
        EmergencyStep('OTIMIZAR', ['Via aérea precoce pelo profissional mais experiente', 'Suspender magnésio IV e administrar cálcio se aplicável', 'Tratar causas obstétricas e gerais']),
        EmergencyStep('PARTO RESSUSCITATIVO', ['Preparar imediatamente se fundo uterino ≥ umbigo', 'Sem ROSC: meta de nascimento até 5 minutos, conforme recursos locais']),
      ],
    ),
  ];
}
