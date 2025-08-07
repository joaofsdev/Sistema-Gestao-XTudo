ASSIGN CURRENT-WINDOW:HIDDEN = TRUE.

DEFINE BUTTON bt-pri LABEL "<<".
DEFINE BUTTON bt-ant LABEL "<".
DEFINE BUTTON bt-prox LABEL ">".
DEFINE BUTTON bt-ult LABEL ">>".
DEFINE BUTTON bt-add LABEL "Novo".
DEFINE BUTTON bt-mod LABEL "Modificar".
DEFINE BUTTON bt-del LABEL "Remover".
DEFINE BUTTON bt-save LABEL "Salvar".
DEFINE BUTTON bt-canc LABEL "Cancelar".
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY.
DEFINE BUTTON bt-rel LABEL "Exportar".
DEFINE BUTTON bt-additem LABEL "Adicionar".
DEFINE BUTTON bt-moditem LABEL "Modificar".
DEFINE BUTTON bt-delitem LABEL "Eliminar".

DEFINE VARIABLE cAction AS CHARACTER NO-UNDO.

DEFINE QUERY qPedidos FOR pedidos, clientes, cidades SCROLLING.
DEFINE QUERY qItens FOR itens, produtos.

DEFINE BROWSE bitens QUERY qItens DISPLAY
    itens.CodItem
    itens.CodProduto
    produtos.NomeProduto
    itens.NumQuantidade
    produtos.ValProduto
    itens.ValTotal
    WITH SEPARATORS 10 DOWN.

DEFINE BUFFER bPed FOR pedidos.
DEFINE BUFFER bClientes FOR clientes.
DEFINE BUFFER bCidades FOR cidades.

DEFINE FRAME f-pedidos
    bt-pri AT 10
    bt-ant 
    bt-prox 
    bt-ult SPACE(3) 
    bt-add bt-mod bt-del bt-rel SPACE(3)
    bt-save bt-canc SPACE(3)
    bt-sair SKIP(1)
    pedidos.CodPedido COLON 20
    pedidos.DataPedido 
    pedidos.CodCliente COLON 20
    clientes.NomeCliente NO-LABELS
    clientes.CodEndereco COLON 20
    clientes.CodCidade COLON 20
    cidades.NomeCidade NO-LABELS SKIP
    pedidos.Observacao COLON 20
    bitens AT ROW 10 COL 5 SKIP(1)
    bt-additem AT 10
    bt-moditem
    bt-delitem
    WITH SIDE-LABELS THREE-D SIZE 150 BY 25
         VIEW-AS DIALOG-BOX TITLE "Pedidos".

ENABLE bitens WITH FRAME f-pedidos.

ON 'choose' OF bt-pri DO:
    GET FIRST qPedidos.
    RUN pimostrar.
END.

ON 'choose' OF bt-additem DO:
    DEFINE VARIABLE iCodItem AS INTEGER NO-UNDO INITIAL 0.
    DEFINE VARIABLE lSalvou AS LOGICAL NO-UNDO.

    IF NOT AVAILABLE pedidos THEN DO:
        MESSAGE "Selecione ou crie um pedido antes de adicionar itens." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    DEFINE VARIABLE cCaminhoItens AS CHARACTER NO-UNDO INITIAL "c:\Xtudo\itens.p".
    IF SEARCH(cCaminhoItens) = ? THEN DO:
        MESSAGE "Programa itens.p n�o encontrado no caminho especificado." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    RUN VALUE(cCaminhoItens) (
        INPUT pedidos.CodPedido,
        INPUT iCodItem,
        OUTPUT lSalvou
    ).

    IF lSalvou THEN DO:
        MESSAGE "Item salvo com sucesso!" VIEW-AS ALERT-BOX INFORMATION.
        RUN piOpenItens(INPUT pedidos.CodPedido).
        REPOSITION qItens TO ROW 1 NO-ERROR.
    END.
END.

