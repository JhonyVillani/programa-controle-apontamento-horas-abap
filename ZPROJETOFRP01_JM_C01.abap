*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_apontamento DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_apontamento DEFINITION.
  PUBLIC SECTION.

*   Tabelas complementares populadas no constructor
    DATA: gt_t001  TYPE TABLE OF t001,  "Descrição empresas
          gt_t500p TYPE TABLE OF t500p, "Descrição área de RH
          gt_t001p TYPE TABLE OF t001p, "Descrição subárea de RH
          gt_t501t TYPE TABLE OF t501t, "Descrição Grupo Emp.
          gt_t503t TYPE TABLE OF t503t, "Descrição Sub-Grupo Emp,
          gt_p0001 TYPE TABLE OF p0001, "Tabela com filtro select-options
          gt_zprojetoft01 TYPE TABLE OF zprojetoft01_jm, "Tabela Apontamento de Projetos
          gt_zprojetoft02 TYPE TABLE OF zprojetoft02_jm, "Tabela de horas trabalhadas
          gt_zprojetoft03 TYPE TABLE OF zprojetoft03_jm. "Tabela de projetos

*   Atributos de saída
    DATA: mt_saida TYPE TABLE OF zprojetofs01_jm,
          ms_saida TYPE zprojetofs01_jm.

*   Atributos do ALV
    DATA: mo_alv TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table,
          go_zebra TYPE REF TO cl_salv_display_settings.

    METHODS:
   constructor,
   processar,
   exibir.

ENDCLASS.                    "lcl_apontamento DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_apontamento IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_apontamento IMPLEMENTATION.
  METHOD constructor.

    SELECT * "bukrs butxt
      FROM t001
      INTO TABLE gt_t001
     WHERE spras = sy-langu. "AND land1 = 'BR'.

    SELECT * "bukrs name1
      FROM t500p
      INTO TABLE gt_t500p.
    "WHERE land1 = 'BR'.

    SELECT *
      FROM t001p
      INTO TABLE gt_t001p.
    "WHERE molga = 37.

    SELECT *
      FROM t501t
      INTO TABLE gt_t501t
     WHERE sprsl = sy-langu.

    SELECT *
      FROM t503t
      INTO TABLE gt_t503t
     WHERE sprsl = sy-langu.

    SELECT *
      FROM zprojetoft01_jm
      INTO TABLE gt_zprojetoft01.

    SELECT *
      FROM zprojetoft02_jm
      INTO TABLE gt_zprojetoft02.

    SELECT *
      FROM zprojetoft03_jm
      INTO TABLE gt_zprojetoft03
     WHERE projt IN so_projt.
    "where IN so_pernr

**********************COMO FAZER O GET_PERAS LER MEUS SELECT-OPTIONS?
*
*    SELECT *
*        FROM pA0001
*        INTO TABLE gt_p0001
*        WHERE schkz    IN so_schkz
*          AND projt    IN so_projt.

  ENDMETHOD.                    "constructor

  METHOD processar.

    SORT p0001 BY begda DESCENDING.

    DATA: gs_p0001 TYPE p0001,
          gs_p0002 TYPE p0002,
          gs_p0007 TYPE p0007,
          gs_t500p TYPE t500p,
          gs_t001p TYPE t001p,
          gs_t501t TYPE t501t,
          gs_t503t TYPE t503t,
          gs_zprojetoft03 TYPE zprojetoft03_jm,
          gs_zprojetoft02 TYPE zprojetoft02_jm,
          gs_zprojetoft01 TYPE zprojetoft01_jm,
          gs_t001  TYPE t001.

    DATA: vlr_aux TYPE zprojetofde04_jm.

    LOOP AT gt_zprojetoft03 INTO gs_zprojetoft03.

      LOOP AT p0001 INTO gs_p0001.
        IF gs_zprojetoft03-pernr EQ gs_p0001-pernr.

          CLEAR gs_zprojetoft01.
          READ TABLE gt_zprojetoft01 INTO gs_zprojetoft01 WITH KEY projt = gs_zprojetoft03-projt.

