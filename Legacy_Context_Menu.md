## I prefer the old right click context menu over the new one as all my third part apps and their actions are visible in it by default

To enable it paste this in elevated CMD and restart
```
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
```

To restore the new windows 11 context menu enter this in elevated CMD and restart
```
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
```
