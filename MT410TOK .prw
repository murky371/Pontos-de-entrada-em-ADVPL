#INCLUDE 'Totvs.ch'

/*/{Protheus.doc} MT410TOK - 
Validar confirmação da operação
@type user function
@author Joao Goncalves
@since 19/06/2024
@version 1.0
@param PARAMIXB
@return lRet
@example
(examples)
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6784353
/*/

User Function MT410TOK()
	Local lRet := .T.             // Conteúdo de retorno

	Local nX   := 1

	Local nOpc      := PARAMIXB[1]
	
	Local cTipoPedido := M->C5_TIPO

	If nOpc == 3 .Or. nOpc == 4

		If cTipoPedido == "N"

			for  nX:=1  to len(aCols)

				If Empty(aCols[nX,GDFieldPos("C6_CC",aHeader)])
					MsgStop("Não é permitido incluir/alterar um pedido do tipo 'N' sem informar o centro de custo (C6_CC).")

					lRet := .F.

                   Exit

				EndIf

			  Next nX
            
			EndIf

		EndIf

Return(lRet)


