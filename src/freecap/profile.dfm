object frmProfile: TfrmProfile
  Left = 233
  Top = 238
  ActiveControl = Edit1
  BorderStyle = bsDialog
  Caption = 'Profile'
  ClientHeight = 257
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 104
    Width = 83
    Height = 13
    Caption = 'Working directory'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 63
    Height = 13
    Caption = 'Program path'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 58
    Height = 13
    Caption = 'Profile name'
  end
  object Label4: TLabel
    Left = 8
    Top = 152
    Width = 94
    Height = 13
    Caption = 'Program parameters'
  end
  object Edit1: TEdit
    Left = 8
    Top = 24
    Width = 257
    Height = 21
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 8
    Top = 72
    Width = 313
    Height = 21
    TabOrder = 1
  end
  object Edit3: TEdit
    Left = 8
    Top = 120
    Width = 313
    Height = 21
    TabOrder = 2
  end
  object Button1: TButton
    Left = 328
    Top = 72
    Width = 105
    Height = 25
    Caption = 'Browse...'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 224
    Width = 113
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 336
    Top = 224
    Width = 113
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Edit4: TEdit
    Left = 8
    Top = 168
    Width = 313
    Height = 21
    TabOrder = 6
  end
  object checkAutorun: TCheckBox
    Left = 8
    Top = 192
    Width = 313
    Height = 17
    Caption = 'Run program at FreeCap startup'
    TabOrder = 7
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Executables|*.exe'
    Left = 328
    Top = 16
  end
end
