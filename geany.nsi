;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Installer script for Geany (Windows Installer)      ;
; Script generated by the HM NIS Edit Script Wizard.  :
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;
; helper defines  ;
;;;;;;;;;;;;;;;;;;;
!define PRODUCT_NAME "Geany"
!define PRODUCT_VERSION "0.11"
!define PRODUCT_VERSION_ID "0.11.0.0"
!define PRODUCT_PUBLISHER "Enrico Tr�ger"
!define PRODUCT_WEB_SITE "http://geany.uvena.de"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Geany.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

!define RESOURCEDIR "geany-${PRODUCT_VERSION}"

; only used when embedding GTK+ installer
!define GTK_INSTALLER "gtk+-2.10.6-1-setup.exe"

SetCompressor /SOLID lzma
XPStyle on
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
!ifdef INCLUDE_GTK
OutFile "geany-${PRODUCT_VERSION}_setup.exe"
!else
OutFile "geany-${PRODUCT_VERSION}_nogtk_setup.exe"
!endif
InstallDir "$PROGRAMFILES\Geany"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails hide
ShowUnInstDetails hide

;;;;;;;;;;;;;;;;;;;;;
; Version resource  ;
;;;;;;;;;;;;;;;;;;;;;
VIProductVersion "${PRODUCT_VERSION_ID}"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright 2005-2007 by Enrico Tr�ger"
VIAddVersionKey "FileDescription" "${PRODUCT_NAME} Installer"

;;;;;;;;;;;;;;;;
; Init code    ;
;;;;;;;;;;;;;;;;
Function .onInit
  ; prevent running multiple instances of the installer
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "geany_installer") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort

  ; warn about a new install over an existing installation
  ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"
  StrCmp $R0 "" done

  MessageBox MB_YESNO|MB_ICONEXCLAMATION \
  "Geany has already been installed. $\nDo you want to remove the previous version before installing $(^Name) ?" \
  IDNO done

  ;Run the uninstaller
  ClearErrors
  ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file

  done:
FunctionEnd


;;;;;;;;;;;;;;;;
; MUI Settings ;
;;;;;;;;;;;;;;;;
!include "MUI.nsh"

!define MUI_ABORTWARNING
#!define MUI_ICON "pixmaps\geany.ico"
#!define MUI_UNICON "pixmaps\win-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
;!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "${RESOURCEDIR}\Copying.txt"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE OnDirLeave
!insertmacro MUI_PAGE_DIRECTORY
; Start menu page
var ICONS_GROUP
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Geany"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\Geany.exe"
!insertmacro MUI_PAGE_FINISH
; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES
; Language files
!insertmacro MUI_LANGUAGE "English"
; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; MUI end ------


;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sections and InstTypes  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
InstType "Full"
InstType "Minimal"

Section "!Program Files" SEC01
  SectionIn RO 1 2
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "${RESOURCEDIR}\Geany.exe"
  File "${RESOURCEDIR}\*.txt"

  SetOutPath "$INSTDIR\data"
  File "${RESOURCEDIR}\data\GPL-2"
  File "${RESOURCEDIR}\data\file*"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Geany.lnk" "$INSTDIR\Geany.exe"
  CreateShortCut "$DESKTOP\Geany.lnk" "$INSTDIR\Geany.exe"
  CreateShortCut "$QUICKLAUNCH\Geany.lnk" "$INSTDIR\Geany.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Language Files" SEC02
  SectionIn 1
  SetOutPath "$INSTDIR"
  File /r "${RESOURCEDIR}\lib"
SectionEnd

Section "Documentation" SEC03
  SectionIn 1
  SetOverwrite ifnewer
  SetOutPath "$INSTDIR"
  File /r "${RESOURCEDIR}\doc"

; Shortcuts
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  WriteIniStr "$INSTDIR\Documentation.url" "InternetShortcut" "URL" "$INSTDIR\doc\index.html"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Documentation.lnk" "$INSTDIR\Documentation.url"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Autocompletion Tags" SEC04
  SectionIn 1
  SetOutPath "$INSTDIR\data"
  SetOverwrite ifnewer
  File "${RESOURCEDIR}\data\php.tags"
  File "${RESOURCEDIR}\data\pascal.tags"
  File "${RESOURCEDIR}\data\latex.tags"
  File "${RESOURCEDIR}\data\html_entities.tags"
  File "${RESOURCEDIR}\data\global.tags"
SectionEnd

