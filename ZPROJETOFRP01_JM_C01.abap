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

    "Tabelas complementares populadas no constructor
    DATA: mt_t001  TYPE TABLE OF t001,  "Descrição empresas
          mt_t500p TYPE TABLE OF t500p, "Descrição área de RH
          mt_t001p TYPE TABLE OF t001p, "Descrição subárea de RH
          mt_t501t TYPE TABLE OF t501t, "Descrição Grupo Emp.
          mt_t503t TYPE TABLE OF t503t. "Descrição Sub-Grupo Emp.

    "Tabelas relacionadas aos projetos e horas apontadas, populadas no constructor
    DATA: mt_zprojetoft01 TYPE TABLE OF zprojetoft01_jm, "Tabela Apontamento de Projetos
          mt_zprojetoft02 TYPE TABLE OF zprojetoft02_jm, "Tabela de horas trabalhadas
          mt_zprojetoft03 TYPE TABLE OF zprojetoft03_jm. "Tabela de projetos

    "Atributos de saída
    DATA: mt_saida    TYPE TABLE OF zprojetofs01_jm,
          ms_saida    TYPE zprojetofs01_jm.

    "Atributos do ALV
    DATA: mo_alv     TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table,
          go_zebra   TYPE REF TO cl_salv_display_settings,
          gr_columns TYPE REF TO cl_salv_columns_table,
          gr_column  TYPE REF TO cl_salv_column.

*     Variável de classe, que precisa ser chamada extaticamente
*--------------------------------------------------------------
    CLASS-DATA: mv_nome_do_arquiv TYPE string.

    METHODS:
   constructor,
   processar,
   alv,
   smart,
   rebase,
   verifica,
   leitura_dados.

*     Função que precisa ser chamada estaticamente
*-------------------------------------------------
    CLASS-METHODS:
save_file.

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

*     Verifica se a seleção obteve resultados
*-----------------------------------------------------
    IF sy-subrc IS NOT INITIAL.
      MESSAGE s001(00) WITH text-m01 DISPLAY LIKE 'E'.

      "Retorna para a tela de seleção
      LEAVE LIST-PROCESSING.
    ENDIF.

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
*--------------------------------------------------------------------------------------------------------------------------
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
*-------------------------------------
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
*-------------------------------------
        IF p_sinttc = abap_false.
          APPEND ms_saida TO mt_saida.

*     CASO SINTÉTICO MARCADO
*-----------------------------------------------------------------------------
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
*-------------------------------------------------------------------------------------------------
    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = mo_alv
          CHANGING
            t_table      = mt_saida.
      CATCH cx_salv_msg.
    ENDTRY.

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
      TRY.
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
        CATCH cx_salv_not_found.
      ENDTRY.

*     CASO SAÍDA SINTÉTICA DESMARCADA
*-----------------------------------------------------------------
    ELSE.

*     Métodos que recebem uma coluna a ser oculta e na sequência oculta a mesma
*------------------------------------------------------------------------------
      TRY.
          gr_column ?= gr_columns->get_column( 'TOTALHR' ).
          gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
          gr_column ?= gr_columns->get_column( 'QTDHREXT' ).
          gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
          gr_column ?= gr_columns->get_column( 'VLRHREXT' ).
          gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
          gr_column ?= gr_columns->get_column( 'VLRTLHREXT' ).
          gr_column->set_technical( value = if_salv_c_bool_sap=>true ).
        CATCH cx_salv_not_found.
      ENDTRY.

    ENDIF.

    "Mostra o ALV
    mo_alv->display( ). "Imprime na tela do relatório ALV

  ENDMETHOD.                    "alv

  METHOD smart.

*     Declarações do smartform
*----------------------------------------------------------------------------------------------------
    DATA: lv_fm_name            TYPE rs38l_fnam,
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

      "Atribuição de contador
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
*--------------------------------------------------------------------
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

  METHOD verifica.

*     Verifica se a tabela está vazia e retorna para a tela de seleção
*---------------------------------------------------------------------
    IF mt_saida IS INITIAL.
      MESSAGE s001(00) WITH text-m02 DISPLAY LIKE 'E'.

      "Retorna à tela de seleção
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDMETHOD.                    "verifica

  METHOD leitura_dados.

*     Verifica se o campo PATH está preenchido
*--------------------------------------------------------------
    IF p_file IS NOT INITIAL.

      "Define um TYPES com saídas em formato de STRING
      TYPES: BEGIN OF ty_s_linha_arquivo,
              linha TYPE c LENGTH 1000,
             END OF   ty_s_linha_arquivo.

      "Declarações de variáveis a serem utilizadas na função DOWNLOAD
      DATA: lv_filename  TYPE string,
            lt_data_tab       TYPE TABLE OF ty_s_linha_arquivo,
            ls_data_tab       TYPE ty_s_linha_arquivo,
            ls_saida          TYPE zprojetofs01_jm.

