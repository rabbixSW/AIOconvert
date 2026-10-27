#ifndef AppVersion
  #error AppVersion must be supplied by build-windows-installer.ps1
#endif
#ifndef StagingDir
  #error StagingDir must be supplied by build-windows-installer.ps1
#endif
#ifndef OutputDir
  #error OutputDir must be supplied by build-windows-installer.ps1
#endif
#ifndef ProjectDir
  #error ProjectDir must be supplied by build-windows-installer.ps1
#endif

[Setup]
AppId={{8F9D29A5-7B7C-4D0A-9F3C-4C5A83A5C01E}
AppName=AIOconvert
AppVersion={#AppVersion}
AppPublisher=com.aioconvert
DefaultDirName={autopf}\AIOconvert
DefaultGroupName=AIOconvert
UninstallDisplayIcon={app}\AIOconvert.exe
SetupIconFile={#ProjectDir}\windows\runner\resources\app_icon.ico
OutputDir={#OutputDir}
OutputBaseFilename=AIOconvert-{#AppVersion}-windows-x64-setup
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "{#StagingDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\AIOconvert"; Filename: "{app}\AIOconvert.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\AIOconvert"; Filename: "{app}\AIOconvert.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\AIOconvert.exe"; Description: "Launch AIOconvert"; Flags: postinstall nowait skipifsilent