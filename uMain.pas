unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.ComCtrls, AdvListV,
  Vcl.StdCtrls, AdvUtil, Vcl.Grids, AdvObj, BaseGrid, AdvGrid, AdvGridCSVPager,
  System.Generics.Collections, ComObj, System.IOUtils, FlexCel.Core, FlexCel.XlsAdapter, VCL.FlexCel.Core,
  FlexCel.Render, FlexCel.Preview, Vcl.Buttons, inifiles, Vcl.Menus,
  Vcl.ExtCtrls, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Data.DB, DateUtils, Vcl.Imaging.pngimage, System.UITypes, Math,
  FireDAC.Phys.SQLiteWrapper.Stat, AdvPageControl, System.ImageList, Vcl.ImgList,
  IdHTTP, IdSSL, IdSSLOpenSSL, System.JSON, IdIcmpClient, IdURI;





type
  TfMain = class(TForm)
    lvZeiterfassung: TAdvListView;
    OpenTextFileDialog1: TOpenTextFileDialog;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    cbBlattnamen: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    Dazei1: TMenuItem;
    Beenden1: TMenuItem;
    Einstellungen1: TMenuItem;
    Einstellungen2: TMenuItem;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDConnection1: TFDConnection;
    btnConvertDienstplanZuZeiterfassung: TButton;
    Legende1: TMenuItem;
    Image1: TImage;
    Mitarbeiter1: TMenuItem;
    SaveDialog1: TSaveDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    Mitarbeiterlisteexportieren1: TMenuItem;
    ExportLegende: TMenuItem;
    ImportLegende: TMenuItem;
    ExportMitarbeiter: TMenuItem;
    ImportMitarbeiter: TMenuItem;
    StatusBar1: TStatusBar;
    Einstellungen3: TMenuItem;
    ExportEinstellungen: TMenuItem;
    ImportEinstellungen: TMenuItem;
    N3: TMenuItem;
    Splitter1: TSplitter;
    AdvPageControl1: TAdvPageControl;
    AdvTabSheet1: TAdvTabSheet;
    mBemerkungenDienstplan: TMemo;
    Timer2: TTimer;
    Hinweis1: TMenuItem;
    Programmhinweis1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbBlattnamenSelect(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConvertDienstplanZuZeiterfassungClick(Sender: TObject);
    procedure Legende1Click(Sender: TObject);
    procedure Mitarbeiter1Click(Sender: TObject);
    procedure Beenden1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExportLegendeClick(Sender: TObject);
    procedure ExportMitarbeiterClick(Sender: TObject);
    procedure ImportLegendeClick(Sender: TObject);
    procedure ImportMitarbeiterClick(Sender: TObject);
    procedure ExportEinstellungenClick(Sender: TObject);
    procedure ImportEinstellungenClick(Sender: TObject);
    procedure Einstellungen2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Programmhinweis1Click(Sender: TObject);
  private
    procedure ReplaceNamesWithPersonalNr;
    function ExtractField(const s: string; const delimiter: char; index: integer): string;
    procedure ShowSelectedDienstplanInListView;
    procedure ConvertMonthYearFromBlattName(cb: TComboBox);
    procedure ExportListViewToExcel(ListView: TListView; const DateiName: String);
    function MonatAlsZahl(const MonthStr: string): Integer;
    procedure CheckNonNumericEntries;
    procedure ExtractNameAndInitial(var FullName: string; var Nachname: string; var Initial: string);
  public
    procedure LoadSheetNames(const FileName: string; ComboBox: TComboBox);
  end;



const
  URL = 'https://esd.developercorner.de/Scripts/';
  SCRIPT = 'getMitarbeiter.php';

var
  fMain: TfMain;
  PATH, OBJEKTNAME, OBJEKTNR, EXCELDATEI: string;
  selMonth, selYear: integer;
  selSheet: string;
  ZEILEVON, ZEILEBIS, SPALTEMA, SPALTEVON, SPALTEBIS: integer;
  BEMSPALTEVON, BEMSPALTEBIS, BEMZEILEVON, BEMZEILEBIS: integer;
  ZELLEMONATSNAME, ZELLEJAHRESZAHL: String;
  DBHOST, DBUSR, DBPW, DBNAME, DBPROT, DBLIBLOC: string;
  FIRSTSTART, FIRSTSTARTNOEXCELDATEI, ENCRYPTDB: boolean;
  GlobalFormatSettings: TFormatSettings;
  ABSENDER: string;
  ABFRAGEERFOLGT : boolean;
  WEBSITEREACHABILITY: boolean;


const
  ENCRYPTIONKEY = 'mdklwuje90321iks,2moijlwödmeu3290dnu2i1p,sdim1239';
  PROGRAMMVERSION = '1.0.0.5';
  LASTCHANGEDATE  = '15.03.2025';
  USEINSTALLER = false;

implementation

{$R *.dfm}
{$R MyResources.RES}

uses uSettings, uFunktionen, uDBFunktionen, uLegende, uMitarbeiter, uExcelFunktionen,
     uMonatJahrAuswahl, uAbout;










procedure TfMain.Legende1Click(Sender: TObject);
begin
  fLegende.Show;
end;




{
  Die Namen aller Mappen der gewählten Exceldatei auslesen
  und in ComboBox einfügen
}
procedure TfMain.LoadSheetNames(const FileName: string; ComboBox: TComboBox);
var
  xls: TXlsFile;
  i: integer;
begin
  ComboBox.Clear;

  if(FileExists(FileName)) then
  begin
    xls := TXlsFile.Create(FileName);
    try
      for i := 1 to xls.SheetCount do
      begin
        ComboBox.Items.Add(xls.GetSheetName(i));
      end;
    finally
      xls.Free;
    end;
  end;
end;







procedure TfMain.Mitarbeiter1Click(Sender: TObject);
begin
  fMitarbeiter.Show;
end;







procedure TfMain.Einstellungen2Click(Sender: TObject);
begin
  fSettings.Show;
end;

procedure TfMain.ExportLegendeClick(Sender: TObject);
begin
  BackupSQLiteTable('Legende', PATH + 'DBDUMP');
end;

procedure TfMain.ImportLegendeClick(Sender: TObject);
begin
  if FileExists(PATH + 'DBDUMP\Legende.sql') then
    ImportSQLiteTable(PATH + 'DBDUMP\Legende.sql');
end;

procedure TfMain.ExportMitarbeiterClick(Sender: TObject);
begin
  BackupSQLiteTable('Mitarbeiter', PATH + 'DBDUMP');
end;

procedure TfMain.ImportMitarbeiterClick(Sender: TObject);
begin
  if FileExists(PATH + 'DBDUMP\Mitarbeiter.sql') then
    ImportSQLiteTable(PATH + 'DBDUMP\Mitarbeiter.sql');
end;




procedure TfMain.ExportEinstellungenClick(Sender: TObject);
begin
  BackupSQLiteTable('einstellungen', PATH + 'DBDUMP');
end;




procedure TfMain.ImportEinstellungenClick(Sender: TObject);
begin
  if FileExists(PATH + 'DBDUMP\Einstellungen.sql') then
  begin
    ImportSQLiteTable(PATH + 'DBDUMP\Einstellungen.sql');
   // LoadSettingsFromDB(YearOf(Now));
    if(cbBlattnamen.ItemIndex <> -1) then
      cbBlattnamenSelect(nil);
  end;
end;

function TfMain.ExtractField(const s: string; const delimiter: char; index: integer): string;
var
  fields: TArray<string>;
begin
  fields := s.Split([delimiter]);
  if (index >= Low(fields)) and (index <= High(fields)) then
  begin
    Result := fields[index];
  end
  else
    Result := '';
end;









procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FDConnection1.Connected then
    FDConnection1.Close; // Verbindung schließen
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  PATH := ExtractFilePath(ParamStr(0));

  FIRSTSTARTNOEXCELDATEI := true;

  selMonth := MonthOf(Now);
  selYear  := YearOf(Now);

  ABSENDER := '';
  ABFRAGEERFOLGT := false;

  Application.ShowMainForm := True; // Hauptfenster in Taskleiste anzeigen

  ForceDirectories(PATH + 'DBDUMP');
  ForceDirectories(PATH + 'TEMP');

  //Wenn kein Installer genutzt wird, Dateien aus Resourcen laden
  if(USEINSTALLER = false) then
  begin
    SaveResourceToFile('SQLITE3DLL64BIT', 'sqlite3.dll');
    SaveResourceToFile('SSLEAY32', 'ssleay32.dll');
    SaveResourceToFile('LIBEAY32', 'libeay32.dll');
  end;

  DBNAME     := 'zeiterfassung.s3db';
  ENCRYPTDB  := false; //im Produktivmodus auf true setzen damit Datenbank verschlüsselt wird
  FIRSTSTART := false;


  //Wenn FirstStart abgebrochen wurde und so kein Admin angelegt werden konnte,
  //die Datenbankdatei löschen
  if(FileExists(DBNAME)) then
  begin
    if IsFileZeroSize(DBNAME) then
    begin
      if(FDConnection1.Connected) then FDConnection1.Connected := false;
      DeleteFile(DBNAME);
    end;
  end;

  //Wenn Datenbank noch nicht vorhanden Formular zum anlegen eines neuen Nutzers anzeigen
  if not FileExists(DBNAME) then
  begin
    FIRSTSTART := true;
  end;

  FDConnection1.Connected := False; // Sicherstellen, dass die Verbindung geschlossen ist
  FDConnection1.DriverName := 'SQLite';
  FDConnection1.Params.Values['Database'] := DBNAME; // Datenbankname/Pfad
  FDConnection1.Params.Values['CharacterSet'] := 'utf8';
  if(ENCRYPTDB) then
  begin
    FDConnection1.Params.Values['EncryptionMode'] := 'Aes128'; // Verschlüsselung (optional)
    FDConnection1.Params.Values['Password'] := ENCRYPTIONKEY; // Passwort (optional)
  end;

  FDConnection1.Connected := true;
  FDConnection1.Open(); // Verbindung öffnen
end;












procedure TfMain.FormDestroy(Sender: TObject);
begin
  if FDConnection1.Connected then
    FDConnection1.Close; // Verbindung schließen
end;






procedure TfMain.FormResize(Sender: TObject);
begin
  StatusBar1.Panels[0].Width := 300;
  StatusBar1.Panels[2].Width := 200;
  StatusBar1.Panels[1].Width := fMain.Width - 500;  //anpassen
end;




procedure TfMain.FormShow(Sender: TObject);
begin
  fMain.Caption := 'ESD Zeiterfassung ' + PROGRAMMVERSION + '    -     Letzte Änderung: ' + LASTCHANGEDATE;


  if(FIRSTSTART = true) then
  begin
    CreateDatabaseTables;
    fSettings.ShowModal;
  end
  else
  begin
    LoadSettingsFromDB;

    if(FileExists(EXCELDATEI)) then
    begin
      LoadSheetNames(EXCELDATEI, cbBlattnamen);
      FIRSTSTARTNOEXCELDATEI := false;
    end
    else
    begin
      FIRSTSTARTNOEXCELDATEI := true;
      FIRSTSTART := true;
      ShowMessage('Die Dienstplan Exceldatei wurde nicht gefunden!' + #13#10 +
                  'Sie können das Programm erst benutzen, wenn Sie eine ' + #13#10 +
                  'Dienstplan-Exceldatei in den Einstellungen angegeben ' + #13#10 +
                  'und die Excel-Koordinaten eingetragen haben!');

      fSettings.Show;
      fSettings.PageControl1.ActivePageIndex := 0;
      fSettings.edDienstplan.SetFocus;
    end;
  end;

  StatusBar1.Panels[0].Text := 'ObjektNr: ' + OBJEKTNR;
  StatusBar1.Panels[1].Text := OBJEKTNAME;
  if(InternetErreichbar = true) then
    StatusBar1.Panels[2].Text := 'Online'
  else
    StatusBar1.Panels[2].Text := 'Offline';
end;






procedure TfMain.ExtractNameAndInitial(var FullName: string; var Nachname: string; var Initial: string);
var
  LastSpacePos: Integer;
  Vorname: string;
  const
    AWP_PREFIX = 'awp';
    OL_PREFIX  = 'ol';
    ORT_PREFIX = 'mümü';  // Konvertiere die Vergleichszeichenfolge in Kleinbuchstaben
begin
  // Trim vor der Verarbeitung, um führende/nachfolgende Leerzeichen zu entfernen
  FullName := Trim(FullName);

  // Entferne "AWP" am Anfang, unabhängig von der Groß-/Kleinschreibung
  if Pos(AnsiUpperCase(AWP_PREFIX) + ' ', AnsiUpperCase(FullName)) = 1 then
    FullName := Trim(Copy(FullName, Length(AWP_PREFIX) + 2, Length(FullName) - Length(AWP_PREFIX) - 1));


  // Entferne "OL" am Anfang
  if Pos(AnsiUpperCase(OL_PREFIX) + ' ', AnsiUpperCase(FullName)) = 1 then
    FullName := Trim(Copy(FullName, Length(OL_PREFIX) + 2, Length(FullName) - Length(OL_PREFIX) - 1));


  // Entferne "AWP" am Ende
  if AnsiLowerCase(Copy(FullName, Length(FullName) - Length(AWP_PREFIX) + 1, Length(AWP_PREFIX))) = AWP_PREFIX then
    FullName := Trim(Copy(FullName, 1, Length(FullName) - Length(AWP_PREFIX)));

  // Entferne "OL" am Ende
  if AnsiLowerCase(Copy(FullName, Length(FullName) - Length(OL_PREFIX) + 1, Length(OL_PREFIX))) = OL_PREFIX then
    FullName := Trim(Copy(FullName, 1, Length(FullName) - Length(OL_PREFIX)));

  // Entferne Variationen von "Mümü" (z.B. "MüMü", "müMü", "Mümpü", "mümpü")
  if AnsiLowerCase(Copy(FullName, Length(FullName) - Length(ORT_PREFIX) + 1, Length(ORT_PREFIX))) = ORT_PREFIX then
    FullName := Trim(Copy(FullName, 1, Length(FullName) - Length(ORT_PREFIX)));

  // Finde das letzte Leerzeichen oder Komma im Namen
  LastSpacePos := LastDelimiter(' ,', FullName);  // Suche nach Leerzeichen oder Komma

  // Ermittle den Nachnamen: Alles vor dem letzten Leerzeichen oder Komma
  if LastSpacePos > 0 then
  begin
    Nachname := Trim(Copy(FullName, 1, LastSpacePos - 1));  // Alles vor dem letzten Leerzeichen/Komma
    Nachname := StringReplace(Nachname, ',', '', [rfReplaceAll]);  // Kommas aus Nachname entfernen
  end
  else
    Nachname := FullName;  // Wenn kein Leerzeichen oder Komma vorhanden, der komplette Name ist Nachname

  // Ermittle den Vornamen: Alles nach dem letzten Leerzeichen oder Komma
  Vorname := Trim(Copy(FullName, LastSpacePos + 1, Length(FullName)));

  // Entferne Leerzeichen, Kommas und Punkte aus dem Vornamen
  Vorname := StringReplace(Vorname, ' ', '', [rfReplaceAll]);
  Vorname := StringReplace(Vorname, ',', '', [rfReplaceAll]);
  Vorname := StringReplace(Vorname, '.', '', [rfReplaceAll]);

  // Das Initial ist das erste Zeichen des verbleibenden Vornamens
  if Length(Vorname) > 0 then
    Initial := Copy(Vorname, 1, 1)
  else
    Initial := '';  // Wenn kein Vorname vorhanden, bleibt Initial leer
end;









procedure TfMain.ShowSelectedDienstplanInListView;
var
  xls: TXlsFile;
  TagEntries, NachtEntries, CombinedEntries: TStringList;
  i, j, colIndex: Integer;
  Mitarbeiter, tagValue, currentDate, dateCaption: string;
  item: TListItem;
  day: integer;
  SchichtData: TSchichtData;
  FullName, Nachname, Initial: string;
  NAVISIONPatchBisDatum: string;   //Bis Datum bei 24 Stunden anpassen dass anstatt von 18:00:00 bis 18:00:00 bis 17:59:59 wird damit das NAVISION Programm im Büro funktioniert
begin
  day := 1;
  TagEntries      := TStringList.Create;
  NachtEntries    := TStringList.Create;
  CombinedEntries := TStringList.Create;
  try
    xls := TXlsFile.Create(TPath.Combine(TPath.GetDocumentsPath, EXCELDATEI));
    try
      xls.ActiveSheetByName := selSheet;

      // Anzahl der eingetragenen Mitarbeiter in Spalte B ermitteln
      if(CountEntriesInColumnB(Xls, ZEILEVON, ZEILEBIS) = 0) then
      begin
        lvZeiterfassung.Items.Clear;
        ShowMessage('Im Dienstplan "' + selSheet + '" stehen keine Mitarbeiter!');
        exit;
      end;

      // Durch die Spalten der Exceldatei iterieren
      for colIndex := SPALTEVON to SPALTEBIS do
      begin
        // Durch die Zeilen der StringList iterieren
        for j := ZEILEVON to ZEILEBIS do
        begin
          Mitarbeiter := trim(xls.GetCellValue(j, SPALTEMA).ToString);


          if(Mitarbeiter <> '') then
          begin
            FullName := Mitarbeiter;
            ExtractNameAndInitial(FullName, Nachname, Initial);
            Mitarbeiter := Nachname + ' ' + Initial;
          end;


          //tagValue in Grossbuchstaben umwandeln
          tagValue    := UpperCase(xls.GetCellValue(j, colIndex).ToString);

          // Tag des Dienstplanes basierend auf der Spalte berechnen
          dateCaption := Format('%.2d.%.2d.%.4d', [day, selMonth, selYear]);

          if SchichtExists(tagValue) then
          begin
            SchichtData := GetSchichtData(tagValue);

            if (SchichtData.UhrzeitVon < SchichtData.UhrzeitBis) then
            begin
              TagEntries.Add(Format('%s;%s;%s;%s;%s;%s;%s', [dateCaption, Mitarbeiter, SchichtData.UhrzeitVon, SchichtData.UhrzeitBis, SchichtData.VertragsNr, SchichtData.Einsatz, SchichtData.Leistungsart]));
            end
            else if (SchichtData.UhrzeitVon > SchichtData.UhrzeitBis) then
            begin
              NachtEntries.Add(Format('%s;%s;%s;%s;%s;%s;%s', [dateCaption, Mitarbeiter, SchichtData.UhrzeitVon, SchichtData.UhrzeitBis, SchichtData.VertragsNr, SchichtData.Einsatz, SchichtData.Leistungsart]));
            end
            else if(SchichtData.UhrzeitVon = SchichtData.UhrzeitBis) then
            begin
              //24 Std Dienst

              NAVISIONPatchBisDatum := SubtractOneSecond(SchichtData.UhrzeitBis);
              TagEntries.Add(Format('%s;%s;%s;%s;%s;%s;%s', [dateCaption, Mitarbeiter, SchichtData.UhrzeitVon, NAVISIONPatchBisDatum, SchichtData.Vertragsnr, SchichtData.Einsatz, SchichtData.Leistungsart]));
            //  NachtEntries.Add(Format('%s;%s;%s;%s;%s;%s;%s', [dateCaption, PersonalNr, SchichtData.UhrzeitVon, SchichtData.UhrzeitBis, SchichtData.Vertragsnr, SchichtData.Einsatz, SchichtData.Leistungsart]));
            end

          end;
        end;
        inc(day);
      end;

      currentDate := '';

      // CombinedEntries erstellen
      day := 1;

      for colIndex := SPALTEVON to SPALTEBIS do
      begin
        dateCaption := Format('%.2d.%.2d.%.4d', [day, selMonth, selYear]);

        if currentDate <> dateCaption then
        begin
          currentDate := dateCaption;

          // TagEntries für das aktuelle Datum hinzufügen
          for i := 0 to TagEntries.Count - 1 do
          begin
            if ExtractField(TagEntries[i], ';', 0) = currentDate then
              CombinedEntries.Add(TagEntries[i]);
          end;

          // NachtEntries für das aktuelle Datum hinzufügen
          for i := 0 to NachtEntries.Count - 1 do
          begin
            if ExtractField(NachtEntries[i], ';', 0) = currentDate then
              CombinedEntries.Add(NachtEntries[i]);
          end;
        end;
        inc(day);
      end;

      lvZeiterfassung.Items.Clear;

      // CombinedEntries in die ListView einfügen
      for i := 0 to CombinedEntries.Count - 1 do
      begin
        item := lvZeiterfassung.Items.Add;
        item.Caption := ExtractField(CombinedEntries[i], ';', 0);
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 1));
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 2));
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 3));
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 4));
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 5));
        item.SubItems.Add(ExtractField(CombinedEntries[i], ';', 6));
      end;
    finally
      xls.Free;
    end;
  finally
    TagEntries.Free;
    NachtEntries.Free;
    CombinedEntries.Free;
  end;
