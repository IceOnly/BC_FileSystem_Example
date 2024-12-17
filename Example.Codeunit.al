codeunit 50100 "FS Example"
{
    internal procedure StoreOrderConfirmation(SalesHeader: Record "Sales Header")
    var
        FileSystem: Codeunit "File System";
        TempBlob: Codeunit "Temp Blob";
        Stream: InStream;
        FilePath: Text;
    begin

        FileSystem.Initialize(Enum::"File Scenario"::"Order Confirmation");
        FilePath := FileSystem.SaveFile('', 'pdf');
        if FilePath = '' then
            exit;

        CreateOrderConfirmation(SalesHeader, TempBlob);
        TempBlob.CreateInStream(Stream);
        if not FileSystem.FileExists(FilePath) then
            FileSystem.CreateFile(FilePath, Stream);
    end;

    internal procedure LookupFolderToStore(var FoldertoStore: Text[2048])
    var
        FileSystem: Codeunit "File System";
        NewFolder: Text;
    begin
        FileSystem.Initialize(Enum::"File Scenario"::"Order Confirmation");
        NewFolder := FileSystem.SelectAndGetFolderPath(FoldertoStore);
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
        FileSystem: Codeunit "File System";
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

        FileSystem.Initialize(Enum::"File Scenario"::"Order Confirmation");
        FilePath := FileSystem.CombinePath(FSSetup."Folder to Store", StrSubstNo(PDFNameLbl, SalesHeader."No."));
        if not FileSystem.FileExists(FilePath) then
            FileSystem.CreateFile(FilePath, Stream);
    end;
}