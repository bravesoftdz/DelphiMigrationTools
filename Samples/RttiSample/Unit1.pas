unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    btnSetProperties: TButton;
    btnGetProperties: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Edit1: TEdit;
    TabSheet3: TTabSheet;
    Button1: TButton;
    procedure btnSetPropertiesClick(Sender: TObject);
    procedure btnGetPropertiesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    FComp: TComponent;

    function GetCurrentPageComponent: TComponent;
    procedure Log(AValue: string);

//    procedure SetProperty(AComp: TComponent; APropName, APropValue: string); overload;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Rtti, System.TypInfo, ConvertUtils;


function ComponentToText(AComponent: TComponent): string;
var
  LStrStream: TStringStream;
  LMemStream: TMemoryStream;
begin
  if AComponent = nil then
    Exit('');

  LStrStream := nil;
  LMemStream := nil;

  try
    LMemStream := TMemoryStream.Create();
    LStrStream := TStringStream.Create();
    // Stream the component
    LMemStream.WriteComponent(AComponent);
    LMemStream.Position := 0;
    // Convert to text
    ObjectBinaryToText(LMemStream, LStrStream);
    LStrStream.Position := 0;
    // Output the text
    Result := LStrStream.ReadString(LStrStream.Size);
  finally
    LStrStream.Free;
    LMemStream.Free;
  end;
end;

function UnicodeStrToStr(AUnicode: string): string;
var
  I, Len, W, Count: Integer;
  C: Char;
  WideChars: TCharArray;

  IsTokenStart: Boolean;
  IsUnicode: Boolean;

  procedure SetChar(AChar: WideChar);
  begin
    WideChars[Count] := AChar;
    Inc(Count);
  end;
begin
// Samples
//  s := '#44256#44061#44396#48516';                        // ������
//  s := '#54788#44552'' ''#51077''/''#52636#44552';        // ���� ��/���
//  s := '#54788#44552'' ''#51077''/''#52636#44552''/''';   // ���� ��/���/

// "#"�� �����ϴ� ���ڴ� �����ڵ�
// "'' ����'" ������ ���ڴ� �Ϲݹ���

  if AUnicode.CountChar('#') = 0 then
    Exit(AUnicode);

  /////////////////////////////////////////////
  // ���� ���
  Len := 0;
  IsTokenStart := False;
  IsUnicode := False;
  for I := Low(AUnicode) to High(AUnicode) do
  begin
    C := AUnicode[I];
    case C of
    '#':
      Inc(Len);
    '''':
      IsTokenStart := not IsTokenStart;
    else
      begin
        if IsTokenStart then // �Ϲݹ���
          Inc(Len)
        else                 // �����ڵ�
        ;
      end;
    end;
  end;
  SetLength(WideChars, Len);

  /////////////////////////////////////////////
  // �����ڵ�� ���� ����
  W := 0;
  Count := 0;
  for I := Low(AUnicode) to High(AUnicode) do
  begin
    C := AUnicode[I];
    case C of
    '#':
      begin
        if IsUnicode then
          SetChar(WideChar(SmallInt(W)));
        IsUnicode := True;
        W := 0;
        if I = Low(AUnicode) then
          Continue;
      end;
    '''':
      begin
        if (not IsTokenStart) and IsUnicode then
          SetChar(WideChar(SmallInt(W)));

        IsTokenStart := not IsTokenStart;
        IsUnicode := False;
      end;
    else
      begin
        if IsTokenStart then // �Ϲݹ���
          SetChar(C)
        else                 // �����ڵ�
          W := W * 10 + (Ord(C) - Ord('0'));
        ;
      end;
    end;
  end;
  if IsUnicode then
    SetChar(WideChar(SmallInt(W)));

  Result := string.Create(WideChars);
end;

