#include 'TopConn.ch'
#include 'Totvs.ch'

/*/{Protheus.doc} MS520DEL
Esse ponto de entrada está localizado na função MaDelNfs e é executado antes da exclusão do registro da tabela SF2.
@type function
@version  
@author Joao Goncalves
@since 6/28/2023
@link https://tdn.totvs.com/display/public/PROT/MS520DEL
@return Sem retorno
/*/

User Function MS520DEL()

	Local aAreaSE3 :=    SE3->(GetArea())

	//Pega o pedido
	DbSelectArea('SE3')

	SE3->(DbSetorder(2))

	If SE3->(DbSeek(xFILIAL("SE3")+SF2->F2_VEND1+SF2->F2_PREFIXO+SF2->F2_DOC))

		RecLock("SE3",.T.)

		SE3->E3_FILIAL  := SE3->E3_FILIAL
		SE3->E3_VEND    := SE3->E3_VEND
		SE3->E3_CODCLI  := SE3->E3_CODCLI
		SE3->E3_LOJA    := SE3->E3_LOJA
		SE3->E3_NUM     := SE3->E3_NUM
		SE3->E3_BASE    := SE3->E3_BASE
		SE3->E3_EMISSAO := SE3->E3_EMISSAO
		SE3->E3_VENCTO  := SE3->E3_VENCTO
		SE3->E3_PORC    := SE3->E3_PORC
		SE3->E3_COMIS   := SE3->E3_COMIS * - 1
		SE3->E3_MOEDA   := SE3->E3_MOEDA


		SE3->(MsUnlock())

	EndIf
    
	RestArea(aAreaSE3)

Return
