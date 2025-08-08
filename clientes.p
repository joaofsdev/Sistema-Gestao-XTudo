USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Adicionar".
DEFINE BUTTON bt-mod LABEL "Modificar".
DEFINE BUTTON bt-del LABEL "Eliminar".
DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-exp LABEL "Exportar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE VARIABLE cbo-CodCidade AS INTEGER NO-UNDO
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Selecione uma cidade", 0.

DEFINE QUERY qClientes FOR clientes, cidades SCROLLING.

DEFINE BUFFER bClientes FOR clientes.
DEFINE BUFFER bCidades FOR cidades.

DEFINE FRAME f-clientes
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del SPACE(3)
    bt-save bt-canc bt-exp SPACE(3)
    bt-sair SKIP(1)
    clientes.codcliente COLON 20
    clientes.nomecliente COLON 20
    clientes.codendereco COLON 20 
    cbo-CodCidade COLON 20 LABEL "Cidade"
    cidades.nomecidade NO-LABELS 
    clientes.observacao COLON 20 
    WITH SIDE-LABELS THREE-D SIZE 120 BY 10
         VIEW-AS DIALOG-BOX TITLE "Clientes".

PROCEDURE piPreencheComboCidades:
    DEFINE VARIABLE iCodCidade AS INTEGER NO-UNDO.
    DEFINE VARIABLE cNomeCidade AS CHARACTER NO-UNDO.
    
    cbo-CodCidade:LIST-ITEM-PAIRS IN FRAME f-clientes = "Selecione uma cidade,0".
    
    FOR EACH cidades NO-LOCK:
        ASSIGN
            iCodCidade = cidades.codcidade
            cNomeCidade = cidades.nomecidade.
        cbo-CodCidade:ADD-LAST(cNomeCidade + " (" + STRING(iCodCidade) + ")", iCodCidade) IN FRAME f-clientes.
    END.
END PROCEDURE.

ON 'choose' OF bt-pri 
DO:
    GET FIRST qClientes.
    RUN piMostrar.
END.

ON 'choose' OF bt-ant 
DO:
    GET PREV qClientes.
    IF AVAILABLE clientes THEN
        RUN piMostrar.    
    ELSE
        GET FIRST qClientes.
END.

ON 'choose' OF bt-prox 
DO:
    GET NEXT qClientes.
    IF AVAILABLE clientes THEN
        RUN piMostrar.    
    ELSE
        GET LAST qClientes.
END.

ON 'choose' OF bt-ult 
DO:
    GET LAST qClientes.
    RUN piMostrar.
END.

ON 'choose' OF bt-add 
DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    CLEAR FRAME f-clientes.
    ASSIGN cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes = "0". 
    DISPLAY NEXT-VALUE(NextCodCliente) @ clientes.codcliente WITH FRAME f-clientes.
END.

ON 'choose' OF bt-mod 
DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY clientes.codcliente WITH FRAME f-clientes.
    RUN piMostrar.
END.

ON 'choose' OF bt-del 
DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    MESSAGE "Você confirma a eliminação do Cliente " clientes.codcliente "?" 
        UPDATE lConf VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Eliminação".
    IF lConf THEN 
    DO:
        FIND bClientes WHERE bClientes.codcliente = clientes.codcliente EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bClientes THEN 
        DO:
            DELETE bClientes.
            RUN piOpenQuery.
        END.
    END.
    GET LAST qClientes.
    RUN piMostrar.
END.

