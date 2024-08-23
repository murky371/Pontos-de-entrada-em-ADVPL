#INCLUDE 'Totvs.ch'

/*/{Protheus.doc} MT103NFE
LOCALIZAÇÃO : Function A103NFiscal() - CHAMADA DE QUALQUER ROTINA DA NFE
@type user function
@author Joao Goncalves
@since 19/06/2024
@version 1.0
@Parametros: ParamIxB, MV_XCNPJ
@return: Sem Retorno
@example
(examples)
@see https://tdn.totvs.com/display/public/PROT/MT103NFE
/*/
User Function MT103NFE()

	Local cRaiz := GetMV("MV_XCNPJ")

	DBSelectArea("SA2")

	SA2->(DBSetOrder(1))

	If(SA2->(DBSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)))


		If SubStr(SA2->A2_CGC, 1, 8) $ cRaiz

			If  ParamIxB == 4

				MV_PAR18 := 1
				MV_PAR19 := 1
				MV_PAR26 := 1

			Endif

		Endif

	Endif

Return




