FUNCTION getUserAccountData(pProfileFile as String) as String
	RETURN ReadINI("Profile", "LastUser", pProfileFile)
ENDFUNC

FUNCTION saveUserAccountData(pProfileFile as String, pUserName) as String
	LOCAL nResult
		nResult = WriteINI(pProfileFile, "Profile", "LastUser", pUserName)
		
		IF !nResult
			MESSAGEBOX("Error al guardar informacion de perfil", 48, "Error de escritura")
			RETURN .F.
		ENDIF
		RETURN .T.
ENDFUNC