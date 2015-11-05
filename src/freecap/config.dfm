object frmConfig: TfrmConfig
  Left = 119
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 517
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    733
    517)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 417
    Top = 481
    Width = 73
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 497
    Top = 481
    Width = 73
    Height = 33
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object btnHelp: TButton
    Left = 657
    Top = 481
    Width = 73
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 733
    Height = 473
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 3
    object NavSplitter: TSplitter
      Left = 153
      Top = 1
      Height = 471
    end
    object PageControl1: TPageControl
      Left = 156
      Top = 1
      Width = 576
      Height = 471
      ActivePage = tabProgram
      Align = alClient
      Style = tsFlatButtons
      TabOrder = 0
      OnChange = PageControl1Change
      object tabDefault: TTabSheet
        HelpContext = 3100
        Caption = 'Proxy settings'
        OnShow = tabDefaultShow
        object Image1: TImage
          Left = 16
          Top = 8
          Width = 32
          Height = 32
          AutoSize = True
          Picture.Data = {
            07544269746D617036100000424D361000000000000036000000280000002000
            0000200000000100200000000000001000000000000000000000000000000000
            0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF008D8D8D008D8D8D0083828200A1A1A100FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00ECCCAF00FDECCB00F4CCA200AF917B006A6866007C7C7C008D8D8D008D8D
            8D008D8D8D008D8D8D008D8D8D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00ECCCAF00FEE6C100FADAB200DDB69400BD9E8100BD9E8100AF91
            7B00AF917B009280720092807200747371008D8D8D00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00E6CEBC00EDD6B900FAE1BD00FEDFB800FEDFB800FEDF
            B800FEDFB800FEDFB800F9D5AB00CFA483007E7168008D8D8D00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E6CEBC00ECDBC900E6CEBC00DBCA
            BB00DBCABB00ECCCAF00EDD6B900FEE6C100DDB694007C7C7C00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009B9792009B979200A09F9F00A1A1
            A100A1A1A100A1A1A100A1A1A100FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00DCD6D000F5DEBC00FAE1BD007C7C7C00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF009B9792009B97920090765F009B6432009B643200905C2C008A57
            3100745544006A6866007C7C7C009D9D9D00B5B5B500ACA7A300978B84007C7C
            7C008D8D8D00ACA7A300AC9D9300FDECCB00F5D9B500A1A1A100FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00B5936800B1733100D0723100D0723100D06F4A00D06F4A00D06F4A00D06F
            4A00C7644400B85932008A4C26007455440092807200D3B68D00E5B38900B790
            750090765F0092807200EDD6B900FDECCB00C5A89100FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D3B68D00CB8F
            3400D0723100C7644400C7644400B1715200B1715200C7644400C7644400C967
            4B00D06D5700D06D5700D06D5700CB845C00E8C19A00FADAB200E8BD9500E5B3
            8900ECCCAF00FFFDE600FDF9DB00C5A89100FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D3B68D00DE882000B859
            3200B8593200B24D1F00B24D1F00905C2C0087633500AA441600B24D1F00DB7A
            1200E07D1600D0723100D69F7C00E8C19A00EEC8A100FADAB200E8BD9500D69F
            7C00EDD6B900F6E5C800BD9E81007C7C7C00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D3B68D00E38C1B00B24D1F00AA44
            1600A53E0200A53E0200A53E020080541200516C27009D440400A53E0200C863
            0000E38C1B00D99F6900DDAD8800E8BD9500EEC8A100F9D5AB00F2D2AE00DDAD
            8800DDAD8800E5B38900CFA4830074737100FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E49E3A00AD491200A53E0200A53E
            0200A53E0200AD490000B34C00008B5303001B700B003E691300A2510200B34C
            0000BC621C00D69F7C00DDAD8800E8BD9500EEC8A100FEE6C100FFF4D100FDEC
            CB00F5D9B500EEC8A100E8BD9500978B8400FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00EAA3A000B4540E00A53E0200AD490000B34C
            0000B5520100B9560000C05D0000A55C0000037300000373000054660000B552
            010086380300CA957300DDAD8800EEC8A100F6E5C800F6E5C800FDECCB00FFF4
            D100FFF4D100FDECCB00E6C3A000C7BCB500FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00E49E3A00A53E0200B34C0000B5520100C05D
            0000C4600000C4600000C86300009A770B00027A0000027A0000027A00006C6B
            000086380300B1715200F2D2AE00F6E5C800ECCCAF00E8C19A00E6C3A000F5D9
            B500F5DEBC00BD9E8100ACA7A300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EEBA9A00C1681B00B34C0000B9560000C4600000C863
            0000CC690000D36F0000CF72000032830000028A000000840000008400003283
            0000863803005F382700DBB99C00E6C3A000F4CCA200F9D5AB00F4CCA200DBB9
            9C00B1715200745544009D9D9D00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EEBA9A00B5520100B9560000C4600000CC690000D36F
            0000D4740000DD790100DD7901001F90000000910000028A00002B8900009A77
            0B00A251020013080000310800005F38270074554400A8856600BD9E81007C7B
            4900876335008A4C26008D8D8D00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00E5B46F00B9560000C4600000CC690000D4740000DD79
            0100ED7E0000EC840000AF930700578C00001F9000006C8E0200D4870000F184
            0000CF7200008B530300153900001539000013080000130800002A481200516C
            2700736D3A009A591B0083828200BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00E5B46F00C05D0000CC690000D4740000DD790100E182
            0000A19908007F8E00005EA01300A1990800A1990800DB940200FB990000EA8B
            0000EA8B0000CB8802001F90000000840000027A000004560300045603003172
            1D00516C27009A591B00807C7A00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00E5B46F00C4600000D4740000E67C0000CB880200409E
            08000EAA1A00AF930700A19908007DA81800EEA20900FEA10600FB990000F498
            0200F18F0000EA8B00007F8E0000028A000000840000027A00001B700B002B6E
            0800516C27009A591B0085817D00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00E5B46F00CC690000DD790100E18200005EA0130009B2
            29001EB432002FB738002FB73800B5B53200FDB12E00FDB12E00FFAC1D00FEA1
            0600FB990000FB990000EA8B0000398B000032830000437D00006C6B00005466
            00003E69130096641A008D8D8D00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EDCE9200D36F0000E67C0000AF93070009B229001CBC
            43001CBC430025C14E0028C5550055C65A00D6C65900FFC55800FFBF4900FDB1
            2E00FFA40D00FB990000F18F00006C8E02002B8900001D820000027A00000373
            00001B700B00A2671D00A09F9F00BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EDCE9200DD790100ED7E0000AF9307001CBC430025C1
            4E0033C75B0036CB63003CD16F0030D06E0058D27100FBD77D00FBD77D00FFC5
            5800FDB12E00FEA10600FB9900007F8E000000910000028A000000840000027A
            00002B6E0800B1733100BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EDCE9200E49E3A00E18200004CB4350025C14E0033C7
            5B003CD16F004FD87F0077E08E0062DB85004FD87F00A4E39500FFE59900FBD7
            7D00FFBF4900FFAC1D00F4980200409E08006C8E02002B8900001D820000027A
            00005D770200A8856600BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00F1DC9A005EA013001CBC430033C75B003CD1
            6F004FD87F00B7DF8C00FEEEAB0098EBA90098EBA900ECFBCD00FFF2B400FBD7
            7D00FFC55800FFAC1D00FB990000E4910200AF930700028A0000437D0000027A
            00009A770B00B5B5B500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00EDCE920055C65A001CBC430036CB63004FD8
            7F0062DB8500BAE59B00DFF1B300CBF5BF00CFF7D400FDF9DB00CDEEAD0073D4
            7300D6C65900C5B532007DA81800E4910200E1820000578C0000008400006C8E
            0200B5936800BCBCBC00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F6E5BB0055C65A0036CB630073D4
            73008ADF8B0098EBA900B4F5BB00ECFBCD00B4F5BB00F4F8C000A4E3950030D0
            6E0033C75B0081B53400D09F0800E4910200EC840000C97B0000578C0000CB8F
            3400DBCABB00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F6E5BB00A0C050007FC9
            5F0097D87F00BAE59B00EAE7A100CBF5BF00CDEEAD00EAE7A1008ADF8B003CD1
            6F0028C555004CB43500F4980200F18F0000E1820000E1820000E49E3A00DBCA
            BB00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DCEEB70097D8
            7F0090CA6300AFD57A00BAE59B00BAE59B00BAE59B0077E08E004FD87F003CD1
            6F0028C555002FB73800DB940200EC840000EB921300E49E3A00DCD6D000FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F6E5
            BB00D5E39700AFD57A00BFCB640097D87F0077E08E0062DB850047D3740029C8
            5F001CBC43001EB43200CC9A1400FDB12E00E1BF8400DCD6D000FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00DCEEB700EAE7A100D5D98400AFD57A0097D87F00CFC04D00A0C0
            500090CA6300C0C46A00EDCE9200ECDBC900FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00F6E5BB00F6E5BB00F8E9C100F6E5BB00F6E5
            BB00F6E5BB00F6E5BB00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00}
          Transparent = True
        end
        object Label1: TLabel
          Left = 56
          Top = 8
          Width = 420
          Height = 33
          AutoSize = False
          Caption = 'Specify here settings for your default proxy.'
          WordWrap = True
        end
        object GroupBox6: TGroupBox
          Left = 72
          Top = 49
          Width = 329
          Height = 320
          Caption = 'Default proxy'
          TabOrder = 0
          DesignSize = (
            329
            320)
          object Label2: TLabel
            Left = 34
            Top = 16
            Width = 31
            Height = 13
            Alignment = taRightJustify
            Caption = 'Server'
          end
          object Label3: TLabel
            Left = 238
            Top = 16
            Width = 19
            Height = 13
            Alignment = taRightJustify
            Caption = 'Port'
          end
          object GroupBox4: TGroupBox
            Left = 8
            Top = 48
            Width = 312
            Height = 257
            Anchors = [akLeft, akTop, akRight]
            Caption = 'Protocol'
            TabOrder = 2
            DesignSize = (
              312
              257)
            object labUSERID: TLabel
              Left = 24
              Top = 40
              Width = 81
              Height = 13
              Caption = 'SOCKS4 User ID'
              Enabled = False
            end
            object GroupBox1: TGroupBox
              Left = 24
              Top = 80
              Width = 278
              Height = 73
              Anchors = [akLeft, akTop, akRight]
              Caption = 'Authentication'
              TabOrder = 4
              DesignSize = (
                278
                73)
              object Label4: TLabel
                Left = 64
                Top = 16
                Width = 26
                Height = 13
                Alignment = taRightJustify
                Caption = 'Login'
              end
              object Label5: TLabel
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
                Width = 168
                Height = 21
                HelpContext = 1006
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 0
              end
              object editPass: TEdit
                Left = 96
                Top = 40
                Width = 168
                Height = 21
                HelpContext = 1007
                Anchors = [akLeft, akTop, akRight]
                PasswordChar = '*'
                TabOrder = 1
              end
            end
            object Radio1: TRadioButton
              Left = 8
              Top = 16
              Width = 137
              Height = 17
              HelpContext = 1002
              Caption = 'SOCKS Version 4'
              TabOrder = 0
              OnClick = Radio1Click
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
            object Radio2: TRadioButton
              Left = 8
              Top = 64
              Width = 89
              Height = 17
              HelpContext = 1004
              Caption = 'SOCKS v5'
              Checked = True
              TabOrder = 2
              TabStop = True
              OnClick = Radio2Click
            end
            object editUserID: TEdit
              Left = 112
              Top = 40
              Width = 177
              Height = 21
              HelpContext = 1003
              Color = clInactiveBorder
              Enabled = False
              TabOrder = 1
            end
            object Radio3: TRadioButton
              Left = 8
              Top = 160
              Width = 105
              Height = 17
              HelpContext = 1008
              Caption = 'HTTP Proxy'
              TabOrder = 5
              OnClick = Radio3Click
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
            object GroupBox2: TGroupBox
              Left = 24
              Top = 176
              Width = 278
              Height = 73
              Anchors = [akLeft, akTop, akRight]
              Caption = 'Authentication'
              TabOrder = 7
              DesignSize = (
                278
                73)
              object Label9: TLabel
                Left = 64
                Top = 16
                Width = 26
                Height = 13
                Alignment = taRightJustify
                Caption = 'Login'
              end
              object Label10: TLabel
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
                Width = 168
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
                Width = 168
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
            Left = 264
            Top = 16
            Width = 49
            Height = 21
            HelpContext = 1001
            TabOrder = 1
          end
        end
      end
      object tabChain: TTabSheet
        HelpContext = 3200
        Caption = 'Proxy Chain'
        ImageIndex = 4
        object lvProxy: TListView
          Left = 0
          Top = 0
          Width = 568
          Height = 278
          Align = alClient
          Checkboxes = True
          Columns = <
            item
              Caption = 'Host'
              Width = 130
            end
            item
              Caption = 'Proto'
            end
            item
              Caption = 'Anon?'
            end
            item
              Caption = 'Ping'
              Width = 45
            end
            item
              AutoSize = True
              Caption = 'Status'
            end
            item
              AutoSize = True
              Caption = 'Country'
            end
            item
              AutoSize = True
              Caption = 'Test status'
            end
            item
              AutoSize = True
              Caption = 'Anon status'
            end>
          HideSelection = False
          IconOptions.Arrangement = iaLeft
          IconOptions.WrapText = False
          MultiSelect = True
          ReadOnly = True
          RowSelect = True
          PopupMenu = PopupMenu1
          ShowWorkAreas = True
          TabOrder = 0
          ViewStyle = vsReport
          OnColumnClick = lvProxyColumnClick
          OnCompare = lvProxyCompare
          OnCustomDrawItem = lvProxyCustomDrawItem
          OnDblClick = Edit1Click
          OnKeyUp = lvProxyKeyUp
          OnSelectItem = lvProxySelectItem
        end
        object Panel2: TPanel
          Left = 0
          Top = 278
          Width = 568
          Height = 162
          Align = alBottom
          BevelInner = bvLowered
          TabOrder = 1
          DesignSize = (
            568
            162)
          object ShareLabel: TLabel
            Left = 176
            Top = 40
            Width = 71
            Height = 13
            Caption = 'Through proxy:'
            Enabled = False
          end
          object btnProxyAdd: TButton
            Left = 8
            Top = 8
            Width = 81
            Height = 25
            Caption = 'Add'
            TabOrder = 0
            OnClick = btnProxyAddClick
          end
          object btnProxyDel: TButton
            Left = 96
            Top = 8
            Width = 83
            Height = 25
            Caption = 'Delete'
            TabOrder = 1
            OnClick = btnProxyDelClick
          end
          object btnUp: TButton
            Left = 412
            Top = 8
            Width = 69
            Height = 25
            Anchors = [akTop, akRight]
            Caption = 'Up'
            TabOrder = 2
            OnClick = Moveup1Click
          end
          object btnDown: TButton
            Left = 492
            Top = 8
            Width = 63
            Height = 25
            Anchors = [akTop, akRight]
            Caption = 'Down'
            TabOrder = 3
            OnClick = Movedown1Click
          end
          object btnImportFile: TButton
            Left = 192
            Top = 8
            Width = 113
            Height = 25
            Caption = 'Import from file'
            TabOrder = 4
            OnClick = btnImportFileClick
          end
          object btnImportShare: TButton
            Left = 8
            Top = 48
            Width = 161
            Height = 25
            Caption = 'Import from SocksShare(tm)'
            Enabled = False
            TabOrder = 5
            OnClick = btnImportShareClick
          end
          object comboProxy: TComboBox
            Left = 176
            Top = 56
            Width = 145
            Height = 21
            Style = csDropDownList
            Enabled = False
            ItemHeight = 13
            TabOrder = 6
            Items.Strings = (
              '<Direct connection>')
          end
          object ShareMemo: TMemo
            Left = 8
            Top = 80
            Width = 556
            Height = 73
            Anchors = [akLeft, akTop, akRight]
            ScrollBars = ssVertical
            TabOrder = 7
          end
        end
      end
      object tabShare: TTabSheet
        Caption = 'SocksShare'
        ImageIndex = 6
        DesignSize = (
          568
          440)
        object groupSocksShare: TGroupBox
          Left = 0
          Top = 0
          Width = 566
          Height = 217
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Socks Sharing technology'
          TabOrder = 0
          object labGUID: TLabel
            Left = 16
            Top = 48
            Width = 71
            Height = 13
            Caption = 'Personal GUID'
          end
          object edGUID: TEdit
            Left = 16
            Top = 64
            Width = 241
            Height = 21
            Color = clInactiveBorder
            ReadOnly = True
            TabOrder = 0
            Text = '2F473810-FE98-4427-B1C3-991A3198B30D'
          end
          object checkSocksShare: TCheckBox
            Left = 16
            Top = 24
            Width = 193
            Height = 17
            Caption = 'Enable SocksShare(tm)'
            TabOrder = 1
            OnClick = checkSocksShareClick
          end
          object radioAnon: TRadioButton
            Left = 16
            Top = 96
            Width = 305
            Height = 17
            Caption = 'Share only anonymous proxies'
            Checked = True
            TabOrder = 2
            TabStop = True
          end
          object radioNonAnon: TRadioButton
            Left = 16
            Top = 120
            Width = 305
            Height = 17
            Caption = 'Share non-anonymous as well'
            TabOrder = 3
          end
        end
      end
      object tabDirect: TTabSheet
        HelpContext = 3050
        Caption = 'Direct connections'
        ImageIndex = 3
        object Image4: TImage
          Left = 16
          Top = 8
          Width = 32
          Height = 32
          AutoSize = True
          Picture.Data = {
            07544269746D6170360C0000424D360C00000000000036000000280000002000
            0000200000000100180000000000000C00000000000000000000000000000000
            0000C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            666666666666666666666666666666666666666666666666666666C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8666666666666
            7058547C5A577C5A577C5A577C5A577C5A577C5A575E423C58413868554B6666
            66C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8666666A38086CBBBBB
            DAD0D0DAD0D0D6CCCCD7C7C7D4C1C1D5BABAC7A2A2CCA6A6B692927955525741
            37666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8666666666666CBBBBBDFDFDFDFDFDF
            DDDBDBDDDBDBDBD6D6DAD0D0D7C7C7D5BABAD6CCCCBCAAA8BB9494CA9F9FA97B
            7C584138666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8666666666666775545775545C09B95DDDBDBE7E7E7ECECEC
            E7E7E7DFDFDFDDDBDBDAD0D0D5BABADFD1D0D4C1C1CBBBBBCBBBBBB38B89CA9F
            9F966A69666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8855746A36143B37866AD7B74A97B7CA38086AD7B74C18F76D6B2A4
            E3D2C8E6DFDDDFDFDFDBD6D6CFB4B4DFD1D0CCA6A6CCA6A6CCA6A6B58484CFA4
            A4C1898F666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8D7A783D6B2A4A891969C9095948599ACA1C59D9DD47277D17575C7
            8A80BBC8A5A9DFC9BEDFD1D0CFB1B1DCBAB9CC9696CC9696CC9696B58484CFA4
            A4B58484666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8DCBA99E0B693877368C8C8C8C8C8C8C8C8C8BEA59FECECECF4EEEEBCADCE
            909BE64F65E55467E09F9ED5ECD9D2DCBAB9CA8787CA8787CA8787B87C7CCA9F
            9F8C6D6B666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8E6BC94666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8BCAAA8D5BABAC68282
            CC9696C8A5A99C9DD53B57E93256F39FABF1F4EEEEDBA6A6CC7171B87C7C8268
            5E666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8DCBA99666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8AE8281DB9272
            FED9A3E7C5BCCC9696C682828660A31D3AE3204DFFC3C9F2F2D1CA70514B5741
            37666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8E0B693666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8BB9494DC8E46
            FFA518FFA518FBC069EDC5A3DBA6A6C977776F51AA1D3AE3676FD1E3D2C88268
            5E5D483C666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8E6BC94B2A093666666C8C8C8C8C8C8C8C8C8C8C8C8CA9F9FED9E37
            FFAC26FFAC26FEAF2FFEAF2FFCB341F2BE7DDCA696C1898F5645AA413EAACDB9
            B9AF947C584138666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8E6BC94B3A69E666666C8C8C8C8C8C8A28B89CA9F9FFEAF2F
            FEAF2FFFB436FFB538FFB63AFFB63AFFB63AFFB538F4B55EE3AD858C70A54533
            8DC09B95D3B0855D483C666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8A992BCAAA8666666C8C8C8A28B89CC9D8EFFB538
            FEB73FFFBA42FFBD48FFBD48FFBD48FFBD48FFBD48FFBA42FEB73FFCB341CF96
            61603B6CA06E6AD7A783644F45666666666666666666C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8BAA198B6ADACA59892B3999CD1A07AFFBD48
            FFBF4DFFC353FFC353FFC353FFC75BFFC353FFC353FFC353FFBF4DFFBD48FFBA
            42CF85516C3656A96A5EC18F76644F453F78952EC7E7666666C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8BAA198A38F8FD5BABAD6A369FFC353
            FFC75BFFC75BFEC962FFCB65FFCB65FFCB65FEC962FFC75BFFC75BFFC353FFBF
            4DDF8E5A6B3F3F703337D1886D9B71613F78952EC7E7666666666666666666C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B3999CD9C0C0EAB563FFC75B
            FFCB65FFCE6AFFCF6CFFD272FFD272FFD272FFCF6CFFCF6CFFCB65FEC962FFC7
            5BD4826670514B816868863320DB9272735B52C8C8C8C8C8C833B4E233BCE466
            6666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8A59892CFB1B1FEC962FFCE6A
            FFD272FFD67AFFD67AFFDA81FFDA81FFDA81FFD67AFFD67AFFD272FFCE6AFEC9
            62CE806B725E56C8C8C87F4B41AE512DA06E6AC8C8C8C8C8C840ACC93BB0D1C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8BCAAA8C8AEA1FFCE6AFFD272
            FFD67AFFDD88FFDD88FFE191FFE191FFE191FFDD88FFDD88FFDA81FFD272FFCF
            6CB76C6C76635BC8C8C8C8C8C88E3312C2776C705854666666666666C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8DAD0D0C7AF90FFD272FFD67A
            FFDD88FFE191FFE699FFE699FFE99FFFE99FFFE699FFE191FFDD88FFDA81F7C8
            75985E5C725E56C8C8C8C8C8C887331DB566584E687B357EA04E687B666666C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B6ADACE6DFDDD3B085FFD67AFFDD88
            FFE191FFE699FFECA6FFEFABFFEFABFFEFABFFECA6FFE99FFFE191FFDD88F2BE
            7D985E5C644F45C8C8C86A4F55803329855746318FBB2AF0FF1FAFD9666666C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B6ADACDED7D7EBC27DFFDA81FFE191
            FFE699FFECA6FFF1B1FFF5B9FFF5B9FFF5B9FFF1B1FFECA6FFE699FFE191DEAF
            81764C4858454B513D606033547033378479763B99C51FE0FE26A9D1C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B7B6B6CDC9C9A29492AC9C91C7AF90
            DBBF99E9D7A5FFF5B9FFF9C0FFFDC9FFF9C0FFF5B9FFF1B1FFE99FFFE699DEAF
            814345BC3033A749377659415A666666666666C8C8C8C8C8C8666666C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B7B6B6F4EEEECDC9C9BBB3B3AB9E9E
            A38F8FA38F8FA68C8CBEA59FCFBCA6DFD2B2EFE4B5FFF1B1FFECA6FFE699CC9B
            806A4E49C8C8C8C8C8C8377AA5256EA045526666666639A8C533B4E2666666C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9DAD0D0CBB9B9BCAAA8B69292AB8888AB8888B38B89C39D8CD8B48DBD8A
            80725E56C8C8C84088BB1FE0FE20E8FD1B85C466666639ACD138B9E4666666C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8B9B9B9B9B9B9AFA4A3BCAAA8C1ABABCFB1B1C8A5A9C09B95B68B8BAE82
            81847976C8C8C8428BBF20E8FD2AF0FF318FBB666666C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C86592AD666666666666977C
            7B666666666666C8C8C83B94C83B99C5666666C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C829D8FF29D8FF666666C8C8
            C846A0C382949E666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C835ECFF46A0C3666666C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8C8
            C8C8}
          Transparent = True
        end
        object Label11: TLabel
          Left = 54
          Top = 0
          Width = 408
          Height = 41
          AutoSize = False
          Caption = 
            'Specify here addresses and applications that should make a direc' +
            't connections. You can specify one IP or IP with netmask, for ex' +
            'ample "192.168.0.0/24"'
          WordWrap = True
        end
        object GroupBox7: TGroupBox
          Left = 80
          Top = 40
          Width = 305
          Height = 137
          Caption = 'Direct addresses'
          TabOrder = 0
          object Button8: TButton
            Left = 200
            Top = 16
            Width = 97
            Height = 25
            HelpContext = 1101
            Caption = 'Add'
            TabOrder = 1
            OnClick = Button8Click
          end
          object Button9: TButton
            Left = 200
            Top = 48
            Width = 97
            Height = 25
            HelpContext = 1102
            Caption = 'Delete'
            TabOrder = 2
            OnClick = Button9Click
          end
          object lstDirect: TListBox
            Left = 2
            Top = 15
            Width = 183
            Height = 120
            HelpContext = 1100
            Align = alLeft
            ItemHeight = 13
            TabOrder = 0
          end
        end
        object GroupBox5: TGroupBox
          Left = 80
          Top = 200
          Width = 305
          Height = 137
          Caption = 'Direct ports'
          TabOrder = 1
          object Button2: TButton
            Left = 200
            Top = 16
            Width = 97
            Height = 25
            HelpContext = 1101
            Caption = 'Add'
            TabOrder = 1
            OnClick = Button2Click
          end
          object Button3: TButton
            Left = 200
            Top = 48
            Width = 97
            Height = 25
            HelpContext = 1102
            Caption = 'Delete'
            TabOrder = 2
            OnClick = Button3Click
          end
          object lstDirectPorts: TListBox
            Left = 2
            Top = 15
            Width = 183
            Height = 120
            HelpContext = 1100
            Align = alLeft
            ItemHeight = 13
            TabOrder = 0
          end
        end
      end
      object tabProgram: TTabSheet
        HelpContext = 3090
        Caption = 'Program'
        ImageIndex = 2
        DesignSize = (
          568
          440)
        object Image3: TImage
          Left = 16
          Top = 8
          Width = 32
          Height = 32
          AutoSize = True
          Picture.Data = {
            07544269746D617036100000424D361000000000000036000000280000002000
            0000200000000100200000000000001000000000000000000000000000000000
            0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00BF9D9D00AC828200AC828200AC828200AC828200AC828200AC828200AC82
            8200AC828200FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CDADAD00C3A9
            A900C3A9A900BF9D9D00BF9D9D00BF9D9D00BF9D9D00BF9D9D00BF9D9D00BF9D
            9D00BF9D9D00BF9D9D00B3838300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C3A9A900C3A9A900BCA3
            A300D4CDCD00DCD2D200DCD2D200DCD2D200DCD2D200DDCACA00DAC2C200DAC2
            C200D6BABA00C6A1A100BF9D9D00B3838300B3838300FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C3A9A900C3A9A900DED9D900E4E3
            E300E4E3E300E2DADA00DED9D900DCD2D200DCD2D200DCD2D200C6A1A100B38C
            8C00BD949400CCB2B200D4B1B100C6A1A100B3838300B3838300FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00C3A9A900C3A9A900E4E3E300E4E3E300E4E3
            E300E4E3E300E4E3E300E4E3E300DED9D900DCD2D200CFBFBF00CCB2B200C5C4
            C400A4989800A4818100B38C8C00D4B1B100CFA7A600B3838300FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D6C3C300E2DADA00E4E3E300EDEDED00EDED
            ED00EDEDED00EDEDED00E4E3E300E2DADA00DED9D900C3A9A900DCD2D200C1B2
            B200AA959500AA959500AB8B8B00D4B1B100D3AAAA00C5959500CA9B9B00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D6C3C300E4E3E300EDEDED00F2F2F200F9F9
            F900F2F2F200EDEDED00E4E3E300E4E3E300DED9D900BF9D9D00E2DADA00BCA3
            A300B38C8C00B38C8C00B38C8C00D4B1B100D3AAAA00CA9B9B00CA9B9B00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D6C3C300E4E3E300EDEDED00F9F9F900F9F9
            F900F9F9F900F2F2F200EDEDED00E4E3E300DED9D900C6A1A100DDCACA00B38C
            8C00B38C8C00BD828200BD828200D4B1B100D3AAAA00CA9B9B00CA9B9B00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D6C3C300D6C3C300EDEDED00F9F9F900F9F9
            F900F9F9F900F2F2F200EDEDED00E4E3E300D6C3C300CDADAD00D4B1B100BD82
            8200BD828200C27E7E00C27E7E00D4B1B100D3AAAA00C5959500CA9B9B00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6C3C300DDCACA00E2DADA00CC8B
            8B00CC8B8B00D9BDBD00E4E3E300E4E3E300CDADAD00D4B1B100CA9B9B00C27E
            7E00C27E7E00C27E7E00CC737300D4B1B100CA9B9B00CA9B9B00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6C3C300CA9B9B00CA9B
            9B00ECC7B200DDB3B300CC8B8B00D9A6A600CA9B9B00D9A6A600CA7D7D00CC73
            7300CC737300CC737300CC737300CA9B9B00CA9B9B00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5959500CB98
            9600FFAA1A00FCBF6000F5DBA500E2C0C000CA9B9B00CC737300CC737300CC73
            7300CD6C6C00CD6C6C00CC737300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E2A85800D176
            3400D1763400D3714900D16F4900D16F4900BF5E3400D2735C00CB989600D69A
            7800FFAA1A00FFAA1A00FFB12A00FFB53500F9CC7D00ECC7B200D9A6A600CC73
            7300C66A6A00BC615300CC737300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E2A85800D1763400C4614200C461
            42009E6E5200BF5E3400C4614200C4614200CB694E00D2735C00CFA7A600D99A
            6800FFB12A00FFB12A00FFB53500FFB53500FFB53500FFB53500FCBF6000EEC4
            9600D9A6A600D2898400D2898400D2898400FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00F5960700BF5E3400B24E1F00A8481600A848
            160062661D00A8481600A8481600B24E1F00B24E1F00BC615300D4B1B100D397
            5C00FFB53500FFB93C00FFB93C00FFBC4300FFBC4300FFBC4300FFBC4300FFBC
            4300FEBD4B00EEBE7500E0AE9700CC8B8B00CC737300D2898400FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00EA9A2E00B24E1F00A6430200A6430200A6430200A643
            02003172090062661D00A6430200A6430200A6430200B1695000D4B1B100ECAE
            5000FFBC4300FFBC4300FEBD4B00FFC14D00FFC14D00FFC35300FFC35300FFC1
            4D00FFC14D00FEBD4B00FFBC4300F8B85700D9AF7E00D2898400CC737300FFFF
            FF00FFFFFF00E2A85800B5550E00A6430200AC480000B24E0000B6530000B653
            000031720900027D020062661D00B6530000B24E0000BD867200CDADAD00FEBD
            4B00FFC14D00FFC35300FFC35300FFC65B00FFC65B00FFC65B00FFC65B00FFC6
            5B00FFC65B00FFC35300FFC35300FFC14D00FFBC4300FFBC4300CC737300FFFF
            FF00E2A85800D68F3800AC480000B24E0000B6530000BD5A0000C15E0000C765
            000031720900027D0200027D020087640000BD5A0000CFA7A600C8A79E00FFC3
            5300FFC65B00FFC85E00FFCB6500FFCB6500FFCB6500FFCB6500FFCB6500FFCB
            6500FFCB6500FFCB6500FFC65B00FFC35300FFC35300F6B15200BD828200FFFF
            FF00E2A85800B85A0E00B6530000BD5A0000C7650000C7650000CF6D00008980
            0000027D0200027D0200027D020031720900C66D1500D9BDBD00CFA88D00FFC6
            5B00FFCB6500FFCB6500FFCF6C00FFD37300FFD37300FFD37300FFD37300FFD3
            7300FFD37300FFCF6C00FFCB6500FFCB6500FFC65B00F2B15C00BD828200FFFF
            FF00E2A85800B6530000C15E0000C7650000D5740000D5740000DD7C00008980
            00000C8F00000C8F00000C8F000089800000D1763400E2CECE00D9AF7E00FFCB
            6500FFD06D00FFD37300FFD67D00FFD67D00FFD67D00FFD67D00FFD67D00FFD6
            7D00FFD67D00FFD37300FFD37300FFCF6C00FFCB6500E5A36D00BD828200FFFF
            FF00E2A85800C15E0000C7650000D5740000DD7C0000DA870200AF92040054A1
            0D004499000044990000DA870200E7870000D3975C00E2CECE00D9AF7E00FFD3
            7300FFD67D00FFD67D00FFDA8400FFDD8A00FFDD8A00FFDD8A00FFDD8A00FFDD
            8A00FFDA8400FFDA8400FFD67D00FFD37300FFD06D00E5A36D00BD828200FFFF
            FF00E2A85800C7650000D5740000DD7C0000AF92040016AC1F0054A10D0054A1
            0D003FA81600AF920400F5960700F5960700CFA88D00D6C3C300EEBE7500FFD6
            7D00FFDA8400FFDD8A00FFDD8A00FFE29300FFE29300FFE49A00FFE29300FFE2
            9300FFE29300FFDD8A00FFDA8400FFD67D00FFD67D00D4907900BD828200FFFF
            FF00E2A85800CF6D0000DD7C0000AF92040016AC1F0016AC1F004AB231003CB5
            3200D6B43000FFB12A00FFAA1A00F5960700CFBFBF00CCB2B200F9CC7D00FFDA
            8400FFDD8A00FFE29300FFE49A00FFE49A00FFE9A300FFE9A300FFE9A300FFE9
            A300FFE49A00FFE29300FFDD8A00FFDD8A00FFD67D00D4907900BD828200FFFF
            FF00E2A85800D5740000DD7C00004EA61E001EB73A0028C04D0028C04D0028C0
            4D0081C65A00F3C75B00FFC35300ECAE5000E2DADA00C7B3A700FFD67D00FFDD
            8A00FFE29300FFE49A00FFE9A300FFE9A300FFEEAC00FFEEAC00FFEEAC00FFEE
            AC00FFE9A300FFE7A000FFE49A00FFE29300FFDA8400C27E7E00BD828200FFFF
            FF00E2A85800DD7C0000DA8702004AB2310028C04D0032C85D003FD16F003FD1
            6F003FD16F00A1D88000FFDA8400D9AF7E00F2EBEB00C0AC9A00FFDA8400FFDD
            8A00FFE49A00FFE9A300FFEEAC00FFF1B400FFF1B400FFF4B900FFF4B900FFF1
            B400FFF1B400FFEEAC00FFE9A300FFE49A00FFDD8A00C27E7E00B38C8C00FFFF
            FF00E2A85800EA9A2E00869F1E0028C04D0032C85D0055D475006CDF8B0081E1
            91006CDF8B006CDF8B00FFE9A300CDBB9D00EDEDED00D3B98D00FFDD8A00FFE2
            9300FFE7A000FFEEAC00FFF1B400FFF4B900FFF9C200FFF9C200FFF9C200FFF9
            C200FFF4B900FFF1B400FFE9A300FFE49A00EEC88F00C27E7E00BD949400FFFF
            FF00FFFFFF00CEE39D001EB73A0032C85D003FD16F0062DD8700B4E8A100BFF4
            BB00A1EEAD00D8F7CF00D9F1B400C5C0BB00E4E3E300A4989800C0AC9A00CDBB
            9D00DFCA9F00F5DBA500FFF4B900FFF9C200FFFDCD00FFFDCD00FFFDCD00FFFD
            CD00FFF9C200FFF1B400FFEEAC00FFE9A300EEC88F00BD828200BD949400FFFF
            FF00FFFFFF00CEE39D0087D2760032C85D0055D475007BE39700A1EEAD00BFF4
            BB00BFF4BB00BFF4BB00A9DD9800C5C4C400F9F9F900D4CDCD00BBB2B200AC9F
            9F00AA959500AA959500AA959500C0AC9A00D2C2AD00E1D6B800F0EBC400FFFD
            CD00FFF9C200FFF4B900FFEEAC00FFE9A300DEB58F00BD828200BD949400FFFF
            FF00FFFFFF00FFFFFF00CEE39D00A4BF540055D4750081E19100A1EEAD00D9F1
            B400BFF4BB00D9F1B40081E1910073B989009DC1A500C5C4C400D4CDCD00E4E3
            E300EEE6E600E2DADA00D6C3C300CCB2B200BCA3A300B38C8C00B38C8C00B38C
            8C00C8A79E00D4BAA000E8D0A400F5DBA500CFA88D00BD828200BD949400FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00CEE39D00A9DD98006CDF8B009BE59B00A1EE
            AD00B4E8A1007BE3970062DD87003FD16F0028C04D0072AA2500DE8F2200D68F
            3800BEA17D00CFBFBF00C1B2B200CFBFBF00DDCACA00E2CECE00E2CECE00DAC2
            C200CCB2B200BF9D9D00BD949400B38C8C00B38C8C00BD828200BD949400FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CEE39D00CEE39D009BE59B008BDE
            8B007BE3970062DD870055D4750032C85D0028C04D007EAE2E00F6AB3300F6AB
            3300FFFFFF00FFFFFF00FFFFFF00FFFFFF00C3A9A900C3A9A900C3A9A900C3A9
            A900C3A9A900CCB2B200D9BDBD00DAC2C200BD949400BD828200FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CEE39D00CEE3
            9D00DBE59A00D2D47500F3C75B00D2D47500D2D47500D2D47500FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00C3A9A900C3A9A900C3A9A900C3A9A900FFFFFF00FFFF
            FF00}
          Transparent = True
        end
        object Label8: TLabel
          Left = 56
          Top = 8
          Width = 289
          Height = 33
          AutoSize = False
          Caption = 'Here you can customize the main program settings'
          WordWrap = True
        end
        object GroupBox8: TGroupBox
          Left = 16
          Top = 48
          Width = 535
          Height = 241
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Program settings'
          TabOrder = 0
          object checkOne: TCheckBox
            Left = 24
            Top = 16
            Width = 257
            Height = 25
            HelpContext = 1200
            Caption = 'Only one program instance'
            TabOrder = 0
          end
          object checkRunAtStartup: TCheckBox
            Left = 24
            Top = 40
            Width = 257
            Height = 25
            HelpContext = 1201
            Caption = 'Run at system startup'
            TabOrder = 1
          end
          object checkRunTray: TCheckBox
            Left = 24
            Top = 64
            Width = 257
            Height = 25
            HelpContext = 1202
            Caption = 'Run minimized to system tray'
            TabOrder = 2
          end
          object checkMinTray: TCheckBox
            Left = 24
            Top = 88
            Width = 257
            Height = 25
            HelpContext = 1203
            Caption = 'Minimize to system tray'
            TabOrder = 3
          end
          object checkCaption: TCheckBox
            Left = 24
            Top = 112
            Width = 321
            Height = 25
            HelpContext = 1204
            Caption = 'Add "via Freecap" to captions of SOCKS'#39'ed programs'
            TabOrder = 4
          end
          object checkWarns: TCheckBox
            Left = 24
            Top = 136
            Width = 377
            Height = 25
            HelpContext = 1206
            Caption = 'Show warnings in dialog boxes'
            TabOrder = 5
          end
          object checkUDP: TCheckBox
            Left = 24
            Top = 160
            Width = 377
            Height = 25
            HelpContext = 1206
            Caption = 'Use some tricks to traverse UDP trought NAT'
            TabOrder = 6
          end
          object checkHide: TCheckBox
            Left = 24
            Top = 184
            Width = 377
            Height = 25
            HelpContext = 1206
            Caption = 'Hide FreeCap by Alt+F4 instead of closing'
            TabOrder = 7
          end
          object checkAdvHook: TCheckBox
            Left = 24
            Top = 208
            Width = 481
            Height = 25
            HelpContext = 1206
            Caption = 'Use advanced hooking technic (for ASProtect'#39'ed programs)'
            TabOrder = 8
          end
        end
        object DNSGroup: TRadioGroup
          Left = 16
          Top = 312
          Width = 185
          Height = 113
          HelpContext = 1205
          Anchors = [akLeft, akTop, akRight]
          Caption = 'DNS name resolving'
          ItemIndex = 0
          Items.Strings = (
            'Local'
            'Local then remote'
            'Remote')
          TabOrder = 1
        end
        object GroupBox9: TGroupBox
          Left = 216
          Top = 312
          Width = 337
          Height = 113
          Caption = 'Check new versions'
          TabOrder = 2
          Visible = False
          object Label16: TLabel
            Left = 24
            Top = 47
            Width = 73
            Height = 26
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'Check every'
            Layout = tlCenter
          end
          object Label17: TLabel
            Left = 160
            Top = 48
            Width = 28
            Height = 13
            Caption = 'day(s)'
            Layout = tlCenter
          end
          object Label18: TLabel
            Left = 16
            Top = 80
            Width = 81
            Height = 25
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'Via proxy'
            Layout = tlCenter
          end
          object CheckBox1: TCheckBox
            Left = 16
            Top = 16
            Width = 153
            Height = 17
            Caption = 'Check updates'
            Checked = True
            State = cbChecked
            TabOrder = 0
          end
          object SpinEdit1: TSpinEdit
            Left = 104
            Top = 48
            Width = 49
            Height = 22
            MaxValue = 365
            MinValue = 1
            TabOrder = 1
            Value = 7
          end
          object Button4: TButton
            Left = 240
            Top = 48
            Width = 89
            Height = 25
            Caption = 'Check now!'
            TabOrder = 2
            OnClick = Button4Click
          end
          object comboUpdateProxy: TComboBox
            Left = 104
            Top = 80
            Width = 225
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 3
          end
        end
      end
      object tabLog: TTabSheet
        HelpContext = 3080
        Caption = 'Log settings'
        ImageIndex = 2
        object Label6: TLabel
          Left = 87
          Top = 96
          Width = 34
          Height = 13
          Alignment = taRightJustify
          Caption = 'Log file'
        end
        object Image2: TImage
          Left = 16
          Top = 8
          Width = 32
          Height = 32
          AutoSize = True
          Picture.Data = {
            07544269746D617036100000424D361000000000000036000000280000002000
            0000200000000100200000000000001000000000000000000000000000000000
            0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00666666006666660066666600FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5868500D8D4C500ADA29B006666
            6600666666006666660066666600666666006666660066666600FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5868500FBFACC00FBFACC00FDFD
            D800FCFDE700FCFDE700EAE9E400CBD1AB00C4B6B30066666600666666006666
            660066666600666666006666660066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BB8C8500A8DCA600CAEABB00CAEA
            BB00EBF6CA00FDFDD800FDFDD800FDFDD800FDFDD800FCFDE700FEFEF900FEFE
            F900FEFEF900EAE9E400CCC6C000BCB0AA006666660066666600666666006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FBFACC00EBF6CA00DCF0
            C700CAEABB00A8DCA600A8DCA600A8DCA600A8DCA600CAEABB00DCF0C700EBF6
            D800FCFDE700FCFDE700FCFDE700FCFDE700FEFEF900EAE9E400CCC6C0006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6CA00FDFDD800FDFD
            D800FDFDD800FDFDD800FDFDD800FDFDD800FDFDD800EBF6D800CAEABB00CAEA
            BB00A8DCA60099D79900A8DCA600BBE4B600CBEAC600ECF7E700FCFDE7006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00A8DCA600A8DC
            A600A8DCA600A8DCA600CBD1AB00CEE0AD00EBF6CA00FDFDD800FCFDE700FCFD
            E700FCFDE700FCFDE700FEFEF900ECF7E700DDF1D600CBEAC600A8DCA6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800FDFDD800FDFD
            D800FDFDD800FDFDD800ECD2A600CAC68E00C5D19900A8D39800A8DCA600A8DC
            A600A8DCA600CAEABB00CBEAC600ECF7E700FCFDE700FEFEF900FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600B9E3AC00CAEA
            BB00DCF0C700CBD1AB00C5868500C4746400E9B58300F1CC9B00F4D6A500FCFD
            E700FCFDE700ECF7E700DDF1D600CBEAC600A8DCA600A8DCA600A8DCA6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800EBF6D800EBF6
            D800CAEABB00E4E7D800D9B6B400B8636300B7735A00D0AE6E00D0AE6E00EBC2
            8F00E8E4C400ECF7E700FCFDE700FEFEF900FEFEF900FEFEF900FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800EBF6D800FDFD
            D800FCFDE700F5E8D900F0DEDD00D2A4A400C0767600D3946E00E9B07B00E5A9
            7300E5A97300CBD1AB00A8DCA600A8DCA600A8DCA600A8DCA600BBE4B6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00A8DCA600A8DC
            A600A8DCA600A8DCA600A8DCA600E4E7D800D9B6B400BD706B00D6853600E9B5
            8300E9B58300F1CC9B00F8E9C300FEFEF900FEFEF900FEFEF900ECF7E7006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800FCFDE700FCFD
            E700FCFDE700FCFDE700FCFDE700EBF6D800D3946E00A9512900CC680400D073
            1500DA985400DA985400DA985400E5A36400CBEAC600CBEAC600DDF1D6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600CAEA
            BB00CAEABB00EBF6D800EBF6D800EBF6D800D3946E00DFA05D00D6853600CC68
            0400D0731500E9B07B00E9B58300ECC49300E4E7D800ECF7E700CBEAC6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FDFDD800EBF6
            D800EBF6D800CBEAC600CBEAC600BBE4B600A8DCA600D0AE6E00D6853600D685
            3600CC680400D0731500E5A36400D0AE6E00E9B58300ECF7E700FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00D1EAC600EBF6
            D800EBF6D800FCFDE700FCFDE700FEFEF900FEFEF900FEFEF900E9B07B00D37B
            2300D6802B00CC680400CC680400E5A36400E5A36400DA985400B9CB92006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800D1EAC600CBEA
            C600BBE4B600A8DCA600A8DCA600A8DCA600A8DCA600BBE4B600CBEAC600C97A
            2200D37B2300D6802B00CC680400D37B2300E9B58300E9B58300E9B583006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FCFDE700FCFD
            E700FCFDE700FCFDE700FEFEF900FEFEF900FEFEF900ECF7E700ECF7E700D1EA
            C600D37B2300D37B2300D37B2300CC680400CC731900C4745600DA9854007658
            470066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600CBEA
            C600CBEAC600CBEAC600ECF7E700ECF7E700ECF7E700FEFEF900FEFEF900FEFE
            F900FEFEF900DA985400DA985400D37B2300CC680400C0767600D3946E00854E
            4D006548380066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FCFDE700ECF7
            E700ECF7E700DDF1D600CBEAC600CBEAC600BBE4B600A8DCA600A8DCA600A8DC
            A600A8DCA600A8DCA600B46A3400D19A9600D9B6B400B7735A00D37B2300A878
            6700A67778006149420066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CBEAC600CBEAC600ECF7
            E700ECF7E700ECF7E700FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900F0DEDD00D19A9600CA784700E4984E00CC680400B083
            190076584700916654007058540066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800DDF1D600CBEA
            C600CBEAC600BBE4B600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600A8DC
            A600CBEAC600CBEAC600CBEAC600ECF7E700CC731900D6802B00E4984E00CC68
            0400724C0C0076584700765847007967640066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900ECF7E700ECF7E700DDF1D600CBEAC600CBEAC600DA985400D6802B00E08E
            3C00CC680400724C0C00916654007658470066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600A8DC
            A600A8DCA600A8DCA600CBEAC600CBEAC600CBEAC600ECF7E700ECF7E700ECF7
            E700FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900DA985400D073
            1500D6853600D37B2300A8786700B89C920066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900ECF7E700ECF7E700DDF1D600CBEAC600CBEAC600BBE4
            B600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600CBEAC600B083
            1900D0731500D37B2300D3946E009873670066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900ECF7E7006666
            6600B0831900D0731500B98B220066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500F5E8D9005D5D7500ABCB
            D700FEFEF900E4C6C5004D90B000F4E8E700FEFEF900E4C6C500B0D3E700FEFE
            F900FEFEF900EAE9E400FEFEF900FEFEF900FEFEF900FEFEF900FEFEF9006666
            6600FFFFFF00D3946E0066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500E1BDB900CDA099001996
            B700EBD8D700E4C6C50090A2AF006F91A800FEFEF900C99393002AB0CD00D7E5
            ED00FEFEF900855B68004D90B000FEFEF900D2A4A4001996B700CBDDE4006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400D9B6B400B0899100C58685001996
            B700C5868500B86363009D6972002794B300B8636300C0767600698599006985
            9900C5868500D19A96001996B700D9B6B400D9B6B400C0B8C1006F91A8006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000BC2DA000BC2DA004EB0CD006666
            66006DB2CC000BC2DA002AB0CD00666666004EB0CD0090B1C0000AADCE006666
            660069859900C5AAA5002794B30094818600BD7475006F91A8004D90B0006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000BC2DA002794B300FFFF
            FF00FFFFFF000BC2DA002794B300FFFFFF000BC2DA002794B30066666600FFFF
            FF000BC2DA0060BFEE0066666600FFFFFF000BC2DA0060BFEE0066666600FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00}
          Transparent = True
        end
        object Label7: TLabel
          Left = 56
          Top = 8
          Width = 401
          Height = 41
          AutoSize = False
          Caption = 
            'Logging may be useful for some reason. For example you can diagn' +
            'ose the failed connections or check the traffic that application' +
            ' broadcast over network'
          WordWrap = True
        end
        object GroupBox3: TGroupBox
          Left = 80
          Top = 128
          Width = 329
          Height = 201
          Caption = 'Event categories'
          TabOrder = 2
          object checkINJ: TCheckBox
            Left = 32
            Top = 32
            Width = 153
            Height = 17
            HelpContext = 1302
            Caption = 'Hook injection'
            TabOrder = 0
          end
          object checkCONN: TCheckBox
            Left = 32
            Top = 56
            Width = 209
            Height = 17
            HelpContext = 1303
            Caption = 'Connection status'
            TabOrder = 1
          end
          object checkSOCKS: TCheckBox
            Left = 32
            Top = 80
            Width = 81
            Height = 17
            HelpContext = 1304
            Caption = 'SOCKS'
            TabOrder = 2
          end
          object checkWARN: TCheckBox
            Left = 32
            Top = 104
            Width = 241
            Height = 17
            HelpContext = 1305
            Caption = 'Warning messages'
            TabOrder = 3
          end
          object checkTraffic: TCheckBox
            Left = 32
            Top = 168
            Width = 201
            Height = 17
            HelpContext = 1306
            Caption = 'Log traffic'
            TabOrder = 4
            Visible = False
          end
          object checkSendLogs: TCheckBox
            Left = 32
            Top = 128
            Width = 289
            Height = 17
            HelpContext = 1305
            Caption = 'Programs should send logs to FreeCap'#39's window'
            TabOrder = 5
          end
        end
        object checkLog: TCheckBox
          Left = 88
          Top = 64
          Width = 281
          Height = 25
          HelpContext = 1300
          Caption = 'Enable log'
          TabOrder = 0
          OnClick = checkLogClick
        end
        object editLogFile: TEdit
          Left = 136
          Top = 96
          Width = 241
          Height = 21
          HelpContext = 1301
          TabOrder = 1
        end
      end
      object tabPlugins: TTabSheet
        Caption = 'Plugins'
        Enabled = False
        ImageIndex = 5
        TabVisible = False
        OnShow = tabPluginsShow
        object Image5: TImage
          Left = 16
          Top = 8
          Width = 32
          Height = 32
          AutoSize = True
          Picture.Data = {
            07544269746D617036100000424D361000000000000036000000280000002000
            0000200000000100200000000000001000000000000000000000000000000000
            0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00666666006666660066666600FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5868500D8D4C500ADA29B006666
            6600666666006666660066666600666666006666660066666600FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C5868500FBFACC00FBFACC00FDFD
            D800FCFDE700FCFDE700EAE9E400CBD1AB00C4B6B30066666600666666006666
            660066666600666666006666660066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BB8C8500A8DCA600CAEABB00CAEA
            BB00EBF6CA00FDFDD800FDFDD800FDFDD800FDFDD800FCFDE700FEFEF900FEFE
            F900FEFEF900EAE9E400CCC6C000BCB0AA006666660066666600666666006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FBFACC00EBF6CA00DCF0
            C700CAEABB00A8DCA600A8DCA600A8DCA600A8DCA600CAEABB00DCF0C700EBF6
            D800FCFDE700FCFDE700FCFDE700FCFDE700FEFEF900EAE9E400CCC6C0006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6CA00FDFDD800FDFD
            D800FDFDD800FDFDD800FDFDD800FDFDD800FDFDD800EBF6D800CAEABB00CAEA
            BB00A8DCA60099D79900A8DCA600BBE4B600CBEAC600ECF7E700FCFDE7006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00A8DCA600A8DC
            A600A8DCA600A8DCA600CBD1AB00CEE0AD00EBF6CA00FDFDD800FCFDE700FCFD
            E700FCFDE700FCFDE700FEFEF900ECF7E700DDF1D600CBEAC600A8DCA6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800FDFDD800FDFD
            D800FDFDD800FDFDD800ECD2A600CAC68E00C5D19900A8D39800A8DCA600A8DC
            A600A8DCA600CAEABB00CBEAC600ECF7E700FCFDE700FEFEF900FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600B9E3AC00CAEA
            BB00DCF0C700CBD1AB00C5868500C4746400E9B58300F1CC9B00F4D6A500FCFD
            E700FCFDE700ECF7E700DDF1D600CBEAC600A8DCA600A8DCA600A8DCA6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800EBF6D800EBF6
            D800CAEABB00E4E7D800D9B6B400B8636300B7735A00D0AE6E00D0AE6E00EBC2
            8F00E8E4C400ECF7E700FCFDE700FEFEF900FEFEF900FEFEF900FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800EBF6D800FDFD
            D800FCFDE700F5E8D900F0DEDD00D2A4A400C0767600D3946E00E9B07B00E5A9
            7300E5A97300CBD1AB00A8DCA600A8DCA600A8DCA600A8DCA600BBE4B6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00A8DCA600A8DC
            A600A8DCA600A8DCA600A8DCA600E4E7D800D9B6B400BD706B00D6853600E9B5
            8300E9B58300F1CC9B00F8E9C300FEFEF900FEFEF900FEFEF900ECF7E7006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FDFDD800FCFDE700FCFD
            E700FCFDE700FCFDE700FCFDE700EBF6D800D3946E00A9512900CC680400D073
            1500DA985400DA985400DA985400E5A36400CBEAC600CBEAC600DDF1D6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600CAEA
            BB00CAEABB00EBF6D800EBF6D800EBF6D800D3946E00DFA05D00D6853600CC68
            0400D0731500E9B07B00E9B58300ECC49300E4E7D800ECF7E700CBEAC6006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FDFDD800EBF6
            D800EBF6D800CBEAC600CBEAC600BBE4B600A8DCA600D0AE6E00D6853600D685
            3600CC680400D0731500E5A36400D0AE6E00E9B58300ECF7E700FEFEF9006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CAEABB00D1EAC600EBF6
            D800EBF6D800FCFDE700FCFDE700FEFEF900FEFEF900FEFEF900E9B07B00D37B
            2300D6802B00CC680400CC680400E5A36400E5A36400DA985400B9CB92006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800D1EAC600CBEA
            C600BBE4B600A8DCA600A8DCA600A8DCA600A8DCA600BBE4B600CBEAC600C97A
            2200D37B2300D6802B00CC680400D37B2300E9B58300E9B58300E9B583006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FCFDE700FCFD
            E700FCFDE700FCFDE700FEFEF900FEFEF900FEFEF900ECF7E700ECF7E700D1EA
            C600D37B2300D37B2300D37B2300CC680400CC731900C4745600DA9854007658
            470066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600CBEA
            C600CBEAC600CBEAC600ECF7E700ECF7E700ECF7E700FEFEF900FEFEF900FEFE
            F900FEFEF900DA985400DA985400D37B2300CC680400C0767600D3946E00854E
            4D006548380066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FCFDE700ECF7
            E700ECF7E700DDF1D600CBEAC600CBEAC600BBE4B600A8DCA600A8DCA600A8DC
            A600A8DCA600A8DCA600B46A3400D19A9600D9B6B400B7735A00D37B2300A878
            6700A67778006149420066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500CBEAC600CBEAC600ECF7
            E700ECF7E700ECF7E700FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900F0DEDD00D19A9600CA784700E4984E00CC680400B083
            190076584700916654007058540066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500EBF6D800DDF1D600CBEA
            C600CBEAC600BBE4B600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600A8DC
            A600CBEAC600CBEAC600CBEAC600ECF7E700CC731900D6802B00E4984E00CC68
            0400724C0C0076584700765847007967640066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FCFDE700FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900ECF7E700ECF7E700DDF1D600CBEAC600CBEAC600DA985400D6802B00E08E
            3C00CC680400724C0C00916654007658470066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400BB8C8500A8DCA600A8DCA600A8DC
            A600A8DCA600A8DCA600CBEAC600CBEAC600CBEAC600ECF7E700ECF7E700ECF7
            E700FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900DA985400D073
            1500D6853600D37B2300A8786700B89C920066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900ECF7E700ECF7E700DDF1D600CBEAC600CBEAC600BBE4
            B600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600A8DCA600CBEAC600B083
            1900D0731500D37B2300D3946E009873670066666600FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFE
            F900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900FEFEF900ECF7E7006666
            6600B0831900D0731500B98B220066666600FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500F5E8D9005D5D7500ABCB
            D700FEFEF900E4C6C5004D90B000F4E8E700FEFEF900E4C6C500B0D3E700FEFE
            F900FEFEF900EAE9E400FEFEF900FEFEF900FEFEF900FEFEF900FEFEF9006666
            6600FFFFFF00D3946E0066666600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400C5868500E1BDB900CDA099001996
            B700EBD8D700E4C6C50090A2AF006F91A800FEFEF900C99393002AB0CD00D7E5
            ED00FEFEF900855B68004D90B000FEFEF900D2A4A4001996B700CBDDE4006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00D2A4A400D9B6B400B0899100C58685001996
            B700C5868500B86363009D6972002794B300B8636300C0767600698599006985
            9900C5868500D19A96001996B700D9B6B400D9B6B400C0B8C1006F91A8006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000BC2DA000BC2DA004EB0CD006666
            66006DB2CC000BC2DA002AB0CD00666666004EB0CD0090B1C0000AADCE006666
            660069859900C5AAA5002794B30094818600BD7475006F91A8004D90B0006666
            6600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000BC2DA002794B300FFFF
            FF00FFFFFF000BC2DA002794B300FFFFFF000BC2DA002794B30066666600FFFF
            FF000BC2DA0060BFEE0066666600FFFFFF000BC2DA0060BFEE0066666600FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00}
          Transparent = True
        end
        object Label12: TLabel
          Left = 56
          Top = 8
          Width = 401
          Height = 33
          AutoSize = False
          Caption = 'Plugins available for FreeCap. Experemental!'
          WordWrap = True
        end
        object Label13: TLabel
          Left = 264
          Top = 48
          Width = 129
          Height = 17
          AutoSize = False
          Caption = 'Name'
        end
        object Label14: TLabel
          Left = 264
          Top = 96
          Width = 121
          Height = 13
          AutoSize = False
          Caption = 'Author'
        end
        object Label15: TLabel
          Left = 264
          Top = 144
          Width = 153
          Height = 17
          AutoSize = False
          Caption = 'Description'
        end
        object lstPlugins: TListBox
          Left = 56
          Top = 48
          Width = 201
          Height = 233
          ItemHeight = 13
          TabOrder = 0
        end
        object Button1: TButton
          Left = 264
          Top = 256
          Width = 105
          Height = 25
          Caption = 'Configure'
          Enabled = False
          TabOrder = 1
        end
        object plugName: TEdit
          Left = 264
          Top = 64
          Width = 169
          Height = 21
          Color = clInactiveBorder
          ReadOnly = True
          TabOrder = 2
        end
        object plugAuthor: TEdit
          Left = 264
          Top = 112
          Width = 169
          Height = 21
          Color = clInactiveBorder
          ReadOnly = True
          TabOrder = 3
        end
        object memoDescr: TMemo
          Left = 264
          Top = 160
          Width = 161
          Height = 89
          Color = clInactiveBorder
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 4
        end
      end
    end
    object NavTree: TTreeView
      Left = 1
      Top = 1
      Width = 152
      Height = 471
      Align = alLeft
      HideSelection = False
      Indent = 19
      ReadOnly = True
      TabOrder = 1
      OnChange = NavTreeChange
      Items.Data = {
        0600000026000000000000000000000000000000FFFFFFFF0000000000000000
        0D44656661756C742070726F787924000000000000000000000001000000FFFF
        FFFF00000000000000000B50726F787920636861696E24000000000000000000
        000002000000FFFFFFFF00000000000000000B536F636B732053686172652B00
        0000000000000000000003000000FFFFFFFF0000000000000000124469726563
        7420636F6E6E656374696F6E7320000000000000000000000004000000FFFFFF
        FF00000000000000000750726F6772616D250000000000000000000000050000
        00FFFFFFFF00000000000000000C4C6F672073657474696E6773}
    end
  end
  object btnApply: TButton
    Left = 574
    Top = 481
    Width = 81
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 4
    OnClick = btnApplyClick
  end
  object PopupMenu1: TPopupMenu
    Left = 60
    Top = 113
    object Addnew1: TMenuItem
      Caption = 'Add new'
      OnClick = btnProxyAddClick
    end
    object Edit1: TMenuItem
      Caption = 'Edit...'
      Default = True
      OnClick = Edit1Click
    end
    object Deleteselected1: TMenuItem
      Caption = 'Delete selected'
      OnClick = btnProxyDelClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Checkselectedproxy1: TMenuItem
      Caption = 'Check selected proxy'
      OnClick = Checkselectedproxy1Click
    end
    object Pingselectedproxy1: TMenuItem
      Caption = 'Ping selected proxy'
      OnClick = Pingselectedproxy1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Moveup1: TMenuItem
      Caption = 'Move up'
      OnClick = Moveup1Click
    end
    object Movedown1: TMenuItem
      Caption = 'Move down'
      OnClick = Movedown1Click
    end
  end
  object ImportDlg: TOpenDialog
    Filter = 'Text files|*.TXT'
    InitialDir = '.'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 56
    Top = 248
  end
end
