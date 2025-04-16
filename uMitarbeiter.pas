unit uMitarbeiter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, AdvListV, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  Data.DB, DateUtils, System.UITypes, Vcl.Mask, Vcl.Menus, IdHTTP, System.JSON,
  IdSSLOpenSSL, System.Generics.Collections;



type
  TfMitarbeiter = class(TForm)
    lvMitarbeiter: TAdvListView;
    edNachname: TLabeledEdit;
    edVorname: TLabeledEdit;
    edPersonalNr: TLabeledEdit;
    btnNewMitarbeiter: TButton;
    btnSave: TButton;
    Panel1: TPanel;
    lbHinweis: TLabel;
    MainMenu1: TMainMenu;
    Mitarbeiter1: TMenuItem;
    Exportieren1: TMenuItem;
    Exportieren2: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    btnLoadMitarbeiterlisteFromWeb: TButton;
    StatusBar1: TStatusBar;
    procedure btnNewMitarbeiterClick(Sender: TObject);
    procedure lvMitarbeiterSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure lvMitarbeiterRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
    procedure Exportieren1Click(Sender: TObject);
    procedure Exportieren2Click(Sender: TObject);
    procedure btnLoadMitarbeiterlisteFromWebClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure LoadMitarbeiterInListView(lv: TListView);
    procedure UpdateMitarbeiterInDB(id: integer);
    procedure InsertNewMitarbeiterInDB;
    procedure InsertDataIntoSQLite(const ObjektNr: string);
    procedure LoadDataFromSQLite(const ObjektNr: string);
    procedure VisibleHideDownloadButton;
  public
    { Public-Deklarationen }
  end;


const
  SCRIPT = 'getMitarbeiterlisteFromWeb.php';

var
  fMitarbeiter: TfMitarbeiter;
  SelEntry: integer;


implementation

{$R *.dfm}

uses uMain, uDBFunktionen, uFunktionen;






procedure TfMitarbeiter.btnLoadMitarbeiterlisteFromWebClick(Sender: TObject);
begin
  InsertDataIntoSQLite(OBJEKTNR);   // Füge die Daten aus dem Web in die SQLite-Datenbank ein
  LoadDataFromSQLite(OBJEKTNR);     // Lade die Daten in die ListView
  btnLoadMitarbeiterlisteFromWeb.Visible := false;

  if(FIRSTSTARTNOEXCELDATEI = true) then
  begin
    FIRSTSTARTNOEXCELDATEI := false;
    FIRSTSTART := false;
  end;

  close;
end;







procedure TfMitarbeiter.InsertDataIntoSQLite(const ObjektNr: string);
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Response: string;
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  i: Integer;
  FDQuery: TFDQuery;
begin
  if(lvMitarbeiter.Items.Count <= 0) then
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
              SQL.Text := 'INSERT INTO mitarbeiter (personalnr, nachname, vorname) VALUES (:personalnr, :nachname, :vorname)';

              ParamByName('personalnr').AsString := JSONObj.GetValue('personalnr').Value;
              ParamByName('nachname').AsString   := JSONObj.GetValue('nachname').Value;
              ParamByName('vorname').AsString    := JSONObj.GetValue('vorname').Value;

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
            ShowMessage('Im PHP-Script "'+ SCRIPT +'" ist ein Fehler aufgetreten.')
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
  end
  else
  begin
    ShowMessage('Die Funktion des automatischen Datenabgleichs kann nur genutzt werden, wenn die Liste noch leer ist.');
  end;
end;










procedure TfMitarbeiter.LoadDataFromSQLite(const ObjektNr: string);
var
  FDQuery: TFDQuery;
  ListItem: TListItem;
begin
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := fMain.FDConnection1;

    // Abfrage, um die Daten aus der Tabelle Legende zu laden
    with FDQuery do
    begin
      SQL.Text := 'SELECT * FROM mitarbeiter ORDER BY nachname ASC';
      Open;
    end;

    // ListView leeren
    lvMitarbeiter.Items.Clear;

    // Daten in die ListView einfügen
    while not FDQuery.Eof do
    begin
      ListItem := lvMitarbeiter.Items.Add;
      ListItem.Caption := FDQuery.FieldByName('id').AsString;

      // Füge leere SubItems hinzu, um sicherzustellen, dass die Liste korrekt gefüllt ist
      while ListItem.SubItems.Count < 3 do
        ListItem.SubItems.Add('');

      // Füge die Werte zu den SubItems hinzu
      ListItem.SubItems[0] := FDQuery.FieldByName('nachname').AsString;
      ListItem.SubItems[1] := FDQuery.FieldByName('vorname').AsString;
      ListItem.SubItems[2] := FDQuery.FieldByName('personalnr').AsString;

      FDQuery.Next;  // Nächster Datensatz
    end;
  finally
    FDQuery.Free;
  end;
