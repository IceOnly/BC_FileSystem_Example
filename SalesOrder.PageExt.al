pageextension 50100 FSSalesOrder extends "Sales Order"
{
    actions
    {
        addfirst("&Order Confirmation")
        {
            action(SaveQuoteToFileAccount)
            {
                ApplicationArea = All;
                Caption = 'Save Order Confirmation';
                Ellipsis = true;
                Image = Save;

                trigger OnAction()
                var
                    Example: Codeunit "FS Example";
                begin
                    Example.StoreOrderConfirmation(Rec);
                end;
            }
        }
    }
}