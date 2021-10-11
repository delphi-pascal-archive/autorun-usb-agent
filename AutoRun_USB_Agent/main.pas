{
   Автор: RusMaXXX - Кутушев Руслан
   e-mail: soft205@mail.ru
   Дата создания: 05.10.2008
}
unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, Menus, Registry, IniFiles, ShellApi,
  ExtCtrls, ShlObj, MMSystem, IdBaseComponent, IdAntiFreezeBase,
  IdAntiFreeze, ImgList;

const
  WM_MYICONNOTIFY = WM_USER + 123;
  AppName = 'No AutoRun_USB Agent';

type
  TMainForm = class(TForm)
    XPManifest: TXPManifest;
    box_config: TGroupBox;
    bt_close: TButton;
    bt_OK: TButton;
    MainPopupMenu: TPopupMenu;
    bt_config: TMenuItem;
    bt_line_2: TMenuItem;
    bt_exit: TMenuItem;
    box_autorun: TCheckBox;
    box_view_event: TCheckBox;
    sTimer: TTimer;
    ida: TIdAntiFreeze;
    box_off_autorun_drives: TCheckBox;
    Label1: TLabel;
    bt_line_1: TMenuItem;
    bt_about: TMenuItem;
    sImage: TImageList;
    procedure FormActivate(Sender: TObject);
    procedure bt_closeClick(Sender: TObject);
    procedure bt_configClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure bt_OKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bt_exitClick(Sender: TObject);
    procedure box_autorunClick(Sender: TObject);
    procedure box_off_autorun_drivesClick(Sender: TObject);
    procedure bt_aboutClick(Sender: TObject);
  private
    { Private declarations }
    ShownOnce: Boolean;
    procedure ViewMain(Sender: TObject);
    procedure HideItemClick(Sender: TObject);
    function ScanInfFile (AList: TStrings): boolean;
  public
    { Public declarations }
    procedure ViewSpeder (file_name: string);
    procedure AutoStarts (sBool: boolean);
    procedure AutoRunDrives (sBool: boolean);
    procedure ShowHints_ex (sText: string);
    procedure WMICON(var msg: TMessage); message WM_MYICONNOTIFY;
    procedure WMSYSCOMMAND(var msg: TMessage); message WM_SYSCOMMAND;
    procedure sViewMainForm;
    procedure HideMainForm;
    procedure CreateTrayIcon(n: Integer);
    procedure DeleteTrayIcon(n: Integer);
    procedure SaveIni;
    procedure LoadIni;
  end;

var
  MainForm: TMainForm;
  DriveList, sDrives: TStringList;
  sIniFile: TIniFile;

implementation

uses SpeDer;

{$R *.dfm}
{$R sound_ex.res}

procedure TMainForm.ShowHints_ex(sText: String);
var
  H: HWND;
  Rec: TRect;
  NeededTop: integer;
  HintForm: TForm;
  HintLabel: TLabel;
  aw: hwnd;
begin
  H := FindWindow('Shell_TrayWnd', nil);
  if H = 0 then exit;
  GetWindowRect(H, Rec);
  HintForm := TForm.Create(nil);
  with HintForm do
  begin
    Width := 245;
    Height := 100;
    Color := clSkyBlue;
    BorderStyle := bsNone;
    //Создаём текст
    HintLabel := TLabel.Create(nil);
    with HintLabel do
    begin
        Parent := HintForm;
        WordWrap := true;
        Caption := ' ' + Trim(sText) + ' ';
        Align := alClient;
        Layout := tlCenter;
        Alignment := taCenter;
    end;
    AlphaBlend := true;
    AlphaBlendValue := 220;
    aw := GetActiveWindow;
    ShowWindow(handle, SW_SHOWNOACTIVATE);
    SetActiveWindow(aw);
    Left := Screen.Width - Width;
    Top := Screen.Height - 20;
    //Выезжаем вверх
    NeededTop := Rec.Top - Height;
    while Top > NeededTop do
    begin
      Top := Top - 2;
      Repaint;
      ida.Sleep(10);
      ida.Process;
    end;
    ida.Sleep(2000);
    //Выезжаем вниз
    NeededTop := Screen.Width - 20;
    while Top < NeededTop do
    begin
      Top := Top + 2;
      Repaint;
      ida.Sleep(10);
      ida.Process;
    end;
    HintLabel.Free;
    Free;
  end;
end;

procedure TMainForm.WMICON(var msg: TMessage);
var
  P: TPoint;
