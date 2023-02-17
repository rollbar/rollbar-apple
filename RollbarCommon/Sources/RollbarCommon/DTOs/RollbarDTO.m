#import "RollbarDTO.h"
#import "../RollbarInternalLogging.h"
#import "NSJSONSerialization+Rollbar.h"
#import "NSObject+Rollbar.h"

@import ObjectiveC.runtime;

@implementation RollbarDTO {

}

#pragma mark - JSON processing routines

+ (BOOL)isTransferableObject:(nullable id)obj {
    
    if (obj) {
        
        BOOL result = [NSJSONSerialization isValidJSONObject:obj];
        return result;
    }
    else {
        
        return NO;
    }
}

+ (BOOL)isTransferableDataValue:(id)obj {
    
    if (obj == [NSNull null]
        || [obj isKindOfClass:[NSString class]]
        || [obj isKindOfClass:[NSNumber class]]
        || [obj isKindOfClass:[NSArray class]]
        || [obj isKindOfClass:[NSDictionary class]]
        || [obj isKindOfClass:[NSNull class]]
        || [self isTransferableObject:obj]
        ) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (nullable NSData *)dataWithJSONObject:(id)obj
                                options:(NSJSONWritingOptions)opt
                                  error:(NSError **)error
                                   safe:(BOOL)safe {
#ifdef DEBUG
    opt |= NSJSONWritingPrettyPrinted;
    if (@available(iOS 11, macOS 10.13, *)) {
        opt |= NSJSONWritingSortedKeys;
    }else {
        // Fallback on earlier versions
    }
#endif
    if (safe) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArr = [NSMutableArray array];
            for (id item in obj) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [newArr addObject:[[self class] safeDataFromJSONObject:item]];
                } else {
                    [newArr addObject:item];
                }
            }
            return [NSJSONSerialization dataWithJSONObject:newArr
                                                   options:opt
                                                     error:error];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            return [NSJSONSerialization dataWithJSONObject:[[self class] safeDataFromJSONObject:obj]
                                                   options:opt
                                                     error:error];
        }
    }
    return [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
}

+ (NSMutableDictionary *)safeDataFromJSONObject:(id)obj {
    
    return [NSJSONSerialization rollbar_safeDataFromJSONObject:obj];
    
//    NSMutableDictionary *safeData = [NSMutableDictionary new];
//    [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        
//        if ([obj isKindOfClass:[NSDictionary class]]) {
//            [safeData setObject:[[self class] safeDataFromJSONObject:obj] forKey:key];
//        } else if ([obj isKindOfClass:[NSArray class]]) {
//            [safeData setObject:((NSArray *)obj).mutableCopy forKey:key];
//        } else if ([obj isKindOfClass:[NSNumber class]]) {
//            [safeData setObject:obj forKey:key];
//        } else if ([obj isKindOfClass:[NSString class]]) {
//            [safeData setObject:obj forKey:key];
//        } else if ([obj isKindOfClass:[NSDate class]]) {
//            [safeData setObject:[obj description] forKey:key];
//        } else if ([obj isKindOfClass:[NSURL class]]) {
//            NSString *url = [obj absoluteString];
//            if (url) {
//                [safeData setObject:[obj absoluteString] forKey:key];
//            }
//            else if([obj description]) {
//                [safeData setObject:[obj description] forKey:key];
//            }
//        } else if ([obj isKindOfClass:[NSError class]]) {
//            [safeData setObject:[[self class] safeDataFromJSONObject:[obj userInfo]] forKey:key];
//        } else if ([obj isKindOfClass:[NSHTTPURLResponse class]]) {
//            [safeData setObject:[obj allHeaderFields] forKey:key];
//        } else if ([obj isKindOfClass:[NSSet class]]) {
//            [safeData setObject:[[obj allObjects] componentsJoinedByString:@","] forKey:key];
//        } else if ([obj isKindOfClass:[NSData class]]) {
//            NSError* error = nil;
//            NSMutableDictionary* json =
//                [NSJSONSerialization JSONObjectWithData:obj
//                                                options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)
//                                                  error:&error];
//
//            if (error == nil) {
//                [safeData setObject:[[self class] safeDataFromJSONObject:json] forKey:key];
//            } else {
//                RBErr(@"Error serializing NSData: %@", [error localizedDescription]);
//            }
//        } else if ([NSJSONSerialization isValidJSONObject:@{key:obj}]) {
//                [safeData setObject:obj forKey:key];
//        } else {
//            RBErr(@"Error serializing class '%@' using NSJSONSerialization",
//                       NSStringFromClass([obj class]));
//        }
//    }];
//    
//    return safeData;
}

+ (unsigned long)measureJSONDataByteSize:(NSData*)jsonData {
    
    return jsonData.length;
}

#pragma mark - de/serialization methods of JSONSupport protocol

