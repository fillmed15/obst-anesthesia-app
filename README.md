# Obst Anesthesia App

Flutter Web mobile-first para consulta e apoio à decisão em anestesia obstétrica. Projeto independente do AnestPedia, inspirado na sua filosofia: pouco texto, hierarquia clínica clara, cards reutilizáveis e cálculos rápidos.

## Estado do primeiro ciclo

- Tema lilás/rosa profissional e responsivo.
- Navegação inferior persistente com Raquianestesia, Analgesia de Parto, Risco & Segurança e Emergências.
- Perfil clínico opcional e reutilizado entre módulos.
- Raquianestesia: dose informada pelo usuário, cálculo dose ↔ volume, posição na faixa estudada, perfil temporal e interpretação de fentanil, sufentanil e morfina; sem “dose ideal”.
- Analgesia: cálculos de solução, PIEB e PCEA com distinção de máximo teórico.
- Cateter peridural: dados de instalação, histórico de bolus/repique, relógio e janela temporal baseada em faixa explicitamente informada.
- Segurança: plaquetas (SOAP 2021) e cenários iniciais de anticoagulação (ASRA 2025).
- Emergências: estrutura QRH; protocolos com dados incompletos são marcados como pendentes.
- Referências e matriz clínica separadas da interface.

## Segurança clínica

O app distingue **Cálculo**, **Estimativa**, **Guideline** e **Pendente**. Ferramenta destinada a profissionais de saúde; não substitui julgamento clínico, protocolo institucional ou avaliação individual.

## Execução

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Estrutura

```text
lib/
  calculations/     matemática determinística
  clinical_data/    conteúdo clínico estruturado e QRHs
  models/           entidades clínicas e referências
  screens/          módulos e fluxos
  services/         estado de sessão
  theme/            identidade visual
  widgets/          componentes reutilizáveis
test/                testes de cálculo
```

## Pendências deliberadas

- Refinar faixas temporais por subgrupos, baricidade, técnica e adjuvantes à medida que novas evidências forem incorporadas.
- Regimes clínicos padrão de PIEB/PCEA e tempo farmacológico de repique.
- Conversão de peridural para cesárea.
- Doses completas nos QRHs de eclâmpsia, hipotensão e bloqueio alto.
- DOACs e antiagregantes adicionais.

Nenhum desses itens é declarado funcional até revisão dedicada.

## Referências principais

- SOAP thrombocytopenia consensus (2021), PMID 33861047.
- ASRA antithrombotic guideline, 5ª edição (2025), PMID 39880411.
- SOAP ERAC consensus (2021), PMID 33177330.
- ASRA LAST checklist (2020; atualização anunciada para 2027).
- WHO/FIGO/ICM postpartum haemorrhage guideline (2025).
- AHA Cardiac Arrest in Pregnancy Algorithm (2025).

Última revisão clínica desta versão: 29/09/2026.
