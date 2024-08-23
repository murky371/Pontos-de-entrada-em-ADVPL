#Include 'Totvs.ch'
#Include "rwmake.ch"
#Include "TBICONN.ch"


/*/{Protheus.doc} FINALeg
Utilizado para alterar as legendas de diversas rotinas do financeiro
@type user function
@author user
@since 05/08/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FINALeg()

	Local dVenc     := DToS(SE2->E2_VENCTO)

	Local aLegenda  := PARAMIXB[4]

	Local dDataBase

	Local aRet      := {}



	If dVenc < dDataBase

		aAdd(aLegenda,{"BR_PINK","Titulos Liberados"})

	EndIf

	BrwLegenda("", "Legenda",aLegenda)

Return aRet
