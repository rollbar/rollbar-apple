#import "RollbarDTO+Protected.h"
#import "NSDate+Rollbar.h"

@implementation RollbarDTO (Protected)

#pragma mark - Property overrides

- (NSString *)description {
    return [self serializeToJSONString];
}

#pragma mark - Properties

-(NSMutableDictionary *)dataDictionary {
    if (self->_dataDictionary) {
        return self->_dataDictionary;
    }
    else {
        if (!self->_data || self->_data == [NSNull null]) {
            return self->_dataDictionary;
        }
        if (!self->_dataArray && [self->_data isKindOfClass:[NSDictionary class]]) {
            self->_dataDictionary = (NSMutableDictionary *) self->_data;
        }
        return self->_dataDictionary;
    }
}

-(NSMutableArray *)dataArray {
    if (self->_dataArray) {
        return self->_dataArray;
    }
    else {
        if (!self->_data || self->_data == [NSNull null]) {
            return self->_dataArray;
        }
        if (!self->_dataDictionary && [self->_data isKindOfClass:[NSArray class]]) {
            self->_dataArray = (NSMutableArray *) self->_data;
        }
        return self->_dataArray;
    }
}

#pragma mark - Core API: transferable data getter/setter by key

- (nullable id)getDataByKey:(nonnull NSString *)key {
    id result = [self->_data objectForKey:key];
    if (nil == result) {
        return nil;
    }
    else if (result == [NSNull null]) {
        return nil;
    }
    return result;
}

- (void)setData:(nullable id)data byKey:(nonnull NSString *)key {
    if (!data) {
        // setting nil data is equivalent to removing its KV-pair (if any):
        [self->_data removeObjectForKey:key];
        return;
    }
    if ([RollbarDTO isTransferableDataValue:data]) {
        [self->_data setObject:data forKey:key];
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"An attempt to set non-transferable data to self->_data!"
                                     userInfo:nil];
    }
}

- (void)mergeDataDictionary:(nonnull NSDictionary *)data {
    if (data) {
        [self->_data addEntriesFromDictionary:data];
        
    }
}

#pragma mark - safe data getters by key

- (NSMutableDictionary *)safelyGetDictionaryByKey:(NSString *)key {

    NSMutableDictionary *result = [self getDataByKey:key];
    if (!result) {
        result = [[NSMutableDictionary alloc] initWithCapacity:5];
        [self setData:result byKey:key];
    }
    return result;
}

- (NSMutableArray *)safelyGetArrayByKey:(NSString *)key {

    NSMutableArray *result = [self getDataByKey:key];
    if (nil == result) {
        result = [[NSMutableArray alloc] initWithCapacity:5];
        [self setData:result byKey:key];
    }
    return result;
}

- (NSMutableString *)safelyGetStringByKey:(NSString *)key {

    NSMutableString *result = [self getDataByKey:key];
    if (nil == result) {
        result = [[NSMutableString alloc] initWithCapacity:10];
        [self setData:result byKey:key];
    }
    return result;
}

- (NSNumber *)safelyGetNumberByKey:(NSString *)key {
    NSNumber *result = [self getDataByKey:key];
    return result;
}

#pragma mark - data setters by key

- (void)setDictionary:(nullable NSDictionary *)data forKey:(NSString *)key {
    
    [self setData:data ? data.mutableCopy : data
            byKey:key
    ];
}

- (void)setArray:(nullable NSArray *)data forKey:(NSString *)key {
    
    [self setData:data ? data.mutableCopy : data
            byKey:key
    ];
}

- (void)setString:(nullable NSString *)data forKey:(NSString *)key {
    
    [self setData:data ? data.mutableCopy : data
            byKey:key
    ];
}

- (void)setNumber:(nullable NSNumber *)data forKey:(NSString *)key {
    
    [self setData:data byKey:key];
}

#pragma mark - Convenience API

