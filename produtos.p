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

DEFINE QUERY qProdutos FOR produtos SCROLLING.

DEFINE BUFFER bProdutos FOR produtos.

DEFINE FRAME f-produtos
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del SPACE(3)
    bt-save bt-canc bt-exp SPACE(3)
    bt-sair  SKIP(1)
    produtos.codproduto  COLON 20
    produtos.nomeproduto     COLON 20
    produtos.valproduto COLON 20 
    WITH SIDE-LABELS THREE-D SIZE 120 BY 10
    VIEW-AS DIALOG-BOX TITLE "produtos".

ON 'choose' OF bt-pri 
    DO:
        GET FIRST qProdutos.
        RUN pimostrar.
    END.

ON 'choose' OF bt-ant 
    DO:
        GET PREV qProdutos.
        IF AVAIL produtos THEN
            RUN pimostrar.    
        ELSE
            GET FIRST qProdutos.
    END.

ON 'choose' OF bt-prox 
    DO:
        GET NEXT qProdutos.
        IF AVAIL produtos THEN
            RUN pimostrar.    
        ELSE
            GET LAST qProdutos.
    END.

ON 'choose' OF bt-ult 
    DO:
        GET LAST qProdutos.
        RUN pimostrar.
    END.

ON 'choose' OF bt-add 
    DO:
        ASSIGN 
            cAction = "add".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        CLEAR FRAME f-produtos.
        DISPLAY NEXT-VALUE(NextCodProduto) @ produtos.codproduto WITH FRAME f-produtos.
    END.

ON 'choose' OF bt-mod 
    DO:
        ASSIGN 
            cAction = "mod".
        RUN piHabilitaBotoes (INPUT FALSE).
        RUN piHabilitaCampos (INPUT TRUE).
        DISPLAY produtos.codproduto WITH FRAME f-produtos.
        RUN pimostrar.
    END.

ON 'choose' OF bt-del 
    DO:
        DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
        DEFINE BUFFER bProdutos FOR produtos.
        MESSAGE "Voce confirma a eliminacao do produto" produtos.codproduto "?" UPDATE lConf
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
            TITLE "Eliminacao".
        IF  lConf THEN 
        DO:
            FIND bProdutos
                WHERE bprodutos.codproduto = produtos.codproduto
                EXCLUSIVE-LOCK NO-ERROR.
            IF  AVAILABLE bProdutos THEN 
            DO:
                DELETE bProdutos.
                RUN piOpenQuery.
            END.
        END.
    END.

ON 'choose' OF bt-save 
    DO:
        IF cAction = "add" THEN 
        DO:
            CREATE bProdutos.
            ASSIGN 
                bprodutos.codproduto = INPUT produtos.codproduto.
        END.
        IF  cAction = "mod" THEN 
        DO:
            FIND FIRST bProdutos 
                WHERE bprodutos.codproduto = produtos.codproduto
                EXCLUSIVE-LOCK NO-ERROR.
        END.
        ASSIGN 
            bProdutos.nomeproduto = INPUT produtos.nomeproduto
            bProdutos.valproduto  = INPUT produtos.valproduto.
        RUN piHabilitaBotoes (INPUT TRUE).
        RUN piHabilitaCampos (INPUT FALSE).
        RUN piOpenQuery.
        IF cAction = "add" THEN
        DO:
            GET LAST qProdutos.
            RUN pimostrar.
        END.
    END.

ON 'choose' OF bt-canc 
    DO:
        RUN piHabilitaBotoes (INPUT TRUE).
        RUN piHabilitaCampos (INPUT FALSE).
        RUN pimostrar.
    END.     

ON 'choose' OF bt-exp 
    DO:
        DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
        ASSIGN 
            cArq = SESSION:TEMP-DIRECTORY + "produtos.csv".
        OUTPUT to value(cArq).
        FOR EACH produtos NO-LOCK:
            PUT UNFORMATTED
                produtos.codproduto  ";"
                produtos.nomeproduto     ";"
                produtos.valproduto    ";".
            PUT UNFORMATTED SKIP.
        END.
        OUTPUT close.
        OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).    
    END.

RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

WAIT-FOR WINDOW-CLOSE OF FRAME f-produtos.

PROCEDURE pimostrar:
    IF AVAILABLE produtos THEN 
    DO:
        DISPLAY produtos.codproduto produtos.nomeproduto produtos.valproduto
            WITH FRAME f-produtos.
    END.
    ELSE 
    DO:
        CLEAR FRAME f-produtos.
    END.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-produtos:
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
    DO WITH FRAME f-produtos:
        ASSIGN 
            produtos.nomeproduto:SENSITIVE = pEnable
            produtos.valproduto:SENSITIVE  = pEnable.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF  AVAILABLE produtos THEN 
    DO:
        ASSIGN 
            rRecord = ROWID(produtos).
    END.
    OPEN QUERY qProdutos 
        FOR EACH produtos.
    REPOSITION qProdutos TO ROWID rRecord NO-ERROR.
END PROCEDURE.