*       Caso a opção “Sintético (horas extras)” estiver marcada, as horas de apontamentos devem ser
*       somadas por dia e somente serão exibidos os dias em que o colaborador possui hora extra:

*       Quantidade de horas extras (= Total de horas apontadas – Horas mínimas diárias da tabela 2)
*       Valor por hora extra (Tabela 2-EXTRA)
*       Valor total de horas extras (= Quantidade de horas extras * Valor por hora extra)

          CLEAR gs_p0002.
          READ TABLE p0002 INTO gs_p0002 WITH KEY pernr = pernr-pernr. "Desc. Pessoa

          CLEAR gs_t001.
          READ TABLE gt_t001 INTO gs_t001 WITH KEY bukrs = gs_p0001-bukrs. "Desc Empresa

          CLEAR gs_t500p.
          READ TABLE gt_t500p INTO gs_t500p WITH KEY bukrs = gs_p0001-bukrs "Desc Área de RH
                                                     persa = gs_p0001-werks.

          CLEAR gs_t001p.
          READ TABLE gt_t001p INTO gs_t001p WITH KEY werks = gs_p0001-werks. "Desc Sub RH

          CLEAR gs_t501t.
          READ TABLE gt_t501t INTO gs_t501t WITH KEY persg = gs_p0001-persg. "Desc Grupo Emp.

          CLEAR gs_t503t.
          READ TABLE gt_t503t INTO gs_t503t WITH KEY persk = gs_p0001-persk. "Desc Sub-Grupo Emp.

          CLEAR gs_p0007.
          READ TABLE p0007[] INTO gs_p0007 WITH KEY pernr = pernr-pernr. "Desc Sub-Grupo Emp.

          CLEAR gs_zprojetoft02.
          READ TABLE gt_zprojetoft02 INTO gs_zprojetoft02 WITH KEY schkz = gs_p0007-schkz. "Horas de trabalho

          ms_saida-pernr  = gs_p0001-pernr.
          ms_saida-cname  = gs_p0002-cname.
          ms_saida-bukrs  = gs_p0001-bukrs.
          ms_saida-butxt  = gs_t001-butxt.
          ms_saida-werks  = gs_p0001-werks.
          ms_saida-name1  = gs_t500p-name1.
          ms_saida-btrtl  = gs_p0001-btrtl.
          ms_saida-btext  = gs_t001p-btext.
          ms_saida-persg  = gs_p0001-persg.
          ms_saida-ptext  = gs_t501t-ptext.
          ms_saida-persk  = gs_p0001-persk.
          ms_saida-ptext2 = gs_t503t-ptext.
          ms_saida-schkz  = gs_p0007-schkz.
          ms_saida-data   = gs_zprojetoft03-data.
          ms_saida-projt  = gs_zprojetoft03-projt.
          ms_saida-protx  = gs_zprojetoft01-protx.
          ms_saida-horas  = gs_zprojetoft03-horas.

          IF gs_zprojetoft03-horas > gs_zprojetoft02-hrmin.
            vlr_aux = gs_zprojetoft03-horas - gs_zprojetoft02-hrmin.
          ELSE.
            vlr_aux = '0.0'.
          ENDIF.

          ms_saida-qtdhrext   = vlr_aux.
          ms_saida-vlrhrext   = gs_zprojetoft02-extra.
          ms_saida-vlrtlhrext = ms_saida-qtdhrext * ms_saida-vlrhrext.

          APPEND ms_saida TO mt_saida.
          CLEAR ms_saida.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.                    "processar

  METHOD exibir.

    IF p_smart IS INITIAL.

*     Criando o relatório ALV, declarando na classe a variáveis mo_alv referenciando cl_salv_table
*     Chama o método que constrói a saída ALV
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = mo_alv
        CHANGING
          t_table      = mt_saida.