end;











procedure TfMain.Timer2Timer(Sender: TObject);
begin
  if(InternetErreichbar = true) then
    StatusBar1.Panels[2].Text := 'Online'
  else
    StatusBar1.Panels[2].Text := 'Offline';
end;

procedure TfMain.ConvertMonthYearFromBlattName(cb: TComboBox);
var
  MonthStr: string;
  YearStr: string;
  xls: TXlsFile;
  X: String;
  i: integer;
begin
 // if(ABSENDER <> 'settings') then
  begin
    xls := TXlsFile.Create(EXCELDATEI);
    try
      i := cbBlattnamen.ItemIndex;
      if(i <> -1) then
      begin
        selSheet := cbBlattnamen.Items[i];
        xls.ActiveSheetByName := selSheet;

        X := ZELLEMONATSNAME;
        MonthStr := GetWertAusZelle(X, xls);

        X := ZELLEJAHRESZAHL;
        YearStr := GetWertAusZelle(X, xls);

        if (MonthStr = '') or (YearStr = '') then
        begin
          // Zeige das Formular für Monat/Jahr-Auswahl modal
          if fMonatJahrAuswahl.ShowModal = mrOk then
          begin
            // Hole die ausgewählten Werte aus den ComboBoxen
            MonthStr := fMonatJahrAuswahl.cbMonat.Text;
            YearStr  := fMonatJahrAuswahl.cbJahr.Text;
            selMonth := MonatAlsZahl(MonthStr);
            selYear  := StrToInt(YearStr);
          end;
        end
        else
        begin
          selMonth := StrToInt(MonthStr);
          selYear  := StrToInt(YearStr);
        end;
      end
      finally
        xls.Free;
      end;
  end;
end;












function TfMain.MonatAlsZahl(const MonthStr: string): Integer;
begin
  if MonthStr = 'Januar' then
    Result := 1
  else if MonthStr = 'Februar' then
    Result := 2
  else if MonthStr = 'März' then
    Result := 3
  else if MonthStr = 'April' then
    Result := 4
  else if MonthStr = 'Mai' then
    Result := 5
  else if MonthStr = 'Juni' then
    Result := 6
  else if MonthStr = 'Juli' then
    Result := 7
  else if MonthStr = 'August' then
    Result := 8
  else if MonthStr = 'September' then
    Result := 9
  else if MonthStr = 'Oktober' then
    Result := 10
  else if MonthStr = 'November' then
    Result := 11
  else if MonthStr = 'Dezember' then
    Result := 12
  else
    Result := 0; // Unbekannter Monat
end;










procedure TfMain.Programmhinweis1Click(Sender: TObject);
begin
  fAbout.Show;
end;

procedure TfMain.ExportListViewToExcel(ListView: TListView; const DateiName: String);
var
  Xls: TXlsFile;
  i, j: Integer;
begin
  // Erstelle eine neue Excel-Datei
  Xls := TXlsFile.Create(true);
  try
    Xls.NewFile(1);  // Eine neue Arbeitsmappe mit 1 Blatt

    // Überschriften in die erste Zeile schreiben
    Xls.SetCellValue(1, 1, 'Datum');
    Xls.SetCellValue(1, 2, 'Mitarbeiter');
    Xls.SetCellValue(1, 3, 'Von Uhrzeit');
    Xls.SetCellValue(1, 4, 'Bis Uhrzeit');
    Xls.SetCellValue(1, 5, 'BelegNr');
    Xls.SetCellValue(1, 6, 'Einsatz');
    Xls.SetCellValue(1, 7, 'Leistungsart');

    // ListView-Daten in die Excel-Datei übertragen
    for i := 0 to ListView.Items.Count - 1 do
    begin
      Xls.SetCellValue(i + 2, 1, ListView.Items[i].Caption);  // Datum (in Caption)
      for j := 0 to ListView.Items[i].SubItems.Count - 1 do
      begin
        Xls.SetCellValue(i + 2, j + 2, ListView.Items[i].SubItems[j]);  // Restliche Spalten
      end;
    end;

    // Speichere die Datei
    Xls.Save(DateiName);
  finally
    Xls.Free;
  end;
