table 50100 "FS Setup"
{
    Caption = 'FS Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = ToBeClassified;
        }
        field(20; "Folder to Store"; Text[2048])
        {
            Caption = 'Folder to Store';
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                FSExample: Codeunit "FS Example";
            begin
                FSExample.LookupFolderToStore(Rec."Folder to Store");
            end;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
