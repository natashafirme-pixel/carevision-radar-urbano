# Metodologia analítica — CareVision Sprint 2

## Recorte executado
O piloto integrado usa **60 observações município-mês**, referentes a cinco municípios paulistas entre janeiro e dezembro de 2025. Somam **921.432 internações SIH/SUS** no recorte. A escolha permite provar ETL, integração territorial, indicador e previsão sem apresentar o resultado como estadual ou nacional.

Para os indicadores integrados SIH + IBGE, o recorte permanece em 12 meses. **Para a modelagem preditiva, foi adicionada uma série de 24 meses (jan/2024–dez/2025) para seis municípios paulistas, totalizando 144 observações município-mês.** Assim, o forecast atende ao horizonte histórico preferencial mínimo, embora ainda permaneça abaixo dos 36 meses ideais.

## Preparação
1. leitura do CSV wide do SIH/SUS;
2. conversão de 12 colunas mensais para formato long;
3. conversão das competências para `DATE` (`YYYY-MM-01`);
4. validação de `codigo_municipio_6`;
5. integração com `codigo_ibge_7` e população 2025;
6. validação da chave `municipio + mes`;
7. checagem de duplicidades, nulos e valores negativos;
8. geração das features analíticas.

No recorte: 60 registros esperados, 60 aproveitados, 0 duplicidades, 0 nulos de origem e 0 valores impossíveis. Os nulos posteriores são exclusivamente estruturais de features temporais.

## Indicadores calculados
- internações;
- internações mensais por 100 mil habitantes;
- crescimento mensal de internações;
- desvio da internação corrente em relação à média dos três meses anteriores;
- IPA-Piloto v1.

Não foram calculados nesta execução: permanência média/mediana, mortalidade hospitalar, quantidade de leitos SUS, leitos por 100 mil ou ocupação estimada, pois os campos necessários não foram materializados de forma integrada no runtime.

## Índice de Pressão Assistencial — IPA-Piloto v1
O índice desta Sprint é **relativo e exploratório**. Ele não é indicador oficial do SUS nem taxa de ocupação.

Componentes disponíveis:
1. `I`: internações por 100 mil habitantes;
2. `G`: crescimento mensal positivo de internações;
3. `D`: desvio positivo frente à média móvel dos três meses anteriores.

Cada componente é normalizado por min-max no universo do piloto:

`N(x) = (x - min(x)) / (max(x) - min(x))`

Variações negativas em `G` e `D` são truncadas em zero, pois representam alívio relativo e não pressão incremental.

**Pesos:** iguais, porque não há nesta Sprint evidência empírica ou consenso de especialistas que sustente pesos diferentes.

`IPA = 100 × [N(I) + N(G) + N(D)] / 3`

Faixas operacionais exploratórias:
- 0 a <25: baixa pressão;
- 25 a <50: pressão moderada;
- 50 a <75: alta pressão;
- 75 a 100: pressão crítica.

## Previsão
Alvo: internações do mês seguinte por município. A série cobre **Bauru, Campinas, Presidente Prudente, Santos, São Paulo e Sorocaba** entre janeiro/2024 e dezembro/2025.

Não há divisão aleatória. A avaliação é temporal:
- treino: alvos até agosto/2025;
- validação: setembro e outubro/2025;
- teste: novembro e dezembro/2025.

Modelos comparados:
- baseline último valor observado;
- baseline média dos 3 últimos meses;
- baseline sazonal ingênuo (mesmo mês do ano anterior, t-12);
- Ridge sobre `log1p(target)`.

Resultado no teste: o **baseline sazonal t-12** obteve o menor MAE e RMSE (351,3 e 473,6), enquanto o último valor teve MAPE ligeiramente menor (5,81% vs. 6,00%). O Ridge ficou atrás nos erros absolutos (MAE 1.582,9; RMSE 3.643,0; MAPE 6,32%). Portanto, **o modelo complexo não deve ser promovido para decisão operacional** nesta Sprint.
