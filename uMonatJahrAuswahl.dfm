object fMonatJahrAuswahl: TfMonatJahrAuswahl
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'MonatJahr'
  ClientHeight = 260
  ClientWidth = 383
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 17
  object Label1: TLabel
    Left = 24
    Top = 152
    Width = 38
    Height = 17
    Caption = 'Monat'
  end
  object Label2: TLabel
    Left = 208
    Top = 157
    Width = 24
    Height = 17
    Caption = 'Jahr'
  end
  object Label3: TLabel
    Left = 24
    Top = 32
    Width = 314
    Height = 102
    Caption = 
      'Sie benutzen einen Dienstplan, in dem es keine separaten Felder ' +
      'f'#252'r den Monatsnamen und das Jahr gibt.'#13#13'Geben Sie hier bitte an ' +
      'von welchem Monat / Jahr dieser Dienstplan ist!'
    WordWrap = True
  end
  object cbMonat: TComboBox
    Left = 24
    Top = 176
    Width = 145
    Height = 25
    Style = csDropDownList
    DropDownCount = 12
    TabOrder = 0
  end
  object cbJahr: TComboBox
    Left = 208
    Top = 176
    Width = 145
    Height = 25
    Style = csDropDownList
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 208
    Top = 215
    Width = 145
    Height = 25
    Caption = 'Weiter'
    DisabledImageName = 'btn'
    TabOrder = 2
    OnClick = btnOKClick
  end
end
