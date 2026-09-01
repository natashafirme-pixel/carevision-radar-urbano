# Guia de deploy do MVP em Oracle APEX

Status atual: **artefatos prontos; deploy bloqueado por ausência de tenancy/credenciais Oracle nesta sessão**.

1. Provisionar Oracle Autonomous AI Database.
2. Criar workspace APEX vinculado ao schema do CareVision.
3. Executar `sql/ddl/01_carevision_dimensional.sql` e `sql/views/01_analytical_views.sql`.
4. Carregar os CSVs em RAW/STAGING ou, no fluxo produtivo, via OCI Object Storage + Data Integration.
5. Configurar papéis de leitura para a aplicação; não usar usuário ADMIN na aplicação.
6. Criar páginas:
   - Visão Executiva: KPIs, tendência e ranking;
   - Pressão Assistencial: filtro de período/município e metodologia;
   - Previsão: realizado × previsto + aviso de qualidade do modelo;
   - Fontes e Metodologia;
   - Consulta em linguagem natural (após Select AI habilitado).
7. Configurar `DBMS_CLOUD_AI` conforme `sql/select_ai/01_setup_select_ai.sql`, armazenando credenciais no OCI Vault ou mecanismo Oracle apropriado; nunca no código.
8. Testar com usuário de menor privilégio, revisar Session State Protection, autorização e logs.
9. Publicar a URL somente após validar navegação, consultas e ausência de segredos.

## Aceite mínimo
- filtros por período e município;
- indicadores e tendência;
- ranking do IPA;
- previsão/baseline;
- página de fontes e limitações;
- consulta NL2SQL somente em views autorizadas.
