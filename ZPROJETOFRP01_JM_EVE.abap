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

*     Verificação dos campos do PNPCE antes do PROCESSAMENTO dos dados
*----------------------------------------------------------------------
    IF p0007-schkz NOT IN so_schkz.
      "Pula iteração caso verdadeiro, para cada PERNR do select-options
      REJECT.

    ELSEIF p0001-bukrs NOT IN pnpbukrs.
      "Pula iteração do campo Empresa
      REJECT.

    ELSEIF p0001-werks NOT IN pnpwerks.
      "Pula iteração da Área de RH
      REJECT.

    ELSEIF p0001-btrtl NOT IN pnpbtrtl.
      "Pula iteração da Sub-Área de RH
      REJECT.

    ENDIF.

*     Inicia o processamento dos dados encontrados no Select-Options
*-------------------------------------------------------------------
    go_apontamento->processar( ).

  END-OF-SELECTION.

*     Prepara a exibição dos dados caso exista(m) resultado(s)
*-------------------------------------------------------------
    "Verifica se a tabela está vazia
    go_apontamento->verifica( ).

    "Realiza uma apuração dos dados de saída sintética
    go_apontamento->rebase( ).

    IF p_smart IS INITIAL.

      go_apontamento->alv( ).

    ELSE.

      go_apontamento->smart( ).

    ENDIF.