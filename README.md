# CareVision — Radar Urbano | Sprint 2

CareVision transforma dados públicos de saúde em indicadores auditáveis de pressão assistencial, tendências e previsões para apoiar gestores públicos. Este repositório contém a execução técnica das **entregas 1, 3 e 4** do Challenge Oracle + FIAP.

## Status honesto desta entrega

| Componente | Status |
|---|---|
| ETL Python do recorte real | Implementado e testado |
| SIH/SUS 2025 — 5 municípios | Implementado e testado |
| IBGE 2025 — população | Implementado e testado |
| Indicadores + IPA-Piloto | Implementado e testado |
| Modelo Ridge + baselines | Implementado e testado |
| Oracle DDL / views | Implementado como código; não executado em OCI |
| CNES / leitos | Fonte e modelo preparados; dados não materializados nesta execução |
| Select AI | Script preparado; bloqueado sem Autonomous AI Database/credenciais |
| Oracle APEX/OAC | Guia e desenho preparados; MVP não publicado |
| GitHub | Publicado em `natashafirme-pixel/carevision-radar-urbano` |

## Problema e objetivo
Dados de internações, capacidade hospitalar, estabelecimentos e população estão distribuídos entre sistemas públicos e possuem granularidades diferentes. O CareVision organiza essas fontes em uma arquitetura Oracle e produz uma camada analítica que permite acompanhar pressão assistencial, desigualdades territoriais e evolução da demanda.

## Recorte quantitativo executado
- São Paulo, Guarulhos, Osasco, Santo André e São Bernardo do Campo;
- janeiro a dezembro de 2025 na camada integrada SIH + IBGE;
- 60 registros município-mês e 921.432 internações nesse recorte;
- população estimada pelo IBGE em 1º de julho de 2025;
- **série separada de modelagem: 6 municípios × 24 meses (2024–2025), 144 observações.**

Resultados dos indicadores não devem ser generalizados para o Brasil ou para todo o Estado de São Paulo. A série de 24 meses é usada para forecast e mantém o recorte claramente identificado.

## Arquitetura
`SIH/SUS + CNES + IBGE → OCI Object Storage → OCI Data Integration/Python → Oracle Autonomous AI Database (RAW/STAGING/ANALYTICS) → SQL/PLSQL + ML → Oracle Select AI → Oracle APEX/OAC`.

Controles transversais: IAM, Vault, TLS, Logging/Monitoring, qualidade, linhagem e versionamento.

Veja `docs/arquitetura/arquitetura_final.md` e `docs/arquitetura/status_arquitetura.csv`.

## Fontes
- Ministério da Saúde / DATASUS — SIH/SUS;
- Ministério da Saúde / CNES — Hospitais e Leitos;
- IBGE — Estimativas da População 2025.

URLs exatas, datas de acesso, períodos, formatos e limitações estão em `docs/fontes_dados.md` e `data/source_provenance.csv`.

## Dados e dicionário
- `data/raw_sample/`: amostra real mínima para reprodução;
- `data/processed_sample/`: saídas analíticas, métricas e previsões;
- `data/data_dictionary.csv`: dicionário de campos;
- `data/CHECKSUMS.sha256`: integridade dos arquivos usados.

## Instalação
```bash
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

## Execução
```bash
python pipelines/run_pipeline.py
pytest -q
```

O pipeline gera:
1. transformação wide → long;
2. integração com população;
3. validações de qualidade;
4. indicadores e IPA-Piloto;
5. treino e avaliação temporal do modelo;
6. `.joblib`, CSVs de métricas e gráficos.

## Índice de Pressão Assistencial
A versão executada usa três componentes disponíveis: internações por 100 mil, crescimento mensal positivo e desvio positivo da média móvel de três meses. Os componentes são normalizados e combinados com **pesos iguais**, pois não há evidência nesta Sprint para sustentar pesos diferentes.

O IPA é exploratório e **não é taxa oficial de ocupação**. A versão completa deverá incorporar leitos, pacientes-dia, permanência e mortalidade após a integração CNES/SIH detalhada.

## Modelo preditivo
Alvo: internações do mês seguinte. A separação é temporal e evita vazamento.

A série de forecast usa Bauru, Campinas, Presidente Prudente, Santos, São Paulo e Sorocaba entre jan/2024 e dez/2025.

No teste nov–dez/2025:
- baseline último valor: MAE **925,7**, RMSE **1.763,2**, MAPE **5,81%**;
- baseline sazonal t-12: MAE **351,3**, RMSE **473,6**, MAPE **6,00%**;
- Ridge log: MAE **1.582,9**, RMSE **3.643,0**, MAPE **6,32%**.

Os baselines simples venceram o Ridge; o modelo treinado é entregue como artefato experimental e **não é recomendado para produção** nesta Sprint.

## Oracle
- `sql/ddl/01_carevision_dimensional.sql`: dimensões/fatos e auditoria ETL;
- `sql/views/01_analytical_views.sql`: views para APEX/OAC/Select AI;
- `sql/select_ai/01_setup_select_ai.sql`: perfil Select AI com placeholders, sem segredos;
- `docs/mvp_deploy_apex.md`: roteiro de publicação.

## Segurança e LGPD
O pacote analítico desta entrega mantém apenas dados agregados município-mês. Credenciais, wallets, chaves, tokens e URLs secretas não são versionadas. O desenho produtivo prevê menor privilégio, IAM, Vault, criptografia em trânsito/repouso, logging e rastreabilidade.

## Notebooks
1. `01_extracao_dados.ipynb`
2. `02_qualidade_tratamento.ipynb`
3. `03_eda.ipynb`
4. `04_indice_pressao.ipynb`
5. `05_modelagem_preditiva.ipynb`

Todos foram executados do início ao fim na geração deste pacote.

## Repositório
https://github.com/natashafirme-pixel/carevision-radar-urbano

## Deploy e MVP
Não há URL publicada nesta execução. Para publicação real, seguir `docs/mvp_deploy_apex.md`, provisionar o Autonomous AI Database e criar o workspace APEX. Somente depois de testar a navegação e o Select AI a URL deve ser adicionada aqui.

## Limitações e próximos passos
Consulte `docs/limitacoes.md`. Prioridades: evoluir de 24 para 36 meses na série de forecast, ampliar cobertura territorial, integrar competências CNES mensais, permanência/mortalidade, validar o IPA com especialistas, rolling-origin validation e deploy Oracle.

## Autores — Radar Urbano
- Diogo Mendes — RM 571539
- Fernando Pereira — RM 573350
- Marlon Petrvky — RM 570188
- Natasha Firme — RM 573628

Projeto acadêmico — FIAP + Oracle Challenge, 2026.
