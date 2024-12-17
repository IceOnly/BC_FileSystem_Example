codeunit 50100 "FS Example"
{
    internal procedure StoreOrderConfirmation(SalesHeader: Record "Sales Header")
    var
        ExternalFileStorage: Codeunit "External File Storage";
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
        FilePath: Text;
    begin

        ExternalFileStorage.Initialize(Enum::"File Scenario"::"Order Confirmation");
        FilePath := ExternalFileStorage.SaveFile('', 'pdf');
        if FilePath = '' then
            exit;

        CreateOrderConfirmation(SalesHeader, TempBlob);
        TempBlob.CreateInStream(Stream);
        if not ExternalFileStorage.FileExists(FilePath) then
            ExternalFileStorage.CreateFile(FilePath, Stream);
    end;

    internal procedure LookupFolderToStore(var FoldertoStore: Text[2048])
    var
        ExternalFileStorage: Codeunit "External File Storage";
        NewFolder: Text;
    begin
        ExternalFileStorage.Initialize(Enum::"File Scenario"::"Order Confirmation");
        NewFolder := ExternalFileStorage.SelectAndGetFolderPath(FoldertoStore);
        if NewFolder = '' then
            exit;

        FoldertoStore := NewFolder;
    end;

    local procedure CreateOrderConfirmation(var SalesHeader: Record "Sales Header"; var TempBlob: Codeunit "Temp Blob")
    var
        ReportSelections: Record "Report Selections";
        Stream: OutStream;
        RecRef: RecordRef;
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
        ReportSelections.FindFirst();

        SalesHeader.SetRecFilter();
        RecRef.GetTable(SalesHeader);
        TempBlob.CreateOutStream(Stream);
        Report.SaveAs(ReportSelections."Report ID", '', ReportFormat::Pdf, Stream, RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnAfterManualReleaseSalesDoc, '', false, false)]
    local procedure OnAfterManualReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean);
    var
        FSSetup: Record "FS Setup";
        ExternalFileStorage: Codeunit "External File Storage";
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
        FilePath: Text;
        PDFNameLbl: Label 'OC_%1.pdf';
    begin
        if not FSSetup.Get() then
            exit;

        if not FSSetup.Enabled then
            exit;

        CreateOrderConfirmation(SalesHeader, TempBlob);
        TempBlob.CreateInStream(Stream);

        ExternalFileStorage.Initialize(Enum::"File Scenario"::"Order Confirmation");
        FilePath := ExternalFileStorage.CombinePath(FSSetup."Folder to Store", StrSubstNo(PDFNameLbl, SalesHeader."No."));
        if not ExternalFileStorage.FileExists(FilePath) then
            ExternalFileStorage.CreateFile(FilePath, Stream);
    end;
}