; Include GTK runtime library but only if desired from command line
!ifdef INCLUDE_GTK
Section "GTK 2.10 Runtime Environment" SEC05
  SectionIn 1
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "gtk\*"
  SetOutPath "$INSTDIR\etc"
  File /r "gtk\etc\*"
  SetOutPath "$INSTDIR\lib"
  File /r "gtk\lib\*"
  SetOutPath "$INSTDIR\share"
  File /r "gtk\share\*"
/* code to embed GTK+ installer executable
  File ${GTK_INSTALLER}
  ExecWait ${GTK_INSTALLER}
*/
SectionEnd
!endif

Section "Context menus" SEC06
  SectionIn 1
  WriteRegStr HKCR "*\shell\OpenWithGeany" "" "Open with Geany"
  WriteRegStr HKCR "*\shell\OpenWithGeany\command" "" '$INSTDIR\geany.exe "%1"'
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Geany.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Geany.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;
; Section descriptions  ;
;;;;;;;;;;;;;;;;;;;;;;;;;
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Required program files. You cannot skip these files."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} ""
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Manual in Text and HTML format."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Symbol lists necessary for auto completion of symbols."
!ifdef INCLUDE_GTK
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "You need this files to run Geany. If you have already installed a GTK Runtime Environment (2.6 or higher), you can skip it."
!endif
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06} "Add context menu item 'Open With Geany'"
!insertmacro MUI_FUNCTION_DESCRIPTION_END



;;;;;;;;;;;;;;;;;;;;;
; helper functions  ;
;;;;;;;;;;;;;;;;;;;;;
Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Function OnDirLeave
  ClearErrors
  SetOutPath "$INSTDIR" ; what about IfError creating $INSTDIR?
  GetTempFileName $1 "$INSTDIR" ; creates tmp file (or fails)
  FileOpen $0 "$1" "w" ; error to open?
  FileWriteByte $0 "0"
  IfErrors notPossible possible

notPossible:
  RMDir "$INSTDIR" ; removes folder if empty
  MessageBox MB_OK "The given directory is not writeable. Please choose another one!"
  Abort
possible:
  FileClose $0
  Delete "$1"
FunctionEnd

Section Uninstall
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\Documentation.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\News.txt"
  Delete "$INSTDIR\ReadMe.txt"
  Delete "$INSTDIR\Thanks.txt"
  Delete "$INSTDIR\ToDo.txt"
  Delete "$INSTDIR\Authors.txt"
  Delete "$INSTDIR\ChangeLog.txt"
  Delete "$INSTDIR\Copying.txt"
  Delete "$INSTDIR\Geany.exe"
  ; GTK files
  Delete "$INSTDIR\charset.dll"
  Delete "$INSTDIR\gspawn-win32-helper.exe"
  Delete "$INSTDIR\gspawn-win32-helper-console.exe"
  Delete "$INSTDIR\iconv.dll"
  Delete "$INSTDIR\intl.dll"
  Delete "$INSTDIR\libgthread-2.0-0.dll"
  Delete "$INSTDIR\libgtk-win32-2.0-0.dll"
  Delete "$INSTDIR\libpangocairo-1.0-0.dll"
  Delete "$INSTDIR\libpangowin32-1.0-0.dll"
  Delete "$INSTDIR\libgobject-2.0-0.dll"
  Delete "$INSTDIR\libpango-1.0-0.dll"
  Delete "$INSTDIR\libpangoft2-1.0-0.dll"
  Delete "$INSTDIR\libpng13.dll"
  Delete "$INSTDIR\libatk-1.0-0.dll"
  Delete "$INSTDIR\libcairo-2.dll"
  Delete "$INSTDIR\libgdk_pixbuf-2.0-0.dll"
  Delete "$INSTDIR\libgdk-win32-2.0-0.dll"
  Delete "$INSTDIR\libglib-2.0-0.dll"
  Delete "$INSTDIR\libgmodule-2.0-0.dll"
  Delete "$INSTDIR\zlib1.dll"

  Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
  Delete "$QUICKLAUNCH\Geany.lnk"
  Delete "$DESKTOP\Geany.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Geany.lnk"
  Delete "$SMPROGRAMS\$ICONS_GROUP\Documentation.lnk"

  RMDir "$SMPROGRAMS\$ICONS_GROUP"
  RMDir /r "$INSTDIR\doc"
  RMDir /r "$INSTDIR\data"
  RMDir /r "$INSTDIR\etc"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\share"
  RMDir "$INSTDIR"

  DeleteRegKey HKCR "*\shell\OpenWithGeany"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd

