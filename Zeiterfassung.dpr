program Zeiterfassung;

uses
  Vcl.Forms,
  Windows,
  Dialogs,
  System.UITypes,
  uMain in 'uMain.pas' {fMain},
  uSettings in 'uSettings.pas' {fSettings},
  uFunktionen in 'uFunktionen.pas',
  uDBFunktionen in 'uDBFunktionen.pas',
  uLegende in 'uLegende.pas' {fLegende},
  uMitarbeiter in 'uMitarbeiter.pas' {fMitarbeiter},
  uExcelFunktionen in 'uExcelFunktionen.pas',
  uMonatJahrAuswahl in 'uMonatJahrAuswahl.pas' {fMonatJahrAuswahl},
  uAbout in 'uAbout.pas' {fAbout};

{$R *.res}


var
  MutexHandle: THandle;



begin
  MutexHandle := CreateMutex(nil, True, 'Local\Zeiterfassung_{8F1D3B57-5C24-4B3A-B06A-DF31D4E3563B}');
  if (MutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    MessageDlg('Das Programm ist bereits geöffnet.', mtWarning, [mbOK], 0);
    Application.Terminate;
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfSettings, fSettings);
  Application.CreateForm(TfLegende, fLegende);
  Application.CreateForm(TfMitarbeiter, fMitarbeiter);
  Application.CreateForm(TfMonatJahrAuswahl, fMonatJahrAuswahl);
  Application.CreateForm(TfAbout, fAbout);
  Application.Run;

  // Schließe den Mutex beim Beenden des Programms
  CloseHandle(MutexHandle);
end.