- (NSMutableDictionary *)jsonFriendlyData {
    
    return self->_data;
}

- (nullable NSData *)serializeToJSONData {

    BOOL hasValidData = [NSJSONSerialization isValidJSONObject:self->_data];
    if (NO == hasValidData) {
        
        RBCErr(@"JSON-invalid internal data.");
    }
    
    NSJSONWritingOptions opt = 0;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self->_data options:opt error:&error];
    if ((nil == jsonData) && (nil != error)) {
        
        RBCErr(@"Error serializing NSData: %@", [error localizedDescription]);
    }
    return jsonData;
}

- (nullable NSString *)serializeToJSONString {
    
    BOOL hasValidData = [NSJSONSerialization isValidJSONObject:self->_data];
    if (NO == hasValidData) {
        
        RBCErr(@"JSON-invalid internal data.");
    }
    
    NSJSONWritingOptions opt = 0;
#ifdef DEBUG
    opt |= NSJSONWritingPrettyPrinted;
    if (@available(iOS 11, macOS 10.13, *)) {
        
        opt |= NSJSONWritingSortedKeys;
    } else {
        // Fallback on earlier versions
    }
#endif
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self->_data options:opt error:&error];
    if ((nil == jsonData) && (nil != error)) {
        
        RBCErr(@"Error serializing NSData: %@", [error localizedDescription]);
        return nil;
    }

    NSString *result = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return result;
}

- (BOOL)deserializeFromJSONData:(NSData *)jsonData {
    
    self->_data = nil;
    self->_dataArray = nil;
    self->_dataDictionary = nil;
    
    if (!jsonData) {
        return NO;
    }
    
    NSError *error = nil;
    self->_data =
    [NSJSONSerialization JSONObjectWithData:jsonData
                                    options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)
                                      error:&error];
    if (error) {
        RBCErr(@"Error deserializing JSON NSData as a DTO: %@", [error localizedDescription]);
        return NO;
    }
    if (self->_data) {
        
        if ([self->_data isKindOfClass:[NSDictionary class]]) {
            self->_dataDictionary = (NSMutableDictionary *) self->_data;
            return YES;
        }
        else if ([self->_data isKindOfClass:[NSArray class]]) {
            self->_dataArray = (NSMutableArray *) self->_data;
            return YES;
        }
        return NO;
    }
    return NO;
}

- (BOOL)deserializeFromJSONString:(NSString *)jsonString {
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        RBCErr(@"Error converting an NSString instance to NSData: %@", jsonString);
        return NO;
    }
    return [self deserializeFromJSONData:jsonData];
}

- (NSArray *)getDefinedProperties {
    
    NSMutableArray *result = [NSMutableArray array];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    if (!properties) {
        return result;
    }
    
    for(unsigned int i = 0; i < outCount; ++i) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            if (propertyName) {
                [result addObject:propertyName];
            }
        }
    }
    
    free(properties);
    
    //[result addObjectsFromArray:_customData.allKeys];
    
    return result;
}

- (BOOL)hasSameDefinedPropertiesAs:(RollbarDTO *)otherDTO {
    
    return [[self getDefinedProperties] isEqualToArray:[otherDTO getDefinedProperties]];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[RollbarDTO class]]) {
        return NO;
    }
//    if ([self class] != [object class]) {
//        return NO;
//    }
    
    RollbarDTO *otherDTO = object;
    if (self->_data == otherDTO->_data) {
        return YES;
    }
    if(![self hasSameDefinedPropertiesAs:otherDTO]) {
        return NO;
    }
    if (!self->_data && !otherDTO->_data) {
        return YES;
    }
    if (self->_dataDictionary
        && otherDTO->_dataDictionary
        && self->_dataDictionary.count != otherDTO->_dataDictionary.count) {
        
        return NO;
    }
    if (self->_dataArray
        && otherDTO->_dataArray
        && self->_dataArray.count != otherDTO->_dataArray.count) {
        
        return NO;
    }
