*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_SRC
*&---------------------------------------------------------------------*

  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.
  SELECT-OPTIONS so_schkz FOR p0007-schkz NO INTERVALS.
  SELECT-OPTIONS so_projt FOR zprojetoft03_jm-projt NO INTERVALS.
  PARAMETER p_sinttc      AS CHECKBOX DEFAULT abap_true..
  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t03.
  PARAMETER p_alv   RADIOBUTTON GROUP view DEFAULT 'X'.
  PARAMETER p_smart RADIOBUTTON GROUP view.
  SELECTION-SCREEN END OF BLOCK b3.