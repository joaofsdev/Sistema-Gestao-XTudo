CURRENT-WINDOW:WIDTH = 251.

DEFINE BUTTON bt-cidades LABEL "Cidades" SIZE 15 BY 1.
DEFINE BUTTON bt-produtos LABEL "Produtos" SIZE 15 BY 1.
DEFINE BUTTON bt-clientes LABEL "Clientes" SIZE 15 BY 1.
DEFINE BUTTON bt-pedidos LABEL "Pedidos" SIZE 15 BY 1.
DEFINE BUTTON bt-sair LABEL "Sair" AUTO-ENDKEY SIZE 15 BY 1.
DEFINE BUTTON bt-relclientes LABEL "Relatorio de Clientes" SIZE 25 BY 1.     
DEFINE BUTTON bt-relpedidos LABEL "Relatorio de Pedidos" SIZE 25  BY 1.

DEFINE FRAME f-menu
    bt-cidades AT 10
    bt-produtos
    bt-clientes 
    bt-pedidos
    bt-sair SKIP (0.2)
    bt-relclientes AT 10
    bt-relpedidos
    WITH SIDE-LABELS THREE-D SIZE 100 BY 4
    VIEW-AS DIALOG-BOX TITLE "Hamburgueria XTudo".
    
    ON 'choose' OF bt-cidades 
    DO:
        RUN c:\Xtudo\cidades.p.
    END.
    
    ON 'choose' OF bt-produtos
    DO:
        RUN c:\Xtudo\produtos.p.
    END.
    
    ON 'choose' OF bt-clientes
    DO:
        RUN c:\Xtudo\clientes.p.
    END.
    
    ON 'choose' OF bt-pedidos 
    DO:
        RUN c:\Xtudo\pedidos.p.
    END.
    
    ON 'choose' OF bt-relclientes
    DO:
        RUN c:\Xtudo\rel_clientes.p.
    END.
    
    ON 'choose' OF bt-relpedidos
    DO:
        RUN c:\Xtudo\rel_pedidos.p.
    END.
                  
ENABLE ALL WITH FRAME f-menu.
WAIT-FOR WINDOW-CLOSE OF FRAME f-menu.
