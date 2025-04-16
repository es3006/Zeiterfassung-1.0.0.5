unit uFunktionen;

interface

uses
  Windows, SysUtils, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, System.Zip, StdCtrls, ComCtrls, ExtCtrls, DateUtils, ShellApi,
  FileCtrl, System.UITypes, CryptBase, AESObj, MMSystem, System.IOUtils,
  VCL.FlexCel.Core, FlexCel.XlsAdapter, Vcl.Imaging.pngimage,
  IdHTTP, System.JSON, IdSSLOpenSSL, System.Generics.Collections,
  IdIcmpClient, IdGlobal;


function SubtractOneSecond(TimeStr: string): string;
function InternetErreichbar(): boolean;
function CheckListViewColumnForStrings(ListView: TListView; ColumnIndex: Integer): Boolean;
function IsValidNumber(const S: string): Boolean;
function GetWertAusZelle(const Zellbezeichner: String; const Xls: TXlsFile): Variant;
function IsXlsFile(const FileName: string): Boolean;
procedure PlayResourceMP3(ResEntryName, TempFileName: string);
procedure SaveResourceToFile(ResourceName, FileName: string);
procedure LoadImageFromResource(const ResourceName: string; TargetImage: TImage);
function ExcelColumnToIndex(const Column: string): Integer;
function IndexToExcelColumn(Index: Integer): string;
procedure ZipDir(const Dir: string);
function ConvertGermanDateToSQLDate(const GermanDate: string; ShowTime: boolean = false): string;
function ConvertSQLDateToGermanDate(const SQLDate: string; ShowTime: boolean = true; ShortYear: boolean = false): string;
function ReplaceUmlauteWithHtmlEntities(const InputString: string): string;
function DeleteFiles(const AFile: string): boolean;
function IsFileZeroSize(const FileName: string): Boolean;
procedure ReadExcelRange(const FileName: string; const StartRow, StartCol, EndRow, EndCol: Integer; Output: TStrings);
function CountEntriesInColumnB(Xls: TXlsFile; StartRow, EndRow: Integer): Integer;
//procedure CheckWebsiteReachability;
function IsWebsiteReachable(const URL: string): Boolean;


implementation

uses
  uMain;



function SubtractOneSecond(TimeStr: string): string;
var
  TimeValue: TDateTime;
begin
  // String in TDateTime umwandeln
  TimeValue := StrToTime(TimeStr);

  // Eine Sekunde abziehen
  TimeValue := TimeValue - EncodeTime(0, 0, 1, 0);

  // Ergebnis zurückgeben
  Result := FormatDateTime('hh:nn:ss', TimeValue);
end;




function InternetErreichbar(): boolean;
var
  ICMP: TIdIcmpClient;
begin
  ICMP := TIdIcmpClient.Create(nil);
  try
    ICMP.Host := '8.8.8.8'; // Google's DNS-Server
    ICMP.ReceiveTimeout := 500; // Timeout in Millisekunden (1 Sekunde)
    try
      ICMP.Ping;
      if ICMP.ReplyStatus.ReplyStatusType = rsEcho then
        result := true
      else
        result := false;
    except
      on E: Exception do
        result := false;
    end;
  finally
    ICMP.Free;
  end;
end;



function CheckListViewColumnForStrings(ListView: TListView; ColumnIndex: Integer): Boolean;
var
  i: Integer;
  Value: string;
