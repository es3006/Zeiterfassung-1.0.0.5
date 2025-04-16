unit uMonatJahrAuswahl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DateUtils;

type
  TfMonatJahrAuswahl = class(TForm)
    cbMonat: TComboBox;
    cbJahr: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  fMonatJahrAuswahl: TfMonatJahrAuswahl;

implementation

{$R *.dfm}

uses uMain;

procedure TfMonatJahrAuswahl.btnOkClick(Sender: TObject);
begin
  // Prüfen, ob beide ComboBoxen einen Wert haben
  if (cbMonat.ItemIndex = -1) or (cbJahr.ItemIndex = -1) then
  begin
    ShowMessage('Bitte wählen Sie sowohl einen Monat als auch ein Jahr aus.');
    Exit; // Verlasse die Prozedur, wenn nichts ausgewählt ist
  end;

  uMain.ABSENDER := 'MonatJahrAuswahl';
  uMain.selMonth := cbMonat.ItemIndex + 1;
  uMain.selYear  := StrToInt(cbJahr.Items[cbJahr.ItemIndex]);

  // Wenn beide Werte vorhanden sind, Dialog schließen und mrOk zurückgeben
  ModalResult := mrOk;
end;



procedure TfMonatJahrAuswahl.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  uMain.ABSENDER := 'MonatJahrAuswahl';
end;

procedure TfMonatJahrAuswahl.FormCreate(Sender: TObject);
var
  I: Integer;
  CurrentMonth, CurrentYear: Integer;
  MonthName: String;
begin
  // Monate in die ComboBox für Monate einfügen
  cbMonat.Items.Clear;
  for I := 1 to 12 do
    cbMonat.Items.Add(FormatSettings.LongMonthNames[I]);

  // Jahre (z.B. von 2020 bis 2030) in die ComboBox für Jahre einfügen
  cbJahr.Items.Clear;
  for I := 2023 to YearOf(Now) + 1 do
    cbJahr.Items.Add(IntToStr(I));

  // Aktuellen Monat und Jahr ermitteln
  CurrentMonth := MonthOf(Date);
  CurrentYear  := YearOf(Date);

  // Den aktuellen Monat vorselektieren
  MonthName := FormatSettings.LongMonthNames[CurrentMonth]; // Monatname in der aktuellen Sprache
  cbMonat.ItemIndex := cbMonat.Items.IndexOf(MonthName);

  // Das aktuelle Jahr als Text in die ComboBox schreiben
  cbJahr.ItemIndex := cbJahr.Items.IndexOf(IntToStr(CurrentYear));
end;





end.
