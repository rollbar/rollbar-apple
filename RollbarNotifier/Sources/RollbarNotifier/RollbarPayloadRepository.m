#import "RollbarPayloadRepository.h"
#import "RollbarInternalLogging.h"
#import "RollbarNotifierFiles.h"

@import RollbarCommon;

#import "sqlite3.h"

//======================================================================================================================
#pragma mark - Sqlite command execution callbacks
#pragma mark -
//======================================================================================================================

typedef int (^SqliteCallback)(void *info, int columns, char **data, char **column);

static int defaultOnSelectCallback(void *info, int columns, char **data, char **column)
{
    return SQLITE_OK;
}

static int checkIfTableExistsCallback(void *info, int columns, char **data, char **column)
{
    defaultOnSelectCallback(info, columns, data, column);
    
    BOOL *answerFlag = (BOOL *)info;
    if (answerFlag) {

        *answerFlag = (columns > 0) ? YES : NO;
    }
    
    return SQLITE_OK;
}

static int selectSingleRowCallback(void *info, int columns, char **data, char **column)
{
    defaultOnSelectCallback(info, columns, data, column);

    NSDictionary<NSString *, NSString *> *__strong*result = (NSDictionary<NSString *, NSString *> *__strong*)info;
    
    NSMutableDictionary<NSString *, NSString *> *row =
    [NSMutableDictionary<NSString *, NSString *> dictionaryWithCapacity:columns];
    
    for (int i = 0; i < columns; i++) {
        NSString *key = [NSString stringWithFormat:@"%s", column[i]];
        NSString *value = [NSString stringWithFormat:@"%s", data[i]];
        row[key] = value;
    }
    
    *result = [row copy];

    return SQLITE_OK;
}

static int selectMultipleRowsCallback(void *info, int columns, char **data, char **column)
{
    defaultOnSelectCallback(info, columns, data, column);

    NSMutableArray<NSDictionary<NSString *, NSString *> *> *__strong*result =
    (NSMutableArray<NSDictionary<NSString *, NSString *> *> *__strong*)info;
    if (!*result) {
        *result = [NSMutableArray<NSDictionary<NSString *, NSString *> *> array];
    }
    
    NSMutableDictionary<NSString *, NSString *> *row =
    [NSMutableDictionary<NSString *, NSString *> dictionaryWithCapacity:columns];
        
    for (int i = 0; i < columns; i++) {
        NSString *key = [NSString stringWithFormat:@"%s", column[i]];
        NSString *value = [NSString stringWithFormat:@"%s", data[i]];
        row[key] = value;
    }
    
    [*result addObject:[row copy]];
    
    return SQLITE_OK;
}

//======================================================================================================================
#pragma mark - Peyloads Repository
#pragma mark -
//======================================================================================================================

/// Peristent Rollbar  payloads repository
@implementation RollbarPayloadRepository {
    
    @private
    NSString *_storePath;
    sqlite3 *_db;
    char *_sqliteErrorMessage;

}

#pragma mark - factory methods

+ (instancetype)repositoryWithFlag:(BOOL)inMemory {
    
    RollbarPayloadRepository *repo = [RollbarPayloadRepository alloc];
    if (inMemory) {
        return [repo initInMemoryOnly];
    }
    else {
        return [repo init];
    }
}

+ (instancetype)repositoryWithPath:(nonnull NSString *)storePath {
    
    return [[RollbarPayloadRepository alloc] initWithStore:storePath];
}

+ (instancetype)inMemoryRepository {
    
    return [RollbarPayloadRepository repositoryWithFlag:YES];
}

+ (instancetype)persistentRepository {
    
    return [RollbarPayloadRepository repositoryWithFlag:NO];
}

+ (instancetype)persistentRepositoryWithPath:(nonnull NSString *)storePath {
    
    return [RollbarPayloadRepository repositoryWithPath:storePath];
}

#pragma mark - class initializer

+ (void)initialize {
    
}

#pragma mark - instance initializers

- (instancetype)initInMemoryOnly {
    
    if (self = [super init]) {
        
        [self initDB:YES];
        return self;
    }
    
    return nil;
}

- (instancetype)initWithStore:(nonnull NSString *)storePath {
    
    if (self = [super init]) {
        
        self->_storePath = storePath;
        [self initDB:NO];
        return self;
    }
    
    return nil;
}

