SET TALK OFF
SET DELETED ON
SET CENTURY ON
SET DATE TO YMD

CD JUSTPATH(SYS(16))

SET PROCEDURE TO utilities ADDITIVE
SET PROCEDURE TO account_utilities ADDITIVE
SET PROCEDURE TO migration_helper ADDITIVE
LOCAL nHandle, lcRetry, nSuccess, lcMigrationResult
PUBLIC fConfigINI, pConfigINI, cLoggedIn, cCurrentUser, cCurrentUserID
fConfigINI = "config.ini"
pConfigINI = "profile.ini"
cLoggedIn = .F.
cCurrentUser = ""

DO WHILE .T.
    nSuccess = ConnectToMySQL(fConfigINI)
    
    IF nSuccess > 0
        PUBLIC gnDBHandle
        gnDBHandle = nSuccess
        MigrateMYSQL(gnDBHandle)
        EXIT 
    ELSE
        lcRetry = MESSAGEBOX("Conexion a la base de datos fallida" + CHR(13) + ;
                             "¿Desea reintentar?", ;
                             52, ;
                             "Error de conexion")
        
        IF lcRetry = 7 
            MESSAGEBOX("La aplicacion se cerrara", 48, "Aviso")
            RETURN 
        ENDIF
    ENDIF
ENDDO

DO FORM formmain

READ EVENTS


IF TYPE("gnDBHandle") = "N" AND gnDBHandle > 0
    SQLDISCONNECT(gnDBHandle)
ENDIF

RETURN