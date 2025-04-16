unit uSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, IniFiles,
  Vcl.ComCtrls, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Data.DB, DateUtils, Vcl.Imaging.pngimage, Vcl.Mask, System.UITypes, Vcl.Menus,
  VCL.FlexCel.Core, FlexCel.XlsAdapter, IdHTTP, System.JSON,
  IdSSLOpenSSL, System.Generics.Collections, System.ImageList, Vcl.ImgList;

type
  TfSettings = class(TForm)
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    edZeileVon: TLabeledEdit;
    edZeileBis: TLabeledEdit;
    edSpalteVon: TLabeledEdit;
    edSpalteBis: TLabeledEdit;
    lbSchichtenHinweis: TLabel;
    edSpalteMA: TLabeledEdit;
    Label5: TLabel;
    Label6: TLabel;
    edObjektname: TLabeledEdit;
    edDienstplan: TLabeledEdit;
    sbLoadDienstplan: TSpeedButton;
    edObjektNr: TLabeledEdit;
    Label1: TLabel;
    lbBemerkungenHinweis: TLabel;
    edBemSpalteVon: TLabeledEdit;
    edBemSpalteBis: TLabeledEdit;
    edBemZeileBis: TLabeledEdit;
    edBemZeileVon: TLabeledEdit;
    btnWeiter: TButton;
    btnSaveKoordinatenSettings: TButton;
    lbMitarbeiterHinweis: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    lbDienstplanHinweis: TLabel;
    Bevel3: TBevel;
    Image1: TImage;
    btnLoadSettingsFromServer: TButton;
    edZelleMonatsname: TLabeledEdit;
    edZelleJahreszahl: TLabeledEdit;
    lbMonatJahrHinweis: TLabel;
    ImageList1: TImageList;
    cbObjekteFromWeb: TComboBox;
    lbObjekteFromWeb: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure sbLoadDienstplanClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnWeiterClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure edSpalteVonKeyPress(Sender: TObject; var Key: Char);
    procedure btnSaveKoordinatenSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edZeileVonClick(Sender: TObject);
    procedure edSpalteVonClick(Sender: TObject);
    procedure edSpalteMAClick(Sender: TObject);
    procedure edBemZeileVonClick(Sender: TObject);
    procedure edBemSpalteVonClick(Sender: TObject);
    procedure btnLoadSettingsFromServerClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edObjektnameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbObjekteFromWebSelect(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure LoadStart;
    procedure InsertDataIntoSQLite(const ObjektNr: string);
    procedure getObjektNrByObjektID(const ObjektID: integer);
    procedure VisibleHideDownloadButton;
    procedure LoadAllObjekteFromWeb(CB: TComboBox);
  public
    { Public-Deklarationen }
  end;


const
  SCRIPT = 'getDienstplanKoordinatenFromWeb.php';
  SCRIPTOBJEKTE = 'getAllObjektnamenOrteIDs.php';
  SCRIPTBYOBJEKTID = 'getObjektNrByObjektID.php';
var
  fSettings: TfSettings;
  SelLegendeEntry: integer;
  DPChanged: Boolean;



implementation

{$R *.dfm}

uses
  uMain, uFunktionen, uDBFunktionen, uSettingsHelp, uLegende;



procedure TfSettings.VisibleHideDownloadButton;
begin
  if(InternetErreichbar = true) then
  begin
    if(IsWebsiteReachable(URL + SCRIPT) = true) then
    begin
      edObjektname.Enabled := false;
      btnLoadSettingsFromServer.Visible := true;
      lbObjekteFromWeb.Visible := true;
      cbObjekteFromWeb.Visible := true;
      btnWeiter.Visible := false;
    end
    else
    begin
      edObjektname.Enabled := true;
      btnLoadSettingsFromServer.Visible := false;
      lbObjekteFromWeb.Visible := false;
      cbObjekteFromWeb.Visible := false;
      btnWeiter.Visible := true;
    end;
  end
  else
  begin
    edObjektname.Enabled := true;
    btnLoadSettingsFromServer.Visible := false;
    lbObjekteFromWeb.Visible := false;
    cbObjekteFromWeb.Visible := false;
  end;
end;






procedure TfSettings.btnWeiterClick(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 1;
  PageControl1Change(nil);
end;







procedure TfSettings.btnSaveKoordinatenSettingsClick(Sender: TObject);
var
  FDQuery: TFDQuery;
  i, MONAT, JAHR, ZEILEVON, ZEILEBIS, BEMZEILEVON, BEMZEILEBIS: integer;
  ZELLEMONATSNAME, ZELLEJAHRESZAHL: String;
  SPALTEMA, SPALTEVON, SPALTEBIS, SPALTEBEMVON, SPALTEBEMBIS: string;
  OBJEKTNAME, OBJEKTNR, EXCELDATEI: string;
begin
  i     := fMain.cbBlattnamen.ItemIndex;

  OBJEKTNAME   := trim(edObjektname.Text);
  OBJEKTNR     := trim(edObjektNr.Text);
  EXCELDATEI   := trim(edDienstplan.Text);


  if OBJEKTNR = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie eine gültige ObjektNr ein.');
    edObjektNr.SetFocus;
    Exit;
  end;

  if OBJEKTNAME = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie einen Objektnamen ein.');
    edObjektname.SetFocus;
    Exit;
  end;




  try
    ZEILEVON := StrToInt(trim(edZeileVon.Text));
  except
    on E: EConvertError do
    begin
      ShowMessage('Fehler:'+#13#10+'Ungültiger Wert in "Dienste: Zeile von".'+#13#10+'Bitte eine gültige Zahl eingeben.');
      edZeileVon.SetFocus;
      Exit;
    end;
  end;

  try
    ZEILEBIS := StrToInt(trim(edZeileBis.Text));
  except
    on E: EConvertError do
    begin
      ShowMessage('Fehler:'+#13#10+'Ungültiger Wert in "Dienste: Zeile bis".'+#13#10+'Bitte eine gültige Zahl eingeben.');
      edZeileBis.SetFocus;
      Exit;
    end;
  end;

  try
    BEMZEILEVON := StrToInt(trim(edBemZeileVon.Text));
  except
    on E: EConvertError do
    begin
      ShowMessage('Fehler:'+#13#10+'Ungültiger Wert in "Bemerkungszeile von".'+#13#10+'Bitte eine gültige Zahl eingeben.');
      edBemZeileVon.SetFocus;
      Exit;
    end;
  end;

  try
    BEMZEILEBIS := StrToInt(trim(edBemZeileBis.Text));
  except
    on E: EConvertError do
    begin
      ShowMessage('Fehler:'+#13#10+'Ungültiger Wert in "Bemerkungszeile bis".'+#13#10+'Bitte eine gültige Zahl eingeben.');
      edBemZeileBis.SetFocus;
      Exit;
    end;
  end;


  // Überprüfung der Textfelder
  SPALTEMA := trim(edSpalteMA.Text);
  if SPALTEMA = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie die Spalte an, in der die Mitarbeiternamen auf dem Dienstplan stehen.');
    edSpalteMA.SetFocus;
    Exit;
  end;

  SPALTEVON := trim(edSpalteVon.Text);
  if SPALTEVON = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie an, in welcher Spalte auf dem Dienstplan der Erste Tage des Monats steht.');
    edSpalteVon.SetFocus;
    Exit;
  end;

  SPALTEBIS := trim(edSpalteBis.Text);
  if SPALTEBIS = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie an, in welcher Spalte auf dem Dienstplan der letzte Tag des Monats steht.');
    edSpalteBis.SetFocus;
    Exit;
  end;

  SPALTEBEMVON := trim(edBemSpalteVon.Text);
  if SPALTEBEMVON = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie die erste Spalte an, in der die Bemerkungen zu den Diensten auf dem Dienstplan stehen.');
    edBemSpalteVon.SetFocus;
    Exit;
  end;

  SPALTEBEMBIS := trim(edBemSpalteBis.Text);
  if SPALTEBEMBIS = '' then
  begin
    ShowMessage('Fehler:'+#13#10+'Bitte geben Sie die letzte Spalte an, in der die Bemerkungen zu den Diensten auf dem Dienstplan stehen.');
    edBemSpalteBis.SetFocus;
    Exit;
  end;

  ZELLEMONATSNAME := trim(edZelleMonatsname.Text);
  if ZELLEMONATSNAME = '' then ZELLEMONATSNAME := 'A1';

  ZELLEJAHRESZAHL := trim(edZelleJahresZahl.Text);
  if ZELLEJAHRESZAHL = '' then ZELLEJAHRESZAHL := 'A1';



  if(DPChanged = true) then
  begin
    btnWeiterClick(nil);
    DPChanged := false;
  end;



  FDQuery := TFDquery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

    //  if FIRSTSTART = false then
    //  begin
        SQL.Text := 'UPDATE einstellungen SET Exceldatei = :EXCELDATEI,' +
                    'ExcelMaSpalte = :SPALTEMA, ExcelDienstSpalteVon = :SPALTEVON, '+
                    'ExcelDienstSpalteBis = :SPALTEBIS, ExcelZeileVon = :ZEILEVON, ExcelZeileBis = :ZEILEBIS, '+
                    'ExcelBemerkungenSpalteVon = :BEMSPALTEVON, ExcelBemerkungenSpalteBis = :BEMSPALTEBIS, ' +
                    'ExcelBemerkungenZeileVon = :BEMZEILEVON, ExcelBemerkungenZeileBis = :BEMZEILEBIS, ' +
                    'ZelleMonatsname = :ZELLEMONATSNAME, ZelleJahreszahl = :ZELLEJAHRESZAHL, ' +
                    'Objektname = :OBJEKTNAME, ObjektNr = :OBJEKTNR;';

        ParamByName('EXCELDATEI').AsString    := EXCELDATEI;
        ParamByName('SPALTEMA').AsInteger     := ExcelColumnToIndex(SPALTEMA);
        ParamByName('SPALTEVON').AsInteger    := ExcelColumnToIndex(SPALTEVON);
        ParamByName('SPALTEBIS').AsInteger    := ExcelColumnToIndex(SPALTEBIS);
        ParamByName('ZEILEVON').AsInteger     := ZEILEVON;
        ParamByName('ZEILEBIS').AsInteger     := ZEILEBIS;
        ParamByName('BEMSPALTEVON').AsInteger := ExcelColumnToIndex(SPALTEBEMVON);
        ParamByName('BEMSPALTEBIS').AsInteger := ExcelColumnToIndex(SPALTEBEMBIS);
        ParamByName('BEMZEILEVON').AsInteger  := BEMZEILEVON;
        ParamByName('BEMZEILEBIS').AsInteger  := BEMZEILEBIS;
        ParamByName('ZELLEMONATSNAME').AsString  := ZELLEMONATSNAME;
        ParamByName('ZELLEJAHRESZAHL').AsString  := ZELLEJAHRESZAHL;
        ParamByName('OBJEKTNR').AsString      := OBJEKTNR;
        ParamByName('OBJEKTNAME').AsString    := OBJEKTNAME;
        try
          ExecSQL;
          ABSENDER   := 'settings';
          LoadSettingsFromDB;

          if(i <> -1) then
          begin
            fMain.cbBlattnamen.ItemIndex := i;
            fMain.cbBlattnamenSelect(nil);
          end;
        except
          on E: Exception do
            ShowMessage('Fehler beim Ändern der Dienstplan-Koordinaten in der Datenbank: ' + E.Message);
        end;
    end;
  finally
    FDQuery.Free;
  end;
  ABSENDER   := 'settings';
  LoadSettingsFromDB;
  fMain.LoadSheetNames(EXCELDATEI, fMain.cbBlattnamen);
 // FirstStart := False;
  close;
end;








procedure TfSettings.LoadAllObjekteFromWeb(CB: TComboBox);
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  ID: Integer;
  Objektname, Objektort, DisplayText: string;
  i: Integer;
begin
  CB.Items.Clear;

  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  HTTP.IOHandler := SSLHandler;

  try
    HTTP.HandleRedirects := True;

    try
      Response := HTTP.Get(URL + SCRIPTOBJEKTE);

      JSONArray := TJSONObject.ParseJSONValue(Response) as TJSONArray;

      try
        for i := 0 to JSONArray.Count - 1 do
        begin
          JSONObj := JSONArray.Items[i] as TJSONObject;

          ID         := JSONObj.GetValue<Integer>('id');
          Objektname := JSONObj.GetValue<string>('objektname');
          Objektort  := JSONObj.GetValue<string>('objektort');

          DisplayText := Format('%s - %s', [Objektname, Objektort]);

          CB.Items.AddObject(DisplayText, TObject(ID));
        end;
      finally
        JSONArray.Free;
      end;

    except
      on E: Exception do
        ShowMessage('Fehler beim Abrufen der Daten: ' + E.Message);
    end;
  finally
    HTTP.Free;
    SSLHandler.Free;
  end;
end;





procedure TfSettings.cbObjekteFromWebSelect(Sender: TObject);
var
  objektnr: string;
  SelectedID: Integer;
begin
  if cbObjekteFromWeb.ItemIndex <> -1 then
  begin
    SelectedID := Integer(cbObjekteFromWeb.Items.Objects[cbObjekteFromWeb.ItemIndex]);
    if(FIRSTSTART = false) then
    begin
      if MessageDlg('Wollen Sie die Einstellungen wirklich vom Server laden?'+#13#10+'Vorhandene Einträge in den Dienstplan-Koordinaten werden dabei überschrieben!',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        edDienstplan.Clear;
        edObjektname.Clear;
        getObjektNrByObjektID(SelectedID);
        edObjektname.Text := cbObjekteFromWeb.Text;
        edDienstplan.SetFocus;
      end;
    end
    else
    begin
      edDienstplan.Clear;
      edObjektname.Clear;
      getObjektNrByObjektID(SelectedID);
      edObjektname.Text := cbObjekteFromWeb.Text;
      edDienstplan.SetFocus;
    end;
  end;
end;








procedure TfSettings.btnLoadSettingsFromServerClick(Sender: TObject);
var
  objektnr: string;
begin
  objektnr := Trim(edObjektNr.text);

  if(length(objektnr) > 0) then
  begin
    if MessageDlg('Wollen Sie die Einstellungen wirklich vom Server laden?'+#13#10+'Vorhandene Einträge in den Dienstplan-Koordinaten werden dabei überschrieben!',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      FirstStart := true;

      deleteAllMitarbeiter;
      deleteAllLegende;

      InsertDataIntoSQLite(trim(edObjektNr.Text));

      LoadSettingsFromDB;

      LoadStart;

      btnSaveKoordinatenSettingsClick(nil);
    end;
  end
  else
  begin
    showmessage('Bitte geben Sie die ObjektNr Ihres Objektes ein um die Einstellungen vom Server zu laden!');
    edObjektNr.SetFocus;
  end;
end;






procedure TfSettings.InsertDataIntoSQLite(const ObjektNr: string);
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  i: Integer;
  FDQuery: TFDQuery;
begin
    HTTP := TIdHTTP.Create(nil);
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
    HTTP.IOHandler := SSLHandler;

    try
      HTTP.HandleRedirects := True;  // Umleiten erlauben, falls nötig

      try
        // PHP-Seite aufrufen mit objektnr als Parameter
        Response := HTTP.Get(URL + SCRIPT + '?objektnr=' + ObjektNr);

        // JSON parsen
        JSONArray := TJSONObject.ParseJSONValue(Response) as TJSONArray;

        if JSONArray = nil then
        begin
          raise Exception.Create('Die Antwort enthält keine gültigen Daten.');
        end;

        // SQLite-Datenbankverbindung herstellen
        FDQuery := TFDQuery.Create(nil);
        try
          FDQuery.Connection := fMain.FDConnection1;

          // Daten in die SQLite-Datenbank einfügen
          for i := 0 to JSONArray.Count - 1 do
          begin
            JSONObj := JSONArray.Items[i] as TJSONObject;

            with FDQuery do
            begin
              SQL.Text := '''
                UPDATE einstellungen SET
                Exceldatei = :EXCELDATEI,
                ExcelMaSpalte = :SPALTEMA,
                ExcelDienstSpalteVon = :DIENSTSV,
                ExcelDienstSpalteBis = :DIENSTSB,
                ExcelZeileVon = :DIENSTZV,
                ExcelZeileBis = :DIENSTZB,
                ExcelBemerkungenSpalteVon = :BEMERKUNGENSV,
                ExcelBemerkungenSpalteBis = :BEMERKUNGENSB,
                ExcelBemerkungenZeileVon = :BEMERKUNGENZV,
                ExcelBemerkungenZeileBis = :BEMERKUNGENZB,
                ZelleMonatsname = :MONATZELLE,
                ZelleJahreszahl = :JAHRZELLE,
                Objektname = :OBJEKTNAME,
                ObjektNr = :OBJEKTNR;
              ''';
              ParamByName('EXCELDATEI').AsString    := trim(edDienstplan.Text);
              ParamByName('SPALTEMA').AsInteger     := ExcelColumnToIndex(JSONObj.GetValue('mitarbeiter_s').Value);
              ParamByName('DIENSTSV').AsInteger      := ExcelColumnToIndex(JSONObj.GetValue('dienst_sv').Value);
              ParamByName('DIENSTSB').AsInteger      := ExcelColumnToIndex(JSONObj.GetValue('dienst_sb').Value);
              ParamByName('DIENSTZV').AsString      := JSONObj.GetValue('dienst_zv').Value;
              ParamByName('DIENSTZB').AsString      := JSONObj.GetValue('dienst_zb').Value;
              ParamByName('BEMERKUNGENSV').AsInteger := ExcelColumnToIndex(JSONObj.GetValue('bemerkungen_sv').Value);
              ParamByName('BEMERKUNGENSB').AsInteger := ExcelColumnToIndex(JSONObj.GetValue('bemerkungen_sb').Value);
              ParamByName('BEMERKUNGENZV').AsString := JSONObj.GetValue('bemerkungen_zv').Value;
              ParamByName('BEMERKUNGENZB').AsString := JSONObj.GetValue('bemerkungen_zb').Value;
              ParamByName('MONATZELLE').AsString    := JSONObj.GetValue('monat_zelle').Value;
              ParamByName('JAHRZELLE').AsString     := JSONObj.GetValue('jahr_zelle').Value;
              ParamByName('OBJEKTNAME').AsString    := JSONObj.GetValue('objektname').Value;
              ParamByName('OBJEKTNR').AsString      := ObjektNr;

              ExecSQL;
            end;
          end;
        finally
          FDQuery.Free;
        end;

      except
        on E: EIdHTTPProtocolException do
        begin
          if E.ErrorCode = 500 then
            ShowMessage('Im PHP-Script "' + SCRIPT + '" ist ein Fehler aufgetreten.')
          else if E.ErrorCode = 404 then
            ShowMessage('Die Datei "' + SCRIPT + '" konnte auf dem Server nicht gefunden werden.')
          else
            ShowMessage('HTTP-Fehler: ' + IntToStr(E.ErrorCode) + ' - ' + E.Message);
        end;
        on E: Exception do
        begin
          // Alle anderen Fehler behandeln
          ShowMessage('Fehler beim Abrufen der Daten: ' + E.Message);
        end;
      end;

    finally
      HTTP.Free;
      SSLHandler.Free;
    end;
end;










procedure TfSettings.getObjektNrByObjektID(const ObjektID: Integer);
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONObj: TJSONObject;
  JSONValue: TJSONValue;
begin
  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  HTTP.IOHandler := SSLHandler;
  SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  try
    HTTP.HandleRedirects := True;

    try
      Response := HTTP.Get(URL + SCRIPTBYOBJEKTID + '?objektid=' + IntToStr(ObjektID));

      JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject;

      if Assigned(JSONObj) then
      try
        JSONValue := JSONObj.GetValue('objektnr');
        if Assigned(JSONValue) then
        begin
          edObjektNr.Text := JSONValue.Value;
        end
        else
          ShowMessage('"objektnr" Schlüssel ist nicht vorhanden oder leer.');

      finally
        JSONObj.Free;
      end
      else
        ShowMessage('Die Antwort enthält kein gültiges JSON-Objekt.');

    except
      on E: EIdHTTPProtocolException do
      begin
        if E.ErrorCode = 500 then
          ShowMessage('Fehler im PHP-Skript "' + SCRIPTBYOBJEKTID + '".')
        else if E.ErrorCode = 404 then
          ShowMessage('Die Datei "' + SCRIPTBYOBJEKTID + '" wurde auf dem Server nicht gefunden.')
        else
          ShowMessage('HTTP-Fehler: ' + IntToStr(E.ErrorCode) + ' - ' + E.Message);
      end;
      on E: Exception do
        ShowMessage('Fehler beim Abrufen der Daten: ' + E.Message);
    end;

  finally
    HTTP.Free;
    SSLHandler.Free;
  end;
end;











procedure TfSettings.edBemSpalteVonClick(Sender: TObject);
begin
  LoadImageFromResource('BEMSPALTEN', Image1);
end;

procedure TfSettings.edBemZeileVonClick(Sender: TObject);
begin
  LoadImageFromResource('BEMZEILEN', Image1);
end;

procedure TfSettings.edObjektnameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  DPChanged := true;
end;

procedure TfSettings.edSpalteMAClick(Sender: TObject);
begin
  LoadImageFromResource('MASPALTE', Image1);
end;

procedure TfSettings.edSpalteVonClick(Sender: TObject);
begin
  LoadImageFromResource('DIENSTESPALTEN', Image1);
end;

procedure TfSettings.edSpalteVonKeyPress(Sender: TObject; var Key: Char);
begin
// Erlaubt sind: Buchstaben (A-Z, a-z), Backspace (#8) und Enter (#13)
  if CharInSet(Key, ['A'..'Z', 'a'..'z']) then
    Key := UpCase(Key)  // Wandelt Kleinbuchstaben in Großbuchstaben um
  else if not CharInSet(Key, [#8, #13]) then
    Key := #0;  // Verhindert, dass andere Tasten verarbeitet werden
end;




procedure TfSettings.edZeileVonClick(Sender: TObject);
begin
  LoadImageFromResource('DIENSTEZEILEN', Image1);
end;






procedure TfSettings.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  EXCELDATEI := trim(edDienstplan.Text);

  if(Length(trim(EXCELDATEI))>0) then
  begin
    if FileExists(EXCELDATEI) then
    begin
      if IsXlsFile(EXCELDATEI) then
      begin
        i := fMain.cbBlattnamen.ItemIndex;

        LoadSettingsFromDB;
        fMain.LoadSheetNames(EXCELDATEI, fMain.cbBlattnamen);

        if(i <> -1) then
        begin
          fMain.cbBlattnamen.ItemIndex := i;
          fMain.cbBlattnamenSelect(nil);
        end;

        if(FIRSTSTARTNOEXCELDATEI = true) OR (FIRSTSTART = true) then
        begin
          showmessage('Laden Sie im Menü über "Einstellungen" als nächstes die Legende und die Mitarbeiter!');
          fLegende.Show;
          FIRSTSTARTNOEXCELDATEI := true;
          FIRSTSTART := false;
        end;
      end
      else
      begin
        showmessage('Der angegebene Dienstplan ist keine Exceldatei.');
        abort;
      end;
    end
    else
    begin
      if MessageDlg('Die Dienstplan Exceldatei wurde nicht gefunden.'+#13#10+'Wollen Sie das Programm beenden?',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      begin
        Application.Terminate;
      end
      else
      begin
        PageControl1.ActivePageIndex := 0;
        edDienstplan.SetFocus;
        abort;
      end;
    end
  end
  else
  begin
    if MessageDlg('Bevor Sie keine Dienstplan Exceldatei angegeben haben, können Sie das Programm nicht benutzen.'+#13#10+'Wollen Sie das Programm beenden?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      Application.Terminate;
    end
    else
    begin
      PageControl1.ActivePageIndex := 0;
      edDienstplan.SetFocus;
      abort;
    end;
  end;
end;




procedure TfSettings.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  uMain.ABSENDER := 'settings';
end;

procedure TfSettings.FormCreate(Sender: TObject);
begin
  lbDienstplanHinweis.Caption  := 'Wählen Sie hier die Exceldatei, in der die Dienstpläne aller Monate eines Jahres stehen.';

  lbMitarbeiterHinweis.Caption := 'Geben Sie hier die Spalte an, in der die Namen der Mitarbeiter im Dienstplan stehen.'+ #13#10 +
                                  'Spalten werden, wie in Excel auch, als Buchstaben angegeben.';

  lbSchichtenHinweis.Caption   := 'Geben Sie hier den Bereich an, in denen die Schichten im Dienstplan stehen.'+#13#10+
                                  'Spalten müssen wie in Excel als Buchstabe und Zeilen als Zahl angegeben werden.';

  lbBemerkungenHinweis.Caption := 'Geben Sie hier den Bereich an, in dem die Bemerkungen zu den Diensten ' + #13#10 +
                                  'auf dem Dienstplan stehen.';

  lbMonatJahrHinweis.Caption := 'Geben Sie hier die Zellen an, in denen der Monatsname und das Jahr stehen ' + #13#10 +
                                'Die Werte müssen in zwei separaten Zellen im Dienstplan angegeben sein.'+#13#10+
                                'Geben Sie die Werte im Format A1 (Spalte+Zeile) an! - Sollte es diese Zellen auf Ihrem '+#13#10+
                                'Dienstplan nicht geben, tragen Sie einfach "A1" in die Felder ein!';
end;




procedure TfSettings.FormShow(Sender: TObject);
begin
  DPChanged := false;

  LoadStart;

  VisibleHideDownloadButton;

  if(InternetErreichbar = true) then
    LoadAllObjekteFromWeb(cbObjekteFromWeb);
end;




procedure TfSettings.LoadStart;
begin
  if FIRSTSTART = true then
  begin
    edZeileVon.Clear;
    edZeileBis.Clear;
    edSpalteVon.Clear;
    edSpalteBis.Clear;
    edSpalteMA.Clear;
    edBemZeileVon.Clear;
    edBemZeileBis.Clear;
    edBemSpalteVon.Clear;
    edBemSpalteBis.Clear;
  end;

  PageControl1.ActivePageIndex := 0;
  fSettings.Caption := 'Einstellungen - Dienstplan';


  edDienstplan.Text := EXCELDATEI;
  edObjektname.Text := OBJEKTNAME;
  edObjektNr.Text   := OBJEKTNR;

  if(ZEILEVON > 0) then
    edZeileVon.Text   := IntToStr(ZEILEVON);

  if(ZEILEBIS > 0) then
    edZeileBis.Text   := IntToStr(ZEILEBIS);

  edSpalteMA.Text     := IndexToExcelColumn(SPALTEMA);
  edSpalteVon.Text    := IndexToExcelColumn(SPALTEVON);
  edSpalteBis.Text    := IndexToExcelColumn(SPALTEBIS);
  edBemSpalteVon.Text := IndexToExcelColumn(BEMSPALTEVON);
  edBemSpalteBis.Text := IndexToExcelColumn(BEMSPALTEBIS);


  if(BEMZEILEVON > 0) then
    edBemZeileVon.Text   := IntToStr(BEMZEILEVON);

  if(BEMZEILEBIS > 0) then
    edBemZeileBis.Text   := IntToStr(BEMZEILEBIS);

  if(ZELLEMONATSNAME <> '') then
    edZelleMonatsname.Text   := ZELLEMONATSNAME;

  if(ZELLEJAHRESZAHL <> '') then
    edZelleJahresZahl.Text   := ZELLEJAHRESZAHL;

  PageControl1.ActivePageIndex := 0;
end;





procedure TfSettings.PageControl1Change(Sender: TObject);
begin
  if(PageControl1.ActivePageIndex = 0) then
  begin
    LoadImageFromResource('DIENSTPLAN', Image1);
    fSettings.Caption := 'Einstellungen - Dienstplan';
  end
  else
  begin
    fSettings.Caption := 'Einstellungen - Dienstplan-Koordinaten';
    edZeileVonClick(nil);
  end;
end;




procedure TfSettings.sbLoadDienstplanClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);  // Setzt das Startverzeichnis auf das Programmverzeichnis
  if OpenDialog1.Execute then
  begin
    edDienstplan.Text := OpenDialog1.FileName;
  end;
end;












procedure TfSettings.Timer1Timer(Sender: TObject);
begin
  VisibleHideDownloadButton;

 // if(InternetErreichbar = true) then
 //   LoadAllObjekteFromWeb(cbObjekteFromWeb);
end;

end.
