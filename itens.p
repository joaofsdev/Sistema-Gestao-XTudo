DEFINE INPUT  PARAMETER ipCodPedido AS INTEGER NO-UNDO.
DEFINE INPUT  PARAMETER ipCodItem   AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER opSalvou    AS LOGICAL NO-UNDO INITIAL FALSE.

DEFINE VARIABLE iCodProduto   AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cNomeProduto  AS CHARACTER NO-UNDO FORMAT "x(25)".
DEFINE VARIABLE iQuantidade   AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE dValorProduto AS DECIMAL   NO-UNDO INITIAL 0.
DEFINE VARIABLE dValTotal     AS DECIMAL   NO-UNDO FORMAT "->>,>>>,>>9.99".
DEFINE VARIABLE lProdutoValido AS LOGICAL  NO-UNDO INITIAL FALSE.

DEFINE BUFFER bItens    FOR itens.
DEFINE BUFFER bProdutos FOR produtos.

DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar" AUTO-ENDKEY.

DEFINE FRAME f-item
    iCodProduto   LABEL "Produto:"      COLON 15
    cNomeProduto  NO-LABELS             COLON 30
    iQuantidade   LABEL "Quantidade:"   COLON 15
    dValTotal     LABEL "Valor Total:"  COLON 15 FORMAT "->>,>>>,>>9.99"
    bt-save       AT 10
    bt-canc       AT 25
    WITH SIDE-LABELS THREE-D TITLE "Item" VIEW-AS DIALOG-BOX SIZE 70 BY 10.

IF ipCodItem > 0 THEN DO:
    FIND FIRST bItens WHERE 
        bItens.CodPedido = ipCodPedido AND 
        bItens.CodItem   = ipCodItem NO-LOCK NO-ERROR.

    IF AVAILABLE bItens THEN DO:
        ASSIGN
            iCodProduto   = bItens.CodProduto
            iQuantidade   = bItens.NumQuantidade.

        FIND FIRST bProdutos WHERE bProdutos.CodProduto = iCodProduto NO-LOCK NO-ERROR.
        IF AVAILABLE bProdutos THEN DO:
            ASSIGN
                cNomeProduto   = bProdutos.NomeProduto
                dValorProduto  = bProdutos.ValProduto
                lProdutoValido = TRUE.
        END.
        ELSE DO:
            ASSIGN
                cNomeProduto   = "Produto não encontrado"
                dValorProduto  = 0
                lProdutoValido = FALSE.
        END.
        
        dValTotal = dValorProduto * iQuantidade.
    END.
END.
ELSE DO:
    ASSIGN
        iCodProduto   = 0
        cNomeProduto  = ""
        iQuantidade   = 1
        dValorProduto = 0
        dValTotal     = 0
        lProdutoValido = FALSE.
END.

DISPLAY iCodProduto cNomeProduto iQuantidade dValTotal WITH FRAME f-item.
ENABLE iCodProduto iQuantidade bt-save bt-canc WITH FRAME f-item.

ON LEAVE OF iCodProduto IN FRAME f-item DO:
    ASSIGN iCodProduto = INTEGER(INPUT iCodProduto) NO-ERROR.
    
    IF ERROR-STATUS:ERROR OR iCodProduto <= 0 THEN DO:
        MESSAGE "Código do produto inválido. Informe um número válido." VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            iCodProduto    = 0
            cNomeProduto   = ""
            dValorProduto  = 0
            dValTotal      = 0
            lProdutoValido = FALSE.
        DISPLAY cNomeProduto dValTotal WITH FRAME f-item.
        RETURN NO-APPLY.
    END.

    FIND FIRST bProdutos WHERE bProdutos.CodProduto = iCodProduto NO-LOCK NO-ERROR.
    IF AVAILABLE bProdutos THEN DO:
        ASSIGN
            cNomeProduto   = bProdutos.NomeProduto
            dValorProduto  = bProdutos.ValProduto
            dValTotal      = dValorProduto * iQuantidade
            lProdutoValido = TRUE.
        DISPLAY cNomeProduto dValTotal WITH FRAME f-item.
    END.
    ELSE DO:
        MESSAGE "Produto com código " iCodProduto " não encontrado!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            cNomeProduto   = ""
            dValorProduto  = 0
            dValTotal      = 0
            lProdutoValido = FALSE.
        DISPLAY cNomeProduto dValTotal WITH FRAME f-item.
        RETURN NO-APPLY.
    END.
END.

ON LEAVE OF iQuantidade IN FRAME f-item DO:
    ASSIGN iQuantidade = INTEGER(INPUT iQuantidade) NO-ERROR.
    
    IF ERROR-STATUS:ERROR OR iQuantidade <= 0 THEN DO:
        MESSAGE "Quantidade deve ser maior que zero." VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            iQuantidade = 1
            dValTotal   = dValorProduto * iQuantidade.
        DISPLAY iQuantidade dValTotal WITH FRAME f-item.
        RETURN NO-APPLY.
    END.
    
    dValTotal = dValorProduto * iQuantidade.
    DISPLAY dValTotal WITH FRAME f-item.
END.

ON CHOOSE OF bt-save IN FRAME f-item DO:
    IF NOT lProdutoValido THEN DO:
        MESSAGE "Informe um produto válido." VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    IF iQuantidade <= 0 THEN DO:
        MESSAGE "Quantidade deve ser maior que zero." VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    DO TRANSACTION:
        IF ipCodItem = 0 THEN DO:
            CREATE bItens.
            ASSIGN
                bItens.CodPedido     = ipCodPedido
                bItens.CodItem       = NEXT-VALUE(NextCodItem)
                bItens.CodProduto    = iCodProduto
                bItens.NumQuantidade = iQuantidade
                bItens.ValTotal      = dValTotal.
        END.
        ELSE DO:
            FIND FIRST bItens WHERE 
                bItens.CodPedido = ipCodPedido AND 
                bItens.CodItem   = ipCodItem EXCLUSIVE-LOCK NO-ERROR.
            IF AVAILABLE bItens THEN
                ASSIGN
                    bItens.CodProduto    = iCodProduto
                    bItens.NumQuantidade = iQuantidade
                    bItens.ValTotal      = dValTotal.
        END.
    END.

    ASSIGN opSalvou = TRUE.
    HIDE FRAME f-item NO-PAUSE.
    APPLY "WINDOW-CLOSE" TO FRAME f-item.
    RETURN.
END.

ON END-ERROR OF FRAME f-item OR CHOOSE OF bt-canc IN FRAME f-item DO:
    ASSIGN opSalvou = FALSE.
    HIDE FRAME f-item NO-PAUSE.
    APPLY "WINDOW-CLOSE" TO FRAME f-item.
    RETURN.
END.

VIEW FRAME f-item.
WAIT-FOR CHOOSE OF bt-save, bt-canc OR END-ERROR OF FRAME f-item.
