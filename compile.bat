@echo off
setlocal enabledelayedexpansion
set BASE=D:\MYFILES\billing\0 Deploys\14 Jangel1\retail\billing\WEB-INF
set CLASSES=%BASE%\classes
set LIB=%BASE%\lib
set SERVLET=C:\Program Files\Apache Software Foundation\Tomcat 10.1\lib\servlet-api.jar

set CP=%CLASSES%;%SERVLET%
for %%f in ("%LIB%\*.jar") do (
    echo %%f | findstr /i "sources javadoc" >nul || set CP=!CP!;%%f
)

echo Compiling billingBean.java and POSPrinter.java...
javac -encoding UTF-8 ^
  --add-exports java.sql.rowset/com.sun.rowset=ALL-UNNAMED ^
  -cp "%CP%" ^
  "%CLASSES%\billing\billingBean.java" ^
  "%CLASSES%\print\POSPrinter.java"
if %ERRORLEVEL%==0 (
    echo.
    echo SUCCESS - Compiled OK
) else (
    echo.
    echo FAILED - See errors above
)


