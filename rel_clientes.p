DEFINE VARIABLE cArq AS CHARACTER NO-UNDO.

DEFINE FRAME f-cab HEADER
    "Relatório de Clientes Cadastrados" AT 1
    TODAY FORMAT "99/99/9999" TO 100 SKIP(1)
    WITH PAGE-TOP WIDTH 132.

DEFINE FRAME f-dados
    clientes.CodCliente    FORMAT ">>>>9"      AT 1
    clientes.NomeCliente   FORMAT "x(30)"       
    clientes.CodEndereco   FORMAT "x(25)"       
    cidades.NomeCidade     FORMAT "x(20)"       
    clientes.Observacao    FORMAT "x(20)"      
    WITH DOWN WIDTH 132 NO-BOX. 

ASSIGN cArq = SESSION:TEMP-DIRECTORY + "clientes.txt".

OUTPUT TO VALUE(cArq) PAGE-SIZE 80 PAGED.

VIEW FRAME f-cab.

FOR EACH clientes NO-LOCK,
    EACH cidades WHERE cidades.CodCidade = clientes.CodCidade NO-LOCK
    BREAK BY clientes.CodCliente:
    DISPLAY 
        clientes.CodCliente
        clientes.NomeCliente
        clientes.CodEndereco
        cidades.NomeCidade
        clientes.Observacao
        WITH FRAME f-dados.
    DOWN WITH FRAME f-dados. 
END.

OUTPUT CLOSE.

OS-COMMAND NO-WAIT VALUE("notepad.exe " + cArq).
