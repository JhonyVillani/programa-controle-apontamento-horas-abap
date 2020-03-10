*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_EVE
*&---------------------------------------------------------------------*

*     Declara uma variável do tipo da classe
*----------------------------------------------------------------
  DATA:
        go_apontamento TYPE REF TO lcl_apontamento. "Classe local

  "No momento que for requisitado um valor, preencherá a variável p_file

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
    lcl_apontamento=>save_file( ). "Chamada de método estático devido não existir instâncias de objetos

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

*     Valida qual radio button está ativo e chama o respectivo método
*--------------------------------------------------------------------
    IF p_alv IS NOT INITIAL.

      go_apontamento->alv( ).

    ELSEIF p_smart IS NOT INITIAL.

      go_apontamento->smart( ).

    ELSE.
      go_apontamento->leitura_dados( ).

    ENDIF.