@echo off
setlocal

IF "%1"=="" (
  echo "Missing MSVC version [2017|2019]"
  pause
  exit /b 1c
)

IF "%2"=="" (
  echo "Missing architecture [x86|x64]"
  pause
  exit /b 1c
)

IF "%3"=="" (
  echo "Missing lib type [dynamic|static]"
  pause
  exit /b 1c
)

IF "%4"=="" (
  echo "Missing QT path ie: C:\Qt\5.14.1\msvc2017"
  pause
  exit /b 1c
)

SET INSTALLPATH=""
IF NOT "%5"=="" (
  SET INSTALLPATH=%5
)

SET MSVC=%1
SET ARCH=%2
SET LIBTYPE=%3
SET QTDIR=%4

SET BUILDTOOL=jom
SET vcarch=%ARCH%
SET usbarch=%ARCH%
IF "%ARCH%" == "x64" SET vcarch=amd64
IF "%ARCH%" == "x86" SET usbarch=Win32
SET PROJDIR=%CD%
SET BUILDDIR=%PROJDIR%\build

SET STATIC=""
IF "%LIBTYPE%" == "static" SET STATIC="CONFIG+=staticlib"

CALL "C:\Program Files (x86)\Microsoft Visual Studio\%MSVC%\Community\VC\Auxiliary\Build\vcvarsall.bat" %vcarch%

SET PATH=%QTDIR%\bin;C:\Qt\Tools\QtCreator\bin;%PATH%

WHERE /Q jom
IF %errorlevel% NEQ 0 set BUILDTOOL=nmake

git submodule update --init --recursive

echo %BUILDDIR%

RMDIR /S /Q %BUILDDIR%
MKDIR %BUILDDIR%
CD %BUILDDIR%
%QTDIR%\bin\qmake.exe %STATIC% %PROJDIR%

IF NOT "%INSTALLPATH%"=="" (
  RMDIR /S /Q %INSTALLPATH%
  MKDIR %INSTALLPATH%
  %BUILDTOOL% INSTALL_ROOT=%INSTALLPATH% install docs install_docs
)
ELSE (
  %BUILDTOOL% install docs install_docs
)
%BUILDTOOL% sub-tests


endlocal