ON VALUE-CHANGED OF cbo-CodCidade IN FRAME f-clientes 
DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iSelected AS INTEGER NO-UNDO.
    
    ASSIGN iSelected = INTEGER(cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "Selecione uma cidade válida." VIEW-AS ALERT-BOX ERROR.
        ASSIGN cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes = "0".
        RETURN NO-APPLY.
    END.
    
    RUN piValidaCidade (INPUT iSelected, OUTPUT lValid).
    IF NOT lValid THEN DO:
        ASSIGN cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes = "0".
        RETURN NO-APPLY.
    END.
    DISPLAY bCidades.nomecidade @ cidades.nomecidade WITH FRAME f-clientes.
END.

ON 'choose' OF bt-save 
DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    DEFINE VARIABLE iCodCidade AS INTEGER NO-UNDO.
    
    ASSIGN iCodCidade = INTEGER(cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes) NO-ERROR.
    IF ERROR-STATUS:ERROR OR iCodCidade = 0 THEN DO:
        MESSAGE "Selecione uma cidade válida." VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    
    RUN piValidaCidade (INPUT iCodCidade, OUTPUT lValid).
    IF NOT lValid THEN DO:
        RETURN NO-APPLY.
    END.
    
    IF cAction = "add" THEN 
    DO:
        CREATE bClientes.
        ASSIGN bClientes.codcliente = INPUT clientes.codcliente.
    END.
    IF cAction = "mod" THEN 
    DO:
        FIND FIRST bClientes WHERE bClientes.codcliente = clientes.codcliente EXCLUSIVE-LOCK NO-ERROR.
    END.
    
    ASSIGN 
        bClientes.nomecliente = INPUT clientes.nomecliente
        bClientes.codendereco = INPUT clientes.codendereco
        bClientes.codcidade = iCodCidade
        bClientes.observacao = INPUT clientes.observacao.
    
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piOpenQuery.
    
    IF cAction = "add" THEN 
    DO:
        GET LAST qClientes.
        RUN piMostrar.
    END.
END.

ON 'choose' OF bt-canc 
DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piMostrar.
END.     

ON 'choose' OF bt-exp 
DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.csv".
    OUTPUT TO VALUE(cArq).
    FOR EACH clientes NO-LOCK:
        FIND FIRST cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK NO-ERROR.
        PUT UNFORMATTED
            clientes.codcliente ";"
            clientes.nomecliente ";"
            clientes.codendereco ";"
            clientes.codcidade ";"
            clientes.observacao ";"
            (IF AVAILABLE cidades THEN cidades.nomecidade ELSE "") SKIP.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).    
END.

RUN piPreencheComboCidades.
RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

WAIT-FOR WINDOW-CLOSE OF FRAME f-clientes.

PROCEDURE piMostrar:
    IF AVAILABLE clientes THEN 
    DO:
        ASSIGN cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes = STRING(clientes.codcidade).
        DISPLAY 
            clientes.codcliente 
            clientes.nomecliente 
            clientes.codendereco 
            clientes.observacao
            cidades.nomecidade
            WITH FRAME f-clientes.
    END.
    ELSE 
    DO:
        CLEAR FRAME f-clientes.
        ASSIGN cbo-CodCidade:SCREEN-VALUE IN FRAME f-clientes = "0".
    END.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-clientes:
        ASSIGN 
            bt-pri:SENSITIVE  = pEnable
            bt-ant:SENSITIVE  = pEnable
            bt-prox:SENSITIVE = pEnable
            bt-ult:SENSITIVE  = pEnable
            bt-sair:SENSITIVE = pEnable
            bt-add:SENSITIVE  = pEnable
            bt-mod:SENSITIVE  = pEnable
            bt-del:SENSITIVE  = pEnable
            bt-exp:SENSITIVE  = pEnable
            bt-save:SENSITIVE = NOT pEnable
            bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-clientes:
        ASSIGN 
            clientes.nomecliente:SENSITIVE = pEnable
            clientes.codendereco:SENSITIVE = pEnable
            cbo-CodCidade:SENSITIVE = pEnable
            clientes.observacao:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE clientes THEN 
    DO:
        ASSIGN rRecord = ROWID(clientes).
    END.
    OPEN QUERY qClientes 
        FOR EACH clientes NO-LOCK,
            FIRST cidades WHERE cidades.codcidade = clientes.codcidade NO-LOCK.
    REPOSITION qClientes TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piValidaCidade:
    DEFINE INPUT PARAMETER pCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bCidades WHERE bCidades.codcidade = pCidade NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bCidades THEN 
    DO:
        MESSAGE "Cidade " pCidade " não existe!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
        ASSIGN pValid = YES.
END PROCEDURE.