function SetProperty(AComp: TComponent; APropName, APropValue: string): Boolean;

  // AValue ���� ������Ÿ������ APropValue�� ������ TValue ��ȯ
  function GetTValue(AValue: TValue; APropValue: string): TValue;
  var
    IdentToInt: TIdentToInt;
    Properties: TArray<string>;
    Int: Integer;
  begin
    Result := TValue.Empty;

    case AValue.Kind of
      tkString, tkLString, tkWString:
        Result := TValue.From<string>(APropValue);
      tkUString:
        Result := TValue.From<string>(UnicodeStrToStr(APropValue));
      tkInteger, tkInt64:
        begin
          IdentToInt := FindIdentToInt(AValue.TypeInfo);
          if Assigned(IdentToInt) then
            IdentToInt(APropValue, Int)
          else
            Int := StrToIntDef(APropValue, 0);
          Result := TValue.From<Integer>(Int);
        end;
      tkEnumeration:
        Result := TValue.FromOrdinal(AValue.TypeInfo, GetEnumValue(AValue.TypeInfo, APropValue));
      tkSet:
        begin
          Int := StringToSet(AValue.TypeInfo, APropValue);
          TValue.Make(@Int, AValue.TypeInfo, Result);
        end;

      tkUnknown: ;
      tkChar: ;
      tkFloat: ;
      tkClass: ;
      tkMethod: ;
      tkWChar: ;
      tkVariant: ;
      tkArray: ;
      tkRecord: ;
      tkInterface: ;
      tkDynArray: ;
      tkClassRef: ;
      tkPointer: ;
      tkProcedure: ;
    end;
  end;

  procedure GetPropertyFromPropertiesText(
          Context: TRttiContext;
          PropName: string;
          var PropObj: TObject;        // �Ӽ��� ������ ��ü
          var Prop: TRttiProperty      // ���� ����(Button.Font.Style)
      );
  var
    I: Integer;
    P: TRttiProperty;
    Properties: TArray<string>;
    TypeInfo: PTypeInfo;
  begin
    Properties := PropName.Split(['.']);
    TypeInfo := PropObj.ClassInfo;
    for I := Low(Properties) to High(Properties) do
    begin
      if I > Low(Properties) then
        PropObj := Prop.GetValue(PropObj).AsObject;
      Prop := Context.GetType(TypeInfo).GetProperty(Properties[I]);
      if Assigned(Prop) then
        TypeInfo := Prop.PropertyType.Handle;
    end;
  end;

var
  CompObj: TObject;
  Context: TRttiContext;
  Prop: TRttiProperty;
  Value, NewValue: TValue;
begin
  Context := TRttiContext.Create;
  CompObj := TObject(AComp);
  GetPropertyFromPropertiesText(
    Context,
    APropName,
    CompObj,            // var
    Prop                // var
  );

  // ������Ʈ�� �ش� �Ӽ� ����
  if not Assigned(Prop) then
    Exit(False);

  Value := Prop.GetValue(CompObj);
  NewValue := GetTValue(Value, APropValue);
  if NewValue.IsEmpty then
    Exit(False);

  Prop.SetValue(CompObj, NewValue);
  Result := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FComp := GetCurrentPageComponent;
end;

procedure TForm1.Log(AValue: string);
begin
  OutputDebugString(PChar(AValue));
end;

procedure TForm1.PageControl1Change(Sender: TObject);
begin
  Memo1.Lines.Clear;
  FComp := GetCurrentPageComponent;
end;

procedure TForm1.btnGetPropertiesClick(Sender: TObject);
begin
  if Assigned(FComp) then
    Memo1.Lines.Text := ComponentToText(FComp);
end;

procedure TForm1.btnSetPropertiesClick(Sender: TObject);
var
  I: Integer;
  Properties: TStrings;
  Key, Value: string;
begin
  Properties := Memo1.Lines;

  for I := 1 to Properties.Count - 2 do
  begin
    Key := Properties.KeyNames[I].Trim;
    Value := Properties.ValueFromIndex[I].Trim.DeQuotedString;

    if not SetProperty(FComp, Key, Value) then
      ShowMessageFmt('Not support property(%s)', [Key]);
  end;
end;

function TForm1.GetCurrentPageComponent: TComponent;
begin
  Result := nil;

  if PageControl1.ActivePage.ControlCount > 0 then
    Result := PageControl1.ActivePage.Controls[0] as TComponent;
end;

end.