begin
  case msg.LParam of
    WM_RBUTTONDOWN:
      begin
        GetCursorPos(p);
        SetForegroundWindow(Application.MainForm.Handle);
        MainPopupMenu.Popup(P.X - 100, P.Y - 5);
      end;
  end;
end;

procedure TMainForm.WMSYSCOMMAND(var msg: TMessage);
begin
  inherited;
  if (Msg.wParam = SC_MINIMIZE) then HideItemClick(Self);
end;

procedure TMainForm.HideMainForm;
begin
  Application.ShowMainForm := False;
  ShowWindow(Application.Handle, SW_HIDE);
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
end;

procedure TMainForm.sViewMainForm;
var
  i, j: Integer;
begin
  Application.ShowMainForm := True;
  ShowWindow(Application.Handle, SW_RESTORE);
  ShowWindow(Application.MainForm.Handle, SW_RESTORE);
  if not ShownOnce then
  begin
    for I := 0 to Application.MainForm.ComponentCount - 1 do
      if Application.MainForm.Components[I] is TWinControl then
        with Application.MainForm.Components[I] as TWinControl do
          if Visible then
          begin
            ShowWindow(Handle, SW_SHOWDEFAULT);
            for J := 0 to ComponentCount - 1 do
              if Components[J] is TWinControl then
                ShowWindow((Components[J] as TWinControl).Handle, SW_SHOWDEFAULT);
          end;
    ShownOnce := True;
  end;

end;

procedure TMainForm.CreateTrayIcon(n: Integer);
var
  nidata: TNotifyIconData;
begin
  with nidata do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := Self.Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallBackMessage := WM_MYICONNOTIFY;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, AppName);
  end;
  Shell_NotifyIcon(NIM_ADD, @nidata);
end;

procedure TMainForm.DeleteTrayIcon(n: Integer);
var
  nidata: TNotifyIconData;
begin
  with nidata do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := Self.Handle;
    uID := 1;
  end;
  Shell_NotifyIcon(NIM_DELETE, @nidata);
end;

procedure TMainForm.ViewMain(Sender: TObject);
begin
  sViewMainForm;
end;

procedure TMainForm.HideItemClick(Sender: TObject);
begin
  HideMainForm;
  CreateTrayIcon(1);
end;

procedure TMainForm.SaveINI ;
begin
  sIniFile.WriteBool('Config', 'ON/OFF autorun drive',
                      box_off_autorun_drives.Checked);
  sIniFile.WriteBool('Config', 'EXE autorun', box_autorun.Checked);
  sIniFile.WriteBool('Config', 'view event', box_view_event.Checked);
end;

procedure TMainForm.LoadIni ;
begin
  box_off_autorun_drives.Checked := sIniFile.ReadBool('Config', 'ON/OFF autorun drive', False);
  box_autorun.Checked            := sIniFile.ReadBool('Config', 'EXE autorun', True);
  box_view_event.Checked         := sIniFile.ReadBool('Config', 'view event', True);
end;

function GetWinDir : string;
var
  pWindowsDir : array [0..MAX_PATH] of Char;
  sWindowsDir : string;
begin
  GetWindowsDirectory (@pWindowsDir, MAX_PATH);
  sWindowsDir := StrPas (pWindowsDir);
  Result := sWindowsDir;
end;

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function StrToPchar(s:string):Pchar;
begin
  S := S+#0;
  Result := StrPCopy(@S[1], S) ;
end;

procedure Sound_ex;
var
  FindHandle, ResHandle: THandle;
  ResPtr: Pointer;
begin
  FindHandle := FindResource(HInstance, 'ALERT', 'WAVE');
  if FindHandle <> 0 then
  begin
    ResHandle := LoadResource(HInstance, FindHandle);
    if ResHandle <> 0 then
    begin
      ResPtr := LockResource(ResHandle);
      if ResPtr <> nil then
        SndPlaySound(PChar(ResPtr), snd_ASync or snd_Memory);
      UnlockResource(ResHandle);
    end;
    FreeResource(FindHandle);
  end;
end;

procedure TMainForm.ViewSpeder(file_name: string);
begin
  with SpederForm do
  begin
    Caption := 'Обнаружен подозрительный файл ...';
    sView.Text := file_name;
    FormStyle := fsStayOnTop;
    ShowModal;
    Application.RestoreTopMosts ;
  end;
end;

function ScanDrives(AList: TStrings): String;
var
 Bufer      : array[0..1024] of char;
 RealLen, i : integer;
 S          : string;
