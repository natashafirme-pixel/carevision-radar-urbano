# Fontes de dados e proveniência

Data de acesso da documentação oficial: **01/09/2026**.

## SIH/SUS — Produção Hospitalar
- Órgão: Ministério da Saúde / DATASUS.
- URL oficial: https://datasus.saude.gov.br/acesso-a-informacao/producao-hospitalar-sih-sus/
- Período usado: janeiro a dezembro de 2025.
- Recorte analítico: São Paulo, Guarulhos, Osasco, Santo André e São Bernardo do Campo.
- Variável usada: internações por município e mês.
- Formato do snapshot: CSV de exportação TabNet.
- Limitações: internações não equivalem a pacientes únicos e revisões podem ocorrer.

Nesta execução local foi usado um snapshot público pinado por commit que preserva uma exportação SIH/SUS, pois o runtime não conseguiu materializar downloads binários externos. A fonte primária permanece o DATASUS e o processo produtivo deve substituir o snapshot por arquivo oficial.

## CNES — Hospitais e Leitos
- Órgão: Ministério da Saúde / CNES.
- URL oficial: https://dadosabertos.saude.gov.br/dataset/hospitais-e-leitos
- Abrangência: Brasil.
- Variáveis previstas: CNES, município, tipo de leito, leitos existentes, leitos SUS e competência.
- Status nesta execução: **não materializado**, portanto não foi usado para produzir números finais de leitos ou ocupação.

## IBGE — Estimativas da População 2025
- Órgão: IBGE.
- URL oficial: https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html
- Data de referência: 01/07/2025.
- Variáveis usadas: código IBGE e população estimada.
- Frequência: anual.

## Série histórica adicional para forecast
Para o modelo preditivo foi montado um painel de seis municípios de São Paulo entre janeiro/2024 e dezembro/2025, totalizando 144 observações município-mês. A fonte primária continua sendo SIH/SUS/DATASUS e a série é usada apenas para modelagem preditiva.

## Regra de governança
1. Arquivo oficial entra em RAW/OCI Object Storage sem alteração.
2. SHA-256 e metadados de origem são registrados.
3. STAGING padroniza tipos, datas e códigos.
4. ANALYTICS mantém apenas campos necessários a indicadores/ML.
5. Nenhum dado deve ser interpretado além da granularidade disponível.
