*&---------------------------------------------------------------------*
*&  Include           ZPROJETOFRP01_JM_EVE
*&---------------------------------------------------------------------*

* Declara uma variável do tipo da classe
  DATA:
        go_apontamento TYPE REF TO lcl_apontamento. "Classe local

  START-OF-SELECTION.

    CREATE OBJECT go_apontamento.

  GET peras.

    go_apontamento->processar( ).

  END-OF-SELECTION.

    go_apontamento->exibir( ).