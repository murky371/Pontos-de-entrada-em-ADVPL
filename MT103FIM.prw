#include 'parmtype.ch'
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*
 Autor: Wagner Nunes
 Data: 05/03/2018
 Chamado: 14143
 Detalhes: Inserir nova opção 7=TITULO CORRIGIDO 

 Criado Por: Wagner Nunes
 Data: 25/05/2017
 Solicitação: 6487 - Melhorias Compras - 2 
*/

user function MT103FIM()

	Local aArea    		:= GetArea()
	Local nOpcao 		:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local nConfirma 	:= PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
	local cTitPai		:= ""
	local nReg			:= 0

	private oDlg      	:= NIL
	private cLocPG 		:= ''
	private cTpPg 		:= ''
	Private lMsErroAuto := .F.

	IF GetRemoteType() < 0
		Return
	EndIf

	if FWIsInCallStack ("GREA066")
		return .T.
	endif

	if FWIsInCallStack("GFEA065")
		cLocPG 	:= SUPERGETMV("ZZ_LOCPG", .f., "1")
		cTpPg 	:= SUPERGETMV("ZZ_TIPPG", .f., "1")
		gravaF1()
	else

		//inclusão de doc de entrada ou classificação de doc
		if ((nOpcao == 3 .or. nOpcao == 4) .And. nConfirma == 1)
			if SF1->F1_COND != '   '

				cTpPg := SC7->C7_ZZTIPPG

				DEFINE MSDIALOG oDlg TITLE "Informações adicionais" FROM 0,0 TO 180,400 OF oMainWnd PIXEL Style DS_MODALFRAME
				oDlg:lEscClose     := .F.
				@ 16,10 SAY RetTitle("F1_ZZLOCPG") SIZE 45,09         OF oDlg PIXEL
				@ 14,50 MSCOMBOBOX oCMBTpPg VAR cLocPG ITEMS {"","1=Matriz","2=Filial"} SIZE 087, 010 OF oDlg  COLORS 0, 16777215 PIXEL
				@ 36,10 SAY  RetTitle("F1_ZZTIPPG")   SIZE 45,09     OF oDlg PIXEL
				@ 34,50 MSCOMBOBOX oCMBLcPg VAR cTpPg ITEMS {"","1=BOLETO","2=DEPOSITO","3=CHEQUE","4=DINHEIRO","5=COMPENSACAO TOTAL","6=COMPENSACAO PARCIAL","7=TITULO CORRIGIDO","8=DEBITO CONTA","9=REEMBOLSO"} SIZE 087, 010 OF oDlg  COLORS 0, 16777215 PIXEL

				DEFINE SBUTTON FROM 54,10 TYPE 1 ACTION  {||gravaF1()} ENABLE OF oDlg

				ACTIVATE MSDIALOG oDlg CENTERED
			ENDIF

			// MAnutenção TOTVSIP - inclusão de funcionalidade para alterar a natureza do titulo
			// de retenção de IR caso o codigo de retenção for igual ao parametro ZZ_NATIRCO
			// SE2->(dbgoto(nREC))
			//dbSelectArea("SE2")
			//dbSetOrder(1)
			//IF dbSeek(SD1->D1_FILIAL+SD1->D1_SERIE+SD1->D1_DOC+'01'+'TX '+'UNIAO '+'00')
			//	IF SE2->E2_CODRET == '8045'
			//		RecLock("SE2", .F.)
			//		SE2->E2_NATUREZ:= SUPERGETMV('ZZ_NATIRCO', .F., 'IRF')
			//		MsUnLock()
			//	ENDIF
			//ENDIF

			cTitPai := retChvTitPai(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, MVNOTAFIS, SF1->F1_EMISSAO )
			if !empty(cTitPai)
				nReg := retReg(cTitPai,SF1->F1_DOC, SF1->F1_SERIE,'TX ','UNIAO ','00','8045' )
				if nReg <> 0
					SE2->(dbSelectArea("SE2"))
					SE2->(dbSetOrder(1))
					SE2->(dbgoto(nReg))
					SE2->(RecLock("SE2", .F.))
					SE2->E2_NATUREZ := SUPERGETMV('ZZ_NATIRCO', .F., 'IRF')
					SE2->(MsUnLock())
				endif
			endif

			SA3->(DbSetOrder(3))
			SD1->(DbSetOrder(1))
			SC7->(DbSetOrder(1))

			//Grava acrescimo e decrescimo para titulos de pagamento de representante
			if SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)) ;
					.AND. SA3->(DbSeek(xFilial("SA3")+SA2->A2_CGC))

				//Verifica se existe acrescimo e decrescimo
				if SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

					//Posiciono no pedido de compra para verificar acrescimo e decrescimo
					if SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO)) .AND. SC7->C7_ZZACRES > 0 .OR. SC7->C7_ZZDECRES > 0

						aTitulo := {{ "E2_PREFIXO"  , SE2->E2_PREFIXO           					    , NIL },;
							{ "E2_NUM"      , SE2->E2_NUM												, NIL },;
							{ "E2_TIPO"     , SE2->E2_TIPO					              				, NIL },;
							{ "E2_FORNECE"  , SE2->E2_FORNECE											, NIL },;
							{ "E2_LOJA"     , SE2->E2_LOJA				                    			, NIL },;
							{ "E2_ACRESC"   , SC7->C7_ZZACRES											, NIL },;
							{ "E2_DECRESC"	, SC7->C7_ZZDECRES											, NIL }}

						MsExecAuto({|x,y,z|FINA050(x,y,z)},aTitulo,, 4)

						if lMsErroAuto
							MostraErro()
						Endif

					endif

				endiF

			endif

			DbSelectArea('SF2')

			SF2->(DbSetorder(1))
			SE3->(DbSetorder(1))

			If SF1->F1_TIPO == "D"

				If SF2->(DbSeek(xFILIAL("SF2")+SD1->D1_NFORI+SD1->D1_SERORI))

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
						SE3->E3_COMIS   := SE3->E3_COMIS 
						SE3->E3_MOEDA   := SE3->E3_MOEDA

						SE3->(MsUnlock())

					EndIf
				EndIf
			EndIf
		EndIf
		RestArea(aArea)

		Return

