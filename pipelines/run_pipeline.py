from pathlib import Path
import sys, json
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from src.transform.prepare import wide_tabnet_to_long, integrate_population, validate_quality
from src.features.pressure_index import build_pressure_index
from src.models.forecast import train_temporal_forecast
from src.visualization.charts import make_charts

raw=ROOT/'data/raw_sample/sih_sus_sp_5municipios_2025_raw_wide.csv'
pop=ROOT/'data/raw_sample/ibge_populacao_5municipios_2025.csv'
processed=ROOT/'data/processed_sample'
long=wide_tabnet_to_long(raw)
base=integrate_population(long,pop)
quality_before=validate_quality(base)
feat=build_pressure_index(base)
feat.to_csv(processed/'analytical_monthly.csv',index=False,date_format='%Y-%m-%d')
quality_after=validate_quality(feat)
forecast_panel=__import__('pandas').read_csv(ROOT/'data/processed_sample/forecast_panel_sih_sp_6municipios_2024_2025.csv', parse_dates=['mes_referencia'])
result=train_temporal_forecast(forecast_panel, str(ROOT/'models/forecast_internacoes_ridge.joblib'))
result.predictions.to_csv(processed/'forecast_test_predictions.csv',index=False,date_format='%Y-%m-%d')
result.metrics.to_csv(processed/'model_metrics.csv',index=False)
make_charts(feat,result.predictions,result.metrics,ROOT/'presentation/assets')
report={'before':quality_before,'after':quality_after,'model_metrics':result.metrics.to_dict(orient='records')}
(processed/'execution_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
