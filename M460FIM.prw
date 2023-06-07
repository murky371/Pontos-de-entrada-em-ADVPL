//Bibliotecas
#include 'TopConn.ch'
#include 'Totvs.ch'

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  M460FIM                                                                                       |
 | Desc:  Gravação dos dados após gerar NF de Saída                                                     |
 | Links: http://tdn.totvs.com/pages/releaseview.action?pageId=6784180                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function M460FIM()
    
    Local aAreaSF4 :=    SF4->(GetArea())
    
    //Pega o pedido
    DbSelectArea('SF4')
    SF4->(DbSetorder(1))
         
    //Se tiver pedido
    SA3->(DbSeek(xFILIAL("SA3") + SF2->F2_VEND1))

    SD2->(DbSetorder(3))
    SD2->(DbSeek(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE)) 
                
    While !SD2->(eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE

        //Se tiver dado, altera o tipo de pagamento
        If  SF4->(DbSeek(xFILIAL("SF4") + SD2->D2_TES)) .AND. SF4->F4_XGERCOM == "S"

             RecLock("SE3",.F.) 

                SE3->E3_VEND          := SF2->F2_VEND1 
                SE3->E3_CODCLI        := SF2->F2_CLIENTE  
                SE3->E3_LOJA          := SF2->F2_LOJA
                SE3->E3_NUM           := SF2->F2_DOC
                SE3->E3_BASE          := SF2->F2_VALBRUT 
                SE3->E3_EMISSAO       := SF2->F2_EMISSAO
                SE3->E3_PORC          := SA3->A3_COMIS   
                SE3->E3_COMIS         := ((SF2->F2_VALBRUT * SA3->A3_COMIS) / 100)
                SE3->E3_VENCTO        := dDataBase
                SE3->E3_MOEDA         := cValToChar(SF2->F2_MOEDA)        

                SE3->(MsUnlock())

        EndIf

        SD2->(DbSkip())
     Enddo
    
    RestArea(aAreaSF4)

Return