- (RollbarDTO *)safelyGetDataTransferObjectByKey:(NSString *)key {
    
    RollbarDTO *result = [RollbarDTO alloc];
    
    NSDictionary<NSString *, id> *data = [self getDataByKey:key];
    if (data) {
        result = [result initWithDictionary:data];
    }
    else {
        result = [result init];
    }
    
    return result;
}

- (void)setDataTransferObject:(RollbarDTO *)data forKey:(NSString *)key {
    [self setData:(data->_data) byKey:key];
}

- (RollbarTriStateFlag)safelyGetTriStateFlagByKey:(NSString *)key {
    NSString *result = [self->_data objectForKey:key];
    if (result == nil) {
        return RollbarTriStateFlag_None;
    }
    else {
        return [RollbarTriStateFlagUtil TriStateFlagFromString:result];
    }
}

- (void)setTriStateFlag:(RollbarTriStateFlag)data forKey:(NSString *)key{
    if (data == RollbarTriStateFlag_None) {
        [self->_data removeObjectForKey:key];
    }
    else {
        [self setData:[RollbarTriStateFlagUtil TriStateFlagToString:data].mutableCopy byKey:key];
    }
}

- (BOOL)safelyGetBoolByKey:(NSString *)key
               withDefault:(BOOL)defaultValue {
    NSNumber *value = [self safelyGetNumberByKey:key];
    if (value) {
        return value.boolValue;
    }
    else {
        return defaultValue;
    }
}
- (void)setBool:(BOOL)data forKey:(NSString *)key {
    NSNumber *number = [NSNumber numberWithBool:data];
    [self setNumber:number forKey:key];
}

- (NSUInteger)safelyGetUIntegerByKey:(NSString *)key
                         withDefault:(NSUInteger)defaultValue{
    NSNumber *value = [self safelyGetNumberByKey:key];
    if (value) {
        return value.unsignedIntegerValue;
    }
    else {
        return defaultValue;
    }
}

- (void)setUInteger:(NSUInteger)data forKey:(NSString *)key {
    NSNumber *number = @(data);
    [self setNumber:number forKey:key];
}

- (NSInteger)safelyGetIntegerByKey:(NSString *)key
                       withDefault:(NSInteger)defaultValue {

    NSNumber *value = [self safelyGetNumberByKey:key];
    if (value) {
        return value.integerValue;
    }
    else {
        return defaultValue;
    }
}

- (void)setInteger:(NSInteger)data forKey:(NSString *)key {

    NSNumber *number = @(data);
    [self setNumber:number forKey:key];
}

- (NSTimeInterval)safelyGetTimeIntervalByKey:(NSString *)key
                                 withDefault:(NSTimeInterval)defaultValue {
    
    NSNumber *value = [self safelyGetNumberByKey:key];
    if (value) {
        return value.doubleValue;
    }
    else {
        return defaultValue;
    }
}

- (void)setTimeInterval:(NSTimeInterval)data
                 forKey:(NSString *)key {
    
    NSNumber *number = @(data);
    [self setNumber:number forKey:key];
}

- (nullable NSDate *)safelyGetDateByKey:(nonnull NSString *)key {
    
    NSString *dateString = [self safelyGetStringByKey:key];
    if (dateString) {
        
        NSDate *value = [NSDate rollbar_dateFromString:dateString];
        return value;
    }
    else {
        
        return nil;
    }
}

- (nonnull NSDate *)safelyGetDateByKey:(nonnull NSString *)key
                            withDefault:(nonnull NSDate *)defaultValue {
    
    NSString *dateString = [self safelyGetStringByKey:key];
    if (dateString) {
        
        NSDate *value = [NSDate rollbar_dateFromString:dateString];
        return value ? value : defaultValue;
    }
    else {
        
        return defaultValue;
    }
}

- (void)setDate:(nullable NSDate *)data
         forKey:(nonnull NSString *)key {
    
    if (data) {
        
        NSString *dateString = [data rollbar_toString];
        [self setString:dateString forKey:key];
    }
    else {
        
        [self setData:nil byKey:key];
    }
    
}

@end