- (instancetype)init {

    // create working cache directory:
    [RollbarCachesDirectory ensureCachesDirectoryExists];
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    NSString *storePath = [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payloadsStore]];
    
    return [self initWithStore:storePath];
}

#pragma mark - Destinations related methods


- (nullable NSDictionary<NSString *, NSString *> *)addDestinationWithEndpoint:(nonnull NSString *)endpoint
                                                                andAccesToken:(nonnull NSString *)accessToken {
    
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO destinations (endpoint, access_token) VALUES ('%@', '%@')",
                     endpoint,
                     accessToken
    ];
    
    if (NO == [self executeSql:sql]) {
        return nil;
    }
    
    sqlite3_int64 destinationID = sqlite3_last_insert_rowid(self->_db);

    return @ {
        @"id": [NSString stringWithFormat:@"%lli", destinationID], //[NSNumber numberWithLongLong:destinationID],
        @"endpoint": endpoint,
        @"access_token": accessToken
    };
}

- (nonnull NSString *)getIDofDestinationWithEndpoint:(nonnull NSString *)endpoint
                                       andAccesToken:(nonnull NSString *)accessToken {
    
    NSString *sql = [NSString stringWithFormat:
                         @"SELECT id FROM destinations WHERE endpoint = '%@' AND access_token = '%@'",
                     endpoint,
                     accessToken
    ];
    
    NSDictionary<NSString *, NSString *> *result = [self selectSingleRowWithSql:sql
                                                                    andCallback:selectSingleRowCallback];
    
    if (!result || (0 == result.count)) {
        result = [self addDestinationWithEndpoint:endpoint
                                    andAccesToken:accessToken];
    }
    
    NSString *destinationID = nil;
    if (result) {
        destinationID = result[@"id"];
    }
    
    if (!destinationID) {
        destinationID = @"";
    }
    
    return destinationID;
}

- (nullable NSDictionary<NSString *, NSString *> *)getDestinationWithEndpoint:(nonnull NSString *)endpoint
                                                                andAccesToken:(nonnull NSString *)accessToken {
    
    NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM destinations WHERE endpoint = '%@' AND access_token = '%@'",
                     endpoint,
                     accessToken
    ];
                                               
    NSDictionary<NSString *, NSString *> *result =
    [self selectSingleRowWithSql:sql andCallback:selectSingleRowCallback];
    
    return result;
}

