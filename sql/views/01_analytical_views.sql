CREATE OR REPLACE VIEW VW_CAREVISION_INDICADORES AS
SELECT
    t.data_referencia,
    t.ano,
    t.mes,
    m.cod_ibge7,
    m.nome_municipio,
    m.uf,
    p.populacao_referencia,
    p.total_internacoes,
    p.internacoes_100k,
    p.media_permanencia,
    p.mediana_permanencia,
    p.taxa_mortalidade_pct,
    p.leitos_sus,
    p.leitos_sus_100k,
    p.ocupacao_estimada_pct,
    p.crescimento_mom_pct,
    p.indice_pressao,
    p.classe_pressao,
    p.previsao_internacoes_prox,
    p.modelo_previsao
FROM fato_pressao_hospitalar_mensal p
JOIN dim_tempo t ON t.sk_tempo = p.sk_tempo
JOIN dim_municipio m ON m.sk_municipio = p.sk_municipio;

CREATE OR REPLACE VIEW VW_CAREVISION_RANKING_PRESSAO AS
SELECT v.*,
       DENSE_RANK() OVER (PARTITION BY data_referencia ORDER BY indice_pressao DESC NULLS LAST) AS posicao_pressao
FROM VW_CAREVISION_INDICADORES v;

CREATE OR REPLACE VIEW VW_CAREVISION_SELECT_AI AS
SELECT data_referencia, cod_ibge7, nome_municipio, uf,
       total_internacoes, internacoes_100k, leitos_sus, leitos_sus_100k,
       crescimento_mom_pct, indice_pressao, classe_pressao,
       previsao_internacoes_prox, modelo_previsao
FROM VW_CAREVISION_INDICADORES;

COMMENT ON TABLE VW_CAREVISION_SELECT_AI IS 'CareVision: indicadores municipais mensais para consultas analíticas. IPA é índice exploratório; ocupação só existe quando calculada com dados compatíveis.';
