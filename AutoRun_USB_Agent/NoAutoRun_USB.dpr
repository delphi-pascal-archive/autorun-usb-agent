program NoAutoRun_USB;

uses
  Forms,
  main in 'main.pas' {MainForm},
  SpeDer in 'SpeDer.pas' {SpederForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSpederForm, SpederForm);
  Application.Run;
end.
