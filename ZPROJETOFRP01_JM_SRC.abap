*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_SRC
*&---------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.
  SELECT-OPTIONS so_schkz FOR p0007-schkz NO INTERVALS.
  SELECT-OPTIONS so_projt FOR zprojetoft01_jm-projt NO INTERVALS.
  PARAMETER p_sinttc      AS CHECKBOX DEFAULT abap_true..
  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t03.
  PARAMETER p_alv   RADIOBUTTON GROUP view DEFAULT 'X'.
  PARAMETER p_smart RADIOBUTTON GROUP view.
  SELECTION-SCREEN END OF BLOCK b3.

* Ocultando campo Status do PNPCE
  AT SELECTION-SCREEN OUTPUT.
    LOOP AT SCREEN.
      IF  screen-name = '%_PNPSTAT2_%_APP_%-TEXT' " For Text Lable
       OR  screen-name = 'PNPSTAT2-LOW'                     " For Text Field
       OR  screen-name = '%_PNPSTAT2_%_APP_%-VALU_PUSH'. " For Extension Button
        screen-active = '0'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.