chcp 65001
@set iasver=1.0
@setlocal DisableDelayedExpansion
@echo off

::============================================================================
::
::   IDM 激活脚本（IAS）
::
::   主页：https://github.com/WindowsAddict/IDM-Activation-Script
::         https://massgrave.dev/idm-activation-script
::
::   电子邮件：windowsaddict@protonmail.com
::
::============================================================================

::  要激活，请使用 "/act" 参数运行脚本，或在下面的行中将 0 更改为 1
set _activate=0

::  要重置激活和试用期，请使用 "/res" 参数运行脚本，或在下面的行中将 0 更改为 1
set _reset=0

::  如果在上面的行中更改了值或使用了参数，则脚本将以无人值守模式运行

::  在 IDM 许可信息中添加自定义名称，在等号后的下面一行写入英文
set name=

::========================================================================================================================================
:: 设置路径变量，如果系统中配置错误，这将有助于修正

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
    set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

:: 如果由 x64 进程在 x64 位 Windows 上启动，则使用 x64 进程重新启动脚本
:: 或者如果由 x86/ARM32 进程在 ARM64 Windows 上启动，则使用 ARM64 进程重新启动脚本

set "_cmdf=%~f0"
for %%# in (%*) do (
    if /i "%%#"=="r1" set r1=1
    if /i "%%#"=="r2" set r2=1
    if /i "%%#"=="-qedit" (
        reg add HKCU\Console /v QuickEdit /t REG_DWORD /d "1" /f 1>nul
        rem 检查下面的管理员提升代码，理解为什么它在这里
    )
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
    setlocal EnableDelayedExpansion
    start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
    exit /b
)

:: 如果由 x64 进程在 ARM64 Windows 上启动，则使用 ARM32 进程重新启动脚本

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
    setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::========================================================================================================================================

set "blank="
set "mas=ht%blank%tps%blank%://mass%blank%grave.dev/"

::  检查 Null 服务是否正在运行，这对于批处理脚本很重要

sc query Null | find /i "RUNNING"
if %errorlevel% NEQ 0 (
    echo:
    echo Null 服务未运行，脚本可能会崩溃...
    echo:
    echo:
    echo 帮助 - %mas%idm-activation-script.html#Troubleshoot
    echo:
    echo:
    ping 127.0.0.1 -n 10
)
cls

::  检查 LF 行结束符

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
    echo:
    echo 错误：脚本可能存在 LF 行结束符问题，或者脚本末尾缺少空行。
    echo:
ping 127.0.0.1 -n 6 >nul
popd
exit /b
)
popd

::========================================================================================================================================

cls
color 07
title  IDM Activation Script %iasver%

set _args=
set _elev=
set _unattended=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
    for %%A in (%_args%) do (
        if /i "%%A"=="-el"  set _elev=1
        if /i "%%A"=="/res" set _reset=1
        if /i "%%A"=="/act" set _activate=1
    )
)

for %%A in (%_activate% %_reset%) do (if "%%A"=="1" set _unattended=1)

::========================================================================================================================================

set "nul1=1>nul"
set "nul2=2>nul"
set "nul6=2^>nul"
set "nul=>nul 2>&1"

set psc=powershell.exe
set winbuild=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 %nul2% | find /i "0x0" %nul1% && (set _NCS=0)

if %_NCS% EQU 1 (
    for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
    set     "Red="41;97m""
    set    "Gray="100;97m""
    set   "Green="42;97m""
    set    "Blue="44;97m""
    set  "_White="40;37m""
    set  "_Green="40;92m""
    set "_Yellow="40;93m""
) else (
    set     "Red="Red" "white""
    set    "Gray="Darkgray" "white""
    set   "Green="DarkGreen" "white""
    set    "Blue="Blue" "white""
    set  "_White="Black" "Gray""
    set  "_Green="Black" "Green""
    set "_Yellow="Black" "Yellow""
)
set "nceline=echo: &echo ==== ERROR ==== &echo:"
set "eline=echo: &call :_color %Red% "==== ERROR ====" &echo:"
set "line=___________________________________________________________________________________________________"
set "_buf={$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=34;$B.Height=300;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"