begin
  Result := False; // Voraussetzen, dass keine ungültigen Einträge vorhanden sind

  for i := 0 to ListView.Items.Count - 1 do
  begin
    // Wert aus der gewünschten Spalte holen
    if ColumnIndex = 0 then
      Value := ListView.Items[i].Caption
    else
      Value := ListView.Items[i].SubItems[ColumnIndex - 1];

    // Überflüssige Leerzeichen entfernen
    Value := Trim(Value);

    // Überprüfen, ob der Wert leer ist
    if Value = '' then
    begin
      ShowMessage('Die Zeiterfassung kann nicht exportiert werden.'+#13#10+'Es befinden sich leere Einträge anstatt der PersonalNr in Spalte Mitarbeitter');
      Result := True; // Ungültiger Eintrag gefunden
      fMain.cbBlattnamenSelect(nil);
      Exit; // Funktion verlassen
    end;

    // Überprüfen, ob der Wert numerisch ist
    if not IsValidNumber(Value) then
    begin
      ShowMessage('Die Zeiterfassung kann nicht exportiert werden.'+#13#10+#13#10+
                  'Es befinden sich noch Mitarbeiternamen anstatt der PersonalNr in der Liste.'+#13#10+#13#10+
                  'Bitte prüfen Sie ob der Name aus der Liste in der Mitarbeiterliste unter "Einstellungen->Mitarbeiter" vorhanden ist.'+#13#10+#13#10+'Fügen Sie diesen Mitarbeiter bei Bedarf zur Mitarbeiterliste hinzu und öffnen Sie diesen Dienstplan erneut!');
      Result := True; // Ungültiger Eintrag gefunden
      fMain.cbBlattnamenSelect(nil);
      Exit; // Funktion verlassen
    end;
  end;
end;






function IsValidNumber(const S: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(S) do
  begin
    if not CharInSet(S[i], ['0'..'9']) then
    begin
      Result := False;
      Break;
    end;
  end;
end;





function GetWertAusZelle(const Zellbezeichner: String; const Xls: TXlsFile): Variant;
var
  Zeile: Integer;
  Spalte: Integer;
  i: Integer;
  SpaltenBuchstaben: String;
begin
  // Spaltenbuchstaben extrahieren
  SpaltenBuchstaben := '';
  for i := 1 to Length(Zellbezeichner) do
  begin
    if CharInSet(Zellbezeichner[i], ['0'..'9']) then
      Break
    else
      SpaltenBuchstaben := SpaltenBuchstaben + Zellbezeichner[i];
  end;

  // Zeile extrahieren (Zahlen am Ende)
  Zeile := StrToInt(Copy(Zellbezeichner, Length(SpaltenBuchstaben) + 1, Length(Zellbezeichner)));

  // Berechnung des Spaltenindex
  Spalte := 0;
  for i := 1 to Length(SpaltenBuchstaben) do
  begin
    Spalte := Spalte * 26 + (Ord(UpperCase(SpaltenBuchstaben[i])[1]) - Ord('A') + 1);
  end;

  // Wert aus der Zelle zurückgeben (beachte, dass FlexCel 1-basierte Indizes verwendet)
  Result := Xls.GetCellValue(Zeile, Spalte); // Keine Anpassung mehr notwendig, da FlexCel 1-basiert arbeitet
end;









function IsXlsFile(const FileName: string): Boolean;
var
  FileExt: string;
begin
  // Hole die Dateiendung
  FileExt := ExtractFileExt(FileName);

  // Prüfe, ob die Dateiendung ".xlsx" oder ".xlsm" ist (unempfindlich gegenüber Groß-/Kleinschreibung)
  Result := SameText(FileExt, '.xlsx') or SameText(FileExt, '.xlsm') or SameText(FileExt, '.xls');
end;



procedure PlayResourceMP3(ResEntryName, TempFileName: string);
var
  ResStream: TResourceStream;
  MemStream: TMemoryStream;
begin
  // Prüfen, ob die Datei bereits vorhanden ist
  if not FileExists(TempFileName) then
  begin
    // Datei aus der Resource holen und speichern
    ResStream := TResourceStream.Create(HInstance, ResEntryName, RT_RCDATA);
    try
      MemStream := TMemoryStream.Create;
      try
        MemStream.LoadFromStream(ResStream);
        MemStream.SaveToFile(TempFileName);
      finally
        MemStream.Free;
      end;
    finally
      ResStream.Free;
    end;
  end;

  // Datei abspielen
  PlaySound(PChar(TempFileName), 0, SND_FILENAME or SND_ASYNC);
end;



procedure SaveResourceToFile(ResourceName, FileName: string);
var
  ResStream: TResourceStream;
  FileStream: TFileStream;
begin
  if not FileExists(FileName) then
  begin
    ResStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA); // RT_RCDATA ist ein gängiger Typ für benutzerdefinierte Ressourcen
    try
      FileStream := TFileStream.Create(FileName, fmCreate);
      try
        FileStream.CopyFrom(ResStream, 0); // Kopiere den Ressourceninhalt in die Datei
      finally
        FileStream.Free;
      end;
    finally
      ResStream.Free;
    end;
  end;
end;




procedure LoadImageFromResource(const ResourceName: string; TargetImage: TImage);
var
  ResourceStream: TResourceStream;
  PngImage: TPngImage;
begin
  // Erstelle den Stream, um die angegebene Ressource zu laden
  ResourceStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    // Erstelle ein TPngImage-Objekt, um die PNG-Daten zu laden
    PngImage := TPngImage.Create;
    try
      // Lade die PNG-Daten aus dem Stream in das TPngImage-Objekt
      PngImage.LoadFromStream(ResourceStream);
      // Weise das geladene Bild der angegebenen TImage-Komponente zu
      TargetImage.Picture.Graphic := PngImage;
    finally
      PngImage.Free;
    end;
  finally
    ResourceStream.Free;
  end;
end;




//Beispiel: Column = B, Index = 2
function ExcelColumnToIndex(const Column: string): Integer;
var
  i, Len, Pos: Integer;
begin
  Result := 0;
  Len := Length(Column);
  for i := 1 to Len do
  begin
    Pos := Ord(UpCase(Column[i])) - Ord('A') + 1;
    Result := Result * 26 + Pos;
  end;
end;


//Beispiel: Index = 2, Column = B
function IndexToExcelColumn(Index: Integer): string;
var
  Remainder: Integer;
begin
  Result := '';
  while Index > 0 do
  begin
    Remainder := (Index - 1) mod 26;
    Result := Char(Ord('A') + Remainder) + Result;
    Index := (Index - 1) div 26;
  end;
end;





procedure ZipDir(const Dir: string);
var
  ZipFile: TZipFile;
  SearchRec: TSearchRec;
  FilePath: string;
  FullDirPath: string;
begin
  // Sicherstellen, dass der Pfad ohne zusätzliche Leerzeichen oder ungültige Zeichen ist
  FullDirPath := Trim(Dir);

  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(FullDirPath + '.zip', zmWrite);

    // Verzeichnisinhalt durchsuchen und Dateien zur Zip-Datei hinzufügen
    if FindFirst(IncludeTrailingPathDelimiter(FullDirPath) + '*.sql', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        FilePath := IncludeTrailingPathDelimiter(FullDirPath) + SearchRec.Name;
        ZipFile.Add(FilePath, ExtractFileName(FilePath));
      until FindNext(SearchRec) <> 0;
      FindClose(SearchRec);
    end;

    ZipFile.Close;
  finally
    ZipFile.Free;
  end;

  // Nach erfolgreicher Zip-Erstellung Verzeichnis löschen
  if SysUtils.DirectoryExists(FullDirPath) then
    TDirectory.Delete(FullDirPath, True);
end;







function IsFileZeroSize(const FileName: string): Boolean;
var
  FileInfo: TSearchRec;
begin
  Result := False;
  if FindFirst(FileName, faAnyFile, FileInfo) = 0 then
  try
    Result := FileInfo.Size = 0;
  finally
    FindClose(FileInfo);
  end;
end;







// Funktion zum Ersetzen von Umlauten durch HTML-Entities
function ReplaceUmlauteWithHtmlEntities(const InputString: string): string;
begin
  // Ersetzen Sie die Umlaute durch die entsprechenden HTML-Entities
  Result := StringReplace(InputString, 'ä', '&auml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ä', '&Auml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ö', '&ouml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ö', '&Ouml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ü', '&uuml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'Ü', '&Uuml;', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'ß', '&szlig;', [rfReplaceAll, rfIgnoreCase]);
end;






function DeleteFiles(const AFile: string): boolean;
var
  sh: SHFileOpStruct;
begin
  ZeroMemory(@sh, SizeOf(sh));
  with sh do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := PChar(AFile +#0);
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  result := SHFileOperation(sh) = 0;
end;










{
  Aktuelle Version um ein deutsches Dateum im Format DD.MM.YY oder DD.MM.YYYY HH:NN:SS in ein
  SQL-Datum im Format YYYY-MM-DD oder YYYY-MM-DD HH:NN:SS umzuwandeln

  Aufruf mit
  ConvertGermanDateToSQLDate('30.06.1975'); //Nur Datum
  ConvertGermanDateToSQLDate('30.06.1975 10:30:20'); //Datum und Zeit
}
function ConvertGermanDateToSQLDate(const GermanDate: string; ShowTime: boolean = false): string;
var
  DateValue: TDateTime;
  FormatedDate: string;
begin
  if(GermanDate = '') then
  begin
    result := '';
    exit;
  end;

  // Prüfen und Konvertieren des Datumsformats von DD.MM.YYYY HH:NN:SS zu einem TDateTime-Wert
  if TryStrToDateTime(GermanDate, DateValue, FormatSettings) then
  begin
    if(ShowTime = true) then
      FormatedDate := FormatDateTime('yyyy-mm-dd hh:nn', DateValue, FormatSettings)
    else
      FormatedDate := FormatDateTime('yyyy-mm-dd', DateValue, FormatSettings);

    Result := FormatedDate;
  end
  else
  begin
    // Bei Fehler wird ein leerer String zurückgegeben
    Result := '';
    ShowMessage('Ungültiges Datumsformat: ' + GermanDate);
    abort;
  end;
end;







function ConvertSQLDateToGermanDate(const SQLDate: string; ShowTime: boolean = true; ShortYear: boolean = false): string;
var
  DateValue: TDateTime;
  FormattedDate: string;
  FormatSettings: TFormatSettings;
begin
  // Spezifische FormatSettings für die Konvertierung von Datums- und Zeitwerten konfigurieren
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DateSeparator   := '-';
  FormatSettings.TimeSeparator   := ':';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FormatSettings.LongTimeFormat  := 'hh:nn:ss';

  if(SQLDate = '') then
  begin
    result := '';
    exit;
  end;
  // Konvertieren des Datumsformats von YYYY-MM-DD HH:NN:SS zu einem TDateTime-Wert
  if TryStrToDateTime(SQLDate, DateValue, FormatSettings) then
  begin
    // Spezifische FormatSettings für die deutsche Schreibweise konfigurieren
    FormatSettings.DateSeparator   := '.';
    FormatSettings.ShortDateFormat := 'dd.mm.yyyy';
    FormatSettings.LongTimeFormat  := 'hh:nn';

    // Das Datum im Format DD.MM.YYYY HH:NN formatiert
    if(ShowTime = true) then
      FormattedDate := FormatDateTime('dd.mm.yyyy hh:nn', DateValue, FormatSettings)
    else
      FormattedDate := FormatDateTime('dd.mm.yyyy', DateValue, FormatSettings);

    // Das Datum im Format DD.MM.YY formatiert
    if(ShortYear = true) then
      FormattedDate := FormatDateTime('dd.mm.yy', DateValue, FormatSettings)
    else
      FormattedDate := FormatDateTime('dd.mm.yyyy', DateValue, FormatSettings);



    Result := FormattedDate;
  end
  else
  begin
    // Bei Fehler wird ein leerer String zurückgegeben
    Result := '';
    ShowMessage('Ungültiges Datumsformat: ' + SQLDate);
    Abort;
  end;
end;






procedure ReadExcelRange(const FileName: string; const StartRow, StartCol, EndRow, EndCol: Integer; Output: TStrings);
var
  xls: TXlsFile;
  Row, Col: Integer;
  CellValue: string;
  RowOutput: string;
  IsRowEmpty: Boolean;
begin
  xls := TXlsFile.Create;
  try
    xls.Open(FileName);
    xls.ActiveSheetByName := selSheet;

    for Row := StartRow to EndRow do
    begin
      RowOutput := '';
      IsRowEmpty := True; // Angenommen, die Zeile ist leer

      for Col := StartCol to EndCol do
      begin
        CellValue := xls.GetCellValue(Row, Col).ToString;
        if Trim(CellValue) <> '' then
          IsRowEmpty := False; // Zeile enthält nicht-leere Zellen

        if Col = StartCol then
          RowOutput := CellValue
        else
          RowOutput := RowOutput + #9 + CellValue; // Tabulator als Trenner
      end;

      // Entfernen von Leerzeichen am Ende der Zeile
      RowOutput := TrimRight(RowOutput);

      // Füge die Zeile nur hinzu, wenn sie nicht leer ist
      if not IsRowEmpty then
      begin
        Output.Add(RowOutput);
      end;
    end;
  finally
    xls.Free;
  end;
end;




//Anzahl EInträge in der Exceldatei in einem bestimmten Bereich ermitteln
function CountEntriesInColumnB(Xls: TXlsFile; StartRow, EndRow: Integer): Integer;
var
  Row: Integer;
  CellValue: TCellValue;
  Count: Integer;
begin
  Count := 0;

  // Durchlaufe die Zeilen von StartRow bis EndRow in Spalte B
  for Row := StartRow to EndRow do
  begin
    CellValue := Xls.GetCellValue(Row, SPALTEMA); // Spalte B ist die 2. Spalte

    // Prüfe, ob die Zelle einen Wert enthält (kein leerer String oder Leerwert)
    if not CellValue.IsEmpty then
    begin
      Inc(Count);
    end;
  end;

  Result := Count;
end;








{procedure CheckWebsiteReachability;
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  HTTP.IOHandler := SSLHandler;

  try
    // URL der Website, die überprüft werden soll
    HTTP.Head('https://esd.developercorner.de/Scripts/getDienstplanKoordinatenFromWeb.php');
    // Falls erfolgreich, ist die Website erreichbar
    WEBSITEREACHABILITY := True;
  except
    on E: EIdHTTPProtocolException do
    begin
      ShowMessage('Website ist nicht erreichbar. HTTP-Fehler: ' + IntToStr(E.ErrorCode) + ' - ' + E.Message);
      WEBSITEREACHABILITY := False;
    end;
    on E: Exception do
    begin
      ShowMessage('Fehler beim Prüfen der Website: ' + E.Message);
      WEBSITEREACHABILITY := False;
    end;
  end;

  // Ressourcen freigeben
  HTTP.Free;
  SSLHandler.Free;
end;
}




function IsWebsiteReachable(const URL: string): Boolean;
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := False;  // Standardmäßig auf False setzen
  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    HTTP.IOHandler := SSLHandler;

    try
      // Sende eine Head-Anfrage an die angegebene URL
      HTTP.Head(URL);
      Result := True;  // Wenn keine Ausnahme auftritt, ist die Seite erreichbar
    except
      on E: Exception do
      begin
        Result := False;  // Ausnahme bedeutet, dass die Seite nicht erreichbar ist
      end;
    end;

  finally
    HTTP.Free;
    SSLHandler.Free;
  end;
end;




end.
