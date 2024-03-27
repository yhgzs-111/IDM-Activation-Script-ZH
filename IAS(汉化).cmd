@set iasver=1.2
@setlocal DisableDelayedExpansion
@echo off

::============================================================================
::
::   IDM 激活脚本 IDM Activation Script（IAS）
::
::   主页：https://github.com/WindowsAddict/IDM-Activation-Script
::         https://massgrave.dev/idm-activation-script
::
::   电子邮件：windowsaddict@protonmail.com
::   汉化作者：https://github.com/yhgzs-111/
::   汉化主页：https://github.com/yhgzs-111/IDM-Activation-Script-ZH/
::
::============================================================================

:: 要激活，请使用 "/act" 参数运行脚本或在下面的行中将 0 更改为 1
set _activate=0

:: 要冻结 30 天的试用期，请使用 "/frz" 参数运行脚本或在下面的行中将 0 更改为 1
set _freeze=0

:: 要重置激活和试用，请使用 "/res" 参数运行脚本或在下面的行中将 0 更改为 1
set _reset=0

:: 如果在上述行中更改了值或使用了参数，则脚本将以无人值守模式运行

::========================================================================================================================================

:: 设置路径变量，如果系统中配置错误，则有助于解决

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

:: 如果在 64 位 Windows 上由 32 位进程启动脚本，则使用 x64 进程重新启动脚本
:: 或者在 ARM64 Windows 上由 x86/ARM32 进程启动脚本时使用 ARM64 进程重新启动

set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="r1" set r1=1
if /i "%%#"=="r2" set r2=1
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
exit /b
)

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::========================================================================================================================================

set "blank="
set "mas=ht%blank%tps%blank%://mass%blank%grave.dev/"

:: 检查空服务是否运行，这对批处理脚本很重要

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

:: 检查 LF 行结束符

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
echo:
echo 错误：脚本可能存在 LF 行结束符问题，或脚本末尾缺少空行。
echo:
ping 127.0.0.1 -n 6 >nul
popd
exit /b
)
popd

::========================================================================================================================================

cls
color 07
title IDM 激活脚本_Github@yhgzs-111 汉化 %iasver%

set _args=
set _elev=
set _unattended=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="-el"  set _elev=1
if /i "%%A"=="/res" set _reset=1
if /i "%%A"=="/frz" set _freeze=1
if /i "%%A"=="/act" set _activate=1
)
)

for %%A in (%_activate% %_freeze% %_reset%) do (if "%%A"=="1" set _unattended=1)

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
    echo 此项目仅支持 Windows 7/8/8.1/10/11 及其服务器等效版本。
    goto done2
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
    %nceline%
    echo 系统中找不到 powershell.exe。
    goto done2
)

::========================================================================================================================================

::  修复路径名称中的特殊字符限制

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%
set _PSarg=%_PSarg:'=''%

set "_appdata=%appdata%"
set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" %nul1% && (
    if /i not "!_work!"=="!_ttemp!" (
        %eline%
        echo 脚本是从临时文件夹启动的，
        echo 很可能您是直接从存档文件运行脚本。
        echo:
        echo 请提取存档文件并在提取后的文件夹并脚本。
        goto done2
    )
)

::========================================================================================================================================

:: 检查 PowerShell

REM :PowerShellTest: $ExecutionContext.SessionState.LanguageMode :PowerShellTest:

%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':PowerShellTest:\s*';iex ($f[1])" | find /i "FullLanguage" %nul1% || (
%eline%
%psc% $ExecutionContext.SessionState.LanguageMode
echo:
echo PowerShell 未正常工作。正在中止...
echo 如果您对 PowerShell 应用了限制，请取消这些更改。
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

::========================================================================================================================================

:: 提升脚本权限为管理员并传递参数以及避免循环

%nul1% fltmc || (
if not defined _elev %psc% "start cmd.exe -arg '/c \"!_PSarg!\"' -verb runas" && exit /b
%eline%
echo 此脚本需要管理员权限。
echo 请重新打开脚本并在弹出管理员权限请求框时选择“是”。
goto done2
)

::========================================================================================================================================

:: 禁用快速编辑（QuickEdit）并从 conhost.exe 启动以避免终端应用

set quedit=
set terminal=

if %_unattended%==1 (
set quedit=1
set terminal=1
)

for %%# in (%_args%) do (if /i "%%#"=="-qedit" set quedit=1)

if %winbuild% LSS 10586 (
reg query HKCU\Console /v QuickEdit %nul2% | find /i "0x0" %nul1% && set quedit=1
)

if %winbuild% GEQ 17763 (
set "launchcmd=start conhost.exe %psc%"
) else (
set "launchcmd=%psc%"
)

set "d1=$t=[AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1).DefineDynamicModule(2, $False).DefineType(0);"
set "d2=$t.DefinePInvokeMethod('GetStdHandle', 'kernel32.dll', 22, 1, [IntPtr], @([Int32]), 1, 3).SetImplementationFlags(128);"
set "d3=$t.DefinePInvokeMethod('SetConsoleMode', 'kernel32.dll', 22, 1, [Boolean], @([IntPtr], [Int32]), 1, 3).SetImplementationFlags(128);"
set "d4=$k=$t.CreateType(); $b=$k::SetConsoleMode($k::GetStdHandle(-10), 0x0080);"

