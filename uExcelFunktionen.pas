unit uExcelFunktionen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, System.Zip, StdCtrls, ComCtrls, ExtCtrls, DateUtils, ShellApi,
  FileCtrl, System.UITypes, CryptBase, AESObj, MMSystem, System.IOUtils,
  VCL.FlexCel.Core, FlexCel.XlsAdapter, Vcl.Imaging.pngimage;

procedure LoadExcelBlattNamenToComboBox(const FileName: string; ComboBox: TComboBox);
function GetPersonalNrByMitarbeiterName(const FileName, SheetName, SettingsSheet: string): TStringList;




implementation


uses
  uMain;


//Alle Blattnamen der übergebenen Exceldatei in ComboBox ausgeben
procedure LoadExcelBlattNamenToComboBox(const FileName: string; ComboBox: TComboBox);
var
  xls: TXlsFile;
  i: Integer;
begin
  xls := TXlsFile.Create;
  try
    xls.Open(FileName);
    ComboBox.Clear;
    for i := 1 to xls.SheetCount do
    begin
      ComboBox.Items.Add(xls.GetSheetName(i));
    end;
  finally
    xls.Free;
  end;
end;





//Die PersonalNummern der Mitarbeiter aus Blatt "Einstellungen" zurückgeben
function GetPersonalNrByMitarbeiterName(const FileName, SheetName, SettingsSheet: string): TStringList;
var
  xls: TXlsFile;
  employeeNames: TStringList;
  employeeIDs: TStringList;
  i, row: Integer;
  employeeName, cellValue: string;
begin
  xls := TXlsFile.Create;
  employeeNames := TStringList.Create;
  employeeIDs := TStringList.Create;
  try
    xls.Open(FileName);

    // Wechsle zum Blatt "Januar 2024"
    xls.ActiveSheetByName := SheetName;

    // Namen der Mitarbeiter von Spalte B, Zeilen 8 bis 31 lesen
    for row := 8 to 31 do
    begin
      employeeName := xls.GetCellValue(row, 2).ToString;
      if employeeName <> '' then
      begin
        employeeNames.Add(employeeName); //Nachname + Erster Buchstabe des Vornamen + .
      end;
    end;

    // Wechsle zum Blatt "Einstellungen"
    xls.ActiveSheetByName := SettingsSheet;

    // Suche die Personalnummer zu jedem Namen
    for i := 0 to employeeNames.Count - 1 do
    begin
      for row := 9 to xls.RowCount do
      begin
        cellValue := xls.GetCellValue(row, 6).ToString;  // Namen in Spalte F
        if cellValue = employeeNames[i] then
        begin
          employeeIDs.Add(xls.GetCellValue(row, 8).ToString);  // PersonalNr in Spalte F11
          Break;
        end;
      end;
    end;

    Result := employeeIDs;
  finally
    xls.Free;
    employeeNames.Free;
  end;
end;



end.
