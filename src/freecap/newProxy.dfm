object frmNewProxy: TfrmNewProxy
  Left = 309
  Top = 140
  ActiveControl = editSocksServ
  BorderStyle = bsDialog
  Caption = 'Proxy'
  ClientHeight = 352
  ClientWidth = 391
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox5: TGroupBox
    Left = 0
    Top = 0
    Width = 391
    Height = 313
    Align = alTop
    TabOrder = 0
    object Label12: TLabel
      Left = 34
      Top = 16
      Width = 31
      Height = 13
      Alignment = taRightJustify
      Caption = 'Server'
    end
    object Label13: TLabel
      Left = 294
      Top = 16
      Width = 19
      Height = 13
      Alignment = taRightJustify
      Caption = 'Port'
    end
    object GroupBox9: TGroupBox
      Left = 8
      Top = 48
      Width = 367
      Height = 257
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Protocol'
      TabOrder = 2
      object labUSERID: TLabel
        Left = 24
        Top = 40
        Width = 81
        Height = 13
        Caption = 'SOCKS4 User ID'
        Enabled = False
      end
      object GroupBox10: TGroupBox
        Left = 24
        Top = 80
        Width = 333
        Height = 73
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Authentication'
        TabOrder = 4
        object Label15: TLabel
          Left = 64
          Top = 16
          Width = 26
          Height = 13
          Alignment = taRightJustify
          Caption = 'Login'
        end
        object Label16: TLabel
          Left = 40
          Top = 40
          Width = 46
          Height = 13
          Alignment = taRightJustify
          Caption = 'Password'
        end
        object editLogin: TEdit
          Left = 96
          Top = 16
          Width = 223
          Height = 21
          HelpContext = 1006
          Anchors = [akLeft, akTop, akRight]
          Color = clInactiveBorder
          Enabled = False
          TabOrder = 0
        end
        object editPass: TEdit
          Left = 96
          Top = 40
          Width = 223
          Height = 21
          HelpContext = 1007
          Anchors = [akLeft, akTop, akRight]
          Color = clInactiveBorder
          Enabled = False
          PasswordChar = '*'
          TabOrder = 1
        end
      end
      object radio1: TRadioButton
        Left = 8
        Top = 16
        Width = 137
        Height = 17
        HelpContext = 1002
        Caption = 'SOCKS Version 4'
        TabOrder = 0
        OnClick = radio1Click
      end
      object checkAuth: TCheckBox
        Left = 112
        Top = 64
        Width = 169
        Height = 17
        HelpContext = 1005
        Caption = 'Authentication required'
        TabOrder = 3
        OnClick = checkAuthClick
      end
      object radio2: TRadioButton
        Left = 8
        Top = 64
        Width = 89
        Height = 17
        HelpContext = 1004
        Caption = 'SOCKS v5'
        Checked = True
        TabOrder = 2
        TabStop = True
        OnClick = radio2Click
      end
      object editUserId: TEdit
        Left = 112
        Top = 40
        Width = 177
        Height = 21
        HelpContext = 1003
        Color = clInactiveBorder
        Enabled = False
        TabOrder = 1
      end
      object radio3: TRadioButton
        Left = 8
        Top = 160
        Width = 105
        Height = 17
        HelpContext = 1008
        Caption = 'HTTP Proxy'
        TabOrder = 5
        OnClick = radio3Click
      end
      object checkHttpAuth: TCheckBox
        Left = 120
        Top = 160
        Width = 177
        Height = 17
        HelpContext = 1009
        Caption = 'Authentication required'
        Enabled = False
        TabOrder = 6
        OnClick = checkHttpAuthClick
      end
      object GroupBox11: TGroupBox
        Left = 24
        Top = 176
        Width = 333
        Height = 73
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Authentication'
        TabOrder = 7
        object Label17: TLabel
          Left = 64
          Top = 16
          Width = 26
          Height = 13
          Alignment = taRightJustify
          Caption = 'Login'
        end
        object Label18: TLabel
          Left = 40
          Top = 40
          Width = 46
          Height = 13
          Alignment = taRightJustify
          Caption = 'Password'
        end
        object editHttpUser: TEdit
          Left = 96
          Top = 16
          Width = 223
          Height = 21
          HelpContext = 1010
          Anchors = [akLeft, akTop, akRight]
          Color = clInactiveBorder
          Enabled = False
          TabOrder = 0
        end
        object editHttpPass: TEdit
          Left = 96
          Top = 40
          Width = 223
          Height = 21
          HelpContext = 1011
          Anchors = [akLeft, akTop, akRight]
          Color = clInactiveBorder
          Enabled = False
          PasswordChar = '*'
          TabOrder = 1
        end
      end
    end
    object editSocksServ: TEdit
      Left = 72
      Top = 16
      Width = 137
      Height = 21
      HelpContext = 1000
      TabOrder = 0
    end
    object editSocksPort: TEdit
      Left = 320
      Top = 16
      Width = 49
      Height = 21
      HelpContext = 1001
      TabOrder = 1
    end
  end
  object Button13: TButton
    Left = 152
    Top = 320
    Width = 105
    Height = 25
    HelpContext = 1012
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = Button13Click
  end
  object Button15: TButton
    Left = 272
    Top = 320
    Width = 113
    Height = 25
    HelpContext = 1013
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button15Click
  end
end