if defined quedit goto :skipQE
%launchcmd% "%d1% %d2% %d3% %d4% & cmd.exe '/c' '!_PSarg! -qedit'" &exit /b
:skipQE

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
echo [1] 获取最新的原版 IAS
echo [2] 获取最新的汉化版 IAS
echo [0] 继续
echo:
call :_color %_Green% "在键盘上输入一个菜单选项 [1,0] :"
choice /C:120 /N
if !errorlevel!==0 rem
if !errorlevel!==1 (start https://github.com/WindowsAddict/IDM-Activation-Script & start %mas%/idm-activation-script & exit /b)
if !errorlevel!==2 (start https://github.com/yhgzs-111/IDM-Activation-Script-ZH & exit /b)
)
)

::========================================================================================================================================

cls
title  IDM 激活脚本 %iasver%

echo:
echo 初始化...

:: 检查 WMI

%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName" %nul2% | find /i "computersystem" %nul1% || (
%eline%
%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName"
echo:
echo WMI 未正常工作。正在中止...
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

:: 检查用户账户 SID

set _sid=
for /f "delims=" %%a in ('%psc% "([System.Security.Principal.NTAccount](Get-WmiObject -Class Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value" %nul6%') do (set _sid=%%a)
 
reg query HKU\%_sid%\Software %nul% || (
for /f "delims=" %%a in ('%psc% "$explorerProc = Get-Process -Name explorer | Where-Object {$_.SessionId -eq (Get-Process -Id $pid).SessionId} | Select-Object -First 1; $sid = (gwmi -Query ('Select * From Win32_Process Where ProcessID=' + $explorerProc.Id)).GetOwnerSid().Sid; $sid" %nul6%') do (set _sid=%%a)
)

