object frmNewDirectIP: TfrmNewDirectIP
  Left = 335
  Top = 190
  ActiveControl = edIP
  BorderStyle = bsDialog
  Caption = 'New direct address'
  ClientHeight = 196
  ClientWidth = 282
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
  object Button1: TButton
    Left = 8
    Top = 168
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 200
    Top = 168
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 121
    Caption = 'IP address / netmask'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 120
      Height = 13
      Caption = 'IP address with CIDR bits'
    end
    object Label2: TLabel
      Left = 16
      Top = 64
      Width = 42
      Height = 13
      Caption = 'Netmask'
      Enabled = False
    end
    object edIP: TEdit
      Left = 16
      Top = 32
      Width = 209
      Height = 21
      TabOrder = 0
    end
    object edMask: TEdit
      Left = 16
      Top = 80
      Width = 209
      Height = 21
      Color = clInactiveBorder
      Enabled = False
      TabOrder = 1
    end
  end
  object RadioButton1: TRadioButton
    Left = 8
    Top = 136
    Width = 113
    Height = 17
    Caption = 'CIDR'
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 128
    Top = 136
    Width = 145
    Height = 17
    Caption = 'Simple'
    TabOrder = 4
    OnClick = RadioButton2Click
  end
end
