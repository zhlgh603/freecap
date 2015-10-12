object frmUpdates: TfrmUpdates
  Left = 224
  Top = 308
  Width = 560
  Height = 141
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Check update'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Gauge1: TGauge
    Left = 24
    Top = 24
    Width = 513
    Height = 17
    Progress = 0
  end
  object Gauge2: TGauge
    Left = 24
    Top = 64
    Width = 513
    Height = 17
    Progress = 0
  end
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 116
    Height = 13
    Caption = 'Current update progress:'
  end
  object Label2: TLabel
    Left = 24
    Top = 48
    Width = 94
    Height = 13
    Caption = 'Download progress:'
  end
  object Button1: TButton
    Left = 224
    Top = 88
    Width = 105
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
  end
end
