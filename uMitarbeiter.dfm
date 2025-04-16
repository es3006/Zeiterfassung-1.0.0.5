object fMitarbeiter: TfMitarbeiter
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Mitarbeiter'
  ClientHeight = 561
  ClientWidth = 883
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    883
    561)
  TextHeight = 19
  object lvMitarbeiter: TAdvListView
    AlignWithMargins = True
    Left = 10
    Top = 131
    Width = 863
    Height = 270
    Margins.Left = 10
    Margins.Top = 10
    Margins.Right = 10
    Margins.Bottom = 10
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'ID'
        MaxWidth = 1
        Width = 0
      end
      item
        Caption = 'Nachname'
        MaxWidth = 250
        MinWidth = 250
        Width = 250
      end
      item
        Caption = 'Vorname'
        MaxWidth = 250
        MinWidth = 250
        Width = 250
      end
      item
        Caption = 'PersonalNr'
        MinWidth = 150
        Width = 358
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    SortType = stBoth
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = lvMitarbeiterSelectItem
    ColumnSize.Stretch = True
    FilterTimeOut = 0
    PrintSettings.DateFormat = 'dd/mm/yyyy'
    PrintSettings.Font.Charset = DEFAULT_CHARSET
    PrintSettings.Font.Color = clWindowText
    PrintSettings.Font.Height = -11
    PrintSettings.Font.Name = 'Tahoma'
    PrintSettings.Font.Style = []
    PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
    PrintSettings.HeaderFont.Color = clWindowText
    PrintSettings.HeaderFont.Height = -11
    PrintSettings.HeaderFont.Name = 'Tahoma'
    PrintSettings.HeaderFont.Style = []
    PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
    PrintSettings.FooterFont.Color = clWindowText
    PrintSettings.FooterFont.Height = -11
    PrintSettings.FooterFont.Name = 'Tahoma'
    PrintSettings.FooterFont.Style = []
    PrintSettings.PageNumSep = '/'
    HeaderHeight = 0
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -13
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = []
    ProgressSettings.ValueFormat = '%d%%'
    SizeWithForm = True
    SortShow = True
    StretchColumn = True
    ItemHeight = 40
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    OnRightClickCell = lvMitarbeiterRightClickCell
    Version = '1.9.1.1'
  end
  object edNachname: TLabeledEdit
    Left = 17
    Top = 432
    Width = 232
    Height = 27
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 74
    EditLabel.Height = 19
    EditLabel.Caption = 'Nachname'
    TabOrder = 1
    Text = ''
  end
  object edVorname: TLabeledEdit
    Left = 263
    Top = 432
    Width = 234
    Height = 27
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 64
    EditLabel.Height = 19
    EditLabel.Caption = 'Vorname'
    TabOrder = 2
    Text = ''
  end
  object edPersonalNr: TLabeledEdit
    Left = 509
    Top = 432
    Width = 164
    Height = 27
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 77
    EditLabel.Height = 19
    EditLabel.Caption = 'PersonalNr'
    TabOrder = 3
    Text = ''
    TextHint = ' '
  end
  object btnNewMitarbeiter: TButton
    Left = 17
    Top = 472
    Width = 174
    Height = 36
    Anchors = [akLeft, akBottom]
    Caption = 'Neuer Eintrag'
    TabOrder = 5
    OnClick = btnNewMitarbeiterClick
  end
  object btnSave: TButton
    Left = 708
    Top = 428
    Width = 161
    Height = 36
    Anchors = [akLeft, akBottom]
    Caption = 'Speichern'
    TabOrder = 4
    OnClick = btnSaveClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 883
    Height = 121
    Align = alTop
    TabOrder = 6
    object lbHinweis: TLabel
      AlignWithMargins = True
      Left = 11
      Top = 11
      Width = 861
      Height = 99
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      Caption = 
        'Die Namen aller Mitarbeiter im Dienstplan, m'#252'ssen hier inklusive' +
        ' deren PersonalNr eingetragen werden.'#13'In dieser Liste fehlende M' +
        'itarbeiter werden anstatt mit der PersonalNr mit Namen angezeigt' +
        '.'#13#13'In der generierten Zeiterfassung werden die Namen der Mitarbe' +
        'iter, die nicht hier angegeben wurden, nicht angezeigt.'
      WordWrap = True
      ExplicitWidth = 836
      ExplicitHeight = 76
    end
  end
  object btnLoadMitarbeiterlisteFromWeb: TButton
    Left = 263
    Top = 472
    Width = 410
    Height = 36
    Anchors = [akLeft, akBottom]
    Caption = 'Mitarbeiterliste vom Server laden'
    DisabledImageName = 'btnLoadMitarbeiterlisteFromWeb'
    TabOrder = 7
    Visible = False
    OnClick = btnLoadMitarbeiterlisteFromWebClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 528
    Width = 883
    Height = 33
    AutoHint = True
    Panels = <
      item
        Width = 700
      end
      item
        Alignment = taCenter
        Width = 200
      end>
    ParentFont = True
    ParentShowHint = False
    ShowHint = True
    UseSystemFont = False
  end
  object MainMenu1: TMainMenu
    Left = 344
    Top = 240
    object Mitarbeiter1: TMenuItem
      Caption = 'Mitarbeiter'
      object Exportieren1: TMenuItem
        Caption = 'Sicherung erstellen'
        OnClick = Exportieren1Click
      end
      object Exportieren2: TMenuItem
        Caption = 'aus Sicherung importieren'
        OnClick = Exportieren2Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object N2: TMenuItem
        Caption = 'Mitarbeiterliste vom Server laden'
      end
    end
  end
end
