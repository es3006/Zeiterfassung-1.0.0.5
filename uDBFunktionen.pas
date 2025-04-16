unit uDBFunktionen;

interface

uses
  Windows, Classes, Forms, SysUtils, Vcl.StdCtrls, Vcl.ComCtrls, Dialogs, Controls, ExtCtrls, DateUtils,
  Graphics, StrUtils, ShellApi, System.UITypes, System.Zip, System.IOUtils,
  FireDAC.Stan.Param, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;


type
  TSchichtData = record
    Einsatz: string;
    Leistungsart: string;
    VertragsNr: string;
    UhrzeitVon: string;
    UhrzeitBis: string;
  end;


procedure CreateDatabaseTables;
procedure ReadSettingsFromDB;
procedure BackupSQLiteTable(const TableName: string; const BackupDir: string);
procedure BackupAllTables;
procedure ImportSQLiteTable(const SQLFileName: string);
procedure ExtractAndImportSQLFiles(const ZipFileName, TargetDir: string);
procedure LoadSettingsFromDB;
function GetSchichtData(Schicht: string): TSchichtData;
function SchichtExists(Schicht: string): Boolean;
procedure deleteAllMitarbeiter;
procedure deleteAllLegende;


implementation

uses
  uMain, uFunktionen;





procedure deleteAllMitarbeiter;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Alle Mitarbeiter löschen
    FDQuery.SQL.Text := 'DELETE FROM mitarbeiter';
    try
      FDQuery.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Fehler beim Löschen der Mitarbeiter: ' + E.Message);
    end;
  finally
    FDQuery.Free;
  end;
end;






procedure deleteAllLegende;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Alle Mitarbeiter löschen
    FDQuery.SQL.Text := 'DELETE FROM legende';
    try
      FDQuery.ExecSQL;
    except
      on E: Exception do
        ShowMessage('Fehler beim Löschen der Legende: ' + E.Message);
    end;
  finally
    FDQuery.Free;
  end;
end;







procedure CreateDatabaseTables;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Prüfen, ob die Tabelle 'einstellungen' existiert
    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="einstellungen"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      // Tabelle 'einstellungen' erstellen
      FDQuery.SQL.Text := '''
        CREATE TABLE einstellungen
        (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          Exceldatei TEXT,
          ExcelMaSpalte INTEGER,
          ExcelDienstSpalteVon INTEGER,
          ExcelDienstSpalteBis INTEGER,
          ExcelZeileVon INTEGER,
          ExcelZeileBis INTEGER,
          ExcelBemerkungenSpalteVon INTEGER,
          ExcelBemerkungenSpalteBis INTEGER,
          ExcelBemerkungenZeileVon INTEGER,
          ExcelBemerkungenZeileBis INTEGER,
          ZelleMonatsname TEXT,
          ZelleJahreszahl TEXT,
          Objektname TEXT,
          ObjektNr TEXT
        );
      ''';
      FDQuery.ExecSQL;

      // Leeren Eintrag in die Tabelle 'einstellungen' einfügen
      FDQuery.SQL.Text := 'INSERT INTO einstellungen (Exceldatei, ExcelMaSpalte, ExcelDienstSpalteVon, ' +
                          'ExcelDienstSpalteBis, ExcelZeileVon, ExcelZeileBis, ExcelBemerkungenSpalteVon, ' +
                          'ExcelBemerkungenSpalteBis, ExcelBemerkungenZeileVon, ExcelBemerkungenZeileBis, ' +
                          'ZelleMonatsname, ZelleJahreszahl, Objektname, ObjektNr) ' +
                          'VALUES (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)';
      FDQuery.ExecSQL;
    end;

    // Prüfen, ob die Tabelle 'legende' existiert
    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="legende"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      // Tabelle 'legende' erstellen
      FDQuery.SQL.Text := 'CREATE TABLE legende (' +
                          'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                          'schicht TEXT, ' +
                          'einsatz TEXT, ' +
                          'leistungsart TEXT, ' +
                          'vertragsnr TEXT, ' +
                          'beschreibung TEXT, ' +
                          'UhrzeitVon TEXT, ' +
                          'UhrzeitBis TEXT);';
      FDQuery.ExecSQL;
    end;

    // Prüfen, ob die Tabelle 'mitarbeiter' existiert
    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type="table" AND name="mitarbeiter"';
    FDQuery.Open();
    if not FDQuery.IsEmpty then
      Exit
    else
    begin
      // Tabelle 'mitarbeiter' erstellen
      FDQuery.SQL.Text := '''
        CREATE TABLE mitarbeiter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personalnr TEXT,
        nachname TEXT NOT NULL,
        vorname TEXT NOT NULL);
      ''';
      FDQuery.ExecSQL;
    end;

  finally
    FDQuery.Free;
  end;
