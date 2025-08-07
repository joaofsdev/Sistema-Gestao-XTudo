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

DEFINE QUERY qCidades FOR cidades SCROLLING.

DEFINE BUFFER bCidades FOR cidades.

DEFINE FRAME f-cidades
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del SPACE(3)
    bt-save bt-canc bt-exp SPACE(3)
    bt-sair  SKIP(1)
    cidades.codcidade  COLON 20
    cidades.nomecidade     COLON 20
    cidades.coduf COLON 20 
    WITH SIDE-LABELS THREE-D SIZE 120 BY 10
    VIEW-AS DIALOG-BOX TITLE "Cidades".

ON 'choose' OF bt-pri 
    DO:
        GET FIRST qCidades.
        RUN piMostrar.
    END.

ON 'choose' OF bt-ant 
    DO:
        GET PREV qCidades.
        IF AVAIL cidades THEN
            RUN piMostrar.    
        ELSE
            GET FIRST qCidades.
    END.

ON 'choose' OF bt-prox 
    DO:
        GET NEXT qCidades.
        IF AVAIL cidades THEN
            RUN piMostrar.    
        ELSE
            GET LAST qCidades.
    END.

ON 'choose' OF bt-ult 
    DO:
        GET LAST qCidades.
        RUN piMostrar.
    END.

ON 'choose' OF bt-add 
    DO:
        ASSIGN 
            cAction = "add".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        CLEAR FRAME f-cidades.
        DISPLAY NEXT-VALUE(NextCodCidade) @ cidades.codcidade WITH FRAME f-cidades.
    END.

ON 'choose' OF bt-mod 
    DO:
        ASSIGN 
            cAction = "mod".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        DISPLAY cidades.codcidade WITH FRAME f-cidades.
        RUN piMostrar.
    END.

ON 'choose' OF bt-del 
    DO:
        DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
        DEFINE BUFFER bCidades FOR cidades.
        MESSAGE "Voce confirma a eliminacao da cidade" cidades.codcidade "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminacao".
        IF  lConf THEN 
        DO:
            FIND bCidades
                WHERE bCidades.codcidade = cidades.codcidade
                EXCLUSIVE-LOCK NO-ERROR.
            IF  AVAILABLE bCidades THEN 
            DO:
                DELETE bCidades.
                RUN piOpenQuery.
            END.
        END.
    END.

ON 'choose' OF bt-save 
    DO:
        IF cAction = "add" THEN 
        DO:
            CREATE bCidades.
            ASSIGN 
                bCidades.codcidade = INPUT cidades.codcidade.
        END.
        IF  cAction = "mod" THEN 
        DO:
            FIND FIRST bCidades 
                WHERE bCidades.codcidade = cidades.codcidade
                EXCLUSIVE-LOCK NO-ERROR.
        END.
        ASSIGN 
            bCidades.nomecidade = INPUT cidades.nomecidade
            bCidades.codUF      = INPUT cidades.codUF.
        RUN piHabilitaBotoes (INPUT TRUE).
        RUN piHabilitaCampos (INPUT FALSE).
        RUN piOpenQuery.
        IF cAction = "add" THEN
        DO:
            GET LAST qCidades.
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
            cArq = SESSION:TEMP-DIRECTORY + "cidades.csv".
        OUTPUT to value(cArq).
        FOR EACH cidades NO-LOCK:
            PUT UNFORMATTED
                cidades.codcidade  ";"
                cidades.nomecidade     ";"
                cidades.coduf    ";".
            PUT UNFORMATTED SKIP.
        END.
        OUTPUT close.
        OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).    
    END.

RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

WAIT-FOR WINDOW-CLOSE OF FRAME f-cidades.

PROCEDURE piMostrar:
    IF AVAILABLE cidades THEN 
    DO:
        DISPLAY cidades.codcidade cidades.nomecidade cidades.coduf
            WITH FRAME f-cidades.
    END.
    ELSE 
    DO:
        CLEAR FRAME f-cidades.
    END.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-cidades:
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
    DO WITH FRAME f-cidades:
        ASSIGN 
            cidades.nomecidade:SENSITIVE = pEnable
            cidades.coduf:SENSITIVE      = pEnable.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF  AVAILABLE cidades THEN 
    DO:
        ASSIGN 
            rRecord = ROWID(cidades).
    END.
    OPEN QUERY qCidades 
        FOR EACH cidades.
    REPOSITION qCidades TO ROWID rRecord NO-ERROR.
END PROCEDURE.