end;














procedure TfMitarbeiter.btnNewMitarbeiterClick(Sender: TObject);
begin
  edNachname.Clear;
  edVorname.Clear;
  edPersonalNr.Clear;
  edNachname.SetFocus;
  lvMitarbeiter.ItemIndex := -1;
  btnSave.Caption := 'Hinzufügen';
  SelEntry := -1;
end;





procedure TfMitarbeiter.btnSaveClick(Sender: TObject);
var
  nachname, vorname, personalnr: string;
begin
  nachname   := trim(edNachname.Text);
  vorname    := trim(edVorname.Text);
  personalnr := trim(edPersonalNr.Text);


  if(nachname <> '') then
  begin
    if(SelEntry = -1) then
    begin
      InsertNewMitarbeiterInDB;
    end
    else if(SelEntry <> -1) then
    begin
      UpdateMitarbeiterInDB(SelEntry);
    end;

    btnNewMitarbeiterClick(nil);

    VisibleHideDownloadButton;
  end
  else
  begin
    showmessage('Bitte füllen Sie alle Eingabefelder aus!');
  end;
end;












procedure TfMitarbeiter.Exportieren1Click(Sender: TObject);
begin
  BackupSQLiteTable('Mitarbeiter', PATH + 'DBDUMP');
  showmessage('Mitarbeiterliste unter dem Namen "Mitarbeiter.sql" im Verzeichnis "DBDUMP" gespeichert');
end;

procedure TfMitarbeiter.Exportieren2Click(Sender: TObject);
begin
  if FileExists(PATH + 'DBDUMP\Mitarbeiter.sql') then
  begin
    ImportSQLiteTable(PATH + 'DBDUMP\Mitarbeiter.sql');
    LoadMitarbeiterInListView(lvMitarbeiter);
  end;
end;

procedure TfMitarbeiter.UpdateMitarbeiterInDB(id: integer);
var
  FDQuery: TFDQuery;
  i: integer;
begin
  i := lvMitarbeiter.ItemIndex;
  if(i <> -1) then
  begin
    FDQuery := TFDquery.Create(nil);
    try
      with FDQuery do
      begin
        Connection := fMain.FDConnection1;

        SQL.Text := 'UPDATE mitarbeiter SET nachname = :NACHNAME, vorname = :VORNAME, personalnr = :PERSONALNR ' +
                    'WHERE id = :ID;';
        Params.ParamByName('ID').AsInteger        := SelEntry;
        Params.ParamByName('NACHNAME').AsString   := edNachname.Text;
        Params.ParamByName('VORNAME').AsString    := edVorname.Text;
        Params.ParamByName('PERSONALNR').AsString := edPersonalNr.Text;
        try
          ExecSQL;
        except
          on E: Exception do
          begin
            ShowMessage('Fehler beim ändern des Mitarbeiters in der Tabelle mitarbeiter: ' + E.Message);
          end;
        end;
      end;
    finally
      FDQuery.Free;

      lvMitarbeiter.Items[i].SubItems[0] := edNachname.Text;
      lvMitarbeiter.Items[i].SubItems[1] := edVorname.Text;
      lvMitarbeiter.Items[i].SubItems[2] := edPersonalNr.Text;

      edNachname.Clear;
      edVorname.Clear;
      edPersonalNr.Clear;
    end;
  end;
end;




procedure TfMitarbeiter.InsertNewMitarbeiterInDB;
var
  FDQuery: TFDQuery;
  l: TListItem;
  insertedID: Integer;
begin
  insertedID := -1;

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'INSERT INTO mitarbeiter (nachname, vorname, personalnr) ' +
                  'VALUES (:NACHNAME, :VORNAME, :PERSONALNR);';
      Params.ParamByName('NACHNAME').AsString   := edNachname.Text;
      Params.ParamByName('VORNAME').AsString    := edVorname.Text;
      Params.ParamByName('PERSONALNR').AsString := edPersonalNr.Text;

      try
        ExecSQL;

        SQL.Text := 'SELECT last_insert_rowid() as last_id;';
        Open;
        insertedID := FieldByName('last_id').AsInteger;
      except
        on E: Exception do
        begin
          ShowMessage('Fehler beim Einfügen in die Tabelle mitarbeiter: ' + E.Message);
        end;
      end;
    end;
  finally
    FDQuery.Free;

    l := lvMitarbeiter.Items.Add;
    l.Caption := IntToStr(insertedID);
    l.SubItems.Add(edNachname.Text);
    l.SubItems.Add(edVorname.Text);
    l.SubItems.Add(edPersonalNr.Text);
  end;
