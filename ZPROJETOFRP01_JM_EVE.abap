*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_EVE
*&---------------------------------------------------------------------*

*     Declara uma variável do tipo da classe
*----------------------------------------------------------------
  DATA:
        go_apontamento TYPE REF TO lcl_apontamento. "Classe local

  START-OF-SELECTION.

    CREATE OBJECT go_apontamento.

  GET peras.

    rp_provide_from_last p0001 space pn-begda pn-endda.
    rp_provide_from_last p0002 space pn-begda pn-endda.
    rp_provide_from_last p0007 space pn-begda pn-endda.

*     Verifica se há filtro de tipo de carga horária
*---------------------------------------------------
    IF p0007-schkz NOT IN so_schkz.

      "Pula iteração caso verdadeiro, para cada PERNR do select-options
      REJECT.
    ENDIF.

    go_apontamento->processar( ).

  END-OF-SELECTION.

    "Realiza uma apuração dos dados de saída sintética
    go_apontamento->rebase( ).

    IF p_smart IS INITIAL.

      go_apontamento->alv( ).

    ELSE.

      go_apontamento->smart( ).

    ENDIF.