#include 'TopConn.ch'
#include 'Totvs.ch'


/*/{Protheus.doc} M103DSE2
Ponto de entrada localizado antes da exclusão de cada Título do SE2 vinculado a Nota de entrada a ser excluida.
@type function
@version  
@author Joao Goncalves
@since 6/27/2023
@link https://tdn.totvs.com/display/public/PROT/M103DSE2 
@return Sem retorno
/*/
User Function M103DSE2()

	Local aAreaZA1 :=    ZA1->(GetArea())

	//Pega o pedido
	DbSelectArea('ZA1')

	ZA1->(DbSetorder(2))
	SD1->(DbSetorder(2))

	If  ZA1->(DbSeek(xFILIAL("ZA1")+SD1->D1_FILIAL+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_PEDIDO))

		While !ZA1->(eof()) ZA1->ZA1_FILIAL+ZA1->ZA1_CODFOR+ZA1->ZA1_LOJFOR+ZA1->ZA1_PEDIDO == SD1->D1_FILIAL+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_PEDIDO

			RecLock("ZA1",.F.)

			ZA1->ZA1_RECEB := .F.

			ZA1->(MsUnlock())

			ZA1->(DbSkip())

		Enddo
	EndIf

	RestArea(aAreaZA1)

Return
