1) Criação de tabelas para apontamento de horas:

Tabela 1: PRJF – Projetos para apontamentos (ZPROJETOFT01_JM)

Nome do campo	Descrição	Tipo	Tamanho	Observação
PROJT	Código do projeto	CHAR	4		Somente letras maiúsculas ZABAPTRDE31_JM
PROTX	Nome do projeto		CHAR	80		Case sensitive			  ZABAPTRDE32_JM

•	Permitir atualização da tabela via transação SM30. ZABAPTRFG10_JM
•	O código do projeto não deve se repetir. Primary Key

A tabela deve conter os seguintes projetos:

PROJT	PROTX
ITZ1	Projeto 1
ITZ2	Projeto 2
ITZ3	Projeto 3
ITZ4	Projeto 4
ITZ5	Projeto 5

---------------------------------------------------------------------------

Tabela 2: PRJF – Carga horária mínima diária (ZPROJETOFT02_JM)

Nome do campo	Descrição						Tipo	Tamanho	Observação
SCHKZ	Código do plano de Horário de trabalho	CHAR	8		Utilizar o mesmo elemento de dados, chave externa ZABAPTRDE33_JM
																e ajuda de pesquisa do campo P0007-SCHKZ.
HRMIN	Horas diárias mínima					DEC		5,3														  ZABAPTRDE34_JM
EXTRA	Valor da hora extra						DEC		5,3														  ZABAPTRDE35_JM

•	Permitir atualização da tabela via transação SM30. ZABAPTRFG11_JM
•	Um plano de horário de trabalho não pode repetir. Primary Key

---------------------------------------------------------------------------

Tabela 3: PRJE – Apontamentos diários (ZPROJETOFT03_JM)

Nome do campo	Descrição	Tipo	Tamanho	Observação
PERNR	Nº Pessoal			NUMC	8		Nº Pessoal: Deve ter chave externa e ajuda de pesquisa igual dos infotipos. ZPROJETOFSH01_JM
DATA	Data do apontamento	DATS	8 																					ZABAPTRDE37_JM
PROJT	Código do projeto	CHAR	4		Deve ter chave externa com a tabela de projetos								ZABAPTRDE31_JM
HORAS	Horas trabalhadas	DEC		5,3																					ZABAPTRDE38_JM

•	Cada colaborador pode ter mais de um apontamento por dia, desde que o projeto seja diferente. Primary Key
•	Deverá ser criada uma visão para atualizar a tabela 3. ZABAPTRFG12_JM
•	A visão deve exibir os campos da tabela 3 + PROTX da tabela 1. ZPROJETOFSH01_JM

---------------------------------------------------------------------------

2) Desenvolver um programa para listar os apontamentos dos colaboradores (ZPROJETOFRP01_JM).

	Tela de seleção:

	Bloco seleção de funcionários:

•	Nº pessoal - select-options (P0001-PERNR)
•	Empresa - select-options (P0001-BUKRS)
•	Área de RH - select-options (P0001-WERKS)
•	Subárea de RH - select-options (P0001-BTRTL)
•	Data início - parameter (P0001-BEGDA)
•	Data fim - parameter (P0001-ENDDA)

O período deve ser utilizado para filtrar colaboradores e apontamentos.

	Bloco outras seleções:

•	Plano de horário de trabalho – select-options (P0007-SCHKZ)
•	Código do projeto – select-options (ZPROJETOFT01-PROJT)
•	Sintético (horas extras) - Checkbox

	Bloco saída:

•	ALV
•	Smartforms

	Pontos de atenção:

•	Para dados dos infotipos, considerar sempre o registro mais recente dentro do período de seleção.
•	O programa deve exibir somente colaboradores que possuem apontamento(s) no período selecionado.
•	Utilizar função HR_READ_INFOTYPE ou banco de dados lógico PNPCE. Diferencial será a utilização
	do banco de dados lógico PNPCE.  

---------------------------------------------------------------------------

ALV:

•	Caso a opção “Sintético (horas extras)” estiver vazia, exibir um relatório com as seguintes informações:
		o	Nº pessoal
		o	Nome completo do funcionário
		o	Empresa
		o	Nome da Empresa (utilizar a função HR_BR_LER_EMPRESA)
		o	Área de RH
		o	Texto da área de RH 
		o	Subárea de RH
		o	Texto da subárea de RH 
		o	Grupo de empregados
		o	Texto do grupo de empregados
		o	Subgrupo de empregados
		o	Texto do subgrupo de empregados
		o	Plano de horário de trabalho (P0007-SCHKZ)
		o	Data do apontamento
		o	Código do projeto
		o	Nome do projeto
		o	Horas apontadas
•	Caso a opção “Sintético (horas extras)” estiver marcada, as horas de apontamentos devem ser somadas por dia e somente serão exibidos os dias em que o colaborador possui hora extra:
		o	Nº pessoal
		o	Nome completo do funcionário
		o	Plano de horário de trabalho (P0007-SCHKZ)
		o	Data do apontamento
		o	Total de horas apontadas
		o	Quantidade de horas extras (= Total de horas apontadas – Horas mínimas diárias da tabela 2)
		o	Valor por hora extra (Tabela 2-EXTRA)
		o	Valor total de horas extras (= Quantidade de horas extras * Valor por hora extra)

---------------------------------------------------------------------------

SMARTFORMS: ZPROJETOFSF01_JM

Exibir um formulário para cada DIA do colaborador com as informações da opção “Sintético (horas extras)”
(ou seja, cada linha do relatório é um formulário) exibindo o seguinte layout:

*********************************************************
*					Dados do Colaborador				*1
*Nº Pessoal				     |XXXXXXXX					*2.2
*Nome						 |XXXXXXXXXXXXXXXXXXXXXXXX	*3.2
*Plano de horário de trabalho|XXXXXXXX					*4.2
*********************************************************5
*					Dados do Apontamento				*6
*Data						 |XX/XX/XXXX				*7.2
*Total de horas apontadas	 |XX,XX						*8.2
*Quantidade de horas extras  |XX,XX						*9.2
*Valor por hora extra		 |XXX,XX					*10.2
*Valor total de horas extras |XXXX,XX					*11.2
*********************************************************

---------------------------------------------------------------------------

3) Criar uma transação para cada desenvolvimento abaixo:

•	Tabela 1: PRJF - Projetos
•	Tabela 2: PRJF – Carga horária mínima diária
•	Visão da Tabela 3: PRJF – Apontamentos diários
•	Programa: PRJF - Controle de Apontamentos

---------------------------------------------------------------------------