::========================================================================================================================================

if %winbuild% LSS 7600 (
    %nceline%
    echo 不支持的操作系统版本 [%winbuild%]。
    echo 该项目仅支持 Windows 7/8/8.1/10/11 及其服务器等效版本。
    goto done2
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
    %nceline%
    echo 在系统中找不到 powershell.exe。
    goto done2
)

::========================================================================================================================================

::  修复路径名称中的特殊字符限制

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''"

set _PSarg="""%~f0""" -el %_args%
set "_appdata=%appdata%"
set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" %nul1% && (
if /i not "!_work!"=="!_ttemp!" (
%eline%
echo 脚本是从临时文件夹启动的，
echo 很可能您是直接从压缩文件中运行脚本。
echo:
echo 解压缩文件并从解压后的文件夹启动脚本。
goto done2
)
)

::========================================================================================================================================

:: 提升脚本为管理员并传递参数，防止循环

%nul1% fltmc || (
if not defined _elev %psc% "start cmd.exe -arg '/c \"!_PSarg:'=''!\"' -verb runas" && exit /b
%eline%
echo 此脚本需要管理员权限。
echo 请右键单击此脚本并选择“以管理员身份运行”。
goto done2
)
::========================================================================================================================================

:: 此代码仅禁用当前 cmd.exe 会话的 QuickEdit，而不对注册表进行永久更改
:: 之所以添加这部分代码，是因为单击脚本窗口会暂停操作，导致混淆，误认为脚本由于错误而停止

if %_unattended%==1 set quedit=1
for %%# in (%_args%) do (if /i "%%#"=="-qedit" set quedit=1)

reg query HKCU\Console /v QuickEdit %nul2% | find /i "0x0" %nul1% || if not defined quedit (
reg add HKCU\Console /v QuickEdit /t REG_DWORD /d "0" /f %nul1%
start cmd.exe /c ""!_batf!" %_args% -qedit"
rem 将 quickedit 重置代码添加到脚本开头而不是此处，因为在某些情况下需要时间来反映
exit /b
)

::========================================================================================================================================

:: 此代码检查脚本是否在终端应用程序中运行，如果是，则使用 conhost.exe 重新启动

if %_unattended%==1 set wtrel=1
for %%# in (%_args%) do (if /i "%%#"=="-wt" set wtrel=1)

if %winbuild% GEQ 17763 (
set terminal=1

if not defined wtrel (
set test=TermTest-%random%
title !test!
%psc% "(Get-Process | Where-Object { $_.MainWindowTitle -like '*!test!*' }).ProcessName"  | find /i "cmd" %nul1% && (set terminal=)
title %comspec%
)

if defined terminal if not defined wtrel (
start conhost.exe "!_batf!" %_args% -wt
exit /b
)

for %%# in (%_args%) do (if /i "%%#"=="-wt" set terminal=)
)

::========================================================================================================================================

:: 检查更新

set -=
set old=

for /f "delims=[] tokens=2" %%# in ('ping -4 -n 1 iasupdatecheck.mass%-%grave.dev') do (
if not [%%#]==[] (echo "%%#" | find "127.69" %nul1% && (echo "%%#" | find "127.69.%iasver%" %nul1% || set old=1))
)