*     Otimiza tamanho das colunas
      go_columns = mo_alv->get_columns( ). "Retorna o objeto tipo coluna INSTANCIADO
      go_columns->set_optimize( ).

*     Zebrar report
      go_zebra = mo_alv->get_display_settings( ).
      go_zebra->set_striped_pattern( abap_true ).

      IF p_sinttc = abap_false. "CASO DESMARCADO

        DATA: gr_columns TYPE REF TO cl_salv_columns_table.
        DATA: gr_column    TYPE REF TO cl_salv_column.

*       Obtem as colunas
        gr_columns = mo_alv->get_columns( ).

*       Selecionar a coluna correta
        TRY.
            gr_column ?= gr_columns->get_column( 'QTDHREXT' ).
            gr_column->set_technical( value = if_salv_c_bool_sap=>true ).

            gr_column ?= gr_columns->get_column( 'VLRHREXT' ).
            gr_column->set_technical( value = if_salv_c_bool_sap=>true ).

            gr_column ?= gr_columns->get_column( 'VLRTLHREXT' ).
            gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
          CATCH cx_salv_not_found.

        ENDTRY.

      ENDIF.

*     Mostra o ALV
      mo_alv->display( ). "Imprime na tela do relatório ALV

    ELSE.
*     Declarações do Smartform
      DATA:
            lv_fm_name            TYPE rs38l_fnam,
            ls_control_parameters TYPE ssfctrlop,
            ls_output_options     TYPE ssfcompop,
            ls_job_output_info    TYPE ssfcrescl,
            ls_saida              TYPE zprojetofs01_jm. "Do tipo da estrutura SE11 criada para exibição

      LOOP AT mt_saida INTO ls_saida.

*       Declarações de variáveis a serem utilizadas no Case que verifica a quantidade de páginas via LOOP
        DATA: lv_lines TYPE i,
              lv_tabix TYPE sy-tabix.
        lv_tabix = sy-tabix.

*        READ TABLE mt_saida INTO ls_saida INDEX 1.

*       Função que passa uma estrutura para o Smartform e exibe-o (Necessário método de importação FM_NAME)
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZPROJETOFSF01_JM'
          IMPORTING
            fm_name            = lv_fm_name "Função definida abaixo
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

*       Definições de saída do Smartform
        ls_output_options-tddest        = 'LP01'.
        ls_output_options-tdimmed       = abap_true.
        ls_control_parameters-no_dialog = abap_true.
        ls_control_parameters-preview   = abap_true.

*       Case para verificar quantidade de páginas a serem exibidas pelo LOOP
        DESCRIBE TABLE mt_saida LINES lv_lines.

        CASE lv_tabix.
          WHEN 1.
            ls_control_parameters-no_open = abap_false.
            ls_control_parameters-no_close = abap_true.
          WHEN OTHERS.
            ls_control_parameters-no_open = abap_true.
            ls_control_parameters-no_close = abap_true.
        ENDCASE.

        IF lv_lines EQ 1.
          ls_control_parameters-no_open = abap_false.
          ls_control_parameters-no_close = abap_false.
        ELSEIF sy-tabix EQ lv_lines.
          ls_control_parameters-no_open = abap_true.
          ls_control_parameters-no_close = abap_false.
        ENDIF.

*       Função que importa a estrutura do programa para dentro do Smartform (Necessária para o primeiro método funcionar)
        CALL FUNCTION lv_fm_name
          EXPORTING
            control_parameters = ls_control_parameters
            output_options     = ls_output_options
            user_settings      = space
            is_saida           = ls_saida "No Smartform é necessário ter a variável job declarada com o mesmo tipo da estrutura global
          IMPORTING
            job_output_info    = ls_job_output_info
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.                    "exibir

ENDCLASS.                    "lcl_apontamento IMPLEMENTATION