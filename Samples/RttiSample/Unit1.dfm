object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 453
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 14
    Top = 182
    Width = 292
    Height = 251
    TabOrder = 0
  end
  object btnSetProperties: TButton
    Left = 165
    Top = 151
    Width = 141
    Height = 25
    Caption = 'Set properties'
    TabOrder = 1
    OnClick = btnSetPropertiesClick
  end
  object btnGetProperties: TButton
    Left = 14
    Top = 151
    Width = 145
    Height = 25
    Caption = 'Get properties'
    TabOrder = 2
    OnClick = btnGetPropertiesClick
  end
  object PageControl1: TPageControl
    Left = 13
    Top = 24
    Width = 297
    Height = 121
    ActivePage = TabSheet2
    TabOrder = 3
    OnChange = PageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'TabSheet1'
      object Edit1: TEdit
        Left = 24
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 0
        Text = 'Edit1'
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 17
        Top = 16
        Width = 248
        Height = 65
        Cursor = crSizeNESW
        Caption = #50504#45397'??'
        Color = clMedGray
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = #48148#53461#52404
        Font.Style = [fsBold, fsItalic]
        ParentBackground = False
        ParentFont = False
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      object Button1: TButton
        Left = 24
        Top = 16
        Width = 201
        Height = 57
        Caption = 'Button1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = #44404#47548#52404
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 0
      end
    end
  end
end
