-- CareVision / Oracle Select AI
-- STATUS: preparado, NÃO executado nesta entrega por ausência de ADB/credenciais.
-- Referência Oracle 2026: DBMS_CLOUD_AI.CREATE_PROFILE / SET_PROFILE.
-- Nunca substitua os placeholders por segredos em um arquivo versionado.

-- Executado por ADMIN, uma vez:
-- GRANT EXECUTE ON DBMS_CLOUD_AI TO CAREVISION_APP;

-- A credencial para OCI Generative AI deve ser criada no banco por processo seguro,
-- preferencialmente referenciando mecanismos Oracle/OCI; não incluir segredo aqui.

BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'CAREVISION_AI',
    attributes   => '{
      "provider": "oci",
      "credential_name": "<GENAI_CREDENTIAL_NAME>",
      "oci_compartment_id": "<OCI_COMPARTMENT_OCID>",
      "model": "<SUPPORTED_OCI_GENAI_MODEL>",
      "object_list": [
        {"owner": "<CAREVISION_SCHEMA>", "name": "VW_CAREVISION_SELECT_AI"},
        {"owner": "<CAREVISION_SCHEMA>", "name": "VW_CAREVISION_RANKING_PRESSAO"}
      ],
      "constraints": "true",
      "conversation": "true",
      "additional_instructions": "Responda apenas com base nas views CareVision. Informe período e município. Não trate IPA como taxa oficial de ocupação. Quando um campo estiver nulo, explique que o indicador não foi calculado."
    }'
  );
END;
/

EXEC DBMS_CLOUD_AI.SET_PROFILE('CAREVISION_AI');

-- Primeiro validar somente SQL gerado:
-- SELECT AI SHOWSQL quais municípios tiveram maior índice de pressão em maio de 2025;
-- Depois de revisar objetos/filtros, executar:
-- SELECT AI quais municípios tiveram maior índice de pressão em maio de 2025;