if defined old (
echo ________________________________________________
%eline%
echo 您正在运行过时的版本 IAS %iasver%
echo ________________________________________________
echo:
if not %_unattended%==1 (
echo [1] 获取最新的 IAS
echo [0] 仍然继续
echo:
call :_color %_Green% "在键盘上输入菜单选项 [1,0] :"
choice /C:10 /N
if !errorlevel!==2 rem
if !errorlevel!==1 (start https://github.com/WindowsAddict/IDM-Activation-Script & start %mas%/idm-activation-script & exit /b)
)
)

::========================================================================================================================================

cls
title IDM激活脚本 %iasver%

echo:
echo 初始化...

:: 检查 PowerShell

%psc% $ExecutionContext.SessionState.LanguageMode %nul2% | find /i "Full" %nul1% || (
%nceline%
%psc% $ExecutionContext.SessionState.LanguageMode
echo:
echo PowerShell未正常工作。中止操作...
echo 如果已经对 PowerShell 进行了限制，请撤销这些更改。
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

:: 检查 WMI
%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName" %nul2% | find /i "computersystem" %nul1% || (
%eline%
%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName"
echo:
echo WMI未正常工作。中止操作...
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

:: 检查用户帐户 SID

set _sid=
for /f "delims=" %%a in ('%psc% "$explorerProc = Get-Process -Name explorer | Where-Object {$_.SessionId -eq (Get-Process -Id $pid).SessionId} | Select-Object -First 1; $sid = (gwmi -Query ('Select * From Win32_Process Where ProcessID=' + $explorerProc.Id)).GetOwnerSid().Sid; $sid" %nul6%') do (set _sid=%%a)

reg query HKU\%_sid%\Software\Classes %nul% || (
%eline%
echo:
echo [%_sid%]
echo 未找到用户帐户 SID。中止操作...
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

::========================================================================================================================================

:: 检查当前用户 SID 是否与 HKCU 条目同步
reg delete HKCU\IAS_TEST /f %nul%
reg delete HKU\%_sid%\IAS_TEST /f %nul%

set HKCUsync=$null
reg add HKCU\IAS_TEST %nul%
reg query HKU\%_sid%\IAS_TEST %nul% && (
set HKCUsync=1
)

reg delete HKCU\IAS_TEST /f %nul%
reg delete HKU\%_sid%\IAS_TEST /f %nul%

::  以下代码也适用于 ARM64 Windows 10（包括 x64 位仿真）

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b
if /i not "%arch%"=="x86" set arch=x64

if "%arch%"=="x86" (
set "CLSID=HKCU\Software\Classes\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\CLSID"
set "HKLM=HKLM\Software\Internet Download Manager"
) else (
set "CLSID=HKCU\Software\Classes\Wow6432Node\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\Wow6432Node\CLSID"
set "HKLM=HKLM\SOFTWARE\Wow6432Node\Internet Download Manager"
)

for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v ExePath %nul6%') do call set "IDMan=%%b"

if not exist %SystemRoot%\Temp md %SystemRoot%\Temp
set "idmcheck=tasklist /fi "imagename eq idman.exe" | findstr /i "idman.exe" %nul1%"

:: 检查 CLSID 注册表访问

reg add %CLSID2%\IAS_TEST %nul%
reg query %CLSID2%\IAS_TEST %nul% || (
%eline%
echo 无法在 %CLSID2% 中写入。
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

reg delete %CLSID2%\IAS_TEST /f %nul%

::========================================================================================================================================

if %_reset%==1 goto :_reset
if %_activate%==1 goto :_activate

:MainMenu

cls
title IDM激活脚本 %iasver%
if not defined terminal mode 75, 28

echo:
echo:
echo:
echo:
echo:
echo:
echo:            ___________________________________________________ 
echo:                                                               
echo:               [1] 激活 IDM
echo:               [2] 重置 IDM 激活 / 试用
echo:               _____________________________________________   
echo:                                                               
echo:               [3] 下载 IDM
echo:               [4] 帮助
echo:               [0] 退出
echo:            ___________________________________________________
echo:         
call :_color2 %_White% "             " %_Green% "在键盘上输入菜单选项 [1,2,3,4,0]"
choice /C:12340 /N
set _erl=%errorlevel%

if %_erl%==5 exit /b
if %_erl%==4 start https://github.com/WindowsAddict/IDM-Activation-Script & start https://massgrave.dev/idm-activation-script & goto MainMenu
if %_erl%==3 start https://www.internetdownloadmanager.com/download.html & goto MainMenu
if %_erl%==2 goto _reset
if %_erl%==1 goto _activate
goto :MainMenu

::========================================================================================================================================

:_reset

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 35
) else (
if not defined terminal mode 113, 35
)
if not defined terminal %psc% "&%_buf%" %nul%

echo:
%idmcheck% && taskkill /f /im idman.exe

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo 在 %SystemRoot%\Temp 创建 CLSID 注册表键的备份

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
%psc% "$HKCUsync = %HKCUsync%; $lockKey = $null; $deleteKey = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

call :add_key

echo:
echo %line%
echo:
call :_color %Green% "IDM 重置过程已完成。"
echo 帮助: %mas%idm-activation-script.html#Troubleshoot

goto done
:delete_queue

echo:
echo 删除 IDM 注册表键...
echo:

for %%# in (
""HKCU\Software\DownloadManager" "/v" "FName""
""HKCU\Software\DownloadManager" "/v" "LName""
""HKCU\Software\DownloadManager" "/v" "Email""
""HKCU\Software\DownloadManager" "/v" "Serial""
""HKCU\Software\DownloadManager" "/v" "scansk""
""HKCU\Software\DownloadManager" "/v" "tvfrdt""
""HKCU\Software\DownloadManager" "/v" "radxcnt""
""HKCU\Software\DownloadManager" "/v" "LstCheck""
""HKCU\Software\DownloadManager" "/v" "ptrk_scdt""
""HKCU\Software\DownloadManager" "/v" "LastCheckQU""
"%HKLM%"
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

if not %HKCUsync%==1 for %%# in (
""HKU\%_sid%\Software\DownloadManager" "/v" "FName""
""HKU\%_sid%\Software\DownloadManager" "/v" "LName""
""HKU\%_sid%\Software\DownloadManager" "/v" "Email""
""HKU\%_sid%\Software\DownloadManager" "/v" "Serial""
""HKU\%_sid%\Software\DownloadManager" "/v" "scansk""
""HKU\%_sid%\Software\DownloadManager" "/v" "tvfrdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "radxcnt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LstCheck""
""HKU\%_sid%\Software\DownloadManager" "/v" "ptrk_scdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LastCheckQU""
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

exit /b

:del

reg delete %reg% /f %nul%

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo 删除 - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "失败 - !reg!"
)

exit /b

::========================================================================================================================================

:_activate

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 35
) else (
if not defined terminal mode 113, 35
)
if not defined terminal %psc% "&%_buf%" %nul%

echo:
if not exist "%IDMan%" (
call :_color %Red% "IDM [Internet Download Manager] 未安装。"
echo 您可以从 https://www.internetdownloadmanager.com/download.html 下载它
goto done
)

:: 使用 internetdownloadmanager.com 的 ping 和端口 80 测试进行互联网检查

set _int=
for /f "delims=[] tokens=2" %%# in ('ping -n 1 internetdownloadmanager.com') do (if not [%%#]==[] set _int=1)

if not defined _int (
%psc% "$t = New-Object Net.Sockets.TcpClient;try{$t.Connect("""internetdownloadmanager.com""", 80)}catch{};$t.Connected" | findstr /i "true" %nul1% || (
call :_color %Red% "无法连接 internetdownloadmanager.com，中止操作..."
goto done
)
call :_color %Gray% "internetdownloadmanager.com 的 ping 命令失败"
echo:
)

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "regwinos=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set "regarch=%%b"
for /f "tokens=6-7 delims=[]. " %%i in ('ver') do if "%%j"=="" (set fullbuild=%%i) else (set fullbuild=%%i.%%j)
for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v idmvers %nul6%') do set "IDMver=%%b"

echo 检查信息 - [%regwinos% ^| %fullbuild% ^| %regarch% ^| IDM: %IDMver%]

%idmcheck% && (echo: & taskkill /f /im idman.exe)

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo 在 %SystemRoot%\Temp 创建 CLSID 注册表键的备份

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
call :add_key

%psc% "$HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $toggle = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

call :register_IDM

if not defined _fileexist call :_color %Red% "错误: 无法使用 IDM 下载文件。"

%psc% "$HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

echo:
echo %line%
echo:
call :_color %Green% "IDM 激活过程已完成。"
echo:
call :_color %Gray% "如果出现假序列屏幕，请再次运行激活选项，不要使用重置选项。"
echo:
echo 帮助: %mas%idm-activation-script.html#Troubleshoot

::========================================================================================================================================

:done

echo %line%
echo:
echo:
if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
call :_color %_Yellow% "按 0 键返回..."
choice /c 0 /n
) else (
call :_color %_Yellow% "按任意键返回..."
pause %nul1%
)
goto MainMenu

:done2

if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
echo 按 0 键退出...
choice /c 0 /n
) else (
echo 按任意键退出...
pause %nul1%
)
exit /b

::========================================================================================================================================

:_rcont

reg add %reg% %nul%
call :add
exit /b

:register_IDM

echo:
echo 应用注册信息...
echo:

If not defined name set name=Tonec FZE

set "reg=HKCU\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%name%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v LName /t REG_SZ /d """ & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "info@tonec.com"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "FOX6H-3KWH4-7TSIN-Q4US7"" & call :_rcont

if not %HKCUsync%==1 (
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%name%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v LName /t REG_SZ /d """ & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "info@tonec.com"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "FOX6H-3KWH4-7TSIN-Q4US7"" & call :_rcont
)

echo:
echo 触发几次下载以创建特定的注册表键，请等待...
echo:

set "file=%SystemRoot%\Temp\temp.png"
set _fileexist=

set link=https://www.internetdownloadmanager.com/images/idm_box_min.png
call :download
set link=https://www.internetdownloadmanager.com/register/IDMlib/images/idman_logos.png
call :download
set link=https://www.internetdownloadmanager.com/pictures/idm_about.png
call :download

echo:
timeout /t 3 %nul1%
%idmcheck% && taskkill /f /im idman.exe
if exist "%file%" del /f /q "%file%"
exit /b

:download

set /a attempt=0
if exist "%file%" del /f /q "%file%"
start "" /B "%IDMan%" /n /d "%link%" /p "%SystemRoot%\Temp" /f temp.png
:check_file

timeout /t 1 %nul1%
set /a attempt+=1
if exist "%file%" set _fileexist=1&exit /b
if %attempt% GEQ 20 exit /b
goto :check_file

::========================================================================================================================================

:add_key

echo:
echo 添加注册表键...
echo:

set "reg="%HKLM%" /v "AdvIntDriverEnabled2""

reg add %reg% /t REG_DWORD /d "1" /f %nul%

:add

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo 添加成功 - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "失败 - !reg!"
)
exit /b
::========================================================================================================================================

:regscan:
$finalValues = @()

$explorerProc = Get-Process -Name explorer | Where-Object {$_.SessionId -eq (Get-Process -Id $pid).SessionId} | Select-Object -First 1
$sid = (gwmi -Query "Select * From Win32_Process Where ProcessID='$($explorerProc.Id)'").GetOwnerSid().Sid

$arch = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
if ($arch -eq "x86") {
  $regPaths = @("HKCU:\Software\Classes\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\CLSID")
} else {
  $regPaths = @("HKCU:\Software\Classes\WOW6432Node\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\Wow6432Node\CLSID")
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
	
    Write-Host
    Write-Host "在 $regPath 中搜索 IDM CLSID 注册表键"
    Write-Host
	
    $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue -ErrorVariable lockedKeys | Where-Object { $_.PSChildName -match '^\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}$' }

    foreach ($lockedKey in $lockedKeys) {
        $leafValue = Split-Path -Path $lockedKey.TargetObject -Leaf
        $finalValues += $leafValue
        Write-Output "$leafValue - 已找到锁定的键"
    }

    if ($subKeys -eq $null) {
        continue
    }
    
    $subKeysToExclude = "LocalServer32", "InProcServer32", "InProcHandler32"

    $filteredKeys = $subKeys | Where-Object { !($_.GetSubKeyNames() | Where-Object { $subKeysToExclude -contains $_ }) }

    foreach ($key in $filteredKeys) {
        $fullPath = $key.PSPath
        $keyValues = Get-ItemProperty -Path $fullPath -ErrorAction SilentlyContinue
        $defaultValue = $keyValues.PSObject.Properties | Where-Object { $_.Name -eq '(default)' } | Select-Object -ExpandProperty Value

        if (($defaultValue -match "^\d+$") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - 在默认值中找到数字且没有子键"
            continue
        }
        if (($defaultValue -match "\+|=") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - 在默认值中找到 + 或 = 且没有子键"
            continue
        }
        $versionValue = Get-ItemProperty -Path "$fullPath\Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)' -ErrorAction SilentlyContinue
        if (($versionValue -match "^\d+$") -and ($key.SubKeyCount -eq 1)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - 在 \Version 中找到数字且没有其他子键"
            continue
        }
        $keyValues.PSObject.Properties | ForEach-Object {
            if ($_.Name -match "MData|Model|scansk|Therad") {
                $finalValues += $($key.PSChildName)
                Write-Output "$($key.PSChildName) - 找到 MData Model scansk Therad"
                continue
            }
        }
        if (($key.ValueCount -eq 0) -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - 找到空键"
            continue
        }
    }
}

$finalValues = @($finalValues | Select-Object -Unique)

if ($finalValues -ne $null) {
    Write-Host
    if ($lockKey -ne $null) {
        Write-Host "锁定 IDM CLSID 注册表键..."
    }
    if ($deleteKey -ne $null) {
        Write-Host "删除 IDM CLSID 注册表键..."
    }
    Write-Host
} else {
    Write-Host "未找到 IDM CLSID 注册表键。"
    $key.SetAccessControl($acl)

    $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
        $everyone,
        'FullControl',
        'Allow'
    )
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
}

foreach ($regPath in $finalValues) {
    $path = $regPath -replace "Registry::", ""
    $rootKey = $path -split '\\', 2
    $regKey = $path -split '\\', 3
    Take-Permissions -rootKey $rootKey[0] -regKey $rootKey[1]
    $key = [Microsoft.Win32.Registry]::$rootKey[0].OpenSubKey($rootKey[1], 'ReadWriteSubTree', 'TakeOwnership')
    if ($key -ne $null) {
        $key.DeleteSubKeyTree($regKey[2], $false)
        Write-Host "已删除注册表键: $($regKey[2])"
    } else {
        Write-Host "无法删除注册表键: $($regKey[2])"
    }
}

Write-Host
Write-Host "已删除所有 IDM CLSID 注册表键。"
Write-Host
        $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'ContainerInherit', 'None', 'Allow')
        $acl.ResetAccessRule($rule)
        $key.SetAccessControl($acl)

        if ($lockKey -ne $null) {
            $acl = New-Object System.Security.AccessControl.RegistrySecurity
            $acl.SetOwner($none)
            $key.SetAccessControl($acl)

            $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'Deny')
            $acl.ResetAccessRule($rule)
            $key.SetAccessControl($acl)
        }
    }
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
    foreach ($finalValue in $finalValues) {
        $fullPath = Join-Path -Path $regPath -ChildPath $finalValue
        if ($fullPath -match 'HKCU:') {
            $rootKey = 'CurrentUser'
        } else {
            $rootKey = 'Users'
        }
        $position = $fullPath.IndexOf("\")
        $regKey = $fullPath.Substring($position + 1)

        if ($lockKey -ne $null) {
            if (-not (Test-Path -Path $fullPath -ErrorAction SilentlyContinue)) { New-Item -Path $fullPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Take-Permissions $rootKey $regKey
            try {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
            }
            catch {
                Write-Host "Locked - $fullPath"
            }
        }

        if ($deleteKey -ne $null) {
            if (Test-Path -Path $fullPath) {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $fullPath) {
                    Take-Permissions $rootKey $regKey
                    try {
                        Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                        Write-Host "Deleted - $fullPath"
                    }
                    catch {
                        Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
                    }
                }
                else {
                    Write-Host "Deleted - $fullPath"
                }
            }
        }
    }
}:regscan:

::========================================================================================================================================

:_color

if %_NCS% EQU 1 (
    echo %esc%[%~1%~2%esc%[0m
) else (
    %psc% write-host -back '%1' -fore '%2' '%3'
)
exit /b

:_color2

if %_NCS% EQU 1 (
    echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
    %psc% write-host -back '%1' -fore '%2' '%3' -NoNewline; write-host -back '%4' -fore '%5' '%6'
)
exit /b

::========================================================================================================================================
:: Leave empty line below
