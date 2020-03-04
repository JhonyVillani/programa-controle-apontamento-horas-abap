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
    DATA: mt_t001  TYPE TABLE OF t001,  "Descrição empresas
          mt_t500p TYPE TABLE OF t500p, "Descrição área de RH
          mt_t001p TYPE TABLE OF t001p, "Descrição subárea de RH
          mt_t501t TYPE TABLE OF t501t, "Descrição Grupo Emp.
          mt_t503t TYPE TABLE OF t503t, "Descrição Sub-Grupo Emp,
          mt_p0001 TYPE TABLE OF p0001, "Tabela com filtro select-options
          mt_zprojetoft01 TYPE TABLE OF zprojetoft01_jm, "Tabela Apontamento de Projetos
          mt_zprojetoft02 TYPE TABLE OF zprojetoft02_jm, "Tabela de horas trabalhadas
          mt_zprojetoft03 TYPE TABLE OF zprojetoft03_jm. "Tabela de projetos

*   Atributos de saída
    DATA: mt_saida    TYPE TABLE OF zprojetofs01_jm,
          mt_saidastc TYPE TABLE OF zprojetofs01_jm,
          ms_saida    TYPE zprojetofs01_jm.

*   Atributos do ALV
    DATA: mo_alv TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table,
          go_zebra TYPE REF TO cl_salv_display_settings,
          gr_columns TYPE REF TO cl_salv_columns_table,
          gr_column    TYPE REF TO cl_salv_column.

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
      INTO TABLE mt_t001
     WHERE spras = sy-langu. "AND land1 = 'BR'.

    SELECT * "bukrs name1
      FROM t500p
      INTO TABLE mt_t500p.
    "WHERE land1 = 'BR'.

    SELECT *
      FROM t001p
      INTO TABLE mt_t001p.
    "WHERE molga = 37.

    SELECT *
      FROM t501t
      INTO TABLE mt_t501t
     WHERE sprsl = sy-langu.

    SELECT *
      FROM t503t
      INTO TABLE mt_t503t
     WHERE sprsl = sy-langu.

    SELECT *
      FROM zprojetoft01_jm
      INTO TABLE mt_zprojetoft01. "Projetos

    SELECT *
      FROM zprojetoft02_jm
      INTO TABLE mt_zprojetoft02. "Plano de horas

    SELECT *
      FROM zprojetoft03_jm
      INTO TABLE mt_zprojetoft03 "Projetos associados à pessoas
     WHERE pernr IN pnppernr
*       AND bukrs IN pnpbukrs
*       AND schkz IN so_schkz
       AND projt IN so_projt.

  ENDMETHOD.                    "constructor

  METHOD processar.

    SORT mt_zprojetoft03 BY data.

    DATA: ms_p0001 TYPE p0001,
          ms_p0002 TYPE p0002,
          ms_p0007 TYPE p0007,
          ms_t500p TYPE t500p, "Descrição área de RH
          ms_t001p TYPE t001p, "Descrição subárea de RH
          ms_t501t TYPE t501t, "Descrição Grupo Emp.
          ms_t503t TYPE t503t, "Descrição Sub-Grupo Emp
          ms_zprojetoft03 TYPE zprojetoft03_jm,
          ms_zprojetoft02 TYPE zprojetoft02_jm,
          ms_zprojetoft01 TYPE zprojetoft01_jm,
          ms_t001  TYPE t001. "Descrição empresas

    DATA: vlr_aux TYPE zprojetofde04_jm.
    DATA: lv_last TYPE p0001-pernr. "Armazena ultimo registro
    DATA: lv_lasthr TYPE zprojetoft03_jm-horas.

*   Loop na tabela de Projetos X Apontamentos
    LOOP AT mt_zprojetoft03 INTO ms_zprojetoft03.

