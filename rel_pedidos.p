DEFINE VARIABLE cArq         AS CHARACTER NO-UNDO.
DEFINE VARIABLE dTotalPedido AS DECIMAL   NO-UNDO.
DEFINE VARIABLE iItemNum     AS INTEGER   NO-UNDO.
DEFINE VARIABLE lTemItens    AS LOGICAL   NO-UNDO.

ASSIGN cArq = SESSION:TEMP-DIRECTORY + "relatorio_pedidos.txt".

OUTPUT TO VALUE(cArq) PAGE-SIZE 60 PAGED.

FOR EACH clientes NO-LOCK,
    EACH pedidos WHERE pedidos.CodCliente = clientes.CodCliente NO-LOCK
    BREAK BY clientes.CodCliente:

    lTemItens = FALSE.
    FOR EACH itens WHERE itens.CodPedido = pedidos.CodPedido NO-LOCK:
        lTemItens = TRUE.
        LEAVE.
    END.
    IF NOT lTemItens THEN NEXT.

    ASSIGN
        dTotalPedido = 0
        iItemNum     = 1.

    FIND FIRST cidades NO-LOCK WHERE cidades.CodCidade = clientes.CodCidade NO-ERROR.

    PUT UNFORMATTED 
        "Pedido:   " pedidos.CodPedido FORMAT ">>9"
        "    Data: " pedidos.DataPedido FORMAT "99/99/9999" SKIP
        "Nome:     " clientes.CodCliente FORMAT ">>9" "- " clientes.NomeCliente SKIP
        "Endereco: " clientes.CodEndereco " - " (IF AVAILABLE cidades THEN cidades.NomeCidade ELSE "") SKIP
        "Observação: " pedidos.Observacao SKIP(2).

    PUT UNFORMATTED
        " Item    Produto                    Quantidade     Valor                Total" SKIP
        "-------- -------------------------  ----------    --------            --------" SKIP.

    FOR EACH itens WHERE itens.CodPedido = pedidos.CodPedido NO-LOCK,
        EACH produtos WHERE produtos.CodProduto = itens.CodProduto NO-LOCK:

        PUT UNFORMATTED
            iItemNum FORMAT ">>9" TO 5 SPACE(2)
            produtos.NomeProduto FORMAT "x(25)" TO 15 SPACE(3)
            itens.NumQuantidade FORMAT ">>9" TO 45 SPACE(5)
            produtos.ValProduto FORMAT ">>>,>>9.99" TO 60
            itens.ValTotal FORMAT ">>>,>>9.99" TO 75 SKIP(1).

        ASSIGN
            dTotalPedido = dTotalPedido + itens.ValTotal
            iItemNum     = iItemNum + 1.
    END.

    PUT UNFORMATTED
        "Total Pedido = " dTotalPedido FORMAT ">>>,>>9.99" SKIP(3).
END.

OUTPUT CLOSE.

OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