begin
 AList.Clear;
 RealLen := GetLogicalDriveStrings(SizeOf(Bufer),Bufer);
 i := 0; S := '';
 while i < RealLen do begin
  if Bufer[i] <> #0 then begin
   S := S + Bufer[i];
   inc(i);
  end else begin
   inc(i);
   if (GetDriveType(PChar(S)) = 2) or (GetDriveType(PChar(S)) = 3) then
   begin
     if S <> 'A:\' then AList.Add(S);
   end;
   S := '';
  end;
 end;
end;

function TMainForm.ScanInfFile (AList: TStrings): boolean;
var
  i: integer;
begin
  if box_view_event.Checked then
  begin
    for i := 0 to AList.Count - 1 do
    begin
      if FileExists(AList.Strings [i] + UpperCase('autorun.inf')) then
      begin
        Sound_ex;
        sTimer.Enabled := False;
        ViewSpeder (AList.Strings [i] + UpperCase('autorun.inf'));
      end;
    end;
  end;
end;

procedure TMainForm.AutoStarts (sBool: boolean);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create ;
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true) then
    begin
      if sBool then
      begin
        if not FileExists(GetWinDir + '\' + AppName + '.exe') then
           CopyDir (Application.ExeName, GetWinDir + '\' + AppName + '.exe');
        Reg.WriteString(AppName, GetWinDir + '\' + AppName + '.exe');
      end
      else
      begin
        if Reg.ValueExists(AppName) then
           Reg.DeleteValue (AppName);
      end;
    end;
  finally
    Reg.Free;
    inherited;
  end;
end;

procedure TMainForm.AutoRunDrives (sBool: boolean);
const
  sKey = 'NoDriveTypeAutoRun';
var
  Reg : TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', True) then
    begin
      if sBool then
        if Reg.ValueExists(sKey) then
           Reg.WriteInteger (sKey, 255)
      else
        if Reg.ValueExists(sKey) then
           Reg.WriteInteger (sKey, 145);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
    inherited;
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  Caption := 'Настройки - ' + AppName;
  Application.Title := AppName;
end;

procedure TMainForm.bt_closeClick(Sender: TObject);
begin
  HideMainForm;
end;

procedure TMainForm.bt_configClick(Sender: TObject);
begin
  ViewMain(Sender);
end;

procedure TMainForm.FormHide(Sender: TObject);
begin
  Application.Minimize ;
end;

procedure TMainForm.bt_OKClick(Sender: TObject);
begin
  SaveIni;
  HideMainForm;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DriveList.Free ;
  DeleteTrayIcon(1);
  sIniFile.Free ;
end;

procedure TMainForm.sTimerTimer(Sender: TObject);
begin
  ScanDrives(sDrives);
  Application.ProcessMessages ;
  ScanInfFile (sDrives);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.Left := (Screen.Width div 2) - (MainForm.Width div 2);
  MainForm.Top := (Screen.Height div 2) - (MainForm.Height div 2);
  DriveList := TStringList.Create ;
  sDrives := TStringList.Create ;
  ShownOnce := False;
  CreateTrayIcon(1);
  ShowWindow(Application.Handle, SW_HIDE);
  Application.ShowMainForm := FALSE;
  sIniFile := TIniFile.Create (AppName + '.ini');
  LoadIni;
end;

procedure TMainForm.bt_exitClick(Sender: TObject);
begin
  Application.Terminate ;
end;

procedure TMainForm.box_autorunClick(Sender: TObject);
begin
  if box_autorun.Checked then
    AutoStarts(True)
  else
    AutoStarts (False);
end;

procedure TMainForm.box_off_autorun_drivesClick(Sender: TObject);
begin
  if box_off_autorun_drives.Checked then
    AutoRunDrives(True)
  else
    AutoRunDrives (False);
end;

procedure TMainForm.bt_aboutClick(Sender: TObject);
var
  AMsgDialog: TForm;
  HM: THandle;
const
  Msg_Caption = 'О программе ...';
  Msg_TXT = 'Программа ' + AppName + ' версия 1.0' + #13#10 +
            'Предназначенна для предотвращения заражения компьютера autorun вирусами' + #13#10 +
            'Почта для пожеланий и предложений: soft205@mail.ru';
begin
  beep;
  AMsgDialog := CreateMessageDialog(Msg_TXT, mtInformation, [mbOK]);
  with AMsgDialog do
    try
      Caption := Msg_Caption ;;
      case ShowModal of
        ID_OK: Exit;
      end;
    finally
      Free;
    end;
end;

end.