//    id thisKeys = self->_data.allKeys;
//    id otherKeys = otherDTO->_data.allKeys;
//    if(![thisKeys isEqualToArray:otherKeys]) {
//        return NO;
//    }
    for (NSString *key in self->_data) {
        id value = self->_data[key];
        if (value != (id)[NSNull null]
            && otherDTO->_data[key] == (id)[NSNull null]) {
            return NO;
        }
        if (![value isEqual:otherDTO->_data[key]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Properties

-(BOOL)isEmpty {
    //TODO: implement
    // iterate through the deep underlying data structure and see if all the
    // non-collection-like data elements (i.e NSString and NSNumber) are
    // either empty/nil or [NSNull null]...
    
    // For now:
    return NO;
}

#pragma mark - Initializers

- (instancetype)initWithJSONString: (NSString *)jsonString {
    self = [self init];
    if (self) {
        [self deserializeFromJSONString:jsonString];
    }
    return self;
}

- (instancetype)initWithJSONData: (NSData *)data {
    self = [self init];
    if (self) {
        [self deserializeFromJSONData:data];
    }
    return self;
}

- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data;  {
    
    self = [super init];
    if (!self) {
        return self;
    }
    
    self->_data = nil;
    self->_dataArray = nil;
    self->_dataDictionary = nil;
    
    if (nil == data) {
        
        data = [NSMutableDictionary<NSString *, id> dictionary];
    }
    
    if (![RollbarDTO isTransferableObject:data]) {
        RBCErr(@"JSON-invalid internal data.");
        return self;
    }
    
    if ([data isKindOfClass:[NSMutableDictionary<NSString *, id> class]]) {
        
        self->_data = (NSMutableDictionary<NSString *, id> *) data;
    }
//    else {
//
//        self->_data = data.mutableCopy;
//    }
    
    if (!self->_data) {
        self->_data = data.mutableCopy;
    }
    
    self->_dataArray = nil;
    self->_dataDictionary = (NSMutableDictionary<NSString *, id> *) self->_data;
    for (NSString *key in self->_dataDictionary.allKeys) {
        
        if (self->_dataDictionary[key] == (id)[NSNull null]) {
            
            [self->_dataDictionary removeObjectForKey:key];
        }
    }
    
    return self;
}

- (instancetype)initWithArray:(NSArray *)data {
    
    self = [super init];
    if (!self) {
        return self;
    }
            
    self->_data = nil;
    self->_dataArray = nil;
    self->_dataDictionary = nil;

    if (!data) {
        //return self;
        data = [NSMutableArray arrayWithCapacity:5];
    }
    
    if (![RollbarDTO isTransferableObject:data]) {
        return self;
    }

    if ([data isKindOfClass:[NSMutableArray class]]) {
        self->_data = (NSMutableArray *) data;
    }

    if (!self->_data) {
        self->_data = data.mutableCopy;
    }

    self->_dataDictionary = nil;
    self->_dataArray = (NSMutableArray *) self->_data;
    for (id item in self->_dataArray) {
        if (item == [NSNull null]) {
            [self->_dataArray removeObject:item];
        }
    }

    return self;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self->_data = nil;
        self->_dataArray = nil;
        self->_dataDictionary = nil;
    }
    return self;
}

//-(instancetype)init {
//
//    if (self = [self initWithDictionary:@{}]) {
//        return self;
//    }
//    return nil;
//}


#pragma mark - NSCopying protocol

-(id) copyWithZone: (NSZone *) zone {
    
    NSString *thisClassName = [self rollbar_objectClassName];

    if (YES == [thisClassName hasPrefix:@"RollbarMutable"]) {
        NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
        NSString *immutableClassName = [thisClassName stringByReplacingOccurrencesOfString:@"RollbarMutable"
                                                                                withString:@"Rollbar"];
        Class immutableClass = [classBundle classNamed:immutableClassName];
        if (immutableClass) {
            RollbarDTO *clone = [[immutableClass allocWithZone:zone] initWithJSONString:[self serializeToJSONString]];
            return clone;
        }
    }
    else if ((YES == [thisClassName hasPrefix:@"Rollbar"]) && (NO == [thisClassName hasPrefix:@"RollbarMutable"])) {
        NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
        NSString *mutableClassName = [thisClassName stringByReplacingOccurrencesOfString:@"Rollbar"
                                                                              withString:@"RollbarMutable"];
        Class mutableClass = [classBundle classNamed:mutableClassName];
        if (mutableClass) {
            // OPTIMIZATION:
            // Since we have a mutable alternative to ths class,
            // it means this is an instance of an immutable class.
            // Hence, there is no need to clone an immutable object.
            return self;
        }
    }
    
    RollbarDTO *clone = [[[self class] allocWithZone:zone] initWithJSONString:[self serializeToJSONString]];
    return clone;
}

#pragma mark - NSMutableCopying protocol

-(id) mutableCopyWithZone: (NSZone *) zone {
    
    NSString *thisClassName = [self rollbar_objectClassName];
    
    if ((NO == [thisClassName hasPrefix:@"RollbarMutable"]) && (YES == [thisClassName hasPrefix:@"Rollbar"])) {
        NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
        NSString *mutableClassName = [thisClassName stringByReplacingOccurrencesOfString:@"Rollbar"
                                                                              withString:@"RollbarMutable"];
        Class mutableClass = [classBundle classNamed:mutableClassName];
        if (mutableClass) {
            RollbarDTO *clone = [[mutableClass allocWithZone:zone] initWithJSONString:[self serializeToJSONString]];
            return clone;
        }
    }
    
    RollbarDTO *clone = [[[self class] allocWithZone:zone] initWithJSONString:[self serializeToJSONString]];
    return clone;
}

@end
