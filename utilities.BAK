FUNCTION ReadINI(pSection as String, pKey as String, pINIFile as String) as String
    LOCAL xDefault, xRetVal, xRetLen, lcIniFile, xRet
    
    lcIniFile = ADDBS(SYS(5) + SYS(2003)) + pINIFile
    
    xDefault = ""
    xRetVal = SPACE(255)
    xRetLen = LEN(xRetVal)
    
    DECLARE INTEGER GetPrivateProfileString IN WIN32API ;
        STRING pSection, STRING pKey, ;
        STRING xDefault, STRING @xRetVal, ;
        INTEGER xRetLen, STRING lcIniFile
    
    xRet = GetPrivateProfileString(pSection, pKey, xDefault, ;
                                    @xRetVal, xRetLen, lcIniFile)
    
    RETURN ALLTRIM(LEFT(xRetVal, AT(CHR(0), xRetVal) - 1))
ENDFUNC

FUNCTION WriteINI(pINIFile AS String, pSection AS String, pKey AS String, pValue AS String) AS Logical
    LOCAL lcIniFile, lnResult
    
    lcIniFile = ADDBS(SYS(5) + SYS(2003)) + pINIFile

    IF !FILE(lcIniFile)
        STRTOFILE("", lcIniFile)
    ENDIF

    DECLARE INTEGER WritePrivateProfileString IN WIN32API ;
        STRING pSection, STRING pKey, STRING pValue, STRING pFileName

    lnResult = WritePrivateProfileString(pSection, pKey, pValue, lcIniFile)

    RETURN (lnResult # 0)
ENDFUNC

FUNCTION fileExists(pFileName)
	LOCAL lcSection
	lcSection = ADDBS(SYS(5) + SYS(2003)) + pFileName
	RETURN FILE(lcSection)
ENDFUNC

FUNCTION ConnectToMySQL(pINIFile as String) as Integer
    LOCAL lnHandle, lcDriver, lcServer, lcDatabase, lcUser, lcPassword
    LOCAL lcConnString, lcError
    LOCAL lcIniExists
    
    IF EMPTY(pINIFile)
        pINIFile = "config.ini"
    ENDIF
    
    lcIniExists = fileExists(pINIFile)
    IF !lcIniExists
    	MESSAGEBOX("El archivo '"+ pINIFile +"' no se encontro o no puede ser leido!", 16, "Error al leer archivo")
    	RETURN -1
    ENDIF
    
    lcDriver = ReadINI("Database", "Driver", pINIFile)
    lcServer = ReadINI("Database", "Server", pINIFile)
    lcDatabase = ReadINI("Database", "Database", pINIFile)
    lcUser = ReadINI("Database", "User", pINIFile)
    lcPassword = ReadINI("Database", "Password", pINIFile)
    
    IF EMPTY(lcDriver) OR EMPTY(lcServer) OR EMPTY(lcDatabase) OR EMPTY(lcUser) OR EMPTY(lcPassword)
    	MESSAGEBOX("Uno o más valores del archivo de configuración están vacíos.", 48, "Error de conexión")
    	RETURN -1
	ENDIF
    
    IF EMPTY(lcDatabase)
        MESSAGEBOX("El nombre de la base de datos no esta en el archivo INI!", 48, "Error de conexion")
        RETURN -1
    ENDIF
    
    lcConnString = "DRIVER=" + ALLTRIM(lcDriver) + ;
                   ";SERVER=" + ALLTRIM(lcServer) + ;
                   ";DATABASE=" + ALLTRIM(lcDatabase) + ;
                   ";UID=" + ALLTRIM(lcUser) + ;
                   ";PWD=" + ALLTRIM(lcPassword) + ;
                   ";OPTION=3;SSLMODE=DISABLED;"
    
    lnHandle = SQLSTRINGCONNECT(lcConnString)
    
    IF lnHandle > 0
        SQLSETPROP(lnHandle, "Transactions", 2)
        SQLSETPROP(lnHandle, "BatchMode", .T.)
        SQLSETPROP(lnHandle, "QueryTimeOut", 30)
        
        RETURN lnHandle
    ELSE
        lcError = GetSQLError()
        
        MESSAGEBOX("Error al conectar con la base de datos!" + CHR(13) + CHR(13) + ;
                   "Server: " + lcServer + CHR(13) + ;
                   "Database: " + lcDatabase + CHR(13) + CHR(13) + ;
                   "Error: " + lcError, 48, "Error de conexion")
        RETURN -1
    ENDIF
ENDFUNC


FUNCTION GetSQLError() as String
    LOCAL laError[1], lcError, i
    
    lcError = ""
    
    IF AERROR(laError) > 0
        FOR i = 1 TO ALEN(laError, 1)
            IF !EMPTY(laError[i, 2])
                lcError = lcError + laError[i, 2] + CHR(13)
            ENDIF
        NEXT
    ENDIF
    
    RETURN IIF(EMPTY(lcError), "Error desconocido", ALLTRIM(lcError))
ENDFUNC


FUNCTION DisconnectFromMySQL(pnHandle as Integer) as Boolean
    IF pnHandle > 0
        SQLDISCONNECT(pnHandle)
        RETURN .T.
    ENDIF
    RETURN .F.
ENDFUNC


FUNCTION TestConnection(pINIFile as String, pDisplayMessage as Boolean) as Boolean
    LOCAL lnHandle
    
    lnHandle = ConnectToMySQL(pINIFile)
    
    IF lnHandle > 0
    	IF pDisplayMessage
        	MESSAGEBOX("Conectado correctamente!", 64, "Success")
        ENDIF
        DisconnectFromMySQL(lnHandle)
        RETURN .T.
    ENDIF
    
    RETURN .F.
ENDFUNC

FUNCTION BETWEENCOUNTS(tcString, tcLow, tcHigh)
    LOCAL i, lnLen, lcChar
    lnLen = LEN(tcString)
    FOR i = 1 TO lnLen
        lcChar = SUBSTR(tcString, i, 1)
        IF lcChar >= tcLow AND lcChar <= tcHigh
            RETURN .T.
        ENDIF
    NEXT
    RETURN .F.
ENDFUNC