end;













procedure ReadSettingsFromDB;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    try
      FDQuery.Connection := fMain.FDConnection1;

      FDQuery.SQL.Text := 'SELECT ExcelMaSpalte, ExcelDienstSpalteVon, ExcelDienstSpalteBis, ExcelZeileVon, ExcelZeileBis, ZelleMonatsname, ZelleJahreszahl, Objektname;';

      FDQuery.Open;

      if not FDQuery.IsEmpty then
      begin
        ZEILEVON  := FDQuery.FieldByName('ExcelZeileVon').AsInteger;
        ZEILEBIS  := FDQuery.FieldByName('ExcelZeileBis').AsInteger;
        SPALTEMA  := FDQuery.FieldByName('ExcelMaSpalte').AsInteger;
        SPALTEVON := FDQuery.FieldByName('ExcelDienstSpalteVon').AsInteger;
        SPALTEBIS := FDQuery.FieldByName('ExcelDienstSpalteBis').AsInteger;
        ZELLEMONATSNAME := FDQuery.FieldByName('ZelleMonatsname').AsString;
        ZELLEJAHRESZAHL := FDQuery.FieldByName('ZelleJahreszahl').AsString;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Fehler beim Lesen der Einstellungen aus der Datenbank: ' + E.Message);
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;







procedure BackupAllTables;
var
  FDQuery: TFDQuery;
  TableNames: TStringList;
  i: Integer;
  BackupDir: string;
begin
  TableNames := TStringList.Create;
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;
    FDQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name NOT LIKE ''sqlite_%'';';
    FDQuery.Open;

    while not FDQuery.Eof do
    begin
      TableNames.Add(FDQuery.Fields[0].AsString);
      FDQuery.Next;
    end;

    // Erzeuge das Verzeichnis für das aktuelle Datum
    BackupDir := IncludeTrailingPathDelimiter(PATH + 'DBDUMPS') + FormatDateTime('DDMMYYYY', Now);
    if not DirectoryExists(BackupDir) then
    begin
      if not ForceDirectories(BackupDir) then
      begin
        ShowMessage('Fehler beim Erstellen des Verzeichnisses ' + BackupDir);
        Exit;
      end;
    end;

    // Sichere jede Tabelle in das entsprechende Verzeichnis
    for i := 0 to TableNames.Count - 1 do
    begin
      BackupSQLiteTable(TableNames[i], BackupDir);
    end;

    // Packe das Verzeichnis am Ende des Vorgangs
    ZipDir(BackupDir);
  finally
    FDQuery.Free;
    TableNames.Free;
  end;
end;







procedure BackupSQLiteTable(const TableName: string; const BackupDir: string);
var
  FDQuery: TFDQuery;
  SQLFile: TStringList;
  FileName: string;
  i: integer;
  Field: TField;
  FieldType: string;
  InsertSQL, CreateTableSQL: string;
