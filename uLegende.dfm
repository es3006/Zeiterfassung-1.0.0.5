object fLegende: TfLegende
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Legende'
  ClientHeight = 640
  ClientWidth = 994
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    994
    640)
  TextHeight = 19
  object lbSchicht: TLabeledEdit
    Left = 12
    Top = 503
    Width = 81
    Height = 27
    Hint = 
      '|Bitte geben Sie hier das K'#252'rzel aus dem Dienstplan ein! (z.B. T' +
      '5)'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 50
    EditLabel.Height = 19
    EditLabel.Caption = 'Schicht'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Text = ''
  end
  object lbEinsatz: TLabeledEdit
    Left = 102
    Top = 503
    Width = 89
    Height = 27
    Hint = '|Bitte geben Sie hier die Einsatz Nummer ein! (z.B. 10000)'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 49
    EditLabel.Height = 19
    EditLabel.Caption = 'Einsatz'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    Text = ''
    TextHint = ' '
  end
  object lbLeistungsart: TLabeledEdit
    Left = 200
    Top = 503
    Width = 105
    Height = 27
    Hint = '|Bitte geben Sie hier die Leistungsart ein! (z.B. normal)'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 85
    EditLabel.Height = 19
    EditLabel.Caption = 'Leistungsart'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    Text = ''
  end
  object lbBeschreibung: TLabeledEdit
    Left = 440
    Top = 503
    Width = 292
    Height = 27
    Hint = 
      '|Bitte geben Sie hier die Beschreibung f'#252'r das K'#252'rzel aus dem Di' +
      'enstplan ein! (z.B. Tagschicht Geb'#228'ude 5)'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 94
    EditLabel.Height = 19
    EditLabel.Caption = 'Beschreibung'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    Text = ''
  end
  object btnNewLegende: TButton
    Left = 8
    Top = 551
    Width = 174
    Height = 39
    Anchors = [akLeft, akBottom]
    Caption = 'Neuer Eintrag'
    TabOrder = 9
    OnClick = btnNewLegendeClick
  end
  object btnAddLegende: TButton
    Left = 827
    Top = 551
    Width = 159
    Height = 39
    Anchors = [akLeft, akBottom]
    Caption = 'Speichern'
    TabOrder = 8
    OnClick = btnAddLegendeClick
  end
  object lvLegende: TAdvListView
    AlignWithMargins = True
    Left = 10
    Top = 131
    Width = 974
    Height = 342
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
        Caption = 'Schicht'
        MaxWidth = 80
        MinWidth = 80
        Width = 80
      end
      item
        Caption = 'EinsatzNr'
        MaxWidth = 100
        MinWidth = 100
        Width = 100
      end
      item
        Caption = 'Leistungsart'
        MaxWidth = 120
        MinWidth = 120
        Width = 120
      end
      item
        Caption = 'VertragsNr'
        Width = 120
      end
      item
        AutoSize = True
        Caption = 'Beschreibung'
        MinWidth = 200
      end
      item
        Caption = 'Uhrzeit Von'
        MaxWidth = 120
        MinWidth = 120
        Width = 120
      end
      item
        Caption = 'Uhrzeit Bis'
        MaxWidth = 120
        MinWidth = 120
        Width = 120
      end>
    GridLines = True
    HideSelection = False
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    SortType = stBoth
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = lvLegendeSelectItem
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
    ItemHeight = 40
    DetailView.Font.Charset = DEFAULT_CHARSET
    DetailView.Font.Color = clBlue
    DetailView.Font.Height = -11
    DetailView.Font.Name = 'Tahoma'
    DetailView.Font.Style = []
    OnRightClickCell = lvLegendeRightClickCell
    Version = '1.9.1.1'
  end
  object edUhrzeitVon: TLabeledEdit
    Left = 738
    Top = 503
    Width = 103
    Height = 27
    Hint = '|Bitte geben Sie die Uhrzeit im Format HH:MM:SS ein'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 83
    EditLabel.Height = 19
    EditLabel.Caption = 'Uhrzeit Von'
    EditMask = '!90:00:00;1;_'
    MaxLength = 8
    NumbersOnly = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Text = '  :  :  '
    TextHint = 'Bitte geben Sie die Zeit im Format HH:MM:SS ein!'
  end
  object edUhrzeitBis: TLabeledEdit
    Left = 847
    Top = 503
    Width = 103
    Height = 27
    Hint = '|Bitte geben Sie die Uhrzeit im Format HH:MM:SS ein'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 75
    EditLabel.Height = 19
    EditLabel.Caption = 'Uhrzeit Bis'
    EditMask = '!90:00:00;1;_'
    MaxLength = 8
    NumbersOnly = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Text = '  :  :  '
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 607
    Width = 994
    Height = 33
    AutoHint = True
    Panels = <
      item
        Width = 900
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 994
    Height = 121
    Align = alTop
    TabOrder = 11
    object lbHinweis: TLabel
      AlignWithMargins = True
      Left = 11
      Top = 11
      Width = 972
      Height = 99
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      Caption = 
        'Geben Sie hier alle K'#252'rzel an, die im Dienstplan vorkommen und f' +
        #252'r die Lohnberechnung ben'#246'tigt werden.'#13'Geben Sie f'#252'r jeden Eintr' +
        'ag die Einsatznummer und die Leistungsart wie die Uhrzeiten im F' +
        'ormat HH:MM:SS ein.'#13#13'Beispiel: '#13'T5, 10000, normal,  Tagschicht G' +
        'eb'#228'ude 5,  06:00:00,  18:00:00'
      WordWrap = True
      ExplicitWidth = 800
      ExplicitHeight = 95
    end
  end
  object lbVertragsNr: TLabeledEdit
    Left = 314
    Top = 503
    Width = 120
    Height = 27
    Hint = '|Bitte geben Sie hier die VertragsNr ein!'
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 76
    EditLabel.Height = 19
    EditLabel.Caption = 'VertragsNr'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    Text = ''
  end
  object btnLoadLegendeFromWeb: TButton
    Left = 200
    Top = 551
    Width = 234
    Height = 39
    Anchors = [akLeft, akBottom]
    Caption = 'Legende vom Server laden'
    TabOrder = 12
    Visible = False
    OnClick = btnLoadLegendeFromWebClick
  end
  object MainMenu1: TMainMenu
    Left = 456
    Top = 264
    object Legende1: TMenuItem
      Caption = 'Legende'
      object Exportieern1: TMenuItem
        Caption = 'Exportieren'
        OnClick = Exportieern1Click
      end
      object Importieren1: TMenuItem
        Caption = 'Importieren'
        OnClick = Importieren1Click
      end
    end
  end
end
