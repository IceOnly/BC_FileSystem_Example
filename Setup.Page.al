page 50100 "FS Setup"
{
    ApplicationArea = All;
    Caption = 'FS Setup';
    PageType = Card;
    SourceTable = "FS Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
                field("Folder to Store"; Rec."Folder to Store")
                {
                    ToolTip = 'Specifies the value of the Folder to Store field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}