end;











procedure TfMain.Beenden1Click(Sender: TObject);
begin
  close;
end;






procedure TfMain.btnConvertDienstplanZuZeiterfassungClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  FileName: string;
  FilePath: string;
  PATH: string;
  Bemerkungen: TStringList;
begin
  if CheckListViewColumnForStrings(lvZeiterfassung, 1) then
    Exit; // Abbrechen wenn noch Mitarbeiternamen anstatt PersonalNr in der Liste stehen

  PlayResourceMP3('CLICK', 'TEMP\click.wav');


  PATH := 'C:\';

  SaveDialog := TSaveDialog.Create(nil);
  Bemerkungen := TStringList.Create;
  try
    SaveDialog.Filter := 'Excel Files (*.xlsx)|*.xlsx|Text Files (*.txt)|*.txt';
    SaveDialog.DefaultExt := 'xlsx';
    SaveDialog.FileName := 'SHD Zeiterfassung ' + IntToStr(SelMonth) + '.'+IntToStr(selYear)+' '+OBJEKTNAME+ '.xlsx';

    // Zeigen Sie den Dialog an und überprüfen Sie, ob der Benutzer auf 'Speichern' geklickt hat
    if SaveDialog.Execute then
    begin
      // Holen Sie sich den vom Benutzer gewählten Pfad
      FileName := SaveDialog.FileName;

      // Überprüfen, ob die Datei bereits existiert
      if FileExists(FileName) then
      begin
        // Benutzer fragen, ob die Datei überschrieben werden soll
        if MessageDlg(Format('Die Datei %s existiert bereits. Möchten Sie diese überschreiben?', [FileName]),
          mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        begin
          Exit; // Abbrechen, falls der Benutzer nicht überschreiben möchte
        end;
      end;

      // Speichern Sie die Excel-Datei
      ExportListViewToExcel(lvZeiterfassung, FileName);

      // Speichern Sie die Bemerkungen als Textdatei im selben Verzeichnis
      FilePath := TPath.ChangeExtension(FileName, '.txt');

      Bemerkungen.Add(mBemerkungenDienstplan.Text);
      Bemerkungen.SaveToFile(FilePath);
    end;
  finally
    SaveDialog.Free;
    Bemerkungen.Free;
  end;
end;









{
  Prüfen ob immer noch Mitarbeiter mit Namen anstatt der PersonalNr in der
  ListView stehen. Abfrage ob diese Mitarbeiter automatisch in die Liste
  der Mitarbeiter importiert werden sollen. Es wird ein php Script aufgerufen dass
  den Namen des Mitarbeiters entgegennimmt und in der MySQL Datenbank auf dem
  Server schaut ob es diesen Namen findet. Anschließend wird die PesronalNr zurück-
  gegeben. Die Pesronalnummer und der volle Name werden in die sqlite Datenbank
  geschrieben und der Name in der ListView wird durch die PersonalNr ersetzt.
}
procedure TfMain.CheckNonNumericEntries;
var
  i, x: Integer;
  l: TListItem;
  Value, Nachname, Initial, Personalnr: string;
  DummyInt: Integer;
  NonNumericList, FailedImports, SuccessfulImports: TList<string>;  // Liste für erfolgreiche und fehlgeschlagene Importe
  SpacePos: Integer;
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  FDQuery: TFDQuery;
  InsertToSQLite: boolean;
begin
  if(ABSENDER <> 'settings') then
  begin
  InsertToSQLite := false;

  NonNumericList    := TList<string>.Create;
  FailedImports     := TList<string>.Create;  // Liste für nicht importierte Mitarbeiter
  SuccessfulImports := TList<string>.Create;  // Liste für erfolgreich importierte Mitarbeiter

  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FDConnection1;

    try
      // Durch alle Einträge der ListView iterieren
      for i := 0 to lvZeiterfassung.Items.Count - 1 do
      begin
        l := lvZeiterfassung.Items[i];
        Value := Trim(l.SubItems[0]);  // Trim entfernt führende/nachfolgende Leerzeichen

        // Prüfen, ob der Wert nicht numerisch ist
        if not TryStrToInt(Value, DummyInt) then
        begin
          // Wenn der Wert noch nicht in der Liste ist, hinzufügen
          if NonNumericList.IndexOf(Value) = -1 then
            NonNumericList.Add(Value);
        end;
      end;

      // Ausgabe der Ergebnisse und Nachfrage, alle Namen anzeigen
      if (InternetErreichbar = true) AND (NonNumericList.Count > 0) AND (ABSENDER <> 'CheckNonNumericEntries') AND (ABSENDER <> 'settings') then
      begin
        // Erstelle Nachricht mit den Namen, die importiert werden sollen
        if MessageDlg('Wollen Sie die fehlenden Mitarbeiter in die Mitarbeiterliste importieren?' +
        sLineBreak +
        sLineBreak +
        String.Join(sLineBreak, NonNumericList.ToArray), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          ABFRAGEERFOLGT := true;
          // SSL-Handler für HTTPS hinzufügen
          SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
          HTTP.IOHandler := SSLHandler;
          HTTP.HandleRedirects := True;

          // Web-Request zu einem PHP-Script auf dem Server, das JSON-Daten zurückgibt
          for i := 0 to NonNumericList.Count - 1 do
          begin
            Value := NonNumericList[i];

            // Den Namen in Nachname und Initial aufteilen
            SpacePos := LastDelimiter(' ', Value);
            if SpacePos > 0 then
            begin
              Nachname := Trim(Copy(Value, 1, SpacePos - 1));  // Teil vor dem Leerzeichen ist der Nachname
              Initial := Trim(Copy(Value, SpacePos + 1, 1));   // Erstes Zeichen nach dem Leerzeichen ist das Initial
            end
            else
              Continue;  // Ungültiger Name, überspringen

            try
              // HTTP-Anfrage senden
              Response := HTTP.Get(URL + SCRIPT + '?nachname='
                + TIdURI.PathEncode(Nachname) + '&initial=' + TIdURI.PathEncode(Initial));

              // JSON-Antwort verarbeiten
              JSONArray := TJSONObject.ParseJSONValue(Response) as TJSONArray;
              if JSONArray = nil then
              begin
                FailedImports.Add(Nachname + ', ' + Initial);  // Mitarbeiter zur Fehlerliste hinzufügen
                Continue;
              end;

              if (JSONArray.Count = 0) then  // Überprüfen, ob das Array leer ist
              begin
                FailedImports.Add(Nachname + ', ' + Initial);  // Mitarbeiter zur Fehlerliste hinzufügen
                Continue;
              end;

              // Mitarbeiterdaten verarbeiten und prüfen, ob Mitarbeiter bereits in der lokalen SQLite-Datenbank existiert
              for x := 0 to JSONArray.Count - 1 do
              begin
                JSONObj := JSONArray.Items[x] as TJSONObject;

                Personalnr := JSONObj.GetValue('personalnr').Value;

                // Prüfe, ob der Mitarbeiter bereits in der SQLite-Datenbank existiert
                FDQuery.SQL.Text := 'SELECT COUNT(*) FROM mitarbeiter WHERE personalnr = :personalnr';
                FDQuery.ParamByName('personalnr').AsString := Personalnr;
                FDQuery.Open;

                if FDQuery.Fields[0].AsInteger = 0 then  // Falls Mitarbeiter noch nicht existiert
                begin
                  FDQuery.Close;  // Vor dem Insert SQL schließen

                  // Mitarbeiter in SQLite einfügen
                  FDQuery.SQL.Text := 'INSERT INTO mitarbeiter (personalnr, nachname, vorname) VALUES (:personalnr, :nachname, :vorname)';
                  FDQuery.ParamByName('personalnr').AsString := Personalnr;
                  FDQuery.ParamByName('nachname').AsString := JSONObj.GetValue('nachname').Value;
                  FDQuery.ParamByName('vorname').AsString := JSONObj.GetValue('vorname').Value;
                  FDQuery.ExecSQL;
                  InsertToSQLite := true;
                  SuccessfulImports.Add(Nachname + ', ' + Initial);  // Erfolgreich importierter Mitarbeiter zur Liste hinzufügen
                end
                else
                begin
                  FDQuery.Close;  // Mitarbeiter existiert bereits, schließe Abfrage
                end;
              end;
            except
              on E: EIdHTTPProtocolException do
              begin
                // Prüfen, ob es sich um einen Fehler 400 handelt
                if E.ErrorCode = 400 then
                begin
                  FailedImports.Add(Nachname + ', ' + Initial);  // Mitarbeiter zur Fehlerliste hinzufügen
                end
                else
                begin
                  FailedImports.Add(Nachname + ', ' + Initial);  // Mitarbeiter zur Fehlerliste hinzufügen
                end;
              end;
              on E: Exception do
              begin
                FailedImports.Add(Nachname + ', ' + Initial);  // Mitarbeiter zur Fehlerliste hinzufügen
              end;
            end;
          end;

          // Überprüfen, ob es fehlgeschlagene Importe gibt
          if FailedImports.Count > 0 then
          begin
            // Zeige die gesammelte Liste der fehlgeschlagenen Importe an
            ShowMessage('Die folgenden Mitarbeiter wurden auf dem Server nicht gefunden und konnten nicht importiert werden:' + sLineBreak + sLineBreak +
                        String.Join(sLineBreak, FailedImports.ToArray) + sLineBreak + sLineBreak + 'Tragen Sie diese bitte von Hand in die Mitarbeiterliste ein!');
            exit;
          end;

        end;
        ABSENDER := '';
      end;

    finally
      NonNumericList.Free;
      FailedImports.Free;
      HTTP.Free;
      SSLHandler.Free;
    end;
  finally
    FDQuery.Free;
    ABSENDER := 'CheckNonNumericEntries';
  end;

  // Zeige erfolgreiche Importe an, falls welche vorhanden sind
//  if SuccessfulImports.Count > 0 then
//  begin
//    ShowMessage('Folgende Mitarbeiter wurden erfolgreich importiert:' + sLineBreak + sLineBreak +
//      String.Join(sLineBreak, SuccessfulImports.ToArray));
//
//  end;

  // Daten aktualisieren, wenn neue Mitarbeiter hinzugefügt wurden
  if InsertToSQLite then
  begin
    ABSENDER := 'CheckNonNumericEntries';
    cbBlattnamenSelect(self);
  end;

  SuccessfulImports.Free;  // Liste der erfolgreichen Importe freigeben
end;
end;


















procedure TfMain.cbBlattnamenSelect(Sender: TObject);
var
  Output: TStringList;
  i: integer;
begin
  ABFRAGEERFOLGT := false;

  i := cbBlattnamen.ItemIndex;
  if(i <> -1) then
  begin
    PlayResourceMP3('WHOOSH', 'TEMP\whoosh.wav');

    ConvertMonthYearFromBlattName(cbBlattnamen);

    ShowSelectedDienstplanInListView;

    ReplaceNamesWithPersonalNr;

    Output := TStringList.Create;
    try
      ReadExcelRange(EXCELDATEI, BEMZEILEVON, BEMSPALTEVON, BEMZEILEBIS, BEMSPALTEBIS, Output); // A=1, S=19
      mBemerkungenDienstplan.Lines.Assign(Output);
    finally
      Output.Free;
    end;
  end;


  //Prüfen ob noch Mitarbeiter mit Namen anstatt PersonalNr in der Liste stehen
  if(ABSENDER <> 'CheckNonNumericEntries') AND (ABFRAGEERFOLGT <> true) then
    CheckNonNumericEntries;

  ABSENDER := '';

  if(lvZeiterfassung.Items.Count > 0) then
  begin
    btnConvertDienstplanZuZeiterfassung.Enabled := true;
  end
  else
  begin
    btnConvertDienstplanZuZeiterfassung.Enabled := false;
  end;
end;







{###################################################
  Alle Namen in der ListView ersetzen durch die    #
  zugehörige PersanalNr aus der Datenbank          #
###################################################}
procedure TfMain.ReplaceNamesWithPersonalNr;
var
  Nachname, Initial, FullName: string;
  FDQuery: TFDQuery;
  i, SpacePos: Integer;
  l: TListItem;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := FDConnection1;

    for i := 0 to lvZeiterfassung.Items.Count - 1 do
    begin
      l := lvZeiterfassung.Items[i];

      FullName := trim(l.SubItems[0]);

      SpacePos := LastDelimiter(' ', FullName);

      if SpacePos > 0 then
      begin
        Nachname := Trim(Copy(FullName, 1, SpacePos - 1));
        Initial  := Trim(Copy(FullName, SpacePos + 1, MaxInt));
      end
      else
      begin
        Nachname := Trim(FullName); // Trim für den Nachnamen
      end;


      // SQL-Abfrage anpassen, um Nachname und Initial zu prüfen
      if Initial <> '' then
      begin
        FDQuery.SQL.Text := 'SELECT PersonalNr FROM mitarbeiter ' +
                            'WHERE TRIM(Nachname) = :Nachname ' +
                            'AND TRIM(SUBSTR(Vorname, 1, 1)) = :Initial';
        FDQuery.Params.ParamByName('Nachname').AsString := Nachname;
        FDQuery.Params.ParamByName('Initial').AsString := Initial;

        FDQuery.Open;

        if not FDQuery.IsEmpty then
        begin
          l.SubItems[0] := FDQuery.FieldByName('PersonalNr').AsString;
        end
        else
        begin
          FDQuery.SQL.Text := 'SELECT PersonalNr FROM mitarbeiter WHERE TRIM(Nachname) = :Nachname';
          FDQuery.Params.ParamByName('Nachname').AsString := Nachname;

          FDQuery.Open;

          if not FDQuery.IsEmpty then
          begin
            l.SubItems[0] := FDQuery.FieldByName('PersonalNr').AsString;
          end;
        end;

        FDQuery.Close;
      end
      else
      begin
        // SQL-Abfrage nur nach dem Nachnamen
        FDQuery.SQL.Text := 'SELECT PersonalNr FROM mitarbeiter WHERE TRIM(Nachname) = :Nachname';
        FDQuery.Params.ParamByName('Nachname').AsString := Nachname;

        FDQuery.Open;

        if not FDQuery.IsEmpty then
        begin
          l.SubItems[0] := FDQuery.FieldByName('PersonalNr').AsString;
        end;
        FDQuery.Close;
      end;
    end;
  finally
    FDQuery.Free;
  end;
end;

























end.