begin
  FDQuery := TFDquery.Create(nil);
  SQLFile := TStringList.Create;
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      SQL.Text := Format('SELECT * FROM %s', [TableName]);
      Open;

      // Erzeuge die CREATE TABLE-Anweisung
      CreateTableSQL := Format('DROP TABLE IF EXISTS %s; CREATE TABLE %s (', [TableName, TableName]);
      for i := 0 to FDQuery.FieldCount - 1 do
      begin
        Field := FDQuery.Fields[i];

        // Überprüfen, ob es sich um die id-Spalte handelt
        if (Field.FieldName = 'id') and (Field.DataType in [ftInteger, ftAutoInc]) then
          FieldType := 'INTEGER PRIMARY KEY AUTOINCREMENT'
        else
        begin
        case Field.DataType of
            ftString, ftMemo, ftWideString, ftWideMemo:
              FieldType := 'TEXT';
            ftInteger, ftSmallint, ftWord, ftAutoInc:
              FieldType := 'INTEGER';
            ftFloat, ftCurrency, ftBCD:
              FieldType := 'REAL';
            ftDate, ftTime, ftDateTime, ftTimeStamp:
              FieldType := 'TEXT'; // SQLite speichert Datumswerte als TEXT
            else
              FieldType := 'BLOB';
          end;
        end;

        if i > 0 then
          CreateTableSQL := CreateTableSQL + ', ';

        CreateTableSQL := CreateTableSQL + Format('%s %s', [Field.FieldName, FieldType]);
      end;
      CreateTableSQL := CreateTableSQL + ');';
      SQLFile.Add(CreateTableSQL);

      // Füge die INSERT-Anweisungen hinzu
      FDQuery.First;
      while not FDQuery.Eof do
      begin
        InsertSQL := Format('INSERT INTO %s VALUES (', [TableName]);
        for i := 0 to FDQuery.FieldCount - 1 do
        begin
          if i > 0 then
            InsertSQL := InsertSQL + ', ';

          if FDQuery.Fields[i].IsNull then
            InsertSQL := InsertSQL + 'NULL'
          else
            InsertSQL := InsertSQL + QuotedStr(FDQuery.Fields[i].AsString);
        end;
        InsertSQL := InsertSQL + ');';
        SQLFile.Add(InsertSQL);
        FDQuery.Next;
      end;

      // Speichere die SQL-Anweisungen in einer Datei
      FileName := Format('%s.sql', [TableName]);
      SQLFile.SaveToFile(IncludeTrailingPathDelimiter(BackupDir) + FileName);
    end;
  finally
    FDQuery.Free;
    SQLFile.Free;
  end;
end;
















procedure ImportSQLiteTable(const SQLFileName: string);
var
  FDQuery: TFDQuery;
  SQLFile: TStringList;
  TableName, InsertSQL: string;
  HighestID: Integer;
begin
  FDQuery := TFDQuery.Create(nil);
  SQLFile := TStringList.Create;
  try
    // 1. Lade die SQL-Datei
    SQLFile.LoadFromFile(SQLFileName);

    // 2. Extrahiere den Tabellennamen aus der CREATE TABLE-Anweisung
    TableName := '';
    if SQLFile.Count > 0 then
    begin
      InsertSQL := SQLFile[0];
      if Pos('CREATE TABLE ', InsertSQL) = 1 then
      begin
        InsertSQL := Copy(InsertSQL, 14, MaxInt);
        TableName := Copy(InsertSQL, 1, Pos(' ', InsertSQL) - 1);
      end;
    end;

    // 3. Führe die SQL-Befehle aus
    FDQuery.Connection := fMain.FDConnection1;
    FDQuery.SQL.Text := SQLFile.Text;
    FDQuery.ExecSQL;

    // 4. Optional: Aktualisiere sqlite_sequence
    if TableName <> '' then
    begin
      FDQuery.SQL.Text := Format('SELECT MAX(id) FROM %s', [TableName]);
      FDQuery.Open;
      HighestID := FDQuery.Fields[0].AsInteger;

      FDQuery.SQL.Text := 'INSERT OR REPLACE INTO sqlite_sequence (name, seq) VALUES (:TableName, :Seq)';
      FDQuery.Params.ParamByName('TableName').AsString := TableName;
      FDQuery.Params.ParamByName('Seq').AsInteger := HighestID;
      FDQuery.ExecSQL;
    end;
  finally
    FDQuery.Free;
    SQLFile.Free;
  end;
end;





procedure ExtractAndImportSQLFiles(const ZipFileName, TargetDir: string);
var
  ZipFile: TZipFile;
  ArchiveDir: string;
  SQLFiles: TStringList;
  SQLQuery: TFDQuery;
  SQLFileContent: TStringList;
  i: Integer;
begin
  ZipFile := TZipFile.Create;
  SQLFiles := TStringList.Create;
  SQLQuery := TFDQuery.Create(nil);
  SQLFileContent := TStringList.Create;

  try
    ZipFile.Open(ZipFileName, zmRead);

    // Extrahiere alle SQL-Dateien aus dem Zip-Archiv
    for i := 0 to ZipFile.FileCount - 1 do
    begin
      if SameText(ExtractFileExt(ZipFile.FileNames[i]), '.sql') then
      begin
        ArchiveDir := IncludeTrailingPathDelimiter(TargetDir);
        ZipFile.Extract(ZipFile.FileNames[i], ArchiveDir);
        SQLFiles.Add(ArchiveDir + ExtractFileName(ZipFile.FileNames[i]));
      end;
    end;

    // Verbinde mit der SQLite-Datenbank
    SQLQuery.Connection := fMain.FDConnection1;
    SQLQuery.Connection.Open;

    // Lese jede SQL-Datei ein und führe den Inhalt aus
    for i := 0 to SQLFiles.Count - 1 do
    begin
      SQLFileContent.LoadFromFile(SQLFiles[i]);

      SQLQuery.SQL.Text := SQLFileContent.Text;
      SQLQuery.ExecSQL;
    end;

    ShowMessage('Import abgeschlossen.');

  finally
    ZipFile.Free;
    SQLFiles.Free;
    SQLQuery.Free;
    SQLFileContent.Free;
  end;
