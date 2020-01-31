@echo off

rem uses xml.exe from https://sourceforge.net/projects/xmlstar/

call %~dp0..\product.environment.bat

setlocal

set repoFile=%~dp0..\repos.properties.xml

set defaultBranch=
for /f %%i in ('xml sel -t -v "//repositories/shared/common/@ref" %repoFile%') do set defaultBranch=%%i

set publicBranch=
for /f %%i in ('xml sel -t -v "//repositories/repos/repository[@name='dev-env-public']/@ref" %repoFile%') do set publicBranch=%%i
IF "%publicBranch%"=="" ( set publicBranch=%defaultBranch% )

cd %~dp0..\..\..
IF NOT EXIST tools ( mkdir tools )
cd %~dp0..\..\..\tools
IF NOT EXIST dev-env ( mkdir dev-env )

cd %~dp0..\..\..\tools\dev-env\
IF NOT EXIST public (
   rem echo cloning dev-env-public on %publicBranch%
   git clone -q -b %publicBranch% git@github.com:CenturyLink-ViNO/dev-env-public.git public
)

cd %~dp0..\..\..
IF NOT EXIST treeTop.txt ( touch /c treeTop.txt )
IF NOT EXIST build.xml (
   copy %ABACUS_PRODUCT_NAME%\product.settings\bootstrap\build.bootstrap.xml build.xml
)

endlocal
cd %~dp0..\..\..
set ANT_TOOLS_HOME=%~dp0..\..\..\tools\dev-env\public\ant\
