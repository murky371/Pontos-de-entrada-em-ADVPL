#INCLUDE "TOTVS.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} MT120OK - 
Validações Específicas de Usuário
@type function
@version 1.0
@author Joao
@since 6/28/2024
@return lRet
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6085483
/*/
User Function  MT120OK()

	Local lRet := .T.             // Conteúdo de retorno

	Local nX   := 1

    CT1->(DBSetOrder(1))

	If INCLUI .Or. ALTERA

		If nTipoPed == 1

			If CT1->(DBSeek(xFilial("CT1")+aCols[nX,GDFieldPos("C7_CONTA")])) .And. CT1->CT1_CCOBRG == "1"

				for  nX:=1  to len(aCols)

					If Empty(aCols[nX,GDFieldPos("C7_CC",aHeader)])
						MsgStop("Não é permitido incluir/alterar um pedido do tipo 'N' sem informar o centro de custo (C7_CC).")

						lRet := .F.

						Exit

					EndIf

				Next nX

			EndIf

		EndIf

	EndIf

Return(lRet)
