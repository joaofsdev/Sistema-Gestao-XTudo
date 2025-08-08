DEFINE INPUT  PARAMETER ipCodPedido AS INTEGER NO-UNDO.
DEFINE INPUT  PARAMETER ipCodItem   AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER opSalvou    AS LOGICAL NO-UNDO INITIAL FALSE.

DEFINE VARIABLE cbo-CodProduto AS INTEGER   NO-UNDO
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Selecione um produto", 0.
DEFINE VARIABLE iQuantidade   AS INTEGER   NO-UNDO INITIAL 1.
DEFINE VARIABLE dValorProduto AS DECIMAL   NO-UNDO INITIAL 0.
DEFINE VARIABLE dValTotal     AS DECIMAL   NO-UNDO FORMAT "->>,>>>,>>9.99".
DEFINE VARIABLE lProdutoValido AS LOGICAL  NO-UNDO INITIAL FALSE.

DEFINE BUFFER bItens    FOR itens.
DEFINE BUFFER bProdutos FOR produtos.

DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar" AUTO-ENDKEY.

DEFINE FRAME f-item
    cbo-CodProduto LABEL "Produto:"     AT ROW 2 COLUMN 15
    iQuantidade    LABEL "Quantidade:"  AT ROW 4 COLUMN 15
    dValTotal      LABEL "Valor Total:" AT ROW 6 COLUMN 15 FORMAT "->>,>>>,>>9.99"
    bt-save        AT ROW 8 COLUMN 15
    bt-canc        AT ROW 8 COLUMN 30
    WITH SIDE-LABELS THREE-D TITLE "Item" VIEW-AS DIALOG-BOX SIZE 70 BY 10 CENTERED.

PROCEDURE piPreencheComboProdutos:
    DEFINE VARIABLE iCodProduto AS INTEGER NO-UNDO.
    DEFINE VARIABLE cNomeProduto AS CHARACTER NO-UNDO.
    cbo-CodProduto:LIST-ITEM-PAIRS IN FRAME f-item = "Selecione um produto,0".
    FOR EACH produtos NO-LOCK:
        ASSIGN
            iCodProduto = produtos.CodProduto
            cNomeProduto = produtos.NomeProduto.
        cbo-CodProduto:ADD-LAST(cNomeProduto + " (" + STRING(iCodProduto) + ")", iCodProduto) IN FRAME f-item.
    END.
END PROCEDURE.

IF ipCodItem > 0 THEN DO:
    FIND FIRST bItens WHERE 
        bItens.CodPedido = ipCodPedido AND 
        bItens.CodItem   = ipCodItem NO-LOCK NO-ERROR.
    IF AVAILABLE bItens THEN DO:
        ASSIGN
            cbo-CodProduto = bItens.CodProduto
            iQuantidade    = bItens.NumQuantidade.
        FIND FIRST bProdutos WHERE bProdutos.CodProduto = cbo-CodProduto NO-LOCK NO-ERROR.
        IF AVAILABLE bProdutos THEN DO:
            ASSIGN
                dValorProduto  = bProdutos.ValProduto
                lProdutoValido = TRUE.
        END.
        ELSE DO:
            ASSIGN
                dValorProduto  = 0
                lProdutoValido = FALSE.
        END.
        dValTotal = dValorProduto * iQuantidade.
    END.
END.
ELSE DO:
    ASSIGN
        cbo-CodProduto = 0
        iQuantidade    = 1
        dValorProduto  = 0
        dValTotal      = 0
        lProdutoValido = FALSE.
END.

DISPLAY cbo-CodProduto iQuantidade dValTotal WITH FRAME f-item.
ENABLE cbo-CodProduto iQuantidade bt-save bt-canc WITH FRAME f-item.

RUN piPreencheComboProdutos.

ON VALUE-CHANGED OF cbo-CodProduto IN FRAME f-item DO:
    DEFINE VARIABLE iSelected AS INTEGER NO-UNDO.
    ASSIGN iSelected = INTEGER(cbo-CodProduto:SCREEN-VALUE IN FRAME f-item) NO-ERROR.
    IF ERROR-STATUS:ERROR OR iSelected <= 0 THEN DO:
        MESSAGE "Selecione um produto válido." VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            cbo-CodProduto:SCREEN-VALUE IN FRAME f-item = "0"
            dValorProduto  = 0
            dValTotal      = 0
            lProdutoValido = FALSE.
        DISPLAY dValTotal WITH FRAME f-item.
        RETURN NO-APPLY.
    END.
    FIND FIRST bProdutos WHERE bProdutos.CodProduto = iSelected NO-LOCK NO-ERROR.
    IF AVAILABLE bProdutos THEN DO:
        ASSIGN
            dValorProduto  = bProdutos.ValProduto
            dValTotal      = dValorProduto * iQuantidade
            lProdutoValido = TRUE.
        DISPLAY dValTotal WITH FRAME f-item.
    END.
    ELSE DO:
        MESSAGE "Produto com código " iSelected " não encontrado!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN 
            cbo-CodProduto:SCREEN-VALUE IN FRAME f-item = "0"
            dValorProduto  = 0
            dValTotal      = 0
            lProdutoValido = FALSE.
        DISPLAY dValTotal WITH FRAME f-item.
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
                bItens.CodProduto    = INTEGER(cbo-CodProduto:SCREEN-VALUE IN FRAME f-item)
                bItens.NumQuantidade = iQuantidade
                bItens.ValTotal      = dValTotal.
        END.
        ELSE DO:
            FIND FIRST bItens WHERE 
                bItens.CodPedido = ipCodPedido AND 
                bItens.CodItem   = ipCodItem EXCLUSIVE-LOCK NO-ERROR.
            IF AVAILABLE bItens THEN
                ASSIGN
                    bItens.CodProduto    = INTEGER(cbo-CodProduto:SCREEN-VALUE IN FRAME f-item)
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