*     Definindo "Header Line" da tabela a ser exportada
*-----------------------------------------------------------------------------------
      ls_data_tab-linha = 'Nº pessoal;Nome;Empresa;Desc. Empresa;'
                        &&'Área RH;Desc. RH;Sub área RH;Desc. Sub área RH;Grupo RH;'
                        &&'Desc. Grupo;Subgrupo RH;Desc. Subgrupo;Carga Horária;'
                        &&'Dt. Apont; Cód. Proj;Projeto;Horas apont;Total Hrs.;'
                        &&'Qtd. Hrs. Extras;Valor Hr; Vlr Total Hrs. Ext.'.

      "Appenda o Header
      APPEND ls_data_tab TO lt_data_tab.
      CLEAR ls_data_tab.

*     Loop para cada informação da tabela final, appendando como uma String única
*--------------------------------------------------------------------------------
      LOOP AT mt_saida INTO ls_saida.

        ls_data_tab-linha = ls_saida-pernr    && ';' "Nº pessoal
                         && ls_saida-cname    && ';' "Nome
                         && ls_saida-bukrs    && ';' "Empresa
                         && ls_saida-butxt    && ';' "Nome Empresa
                         && ls_saida-werks    && ';' "Área RH
                         && ls_saida-name1    && ';' "Desc. RH
                         && ls_saida-btrtl    && ';' "Sub-Área RH
                         && ls_saida-btext    && ';' "Desc. Sub área RH
                         && ls_saida-persg    && ';' "Grupo RH
                         && ls_saida-ptext    && ';' "Desc. Grupo
                         && ls_saida-persk    && ';' "Subgrupo RH
                         && ls_saida-ptext2   && ';' "Desc. Subgrupo
                         && ls_saida-schkz    && ';' "Carga Horária
                         && ls_saida-data     && ';'
                         && ls_saida-projt    && ';'
                         && ls_saida-protx    && ';'
                         && ls_saida-horas    && ';'
                         && ls_saida-totalhr  && ';'
                         && ls_saida-qtdhrext && ';'
                         && ls_saida-vlrhrext && ';'
                         && ls_saida-vlrtlhrext.

        "Appenda uma String na tabela
        APPEND ls_data_tab TO lt_data_tab.
        CLEAR ls_data_tab.

      ENDLOOP.

*     Concatena o nome padrão do arquivo com a data e hora para saída
*------------------------------------------------------------------------------------------------------------
      CONCATENATE p_file '\' 'Apont Horas Extras' '_' sy-datum+6(2)'-' sy-datum+4(2) '-' sy-datum(4) '_'
                                                      sy-uzeit(2) '-'  sy-uzeit+2(2) '-' sy-uzeit+4(2) '.csv'
                                                      INTO lv_filename.

*     Função que exporta o arquivo para o computador local
*---------------------------------------------------------
      CALL METHOD cl_gui_frontend_services=>gui_download
        EXPORTING
          filename                = lv_filename
        CHANGING
          data_tab                = lt_data_tab
        EXCEPTIONS
          file_write_error        = 1
          no_batch                = 2
          gui_refuse_filetransfer = 3
          invalid_type            = 4
          no_authority            = 5
          unknown_error           = 6
          header_not_allowed      = 7
          separator_not_allowed   = 8
          filesize_not_allowed    = 9
          header_too_long         = 10
          dp_error_create         = 11
          dp_error_send           = 12
          dp_error_write          = 13
          unknown_dp_error        = 14
          access_denied           = 15
          dp_out_of_memory        = 16
          disk_full               = 17
          dp_timeout              = 18
          file_not_found          = 19
          dataprovider_exception  = 20
          control_flush_error     = 21
          not_supported_by_gui    = 22
          error_no_gui            = 23
          OTHERS                  = 24.

      "Se não estiver preenchido
    ELSE.
      MESSAGE s001(00) WITH text-m03 DISPLAY LIKE 'E'.

      "Retorna à tela de seleção
      LEAVE LIST-PROCESSING.
    ENDIF. "Fim se o campo PATH está preenchido

  ENDMETHOD.                    "leitura_dados

  METHOD save_file.

*     Declarações de variáveis da função directory_browse
*--------------------------------------------------------
    DATA: lv_fullpath    TYPE string.

*     Função que abre a caixa de diálogo no Select-Options
*---------------------------------------------------------
    CALL METHOD cl_gui_frontend_services=>directory_browse
      CHANGING
        selected_folder      = lv_fullpath
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    p_file = lv_fullpath.

  ENDMETHOD.                    "save_file

ENDCLASS.                    "lcl_apontamento IMPLEMENTATION