ON 'choose' OF bt-moditem DO:
    DEFINE VARIABLE iCodItem AS INTEGER NO-UNDO.
    DEFINE VARIABLE lSalvou AS LOGICAL NO-UNDO.

    IF NOT AVAILABLE pedidos THEN DO:
        MESSAGE "Selecione um pedido antes de modificar itens." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    IF bitens:NUM-SELECTED-ROWS IN FRAME f-pedidos = 0 THEN DO:
        MESSAGE "Selecione um item no browse para modificar." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    GET CURRENT qItens NO-LOCK.
    IF AVAILABLE itens THEN DO:
        ASSIGN iCodItem = itens.CodItem.

        DEFINE VARIABLE cCaminhoItens AS CHARACTER NO-UNDO INITIAL "c:\Xtudo\itens.p".
        IF SEARCH(cCaminhoItens) = ? THEN DO:
            MESSAGE "Programa itens.p n�o encontrado no caminho especificado." 
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.

        RUN VALUE(cCaminhoItens) (
            INPUT pedidos.CodPedido,
            INPUT iCodItem,
            OUTPUT lSalvou
        ).

        IF lSalvou THEN DO:
            MESSAGE "Item modificado com sucesso!" VIEW-AS ALERT-BOX INFORMATION.
            RUN piOpenItens(INPUT pedidos.CodPedido).
            REPOSITION qItens TO ROW 1 NO-ERROR.
        END.
    END.
    ELSE DO:
        MESSAGE "Nenhum item selecionado para modifica��o." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
END.

ON 'choose' OF bt-delitem DO:
    DEFINE VARIABLE iCodItem AS INTEGER NO-UNDO.
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.

    IF NOT AVAILABLE pedidos THEN DO:
        MESSAGE "Selecione um pedido antes de eliminar itens." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    IF bitens:NUM-SELECTED-ROWS IN FRAME f-pedidos = 0 THEN DO:
        MESSAGE "Selecione um item no browse para eliminar." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    GET CURRENT qItens NO-LOCK.
    IF AVAILABLE itens THEN DO:
        ASSIGN iCodItem = itens.CodItem.
        MESSAGE "Confirma a elimina��o do item " iCodItem "?" 
            UPDATE lConf VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Elimina��o".
        IF lConf THEN DO:
            DO TRANSACTION:
                FIND FIRST itens WHERE 
                    itens.CodPedido = pedidos.CodPedido AND 
                    itens.CodItem = iCodItem EXCLUSIVE-LOCK NO-ERROR.
                IF AVAILABLE itens THEN DO:
                    DELETE itens.
                    MESSAGE "Item eliminado com sucesso!" VIEW-AS ALERT-BOX INFORMATION.
                END.
            END.
            RUN piOpenItens(INPUT pedidos.CodPedido).
            REPOSITION qItens TO ROW 1 NO-ERROR.
        END.
    END.
    ELSE DO:
        MESSAGE "Nenhum item selecionado para elimina��o." 
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
END.

ON 'choose' OF bt-ant DO:
    GET PREV qPedidos.
    IF AVAILABLE pedidos THEN
        RUN pimostrar.
    ELSE
        GET FIRST qPedidos.
END.

ON 'choose' OF bt-prox DO:
    GET NEXT qPedidos.
    IF AVAILABLE pedidos THEN
        RUN pimostrar.
    ELSE
        GET LAST qPedidos.
END.

ON 'choose' OF bt-ult DO:
    GET LAST qPedidos.
    RUN pimostrar.
END.

ON 'choose' OF bt-add DO:
    ASSIGN cAction = "add".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    CLEAR FRAME f-pedidos.
    DISPLAY NEXT-VALUE(NextCodPedido) @ pedidos.CodPedido 
    TODAY @ pedidos.DataPedido WITH FRAME f-pedidos.
    CLOSE QUERY qItens.
    DISPLAY bitens WITH FRAME f-pedidos.
END.

