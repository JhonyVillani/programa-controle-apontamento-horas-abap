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
          mt_t503t TYPE TABLE OF t503t. "Descrição Sub-Grupo Emp.

*   Tabelas relacionadas aos projetos e horas apontadas, populadas no constructor
    DATA: mt_zprojetoft01 TYPE TABLE OF zprojetoft01_jm, "Tabela Apontamento de Projetos
          mt_zprojetoft02 TYPE TABLE OF zprojetoft02_jm, "Tabela de horas trabalhadas
          mt_zprojetoft03 TYPE TABLE OF zprojetoft03_jm. "Tabela de projetos

*   Atributos de saída
    DATA: mt_saida    TYPE TABLE OF zprojetofs01_jm,
          ms_saida    TYPE zprojetofs01_jm.

*   Atributos do ALV
    DATA: mo_alv     TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table,
          go_zebra   TYPE REF TO cl_salv_display_settings,
          gr_columns TYPE REF TO cl_salv_columns_table,
          gr_column  TYPE REF TO cl_salv_column.

    METHODS:
   constructor,
   processar,
   alv,
   smart,
   rebase.

ENDCLASS.                    "lcl_apontamento DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_apontamento IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_apontamento IMPLEMENTATION.
  METHOD constructor.

*     Populando as tabelas de informações complementares
*-------------------------------------------------------
    "Descrição área de RH
    SELECT *
      FROM t500p
      INTO TABLE mt_t500p.

    "Descrição subárea de RH
    SELECT *
      FROM t001p
      INTO TABLE mt_t001p.

    "Descrição Grupo Emp.
    SELECT *
      FROM t501t
      INTO TABLE mt_t501t
     WHERE sprsl = sy-langu.

    "Descrição Sub-Grupo Emp.
    SELECT *
      FROM t503t
      INTO TABLE mt_t503t
     WHERE sprsl = sy-langu.

    "Projetos
    SELECT *
      FROM zprojetoft01_jm
      INTO TABLE mt_zprojetoft01.

    "Plano de horas
    SELECT *
      FROM zprojetoft02_jm
      INTO TABLE mt_zprojetoft02.

    "Projetos associados à pessoas (Considerando campos do select-options)
    SELECT *
      FROM zprojetoft03_jm
      INTO TABLE mt_zprojetoft03
     WHERE pernr IN pnppernr
       AND projt IN so_projt.

  ENDMETHOD.                    "constructor

  METHOD processar.

*     Declarações de variáveis
*--------------------------------------------------------------------------------------
    "Estruturas utilizadas no READ TABLE
    DATA: ms_t500p TYPE t500p, "Descrição área de RH
          ms_t001p TYPE t001p, "Descrição subárea de RH
          ms_t501t TYPE t501t, "Descrição Grupo Emp.
          ms_t503t TYPE t503t. "Descrição Sub-Grupo Emp

    "Estruturas relacionadas às tabelas de projetos e apontamentos
    DATA: ms_zprojetoft03 TYPE zprojetoft03_jm,
          ms_zprojetoft02 TYPE zprojetoft02_jm,
          ms_zprojetoft01 TYPE zprojetoft01_jm.

    "Variáveis utilizadas no cálculo de horas extras
    DATA: lv_totalh     TYPE zprojetofs01_jm-totalhr.    "Armazena ultima hora apontada
    DATA: lv_tlatual    TYPE zprojetofs01_jm-totalhr.    "Armazena ultima hora apontada
    DATA: lv_vlrtlhrext TYPE zprojetofs01_jm-vlrtlhrext. "Armazena ultima hora apontada


*     Loop na tabela de Projetos X Apontamentos
*--------------------------------------------------------------------------------------
    LOOP AT mt_zprojetoft03 INTO ms_zprojetoft03.

      "Se a iteração é o mesmo pernr da header e a data for igual ao do PNPCE
      IF ms_zprojetoft03-pernr EQ p0001-pernr AND ( ms_zprojetoft03-data >= pn-begda AND ms_zprojetoft03-data <= pn-endda ).

