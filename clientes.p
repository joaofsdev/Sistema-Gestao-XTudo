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

DEFINE QUERY qClientes FOR clientes, cidades SCROLLING.

DEFINE BUFFER bClientes FOR Clientes.
DEFINE BUFFER bCidades  FOR Cidades.

DEFINE FRAME f-clientes
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del SPACE(3)
    bt-save bt-canc bt-exp SPACE(3)
    bt-sair  SKIP(1)
    clientes.codcliente  COLON 20
    clientes.nomecliente     COLON 20
    clientes.codendereco COLON 20 
    clientes.codcidade COLON 20 cidades.nomecidade NO-LABELS 
    clientes.observacao COLON 20 
    WITH SIDE-LABELS THREE-D SIZE 120 BY 10
    VIEW-AS DIALOG-BOX TITLE "Clientes".

ON 'choose' OF bt-pri 
    DO:
        GET FIRST qClientes.
        RUN piMostrar.
    END.

ON 'choose' OF bt-ant 
    DO:
        GET PREV qClientes.
        IF AVAIL clientes THEN
            RUN piMostrar.    
        ELSE
            GET FIRST qClientes.
    END.

ON 'choose' OF bt-prox 
    DO:
        GET NEXT qClientes.
        IF AVAIL clientes THEN
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
        ASSIGN 
            cAction = "add".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        CLEAR FRAME f-clientes.
        DISPLAY NEXT-VALUE(NextCodCliente) @ clientes.codcliente WITH FRAME f-clientes.
    END.

ON 'choose' OF bt-mod 
    DO:
        ASSIGN 
            cAction = "mod".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        DISPLAY clientes.codcliente WITH FRAME f-clientes.
        RUN piMostrar.
    END.

ON 'choose' OF bt-del 
    DO:
        DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
        DEFINE BUFFER bClientes FOR clientes.
        MESSAGE "Voce confirma a eliminacao do Cliente" clientes.codcliente "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminacao".
        IF  lConf THEN 
        DO:
            FIND bClientes
                WHERE bclientes.codcliente = clientes.codcliente
                EXCLUSIVE-LOCK NO-ERROR.
            IF  AVAILABLE bClientes THEN 
            DO:
                DELETE bClientes.
                RUN piOpenQuery.
            END.
        END.
    END.

ON 'leave' OF clientes.codcidade 
    DO:
        DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
        RUN piValidaCidade (INPUT clientes.codcidade:SCREEN-VALUE, 
            OUTPUT lValid).
        IF  lValid = NO THEN 
        DO:
            RETURN NO-APPLY.
        END.
        DISPLAY bCidades.nomecidade @ cidades.nomecidade WITH FRAME f-clientes.
    END.

ON 'choose' OF bt-save 
    DO:
        DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
        RUN piValidaCidade (INPUT clientes.codcidade:SCREEN-VALUE, 
            OUTPUT lValid).
        IF  lValid = NO THEN 
        DO:
            RETURN NO-APPLY.
        END.
   
        IF cAction = "add" THEN 
        DO:
            CREATE bClientes.
            ASSIGN 
                bclientes.codcliente = INPUT clientes.codcliente.
        END.
        IF  cAction = "mod" THEN 
        DO:
            FIND FIRST bClientes 
                WHERE bclientes.codcliente = clientes.codcliente
                EXCLUSIVE-LOCK NO-ERROR.
        END.
        ASSIGN 
            bClientes.nomecliente = INPUT clientes.nomecliente
            bClientes.codendereco = INPUT clientes.codendereco
            bClientes.codcidade   = INPUT clientes.codcidade
            bClientes.observacao  = INPUT clientes.observacao.
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
        ASSIGN 
            cArq = SESSION:TEMP-DIRECTORY + "clientes.csv".
        OUTPUT to value(cArq).
        FOR EACH clientes NO-LOCK:
            PUT UNFORMATTED
                clientes.codcliente        ";"
                clientes.nomecliente     ";"
                clientes.codendereco    ";"
                clientes.codcidade        ";"
                clientes.observacao      ";".
            IF AVAIL cidades THEN
                cidade.nomecidade.
            PUT UNFORMATTED SKIP.
        END.
        OUTPUT close.
        OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).    
    END.

RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

WAIT-FOR WINDOW-CLOSE OF FRAME f-clientes.

PROCEDURE piMostrar:
    IF AVAILABLE clientes THEN 
    DO:
        DISPLAY clientes.codcliente clientes.nomecliente clientes.codendereco clientes.codcidade clientes.observacao
            WITH FRAME f-clientes.
    END.
    ELSE 
    DO:
        CLEAR FRAME f-clientes.
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
            clientes.codcidade:SENSITIVE   = pEnable
            clientes.observacao:SENSITIVE  = pEnable.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF  AVAILABLE clientes THEN 
    DO:
        ASSIGN 
            rRecord = ROWID(clientes).
    END.
    OPEN QUERY qClientes 
        FOR EACH clientes,
        FIRST cidades WHERE cidades.codcidade = clientes.codcidade.
    REPOSITION qClientes TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piValidaCidade:
    DEFINE INPUT PARAMETER pCidade AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bCidades
        WHERE bCidades.codCidade = pCidade
        NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE bCidades THEN 
    DO:
        MESSAGE "Cidade" pCidade "nao existe!!!"
            VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            pValid = NO.
    END.
    ELSE 
        ASSIGN pValid = YES.
END PROCEDURE.