*     Loop na tabela pa0001
      LOOP AT p0001 INTO ms_p0001.
        IF ms_zprojetoft03-pernr EQ ms_p0001-pernr.

          CLEAR ms_zprojetoft01.
          READ TABLE mt_zprojetoft01 INTO ms_zprojetoft01 WITH KEY projt = ms_zprojetoft03-projt. "Projetos

          CLEAR ms_p0002.
          READ TABLE p0002 INTO ms_p0002 WITH KEY pernr = pernr-pernr. "Desc. Pessoa

          CLEAR ms_t001.
          READ TABLE mt_t001 INTO ms_t001 WITH KEY bukrs = ms_p0001-bukrs. "Desc Empresa

          CLEAR ms_t500p.
          READ TABLE mt_t500p INTO ms_t500p WITH KEY bukrs = ms_p0001-bukrs "Desc Área de RH
                                                     persa = ms_p0001-werks.

          CLEAR ms_t001p.
          READ TABLE mt_t001p INTO ms_t001p WITH KEY werks = ms_p0001-werks. "Desc Sub RH

          CLEAR ms_t501t.
          READ TABLE mt_t501t INTO ms_t501t WITH KEY persg = ms_p0001-persg. "Desc Grupo Emp.

          CLEAR ms_t503t.
          READ TABLE mt_t503t INTO ms_t503t WITH KEY persk = ms_p0001-persk. "Desc Sub-Grupo Emp.

          CLEAR ms_p0007.
          READ TABLE p0007[] INTO ms_p0007 WITH KEY pernr = pernr-pernr. "Desc Sub-Grupo Emp.

          CLEAR ms_zprojetoft02.
          READ TABLE mt_zprojetoft02 INTO ms_zprojetoft02 WITH KEY schkz = ms_p0007-schkz. "Horas de trabalho

          ms_saida-pernr  = ms_p0001-pernr.
          ms_saida-cname  = ms_p0002-cname.
          ms_saida-bukrs  = ms_p0001-bukrs.
          ms_saida-butxt  = ms_t001-butxt.
          ms_saida-werks  = ms_p0001-werks.
          ms_saida-name1  = ms_t500p-name1.
          ms_saida-btrtl  = ms_p0001-btrtl.
          ms_saida-btext  = ms_t001p-btext.
          ms_saida-persg  = ms_p0001-persg.
          ms_saida-ptext  = ms_t501t-ptext.
          ms_saida-persk  = ms_p0001-persk.
          ms_saida-ptext2 = ms_t503t-ptext.
          ms_saida-schkz  = ms_p0007-schkz.
          ms_saida-data   = ms_zprojetoft03-data.
          ms_saida-projt  = ms_zprojetoft03-projt.
          ms_saida-protx  = ms_zprojetoft01-protx.
          ms_saida-horas  = ms_zprojetoft03-horas.

*         IF p_sinttc = abap_true. "CASO MARCADO
          IF lv_last EQ gs_p0001-pernr.
            ms_saida-totalhr = ms_zprojetoft03-horas + lv_lasthr.
          ELSE.
            ms_saida-totalhr = ms_zprojetoft03-horas.
            lv_last = ms_p0001-pernr.
            lv_lasthr = ms_zprojetoft03-horas.
          ENDIF.

          IF ms_zprojetoft03-horas > ms_zprojetoft02-hrmin.
            vlr_aux = ms_zprojetoft03-horas - ms_zprojetoft02-hrmin.
          ELSE.
            vlr_aux = '0.0'.
          ENDIF.

          ms_saida-qtdhrext   = vlr_aux.
          ms_saida-vlrhrext   = ms_zprojetoft02-extra.
          ms_saida-vlrtlhrext = ms_saida-qtdhrext * ms_saida-vlrhrext.

          IF p_sinttc EQ 'X'.
            IF ms_saida-qtdhrext > 0.
              APPEND ms_saida TO mt_saida.
            ENDIF.
          ELSE.
            APPEND ms_saida TO mt_saida.
          ENDIF.

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

*     Obtem as colunas
      gr_columns = mo_alv->get_columns( ).

      IF p_sinttc = abap_true. "CASO MARCADO

*       Selecionar a coluna correta
        gr_column ?= gr_columns->get_column( 'BUKRS ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'BUTXT ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'WERKS ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'NAME1 ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'BTRTL ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'BTEXT ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PERSG ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PTEXT ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PERSK ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PTEXT2' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PROJT ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'PROTX ' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'HORAS ' ).

*        delete mt_saida where.

      ELSE.

*       Selecionar a coluna correta
        gr_column ?= gr_columns->get_column( 'TOTALHR' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'QTDHREXT' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'VLRHREXT' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        gr_column ?= gr_columns->get_column( 'VLRTLHREXT' ).
        gr_column->set_technical( value = if_salv_c_bool_sap=>true ).

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