ON 'choose' OF bt-mod DO:
    ASSIGN cAction = "mod".
    RUN piHabilitaBotoes (INPUT FALSE).
    RUN piHabilitaCampos (INPUT TRUE).
    DISPLAY pedidos.CodPedido WITH FRAME f-pedidos.
    RUN pimostrar.
END.

ON 'choose' OF bt-del DO:
    DEFINE VARIABLE lConf AS LOGICAL NO-UNDO.
    MESSAGE "Confirma a elimina��o do pedido " pedidos.CodPedido "?" 
        UPDATE lConf VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Elimina��o".
    IF lConf THEN DO:
        FIND bPed WHERE bPed.CodPedido = pedidos.CodPedido EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE bPed THEN DO:
            FOR EACH itens WHERE itens.CodPedido = bPed.CodPedido EXCLUSIVE-LOCK:
                DELETE itens.
            END.
            DELETE bPed.
            RUN piOpenQuery.
        END.
    END.
    GET LAST qPedidos.
    RUN pimostrar.
END.

ON 'leave' OF pedidos.CodCliente DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    RUN piValidaClientes (INPUT INTEGER(pedidos.CodCliente:SCREEN-VALUE), 
                          OUTPUT lValid).
    IF NOT lValid THEN DO:
        RETURN NO-APPLY.
    END.
    DISPLAY 
        bClientes.NomeCliente @ clientes.NomeCliente
        bClientes.CodEndereco @ clientes.CodEndereco
        bClientes.CodCidade @ clientes.CodCidade
        WITH FRAME f-pedidos.
    FIND bCidades WHERE bCidades.CodCidade = bClientes.CodCidade NO-LOCK NO-ERROR.
    DISPLAY bCidades.NomeCidade @ cidades.NomeCidade WITH FRAME f-pedidos.
END.

ON 'choose' OF bt-save DO:
    DEFINE VARIABLE lValid AS LOGICAL NO-UNDO.
    RUN piValidaClientes (INPUT INTEGER(pedidos.CodCliente:SCREEN-VALUE), 
                          OUTPUT lValid).
    IF NOT lValid THEN DO:
        RETURN NO-APPLY.
    END.
    IF cAction = "add" THEN DO:
        CREATE bPed.
        ASSIGN bPed.CodPedido = INPUT pedidos.CodPedido.
    END.
    IF cAction = "mod" THEN DO:
        FIND FIRST bPed WHERE bPed.CodPedido = pedidos.CodPedido EXCLUSIVE-LOCK NO-ERROR.
    END.
    ASSIGN 
        bPed.DataPedido = INPUT pedidos.DataPedido
        bPed.CodCliente = INPUT pedidos.CodCliente
        bPed.Observacao = INPUT pedidos.Observacao.
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN piOpenQuery.
    IF cAction = "add" THEN DO:
        GET LAST qPedidos.
        RUN pimostrar.
    END.
END.

ON 'choose' OF bt-canc DO:
    RUN piHabilitaBotoes (INPUT TRUE).
    RUN piHabilitaCampos (INPUT FALSE).
    RUN pimostrar.
END.

ON 'choose' OF bt-rel DO:
    DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.
    DEFINE FRAME f-cab HEADER
        "Relatorio de pedidos" AT 1
        TODAY FORMAT "99/99/9999" TO 130
        WITH PAGE-TOP WIDTH 132.
    DEFINE FRAME f-dados
        pedidos.CodPedido
        pedidos.DataPedido
        pedidos.CodCliente
        pedidos.Observacao
        WITH DOWN WIDTH 132.
    ASSIGN cArq = SESSION:TEMP-DIRECTORY + "pedidos.txt".
    OUTPUT TO VALUE(cArq) PAGE-SIZE 20 PAGED.
    VIEW FRAME f-cab.
    FOR EACH pedidos NO-LOCK:
        DISPLAY 
            pedidos.CodPedido
            pedidos.DataPedido
            pedidos.CodCliente
            pedidos.Observacao
            WITH FRAME f-dados.
    END.
    OUTPUT CLOSE.
    OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