*     Leitura de Campos complementares
*--------------------------------------------------------------------------------------------------------
        CLEAR ms_zprojetoft01.
        READ TABLE mt_zprojetoft01 INTO ms_zprojetoft01 WITH KEY projt = ms_zprojetoft03-projt. "Projetos

        CLEAR ms_t500p.
        READ TABLE mt_t500p INTO ms_t500p WITH KEY bukrs = p0001-bukrs "Desc Área de RH
                                                   persa = p0001-werks.
        CLEAR ms_t001p.
        READ TABLE mt_t001p INTO ms_t001p WITH KEY werks = p0001-werks. "Desc Sub RH

        CLEAR ms_t501t.
        READ TABLE mt_t501t INTO ms_t501t WITH KEY persg = p0001-persg. "Desc Grupo Emp.

        CLEAR ms_t503t.
        READ TABLE mt_t503t INTO ms_t503t WITH KEY persk = p0001-persk. "Desc Sub-Grupo Emp.

        CLEAR ms_zprojetoft02.
        READ TABLE mt_zprojetoft02 INTO ms_zprojetoft02 WITH KEY schkz = p0007-schkz. "Horas de trabalho

*     Atribuições de variáveis
*------------------------------------
        ms_saida-pernr  = p0001-pernr.
        ms_saida-cname  = p0002-cname.
        ms_saida-bukrs  = p0001-bukrs.

*     Função que substitui READ TABLE na tabela t001 (Descrição Empresas)
*------------------------------------------------------------------------
        CALL FUNCTION 'HR_BR_LER_EMPRESA'
          EXPORTING
            company_code            = p0001-bukrs
*           LANGUAGE                = SY-LANGU
          IMPORTING
            company_name            = ms_saida-butxt
*           COMPANY_CGC             =
          EXCEPTIONS
            company_not_found       = 1
            cgc_contains_characters = 2
            OTHERS                  = 3.

        ms_saida-werks  = p0001-werks.
        ms_saida-name1  = ms_t500p-name1.
        ms_saida-btrtl  = p0001-btrtl.
        ms_saida-btext  = ms_t001p-btext.
        ms_saida-persg  = p0001-persg.
        ms_saida-ptext  = ms_t501t-ptext.
        ms_saida-persk  = p0001-persk.
        ms_saida-ptext2 = ms_t503t-ptext.
        ms_saida-schkz  = p0007-schkz.
        ms_saida-data   = ms_zprojetoft03-data.
        ms_saida-projt  = ms_zprojetoft03-projt.
        ms_saida-protx  = ms_zprojetoft01-protx.
        ms_saida-horas  = ms_zprojetoft03-horas.

*     CASO SINTÉTICO DESMARCADO
*------------------------------------
        IF p_sinttc = abap_false.
          APPEND ms_saida TO mt_saida.

*     CASO SINTÉTICO MARCADO
*----------------------------------------------------------------------------
        ELSE.
          "Calcula o total de horas apontadas
          lv_totalh = lv_totalh + ms_zprojetoft03-horas.
          ms_saida-totalhr = lv_totalh.

          "Verifica se o total de horas gerou EXTRA
          IF ms_zprojetoft03-horas > ms_zprojetoft02-hrmin.
            ms_saida-qtdhrext = ms_zprojetoft03-horas - ms_zprojetoft02-hrmin.
            ms_saida-vlrhrext = ms_zprojetoft02-extra.
            ms_saida-vlrtlhrext = ms_saida-qtdhrext * ms_saida-vlrhrext.
            APPEND ms_saida TO mt_saida.
          ENDIF.
        ENDIF. "Verificação SE SINTÉTICO

      ENDIF. "Verificação do pernr

    ENDLOOP. "Fim do loop na tabela de projetos

  ENDMETHOD.                    "processar

  METHOD alv.

*     Criando o relatório ALV, declarando na classe a variáveis mo_alv referenciando cl_salv_table
*     Chama o método que constrói a saída ALV
*---------------------------------------------------------------------------------
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = mo_alv
      CHANGING
        t_table      = mt_saida.

    "Otimiza tamanho das colunas
    go_columns = mo_alv->get_columns( ). "Retorna o objeto tipo coluna INSTANCIADO
    go_columns->set_optimize( ).

    "Zebrar report
    go_zebra = mo_alv->get_display_settings( ).
    go_zebra->set_striped_pattern( abap_true ).

    "Obtem as colunas
    gr_columns = mo_alv->get_columns( ).

*     CASO SAÍDA SINTÉTICA MARCADA
*---------------------------------
    IF p_sinttc = abap_true.

*     Métodos que recebem uma coluna a ser oculta e na sequência oculta a mesma
*------------------------------------------------------------------------------
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
      gr_column->set_technical( value = if_salv_c_bool_sap=>true ).

