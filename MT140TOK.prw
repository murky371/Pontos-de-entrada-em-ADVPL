#Include 'Totvs.ch'
#Include "rwmake.ch"
#Include "TBICONN.ch"

/*/{Protheus.doc} MT140TOK
   Finalidade..: Este ponto é executado após verificar se existem itens a serem gravados e tem como objetivo validar todos os itens do pré-documento
    @type  Function
    @author Joao
    @since 16/07/2024
    @version version
    @param param_name, param_type, param_descr
    @return lRet
    @example D1_ITEM, D1_DOC
    (examples)
    /*/
User Function MT140TOK()

	Local lRet := .T.             // Conteúdo de retorno

	Local nX   := 1

	If INCLUI .Or. ALTERA

		for  nX:=1  to len(aCols)

			If Empty(aCols[nX,GDFieldPos("D1_CC",aHeader)])
				MsgStop("Não é permitido incluir/alterar um pedido sem informar o centro de custo (D1_CC).")

				lRet := .F.

				Exit

			EndIf

		Next nX

	EndIf

Return(lRet)