END.

RUN piOpenQuery.
RUN piHabilitaBotoes (INPUT TRUE).
APPLY "choose" TO bt-pri.

VIEW FRAME f-pedidos.
WAIT-FOR WINDOW-CLOSE OF FRAME f-pedidos.

PROCEDURE piOpenItens:
    DEFINE INPUT PARAMETER pCodPedido AS INTEGER NO-UNDO.
    CLOSE QUERY qItens.
    OPEN QUERY qItens
        FOR EACH itens WHERE itens.CodPedido = pCodPedido NO-LOCK,
            EACH produtos WHERE produtos.CodProduto = itens.CodProduto NO-LOCK.
END PROCEDURE.

PROCEDURE pimostrar:
    IF AVAILABLE pedidos THEN DO:
        DISPLAY 
            pedidos.CodPedido
            pedidos.DataPedido
            pedidos.CodCliente
            pedidos.Observacao
            clientes.NomeCliente
            clientes.CodEndereco
            clientes.CodCidade
            cidades.NomeCidade
            WITH FRAME f-pedidos.
        RUN piOpenItens(INPUT pedidos.CodPedido).
        REPOSITION qItens TO ROW 1 NO-ERROR.
    END.
    ELSE DO:
        CLOSE QUERY qItens.
        CLEAR FRAME f-pedidos.
    END.
END PROCEDURE.

PROCEDURE piOpenQuery:
    DEFINE VARIABLE rRecord AS ROWID NO-UNDO.
    IF AVAILABLE pedidos THEN
        ASSIGN rRecord = ROWID(pedidos).
    OPEN QUERY qPedidos
        FOR EACH pedidos NO-LOCK,
            EACH clientes WHERE clientes.CodCliente = pedidos.CodCliente NO-LOCK,
            EACH cidades WHERE cidades.CodCidade = clientes.CodCidade NO-LOCK.
    REPOSITION qPedidos TO ROWID rRecord NO-ERROR.
END PROCEDURE.

PROCEDURE piHabilitaBotoes:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-pedidos:
        ASSIGN 
            bt-pri:SENSITIVE = pEnable
            bt-ant:SENSITIVE = pEnable
            bt-prox:SENSITIVE = pEnable
            bt-ult:SENSITIVE = pEnable
            bt-sair:SENSITIVE = pEnable
            bt-add:SENSITIVE = pEnable
            bt-mod:SENSITIVE = pEnable
            bt-del:SENSITIVE = pEnable
            bt-rel:SENSITIVE = pEnable
            bt-additem:SENSITIVE = pEnable
            bt-moditem:SENSITIVE = pEnable
            bt-delitem:SENSITIVE = pEnable
            bt-save:SENSITIVE = NOT pEnable
            bt-canc:SENSITIVE = NOT pEnable.
    END.
END PROCEDURE.

PROCEDURE piHabilitaCampos:
    DEFINE INPUT PARAMETER pEnable AS LOGICAL NO-UNDO.
    DO WITH FRAME f-pedidos:
        ASSIGN 
            pedidos.DataPedido:SENSITIVE = pEnable
            pedidos.CodCliente:SENSITIVE = pEnable
            pedidos.Observacao:SENSITIVE = pEnable.
    END.
END PROCEDURE.

PROCEDURE piValidaClientes:
    DEFINE INPUT PARAMETER pCodCliente AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER pValid AS LOGICAL NO-UNDO INITIAL NO.
    FIND FIRST bClientes WHERE bClientes.CodCliente = pCodCliente NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bClientes THEN DO:
        MESSAGE "Cliente " pCodCliente " n�o existe!" VIEW-AS ALERT-BOX ERROR.
        ASSIGN pValid = NO.
    END.
    ELSE 
        ASSIGN pValid = YES.
END PROCEDURE.
