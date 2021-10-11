unit SpeDer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg;

type
  TSpederForm = class(TForm)
    sImage: TImage;
    sView: TMemo;
    bt_delete: TButton;
    bt_rename: TButton;
    bt_ignor: TButton;
    procedure bt_ignorClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure action_ (sTag: integer);
    procedure Rename_File (FileName: string);
    procedure Delete_File (FileName: string);
  end;

var
  SpederForm: TSpederForm;
  Atr: integer;
implementation

uses main;

{$R *.dfm}

procedure TSpederForm.Rename_File(FileName: string);
var
  sTemp: string;
begin
  Atr := FileGetAttr(FileName);
  SetFileAttributes(PChar(FileName), Atr - faReadOnly + faHidden + faSysFile + faArchive);
  sTemp := FileName + '.detect';
  try
    if FileExists(sTemp) then
    begin
       DeleteFile (sTemp);
       ReNameFile (FileName, sTemp);
    end
    else
       ReNameFile (FileName, sTemp);
    MainForm.ShowHints_ex('Файл: ' + FileName + ' был успешно переименован ...' );
  except
    MainForm.ShowHints_ex('Файл: ' + FileName + ' не возможно переименовать ...');
  end;
end;

procedure TSpederForm.Delete_File(FileName: string);
begin
  Atr := FileGetAttr(FileName);
  SetFileAttributes(PChar(FileName), Atr - faReadOnly + faHidden + faSysFile + faArchive);
  try
    if FileExists(FileName) then
       DeleteFile (FileName);
    MainForm.ShowHints_ex('Файл: ' + FileName + ' был успешно удален ...' );
  except
    MainForm.ShowHints_ex('Файл: ' + FileName + ' не возможно удалить ...');
  end;
end;

procedure TSpederForm.action_(sTag: integer);
begin
  case sTag of
    10: close;
    20: Rename_File(sView.Text);
    30: Delete_File(sView.Text);
  end;
end;

procedure TSpederForm.bt_ignorClick(Sender: TObject);
begin
  action_ (TButton(Sender).Tag);
  MainForm.sTimer.Enabled := True;
  close;
end;

procedure TSpederForm.FormPaint(Sender: TObject);
begin
  Application.RestoreTopMosts ;
end;

procedure TSpederForm.FormCreate(Sender: TObject);
begin
  Application.RestoreTopMosts ;
end;

end.
