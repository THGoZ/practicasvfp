FUNCTION MigrateMYSQL(pConn)
LOCAL nConn, nResult, cSQL, cTable, cMigration
nConn = pConn

IF nConn <= 0
    MESSAGEBOX("No se pudo conectar a la base de datos!", 16, "Error")
    RETURN
ENDIF

? "Conectado a MySQL correctamente."


IF NOT TableExists("migrations", nConn)
    ? "Creando tabla: migrations"
    cSQL = ;
        "CREATE TABLE migrations (" + ;
        "id INT AUTO_INCREMENT PRIMARY KEY, " + ;
        "migration_name VARCHAR(150) NOT NULL UNIQUE, " + ;
        "executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP" + ;
        ");"
    RunSQL(cSQL, nConn)
ELSE
    ? "La tabla ya existe: migrations"
ENDIF

LOCAL ARRAY aMigrations[3]
aMigrations[1] = "create_persons_table"
aMigrations[2] = "create_foods_table"
aMigrations[3] = "create_food_logs_table"

FOR i = 1 TO ALEN(aMigrations, 1)
    cMigration = aMigrations[i]

    IF NOT MigrationExists(cMigration, nConn)
        DO CASE
        CASE cMigration == "create_persons_table"
            cSQL = ;
                "CREATE TABLE persons (" + ;
                "id INT AUTO_INCREMENT PRIMARY KEY, " + ;
                "name VARCHAR(100) NOT NULL, " + ;
                "age INT, " + ;
                "weight DOUBLE, " + ;
                "gender CHAR(1)" + ;
                ");"

        CASE cMigration == "create_foods_table"
            cSQL = ;
                "CREATE TABLE foods (" + ;
                "id INT AUTO_INCREMENT PRIMARY KEY, " + ;
                "name VARCHAR(100) NOT NULL UNIQUE, " + ;
                "calories_100g DOUBLE NOT NULL DEFAULT 0" + ;
                ");"

        CASE cMigration == "create_food_logs_table"
            cSQL = ;
                "CREATE TABLE food_logs (" + ;
                "id INT AUTO_INCREMENT PRIMARY KEY, " + ;
                "person_id INT NOT NULL, " + ;
                "food_id INT NOT NULL, " + ;
                "eat_date DATE NOT NULL, " + ;
                "eat_time TIME NOT NULL, " + ;
                "grams DOUBLE NOT NULL DEFAULT 0, " + ;
                "notes VARCHAR(255), " + ;
                "FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE, " + ;
                "FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE, " + ;
                "INDEX (person_id), INDEX (food_id), INDEX (eat_date)" + ;
                ");"
        ENDCASE

        ? "Migrando: " + cMigration
        RunSQL(cSQL, nConn)
        RegisterMigration(cMigration, nConn)
    ELSE
        ? "Migracion ya aplicada: " + cMigration
    ENDIF
NEXT

RETURN

ENDFUNC

FUNCTION MigrationExists(tcName, tnConn)
    LOCAL cSQL, nRes
    cSQL = "SELECT * FROM migrations WHERE migration_name = '" + tcName + "'"
    nRes = SQLEXEC(tnConn, cSQL, "curMig")
    IF nRes > 0 AND RECCOUNT("curMig") > 0
        USE IN curMig
        RETURN .T.
    ENDIF
    RETURN .F.
ENDFUNC

FUNCTION RegisterMigration(tcName, tnConn)
    LOCAL cSQL
    cSQL = "INSERT INTO migrations (migration_name) VALUES ('" + tcName + "')"
    RunSQL(cSQL, tnConn)
ENDFUNC