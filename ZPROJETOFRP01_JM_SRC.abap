*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_SRC
*&---------------------------------------------------------------------*

*     Bloco outras seleções
*--------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.
SELECT-OPTIONS so_schkz FOR p0007-schkz NO INTERVALS.
SELECT-OPTIONS so_projt FOR zprojetoft03_jm-projt NO INTERVALS.
PARAMETER p_sinttc      AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b2.

*     Bloco de saída
*------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t03.
PARAMETER p_alv    RADIOBUTTON GROUP view USER-COMMAND muda_tela DEFAULT 'X'.
PARAMETER p_smart  RADIOBUTTON GROUP view.
PARAMETER p_export RADIOBUTTON GROUP view.

"Parâmetro para leitura de dados
PARAMETERS: p_file TYPE rlgrap-filename MODIF ID t1.

SELECTION-SCREEN END OF BLOCK b3.

AT SELECTION-SCREEN OUTPUT.

  PERFORM modifica_tela.

*&---------------------------------------------------------------*
*&      Form  MODIFICA_TELA
*&---------------------------------------------------------------*
FORM modifica_tela .

*     Loop at screen para a ação do usuário no radio button
*----------------------------------------------------------
  LOOP AT SCREEN.

    "Se não estiver marcado para exportar, oculta campo
    IF p_alv = 'X' OR p_smart = 'X'.

      IF screen-group1 = 'T1'.
        screen-invisible = 1.
        screen-input     = 0.
        screen-active    = 0.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.

      "Reapresenta o campo
    ELSE.
      IF screen-group1 = 'T1'.
        screen-invisible = 0.
        screen-input     = 1.
        screen-active    = 1.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.

  ENDLOOP. "Encerra loop at screen

ENDFORM.                    " MODIFICA_TELA