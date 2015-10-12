object frmCfgSelect: TfrmCfgSelect
  Left = 232
  Top = 126
  Width = 548
  Height = 344
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Import your settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvItems: TListView
    Left = 8
    Top = 8
    Width = 525
    Height = 276
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        AutoSize = True
      end
      item
        AutoSize = True
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvItemsChange
    OnDblClick = btnOpenBrowsClick
  end
  object btnImport: TButton
    Left = 8
    Top = 289
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Import'
    TabOrder = 1
    OnClick = btnImportClick
  end
  object btnOpenFolder: TButton
    Left = 88
    Top = 289
    Width = 97
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Open folder'
    TabOrder = 2
    OnClick = btnOpenFolderClick
  end
  object btnOpenBrows: TButton
    Left = 192
    Top = 289
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Open in browser'
    TabOrder = 3
    OnClick = btnOpenBrowsClick
  end
  object btnCancel: TButton
    Left = 428
    Top = 291
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