reg query HKU\%_sid%\Software %nul% || (
%eline%
echo:
echo [%_sid%]
echo 用户账户 SID 未找到。正在中止...
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

::========================================================================================================================================

:: 检查当前用户 SID 是否与 HKCU 条目同步

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

set HKCUsync=$null
%nul% reg add HKCU\IAS_TEST
%nul% reg query HKU\%_sid%\IAS_TEST && (
set HKCUsync=1
)

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

:: 下面的代码也适用于 ARM64 Windows 10（包括 x64 位模拟）

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

if not exist "%IDMan%" (
if %arch%==x64 set "IDMan=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
if %arch%==x86 set "IDMan=%ProgramFiles%\Internet Download Manager\IDMan.exe"
)

if not exist %SystemRoot%\Temp md %SystemRoot%\Temp
set "idmcheck=tasklist /fi "imagename eq idman.exe" | findstr /i "idman.exe" %nul1%"

:: 检查 CLSID 注册表访问

%nul% reg add %CLSID2%\IAS_TEST
%nul% reg query %CLSID2%\IAS_TEST || (
%eline%
echo 无法写入 %CLSID2%
echo:
echo 请查看此页面以获取帮助。 %mas%idm-activation-script.html#Troubleshoot
goto done2
)

%nul% reg delete %CLSID2%\IAS_TEST /f

::========================================================================================================================================
::没搞懂第二个选项为什么改了字就会出错，也许是我电脑原因？有没有人找到原因提交个PR？

if %_reset%==1 goto :_reset
if %_activate%==1 (set frz=0&goto :_activate)
if %_freeze%==1 (set frz=1&goto :_activate)

:MainMenu

cls
title  IDM 激活脚本_Github@yhgzs-111 汉化 %iasver%
if not defined terminal mode 75, 28

echo:
echo:
echo:
echo:
echo:
echo:
echo:            ___________________________________________________ 
echo:                                                               
echo:               [1] 冻结30天免费试用
echo:               [2] 激活 ^(部分用户无法使用^)
echo:               [3] 重置激活/免费试用
echo:               _____________________________________________   
echo:                                                               
echo:               [4] 下载IDM
echo:               [5] 帮助
echo:               [0] 退出
echo:            ___________________________________________________
echo:         
echo:         汉化^ By Github@yhgzs-11^1
echo:         
call :_color2 %_White% "             " %_Green% "输入键盘上的菜单选项 [1,2,3,4,5,0]"
choice /C:123450 /N
set _erl=%errorlevel%

if %_erl%==6 exit /b
if %_erl%==5 start https://github.com/WindowsAddict/IDM-Activation-Script & start https://massgrave.dev/idm-activation-script & start https://github.com/yhgzs-111/IDM-Activation-Script-ZH & goto MainMenu
if %_erl%==4 start https://www.internetdownloadmanager.com/download.html & goto MainMenu
if %_erl%==3 goto _reset
if %_erl%==2 (set frz=0&goto :_activate)
if %_erl%==1 (set frz=1&goto :_activate)

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
echo 创建 CLSID 注册表项备份至 %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = $null; $deleteKey = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

call :add_key

echo:
echo %line%
echo:
call :_color %Green% "IDM 重置过程已完成。"

goto done

:delete_queue

echo:
echo 删除 IDM 注册表项...
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
echo 已删除 - !reg!
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

if %frz%==0 if %_unattended%==0 (
echo:
echo %line%
echo:
echo      激活对于某些用户无效，IDM 可能会显示虚假序列号提示窗口。
echo:
call :_color2 %_White% "     " %_Green% "建议使用冻结试用期选项。"
echo %line%
echo:
choice /C:19 /N /M ">    [1] 返回 [9] 激活 : "
if !errorlevel!==1 goto :MainMenu
cls
)

echo:
if not exist "%IDMan%" (
call :_color %Red% "IDM [Internet Download Manager] 未安装。"
echo 您可以从 https://www.internetdownloadmanager.com/download.html 下载。
goto done
)

:: 使用 internetdownloadmanager.com ping 和端口 80 测试进行

set _int=
for /f "delims=[] tokens=2" %%# in ('ping -n 1 internetdownloadmanager.com') do (if not [%%#]==[] set _int=1)

if not defined _int (
%psc% "$t = New-Object Net.Sockets.TcpClient;try{$t.Connect("""internetdownloadmanager.com""", 80)}catch{};$t.Connected" | findstr /i "true" %nul1% || (
call :_color %Red% "无法连接 internetdownloadmanager.com，请中止..."
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
echo 创建 CLSID 注册表项备份至 %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
call :add_key

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $toggle = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

if %frz%==0 call :register_IDM

call :download_files
if not defined _fileexist (
%eline%
echo 错误：无法使用 IDM 下载文件。
echo:
echo 帮助： %mas%idm-activation-script.html#Troubleshoot
goto :done
)

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

echo:
echo %line%
echo:
if %frz%==0 (
call :_color %Green% "IDM 激活过程已完成。"
echo:
call :_color %Gray% "如果出现假序列号提示，请使用冻结试用选项。"
) else (
call :_color %Green% "IDM 30 天试用期已成功冻结，终身有效。"
echo:
call :_color %Gray% "如果 IDM 弹出注册提示，请重新安装 IDM。"
)

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
echo 应用注册详情中...
echo:

set /a fname=%random% %% 9999 + 1000
set /a lname=%random% %% 9999 + 1000
set email=%fname%.%lname%@tonec.com

for /f "delims=" %%a in ('%psc% "$key = -join ((Get-Random -Count 20 -InputObject ([char[]]('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'))));$key = ($key.Substring(0, 5) + '-' + $key.Substring(5, 5) + '-' + $key.Substring(10, 5) + '-' + $key.Substring(15, 5) + $key.Substring(20));Write-Output $key" %nul6%') do (set key=%%a)

set "reg=HKCU\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont

if not %HKCUsync%==1 (
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont
)
exit /b

:download_files

echo:
echo 正在触发下载以创建特定的注册表键，请稍候...
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
echo 添加注册表键中...
echo:

set "reg="%HKLM%" /v "AdvIntDriverEnabled2""

reg add %reg% /t REG_DWORD /d "1" /f %nul%

:add

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo 已添加 - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "添加失败 - !reg!"
)
exit /b

::========================================================================================================================================

:regscan:
$finalValues = @()

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
        Write-Output "$leafValue - 找到锁定的键"
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
            Write-Output "$($key.PSChildName) - 在默认值中找到+或=且没有子键"
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
	Exit
}

if (($finalValues.Count -gt 20) -and ($toggle -ne $null)) {
	$lockKey = $null
	$deleteKey = 1
    Write-Host "IDM 键数超过 20 个。现在删除它们而不是锁定..."
	Write-Host
}

function Take-Permissions {
    param($rootKey, $regKey)
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule(2, $False)
    $TypeBuilder = $ModuleBuilder.DefineType(0)

    $TypeBuilder.DefinePInvokeMethod('RtlAdjustPrivilege', 'ntdll.dll', 'Public, Static', 1, [int], @([int], [bool], [bool], [bool].MakeByRefType()), 1, 3) | Out-Null
    9,17,18 | ForEach-Object { $TypeBuilder.CreateType()::RtlAdjustPrivilege($_, $true, $false, [ref]$false) | Out-Null }

    $SID = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $IDN = ($SID.Translate([System.Security.Principal.NTAccount])).Value
    $Admin = New-Object System.Security.Principal.NTAccount($IDN)

    $everyone = New-Object System.Security.Principal.SecurityIdentifier('S-1-1-0')
    $none = New-Object System.Security.Principal.SecurityIdentifier('S-1-0-0')

    $key = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($regkey, 'ReadWriteSubTree', 'TakeOwnership')

    $acl = New-Object System.Security.AccessControl.RegistrySecurity
    $acl.SetOwner($Admin)
    $key.SetAccessControl($acl)

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
}
:regscan:

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
:: 在此留下空行