- (nullable NSDictionary<NSString *, NSString *> *)getDestinationByID:(nonnull NSString *)destinationID {
    NSAssert(destinationID && destinationID.length > 0, @"destinationID cannot be nil");
    NSString *sql = [NSString stringWithFormat:
                     @"SELECT * FROM destinations WHERE id = '%@'",
                     destinationID
    ];
    
    NSDictionary<NSString *, NSString *> *result =
    [self selectSingleRowWithSql:sql andCallback:selectSingleRowCallback];
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllDestinations {
    
    NSString *sql = @"SELECT * FROM destinations";
    
    NSArray<NSDictionary<NSString *, NSString *> *> *result =
    [self selectMultipleRowsWithSql:sql andCallback:selectMultipleRowsCallback];
    
    return result;
}

- (BOOL)removeDestinationWithEndpoint:(nonnull NSString *)endpoint
                        andAccesToken:(nonnull NSString *)accessToken {
    
    NSString *sql =
    [NSString stringWithFormat: @"DELETE FROM destinations WHERE endpoint = '%@' AND access_token = '%@'",
     endpoint,
     accessToken
    ];
    
    return [self executeSql:sql];
}

- (BOOL)removeDestinationByID:(nonnull NSString *)destinationID {
    
    NSString *sql =
    [NSString stringWithFormat: @"DELETE FROM destinations WHERE id = '%@'", destinationID];
    
    return [self executeSql:sql];
}

- (BOOL)removeUnusedDestinations {
    
    NSString *sql =
    @"DELETE FROM destinations WHERE NOT EXISTS (SELECT 1 FROM payloads WHERE payloads.destination_key = destinations.id)";
    return [self executeSql:sql];
}

- (BOOL)removeAllDestinations {
    
    NSString *sql = @"DELETE FROM destinations";
    return [self executeSql:sql];
}

#pragma mark - Payloads related methods

- (nullable NSDictionary<NSString *, NSString *> *)addPayload:(nonnull NSString *)payload
                                                   withConfig:(nonnull NSString *)config
                                             andDestinationID:(nonnull NSString *)destinationID {
    
    NSNumber *timeStamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    
    NSString *escapedPayload = [payload stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *escapedConfig = [config stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString *sql = [NSString stringWithFormat:
      @"INSERT INTO payloads (config_json, payload_json, destination_key, created_at) VALUES ('%@', '%@', '%@', '%ld')",
      escapedConfig,
      escapedPayload,
      destinationID,
      [timeStamp integerValue]
    ];
    
    if (NO == [self executeSql:sql]) {
        return nil;
    }
    
    sqlite3_int64 payloadID = sqlite3_last_insert_rowid(self->_db);
    
    return @ {
        @"id": [NSString stringWithFormat:@"%lli", payloadID], //[NSNumber numberWithLongLong:destinationID],
        @"config_json": config,
        @"payload_json": payload,
        @"destination_key": destinationID
    };
}

- (nullable NSDictionary<NSString *, NSString *> *)getPayloadByID:(nonnull NSString *)payloadID {

    NSString *sql = [NSString stringWithFormat:
      @"SELECT * FROM payloads WHERE id = '%@'",
      payloadID
    ];
    
    NSDictionary<NSString *, NSString *> *result =
    [self selectSingleRowWithSql:sql andCallback:selectSingleRowCallback];
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllPayloadsWithDestinationID:(nonnull NSString *)destinationID {
    
    NSString *sql = [NSString stringWithFormat:
      @"SELECT * FROM payloads WHERE destination_key = '%@'",
      destinationID
    ];

    NSArray<NSDictionary<NSString *, NSString *> *> *result =
    [self selectMultipleRowsWithSql:sql andCallback:selectMultipleRowsCallback];
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithDestinationID:(nonnull NSString *)destinationID
                                                                                    andLimit:(NSUInteger)limit {
    
    return  [self getPayloadsWithDestinationID:destinationID andOffset:0 andLimit:limit];
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithDestinationID:(nonnull NSString *)destinationID
                                                                                andOffset:(NSUInteger)offset
                                                                                 andLimit:(NSUInteger)limit {
    
    
    NSString *sql = [NSString stringWithFormat:
                         @"SELECT * FROM payloads WHERE destination_key = '%@' LIMIT %lu OFFSET %lu",
                     destinationID,
                     limit,
                     offset
    ];
    
    NSArray<NSDictionary<NSString *, NSString *> *> *result =
    [self selectMultipleRowsWithSql:sql andCallback:selectMultipleRowsCallback];
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithLimit:(NSUInteger)limit {

    return [self getPayloadsWithOffset:0 andLimit:limit];
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithOffset:(NSUInteger)offset
                                                                          andLimit:(NSUInteger)limit {

    NSString *sql =
    [NSString stringWithFormat:@"SELECT * FROM payloads LIMIT %lu OFFSET %lu", limit, offset];
    
    NSArray<NSDictionary<NSString *, NSString *> *> *result =
    [self selectMultipleRowsWithSql:sql andCallback:selectMultipleRowsCallback];
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllPayloads {

    NSString *sql = @"SELECT * FROM payloads";
    
    NSArray<NSDictionary<NSString *, NSString *> *> *result =
    [self selectMultipleRowsWithSql:sql andCallback:selectMultipleRowsCallback];
    
    return result;
}

- (NSInteger)getPayloadCount {
    const char *sql = "SELECT COUNT(*) FROM payloads";
    sqlite3_stmt *statement;
    NSInteger count = 0;

    if (sqlite3_prepare_v2(self->_db, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
            break;
        }
    } else {
        RBErr(@"sqlite3_prepare_v2 error %s", sqlite3_errmsg(self->_db));
    }

    sqlite3_finalize(statement);
    return count;
}

- (BOOL)removePayloadByID:(nonnull NSString *)payloadID {
    
    NSString *sql =
    [NSString stringWithFormat: @"DELETE FROM payloads WHERE id = '%@'", payloadID];
    
    return [self executeSql:sql];
}

- (BOOL)removePayloadsOlderThan:(nonnull NSDate *)cutoffTime {
    
    NSTimeInterval interval = [cutoffTime timeIntervalSince1970];
    
    NSString *sql = [NSString stringWithFormat:
                     @"DELETE FROM payloads WHERE created_at <= '%li'",
                     (long int)interval
    ];
    return [self executeSql:sql];
}

- (BOOL)removeAllPayloads {

    NSString *sql = @"DELETE FROM payloads";
    return [self executeSql:sql];
}

#pragma mark - unit testing helper methods

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

- (BOOL)clearDestinations; {

    return [self removeAllDestinations];
}

- (BOOL)clearPayloads {

    return [self removeAllPayloads];
}

- (BOOL)clear {

    BOOL success = [self clearPayloads];
    if (success) {
        success = [self clearDestinations];
    }
    return success;
}

#pragma mark - internal methods

- (void)initDB:(BOOL)inMemory {
    
    if ([self openDB:inMemory]) {

        [self ensureDestinationsTable];
        [self ensurePayloadsTable];
    }
    else {
        
        RBErr(@"Can not open database: %@!!!", inMemory ? @"in memory" : self->_storePath);
    }
}

- (BOOL)openDB:(BOOL)inMemory {
    
    int sqliteDbFlags = inMemory
    ? (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_MEMORY)
    : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);
    
    int result = sqlite3_open_v2([self->_storePath UTF8String], &self->_db, sqliteDbFlags, NULL);
    if (result != SQLITE_OK) {
        
        RBErr(@"sqlite3_open: %s", sqlite3_errmsg(self->_db));
        return NO;
    }

    [self checkDbFile];

    return YES;
}

- (BOOL)ensureDestinationsTable {
    
    NSString *sql = [NSString stringWithFormat:
                         @"CREATE TABLE IF NOT EXISTS destinations (id INTEGER NOT NULL PRIMARY KEY, endpoint TEXT NOT NULL, access_token TEXT NOT NULL, CONSTRAINT unique_destination UNIQUE(endpoint, access_token))"
    ];
    return [self executeSql:sql];
}

- (BOOL)ensurePayloadsTable {
    
    
    
    NSString *sql = [NSString stringWithFormat:
                         @"CREATE TABLE IF NOT EXISTS payloads (id INTEGER NOT NULL PRIMARY KEY, config_json TEXT NOT NULL, payload_json TEXT NOT NULL, created_at INTEGER NOT NULL, destination_key INTEGER NOT NULL, FOREIGN KEY(destination_key) REFERENCES destinations(id) ON UPDATE CASCADE ON DELETE CASCADE)"
    ];
    return [self executeSql:sql];
}

- (void)releaseDB {
    
    sqlite3_close(self->_db);
    self->_db = nil;
}

- (BOOL)checkIfTableExists:(nonnull NSString *)tableName {
    
    [self checkDbFile];
    
    NSString *sql = [NSString stringWithFormat:
                     @"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'", tableName];
    char *sqliteErrorMessage;
    BOOL answerFlag = NO;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], checkIfTableExistsCallback, &answerFlag, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
    RBErr(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
    
    return answerFlag;
}

- (BOOL)executeSql:(nonnull NSString *)sql {
    
    [self checkDbFile];
    
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], NULL, NULL, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RBErr(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
        return NO;
    }
    return YES;
}

- (nullable NSDictionary<NSString *, NSString *> *)selectSingleRowWithSql:(NSString *)sql
                                                              andCallback:(int(*)(void*,int,char**,char**))callback {
    
    [self checkDbFile];

    NSDictionary<NSString *, NSString *> *result = nil;
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], callback, &result, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RBErr(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
    
    return result;
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)selectMultipleRowsWithSql:(NSString *)sql
                                                                           andCallback:(int(*)(void*,int,char**,char**))callback {
    
    [self checkDbFile];
    
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *result = nil;
    
    char *sqliteErrorMessage;
    int sqlResult = sqlite3_exec(self->_db, [sql UTF8String], callback, &result, &sqliteErrorMessage);
    if (sqlResult != SQLITE_OK) {
        
        RBErr(@"sqlite3_exec: %s during %@", sqliteErrorMessage, sql);
        sqlite3_free(sqliteErrorMessage);
    }
    
    if (result) {
        return [result copy];
    }
    else {
        return [NSArray<NSDictionary<NSString *, NSString *> *> array];
    }
}

- (void)checkDbFile {

    if (self->_storePath && ![[NSFileManager defaultManager] fileExistsAtPath:self->_storePath]) {
        RBErr(@"Persistent payloads store was not created: %@!!!", self->_storePath);
        [self openDB:NO];
        [self ensureDestinationsTable];
        [self ensurePayloadsTable];
        return;
    }
    NSAssert(self->_storePath ?
             [[NSFileManager defaultManager] fileExistsAtPath:self->_storePath]
             : YES,
             @"Persistent payloads store was not created: %@!!!", self->_storePath
             );

}

@end
