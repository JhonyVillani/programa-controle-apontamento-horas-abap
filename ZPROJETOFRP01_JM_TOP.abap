*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_TOP
*&---------------------------------------------------------------------*

INFOTYPES: 0001,
           0007.

TABLES pernr.

NODES peras.

TYPES: BEGIN OF ty_s_saida,
         pernr TYPE p0001-pernr,
       END OF ty_s_saida.

DATA:
      gt_saida TYPE TABLE OF ty_s_saida,
      gs_saida TYPE ty_s_saida,
      gs_p0001 TYPE p0001.