end;





procedure TfMitarbeiter.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  ABSENDER := 'Mitarbeiter';
end;

procedure TfMitarbeiter.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[0].Width := fMitarbeiter.Width - 100;
end;

procedure TfMitarbeiter.FormResize(Sender: TObject);
begin
  StatusBar1.Panels[1].Width := 200;
  StatusBar1.Panels[0].Width := fMitarbeiter.Width - 200;
end;

procedure TfMitarbeiter.FormShow(Sender: TObject);
begin
  SelEntry := -1;
  btnNewMitarbeiterClick(nil);

  LoadMitarbeiterInListView(lvMitarbeiter);

  lvMitarbeiter.SortColumn := 1;
  lvMitarbeiter.AlphaSort;
  lvMitarbeiter.Sort;

  VisibleHideDownloadButton;
end;






procedure TfMitarbeiter.lvMitarbeiterRightClickCell(Sender: TObject; iItem, iSubItem: Integer);
var
  i, id: integer;
  FDQuery: TFDQuery;
begin
  i := lvMitarbeiter.ItemIndex;
  if(i <> -1) then
  begin
    if MessageDlg('Wollen Sie diesen Eintrag wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      i := lvMitarbeiter.ItemIndex;
      if i <> -1 then
      begin
        id := StrToInt(lvMitarbeiter.Items[i].Caption);

        FDQuery := TFDQuery.Create(nil);
        try
          with FDQuery do
          begin
            Connection := fMain.FDConnection1;

            SQL.Text := 'DELETE FROM mitarbeiter WHERE id = :ID;';
            Params.ParamByName('ID').AsInteger := id;
            try
              ExecSQL;
            except
              on E: Exception do
              begin
                ShowMessage('Fehler beim löschen des Eintrages aus der Tabelle mitarbeiter: ' + E.Message);
              end;
            end;
          end;
        finally
          FDQuery.Free;
          lvMitarbeiter.DeleteSelected;

          VisibleHideDownloadButton;
        end;
      end;
    end;
  end;
end;



procedure TfMitarbeiter.VisibleHideDownloadButton;
begin
  if(InternetErreichbar = true) then
  begin
    StatusBar1.Panels[1].Text := 'Online';
    if(IsWebsiteReachable(URL + SCRIPT) = true) then
    begin
      if(lvMitarbeiter.Items.Count = 0) then
      begin
        btnLoadMitarbeiterlisteFromWeb.Visible := true;
      end
      else
      begin
        btnLoadMitarbeiterlisteFromWeb.Visible := false;
      end;
    end
    else
    begin
      StatusBar1.Panels[1].Text := 'Datenabgleich nicht verfügbar';
      btnLoadMitarbeiterlisteFromWeb.Visible := false;
    end;
  end
  else
  begin
    StatusBar1.Panels[1].Text := 'Offline';
    btnLoadMitarbeiterlisteFromWeb.Visible := false;
  end;
end;





procedure TfMitarbeiter.lvMitarbeiterSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  i: integer;
begin
  i := lvMitarbeiter.ItemIndex;

  if i <> -1 then
  begin
    SelEntry          := StrToInt(lvMitarbeiter.Items[i].Caption);
    edNachname.Text   := lvMitarbeiter.Items[i].SubItems[0];
    edVorname.Text    := lvMitarbeiter.Items[i].SubItems[1];
    edPersonalNr.Text := lvMitarbeiter.Items[i].SubItems[2];

    btnSave.Caption   := 'Speichern';
  end
  else
  begin
    btnNewMitarbeiterClick(nil);
  end;
end;






procedure TfMitarbeiter.LoadMitarbeiterInListView(lv: TListView);
var
  l: TListItem;
  FDQuery: TFDQuery;
begin
  lv.Items.Clear;

  FDQuery := TFDQuery.Create(nil);
  try
    with FDQuery do
    begin
      Connection := fMain.FDConnection1;

      SQL.Text := 'SELECT id, nachname, vorname, personalnr FROM mitarbeiter ORDER BY nachname;';
      Open;

      while not Eof do
      begin
        l := lv.Items.Add;
        l.Caption := FieldByName('id').AsString;
        l.SubItems.Add(FieldByName('nachname').AsString);
        l.SubItems.Add(FieldByName('vorname').AsString);
        l.SubItems.Add(FieldByName('personalnr').AsString);
        next;
      end;
    end;
  finally
    FDQuery.Free;
    btnNewMitarbeiterClick(nil);
  end;
end;




end.