end;






procedure LoadSettingsFromDB;
var
  FDQuery: TFDQuery;
begin
  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := '''
        SELECT Exceldatei, ExcelMaSpalte, ExcelDienstSpalteVon, ExcelDienstSpalteBis,
        ExcelZeileVon, ExcelZeileBis, ExcelBemerkungenSpalteVon, ExcelBemerkungenSpalteBis,
        ExcelBemerkungenZeileVon, ExcelBemerkungenZeileBis, ZelleMonatsname,
        ZelleJahreszahl, Objektname, ObjektNr FROM einstellungen;
      ''';
      Open;

      if(not FDQuery.IsEmpty) then
      begin
        OBJEKTNAME     := FieldByName('objektname').AsString;
        EXCELDATEI     := FieldByName('Exceldatei').AsString;
        ZEILEVON       := FieldByName('ExcelZeileVon').AsInteger;
        ZEILEBIS       := FieldByName('ExcelZeileBis').AsInteger;
        SPALTEMA       := FieldByName('ExcelMaSpalte').AsInteger;
        SPALTEVON      := FieldByName('ExcelDienstSpalteVon').AsInteger;
        SPALTEBIS      := FieldByName('ExcelDienstSpalteBis').AsInteger;
        OBJEKTNR       := FieldByName('ObjektNr').AsString;
        BEMSPALTEVON   := FieldByName('ExcelBemerkungenSpalteVon').AsInteger;
        BEMSPALTEBIS   := FieldByName('ExcelBemerkungenSpalteBis').AsInteger;
        BEMZEILEVON    := FieldByName('ExcelBemerkungenZeileVon').AsInteger;
        BEMZEILEBIS    := FieldByName('ExcelBemerkungenZeileBis').AsInteger;
        ZELLEMONATSNAME := FieldByName('ZelleMonatsname').AsString;
        ZELLEJAHRESZAHL := FieldByName('ZelleJahreszahl').AsString;

        with fMain.StatusBar1 do
        begin
          Panels[0].Text := 'ObjektNr: ' + OBJEKTNR;
          Panels[1].Text := OBJEKTNAME;
          if(InternetErreichbar = true) then
            Panels[2].Text := 'Online'
          else
            Panels[2].Text := 'Offline';
        end;
      end
      else
      begin
        exit;
      end;
    end;
  finally
    FDQuery.free;
  end;
end;






function SchichtExists(Schicht: string): Boolean;
var
  FDQuery: TFDQuery;
begin
 // Result := False; // Standardmäßig auf False setzen
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;
      SQL.Text := 'SELECT COUNT(*) AS CNT FROM legende WHERE schicht = :SCHICHT';
      Params.ParamByName('SCHICHT').AsString := Schicht;
      Open;
      Result := FieldByName('CNT').AsInteger > 0; // True, wenn CNT > 0
    end;
  finally
    FDQuery.Free;
  end;
end;






{
  Einsatz, Leistungsart, UhrzeitVon und UhrzeitBis anhand des Schichtkürzels ermitteln
}
function GetSchichtData(Schicht: string): TSchichtData;
var
  FDQuery: TFDQuery;
  SchichtData: TSchichtData;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT einsatz, leistungsart, vertragsnr, uhrzeitvon, uhrzeitbis FROM legende WHERE schicht = :SCHICHT;';
      Params.ParamByName('SCHICHT').AsString := Schicht;
      Open;

      if not FDQuery.IsEmpty then
      begin
        SchichtData.Einsatz      := FieldByName('einsatz').AsString;
        SchichtData.Leistungsart := FieldByName('leistungsart').AsString;
        SchichtData.VertragsNr   := FieldByName('vertragsnr').AsString;
        SchichtData.UhrzeitVon   := FieldByName('uhrzeitvon').AsString;
        SchichtData.UhrzeitBis   := FieldByName('uhrzeitbis').AsString;
      end;
    end;
  finally
    FDQuery.Free;
  end;
  Result := SchichtData;
end;











end.
