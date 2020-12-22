# escape=`

# /******************* Generated by UpShift *******************/

FROM microsoft/iis
SHELL ["powershell", "-command"]

RUN Install-WindowsFeature Web-ASP; `
    Install-WindowsFeature Web-CGI; `
    Install-WindowsFeature Web-ISAPI-Ext; `
    Install-WindowsFeature Web-ISAPI-Filter; `
    Install-WindowsFeature Web-Includes; `
    Install-WindowsFeature Web-HTTP-Errors; `
    Install-WindowsFeature Web-Common-HTTP; `
    Install-WindowsFeature Web-Performance; `
    Install-WindowsFeature WAS; `
    Import-module IISAdministration;

RUN md c:/msi;

RUN Invoke-WebRequest 'http://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi' -OutFile c:/msi/urlrewrite2.msi; `
    Start-Process 'c:/msi/urlrewrite2.msi' '/qn' -PassThru | Wait-Process;


EXPOSE 8000
RUN Remove-Website -Name 'Default Web Site'; `
    md c:\ASPWebSite; `
    New-IISSite -Name "ASPWebSite" `
                -PhysicalPath 'c:\ASPWebSite' `
                -BindingInformation "*:8000:";

RUN & c:\windows\system32\inetsrv\appcmd.exe `
    unlock config `
    /section:system.webServer/asp

RUN & c:\windows\system32\inetsrv\appcmd.exe `
      unlock config `
      /section:system.webServer/handlers

RUN & c:\windows\system32\inetsrv\appcmd.exe `
      unlock config `
      /section:system.webServer/modules

ADD . c:\ASPWebSite

# /******************* Uncomment this section based on the requirements *******************/
# Section 1 - Uncomment to add application pool for this web application
# RUN & c:\windows\system32\inetsrv\appcmd.exe `
#      add apppool /name:ASPWebSiteAppPool `
#      /enable32BitAppOnWin64:true `
#      /managedRuntimeVersion:"\"\"" `
#      /managedPipelineMode:Classic ;
# RUN & c:\windows\system32\inetsrv\appcmd.exe `
#      set site "\"/site.name:ASPWebSite\"" `
#          "\"/[path='/'].applicationPool:ASPWebSiteAppPool\"" `


# Section 2 - Uncomment to register a custom library DLL. Provide DLL path in ArgumentList
# RUN Invoke-WebRequest 'https://download.microsoft.com/download/5/a/d/5ad868a0-8ecd-4bb0-a882-fe53eb7ef348/VB6.0-KB290887-X86.exe' -OutFile c:/msi/vbrun60sp6.exe; `
#    Start-Process 'c:/msi/vbrun60sp6.exe' -PassThru | Wait-Process;
# RUN Start-Process c:\windows\SysWOW64\regsvr32.exe `
#    -ArgumentList '/s', "\"c:\ASPWebSite\customDynamicLib.dll\"" -Wait;