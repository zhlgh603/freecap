object frmPassPromt: TfrmPassPromt
  Left = 343
  Top = 307
  ActiveControl = Edit2
  BorderStyle = bsDialog
  Caption = 'SOCKS Authentication'
  ClientHeight = 133
  ClientWidth = 302
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
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 103
    Height = 13
    Caption = 'SOCKS V5 Username'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 101
    Height = 13
    Caption = 'SOCKS V5 Password'
  end
  object Button1: TButton
    Left = 8
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 224
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 120
    Top = 16
    Width = 153
    Height = 21
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 120
    Top = 48
    Width = 153
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
  end
end
