#import "RollbarPayloadRepository.h"

#import "RollbarNotifierFiles.h"

@import RollbarCommon;

#import "sqlite3.h"

static int checkIfTableExistsCallback(void *info, int columns, char **data, char **column)
{
    RollbarSdkLog(@"Columns: %d", columns);
    for (int i = 0; i < columns; i++) {
        RollbarSdkLog(@"Column: %s", column[i]);
        RollbarSdkLog(@"Data: %s", data[i]);
    }
    
    BOOL *answerFlag = (BOOL *)info;
    if (answerFlag) {

        *answerFlag = (columns > 0) ? YES : NO;
    }
    
    return SQLITE_OK;
}

static int insertDestinationCallback(void *info, int columns, char **data, char **column)
{
    RollbarSdkLog(@"Columns: %d", columns);
    for (int i = 0; i < columns; i++) {
        RollbarSdkLog(@"Column: %s", column[i]);
        RollbarSdkLog(@"Data: %s", data[i]);
    }
    
    return SQLITE_OK;
}

@implementation RollbarPayloadRepository {
    
    @private
    NSString *_storePath;
    sqlite3 *_db;
    char *_sqliteErrorMessage;
    
    BOOL _tableExists_Destinations;
    BOOL _tableExists_Payloads;
    BOOL _tableExists_Unknown;
}

+ (void)initialize {
    
}

#pragma mark - instance initializers

- (instancetype)initWithStore:(nonnull NSString *)storePath {
    
    if (self = [super init]) {
        
        self->_storePath = storePath;
        [self initDB];
        return self;
    }
    
    return nil;
}

- (instancetype)init {

    // create working cache directory:
    [RollbarCachesDirectory ensureCachesDirectoryExists];
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    NSString *storePath = [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payloadsStore]];

    if (self = [self initWithStore:storePath]) {
        
        return self;
    }
    
    return nil;
}

#pragma mark - repository methods

- (void)addPayload:(nonnull RollbarPayload *)payload {
    
}

- (void)clear {
    
}

#pragma mark - internal methods

- (void)initDB {
    
    [self openDB];
    [self ensureDestinationsTable];
    [self ensurePayloadsTable];
}

- (void)openDB {
    
    int result = sqlite3_open([self->_storePath UTF8String], &self->_db);
    if (result != SQLITE_OK) {
        
        RollbarSdkLog(@"sqlite3_open: %s", sqlite3_errmsg(self->_db));
    }
}

- (void)ensureDestinationsTable {
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS destinations (id INTEGER NOT NULL PRIMARY KEY, endpoint TEXT NOT NULL, access_token TEXT NOT NULL, CONSTRAINT unique_destination UNIQUE(endpoint, access_token))"
    ];
    [self executeSql:sql];
}

- (void)ensurePayloadsTable {

    
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS payloads (id INTEGER NOT NULL PRIMARY KEY, config_json TEXT NOT NULL, payload_json TEXT NOT NULL, created_at INTEGER NOT NULL, destination_key INTEGER NOT NULL, FOREIGN KEY(destination_key) REFERENCES destinations(id) ON UPDATE CASCADE ON DELETE CASCADE)"
    ];
    [self executeSql:sql];
}

- (void)insertDestinationWithEndpoint:(nonnull NSString *)endpoint
                        andAccesToken:(nonnull NSString *)accessToken {
    
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO destinations (endpoint, access_token) VALUES ('%@', '%@')",
                     endpoint,
                     accessToken
    ];
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], insertDestinationCallback, NULL, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RollbarSdkLog(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
}








- (void)releaseDB {
    
    sqlite3_close(self->_db);
    self->_db = nil;
}

- (void)clearDestinationsTable {
}

- (void)clearPayloadsTable {
}

- (void)clearPayloadsOlderThan:(nonnull NSDate *)cutoffTime {
}

- (void)executeSql:(nonnull NSString *)sql {
    
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], NULL, NULL, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RollbarSdkLog(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
}

- (BOOL)checkIfTableExists_Destinations {
    
    BOOL result = [self checkIfTableExists:@"destinations"];
    return result;
}

- (BOOL)checkIfTableExists_Payloads {
    
    BOOL result = [self checkIfTableExists:@"payloads"];
    return result;
}

- (BOOL)checkIfTableExists_Unknown {
    
    BOOL result = [self checkIfTableExists:@"unknown"];
    return result;
}


- (BOOL)checkIfTableExists:(nonnull NSString *)tableName {
    
    BOOL *answerFlag = nil;
    if ([tableName isEqualToString:@"destinations"]) {
        answerFlag = &(self->_tableExists_Destinations);
    }
    else if ([tableName isEqualToString:@"payloads"]) {
        answerFlag = &(self->_tableExists_Payloads);
    }
    else if ([tableName isEqualToString:@"unknown"]) {
        answerFlag = &(self->_tableExists_Unknown);
    }
    else {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:
                     @"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'", tableName];
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], checkIfTableExistsCallback, answerFlag, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RollbarSdkLog(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
    
    BOOL exists = *answerFlag;
    return exists;
}

@end