Static Function gravaF1()
	IF cTpPg != '' .and. cLocPG != ''
		RecLock("SF1",.F.)

		SF1->F1_ZZTIPPG := cTpPg
		SF1->F1_ZZLOCPG := cLocPG
		SF1->(MsUnlock())

		gravaE2()

		if !FWIsInCallStack("GFEA065")
			oDlg:End()
		endif


	ELSE
		ALERT('Digite local de pagamento e o tipo de pagamento!')
	ENDIF
RETURN NIL

Static Function gravaE2()

	private cQuery    := ""
	private cUpdat    := ""
	private lResult   := 0
	private cMensa := ""
	private cForn := ""

	cQuery := "SELECT								     "  + CRLF
	cQuery += "*									     "  + CRLF
	cQuery += "FROM " + retSqlName("SE2") + " SE2        "  + CRLF
	cQuery += "WHERE SE2.D_E_L_E_T_ NOT LIKE '%*%'	     "  + CRLF
	cQuery += "AND SE2.E2_FILIAL  = '"+ xFilial("SE2")   +"'" + CRLF
	cQuery += "AND SE2.E2_FORNECE = '"+ SF1->F1_FORNECE  +"'" + CRLF
	cQuery += "AND SE2.E2_LOJA    = '"+ SF1->F1_LOJA     +"'" + CRLF
	cQuery += "AND SE2.E2_NUM     = '"+ SF1->F1_DOC 	    +"'" + CRLF
	cQuery += "AND SE2.E2_EMISSAO = '"+ DTOS(SF1->F1_EMISSAO) + "'" + CRLF

	TCQUERY cQuery NEW ALIAS "ZZZ"

	begin transaction

		while ZZZ->(!eof())
			cForn := POSICIONE("SA2",1,xFilial("SA2")+ SF1->F1_FORNECE + SF1->F1_LOJA  ,"A2_NOME")
			cUpdat := "UPDATE SE2010                           "  + CRLF
			cUpdat += "SET E2_ZZTIPPG   = '"+ cTpPg  +		   "'" + CRLF
			cUpdat += ",E2_ZZLOCPG      = '"+ cLocPG +          "'" + CRLF
			cUpdat += ",E2_ZZNOMEF      = '"+ cForn  +		   "'" + CRLF
			cUpdat += "WHERE R_E_C_N_O_ =" + cValToChar(ZZZ->R_E_C_N_O_) + "" + CRLF

			lResult := tcSqlExec(cUpdat)
			If lResult < 0
				cMensagem := "PE - MT103FIM - Erro durante a atualização das informações adicionais do financeiro: " + tcSqlError()
				alert(cMensagem)
				disarmTransaction()
				break
			EndIf
			cUpdat := ""
			ZZZ->(dbskip())
		end

	END transaction
	ZZZ->(dbCloseArea())
