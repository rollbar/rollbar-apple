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
                     @"CREATE TABLE IF NOT EXISTS destinations (id INTEGER, endpoint TEXT, access_token TEXT)"];
    [self executeSql:sql];
}

- (void)ensurePayloadsTable {
    
    NSString *sql = [NSString stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS payloads (id INTEGER, destination_id INTEGER, payload_json TEXT, timestamp TEXT)"];
    [self executeSql:sql];
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
    int result = sqlite3_exec(self->_db, [sql UTF8String], NULL, NULL, &sqliteErrorMessage);
    if (result != SQLITE_OK) {
        
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
    int result = sqlite3_exec(self->_db, [sql UTF8String], checkIfTableExistsCallback, answerFlag, &sqliteErrorMessage);
    if (result != SQLITE_OK) {
        
        RollbarSdkLog(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
    
    BOOL exists = *answerFlag;
    return exists;
}

@end