*     CASO SAÍDA SINTÉTICA DESMARCADA
*-----------------------------------------------------------------
    ELSE.

*     Selecionar a coluna correta
      gr_column ?= gr_columns->get_column( 'TOTALHR' ).
      gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
      gr_column ?= gr_columns->get_column( 'QTDHREXT' ).
      gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
      gr_column ?= gr_columns->get_column( 'VLRHREXT' ).
      gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
      gr_column ?= gr_columns->get_column( 'VLRTLHREXT' ).
      gr_column->set_technical( value = if_salv_c_bool_sap=>true ).

    ENDIF.

    "Mostra o ALV
    mo_alv->display( ). "Imprime na tela do relatório ALV

  ENDMETHOD.                    "alv

  METHOD smart.

*     Declarações do smartform
*----------------------------------------------------------------------------------------------------
    DATA:
          lv_fm_name            TYPE rs38l_fnam,
          ls_control_parameters TYPE ssfctrlop,
          ls_output_options     TYPE ssfcompop,
          ls_job_output_info    TYPE ssfcrescl,
          ls_saida              TYPE zprojetofs01_jm. "Do tipo da estrutura SE11 criada para exibição

*     Loop na tabela final (Enviando dados via WORK-AREA para o Smartform)
*-------------------------------------------------------------------------------------------------------
    LOOP AT mt_saida INTO ls_saida.

*     Declarações de variáveis a serem utilizadas no Case que verifica a quantidade de páginas via LOOP
*------------------------------------------------------------------------------------------------------
      DATA: lv_lines TYPE i,
            lv_tabix TYPE sy-tabix.
      lv_tabix = sy-tabix.

*     Função que passa uma estrutura para o Smartform e exibe-o (Necessário método de importação FM_NAME)
*--------------------------------------------------------------------------------------------------------
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZPROJETOFSF01_JM'
        IMPORTING
          fm_name            = lv_fm_name "Função definida abaixo
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      "Definições de saída do Smartform
      ls_output_options-tddest        = 'LP01'.
      ls_output_options-tdimmed       = abap_true.
      ls_control_parameters-no_dialog = abap_true.
      ls_control_parameters-preview   = abap_true.

*     Case para verificar quantidade de páginas a serem exibidas
*---------------------------------------------------------------
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

*     Função que importa a estrutura do programa para dentro do Smartform (Necessária para o primeiro método funcionar)
*----------------------------------------------------------------------------------------------------------------------
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

  ENDMETHOD.                    "smart

  METHOD rebase.

*     Atributos de saída do método que Refina informações sintéticas
*-------------------------------------------------------------------
    DATA: mt_saidastc TYPE TABLE OF zprojetofs01_jm,
          ms_saidastc TYPE zprojetofs01_jm,
          mv_pernr    TYPE zprojetofs01_jm-pernr,
          mv_totalhr  TYPE zprojetofs01_jm-totalhr,
          mv_lasttotal  TYPE zprojetofs01_jm-totalhr.

    "Ordena a tabela pelo PERNR e maior quantidade de HORAS apontadas
    SORT mt_saida BY pernr totalhr DESCENDING.

*     Loop na tabela final (Refinando informações)
*-------------------------------------------------
    LOOP AT mt_saida INTO ms_saida.

      "Recebe dados da tabela final
      ms_saidastc = ms_saida.

*     Verifica se o PERNR é o mesmo da iteração
*----------------------------------------------
      IF mv_pernr EQ ms_saida-pernr.
        ms_saidastc-totalhr = mv_lasttotal.
        APPEND ms_saidastc TO mt_saidastc.
        CONTINUE.
      ENDIF.

*     Caso não seja o mesmo PERNR da iteração, atribui nova PERNR e total de horas
*---------------------------------------------------------------------------------
      mv_pernr = ms_saida-pernr.
      mv_totalhr = ms_saida-totalhr.
      mv_lasttotal = mv_totalhr.
      ms_saidastc-totalhr = ms_saida-totalhr.

      APPEND ms_saidastc TO mt_saidastc.
      CONTINUE.

    ENDLOOP.

    mt_saida = mt_saidastc.

    SORT mt_saida BY pernr.

  ENDMETHOD.                    "rebase

ENDCLASS.                    "lcl_apontamento IMPLEMENTATION