Return Nil

static function retChvTitPai(cNumTit, cPrefixo, cFornece, cLoja, cTipo, dDtEmis )
	local cQry	:= ""
	local cRet := ""

	cQry	:= "SELECT "
	cQry	+= "	* "
	cQry	+= "FROM  "
	cQry	+= "	" + retSqlName("SE2")+ " SE2 "
	cQry	+= "WHERE "
	cQry	+= "	SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
	cQry	+= "	SE2.E2_NUM = '" + cNumTit + "' AND "
	cQry	+= "	SE2.E2_PREFIXO = '" + cPrefixo + "' AND "
	cQry	+= "	SE2.E2_FORNECE = '" + cFornece + "' AND "
	cQry	+= "	SE2.E2_LOJA = '" + cLoja + "' AND "
	cQry	+= "	SE2.E2_TIPO = '" + cTipo + "' AND "
	cQry    += "    SE2.E2_EMISSAO = '"+ DTOS(dDtEmis) + "' AND" + CRLF
	cQry	+= "	SE2.D_E_L_E_T_ = '' "
	cQry	+= "ORDER BY E2_PARCELA "

	TCQUERY cQry NEW ALIAS "qZAux"

	if qZAux->(!eof())
		cRet := qZAux->E2_PREFIXO + qZAux->E2_NUM + qZAux->E2_PARCELA + qZAux->E2_TIPO + qZAux->E2_FORNECE + qZAux->E2_LOJA
	endif

	qZAux->(dbCloseArea())

return cRet

static function retReg(cTitPai,cNumtit, cPrefixo,cTipo,cFornece,cLoja,cCodRet )
	local cQry	:= ""
	local nRet := 0

	cQry	:= "SELECT "
	cQry	+= "	R_E_C_N_O_ AS REG "
	cQry	+= "FROM  "
	cQry	+= "	" + retSqlName("SE2")+ " SE2 "
	cQry	+= "WHERE "
	cQry	+= "	SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND "
	cQry	+= "	SE2.E2_NUM = '" + cNumTit + "' AND "
	cQry	+= "	SE2.E2_PREFIXO = '" + cPrefixo + "' AND "
	cQry	+= "	SE2.E2_FORNECE = '" + cFornece + "' AND "
	cQry	+= "	SE2.E2_LOJA = '" + cLoja + "' AND "
	cQry	+= "	SE2.E2_TIPO = '" + cTipo + "' AND "
	cQry	+= "	SE2.E2_TITPAI = '" + cTitPai + "' AND "
	cQry	+= "	SE2.E2_CODRET = '" + cCodRet + "' AND "
	cQry	+= "	SE2.D_E_L_E_T_ = '' "
	TCQUERY cQry NEW ALIAS "qZAux"

	if qZAux->(!eof())
		nRet := qZAux->REG
	endif

	qZAux->(dbCloseArea())
return nRet
