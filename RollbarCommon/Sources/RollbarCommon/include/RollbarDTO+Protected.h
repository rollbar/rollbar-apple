#ifndef RollbarDTO_Protected_h
#define RollbarDTO_Protected_h

#import "RollbarDTO.h"
#import "RollbarTriStateFlag.h"

NS_ASSUME_NONNULL_BEGIN

/// Dfines the protected DTO interface
/// intended for use internally by any DTO derivative/implementation.
@interface RollbarDTO (Protected)

#pragma mark - Properties

/// The encapsulated data as a dictionary
@property (nonatomic, readonly, nullable) NSMutableDictionary *dataDictionary;
/// The encapsulated adta as an array
@property (nonatomic, readonly, nullable) NSMutableArray *dataArray;

#pragma mark - Core API: transferable data getter/setter by key

/// Gets a transferrable data object (or nil) by its key.
/// @param key the data key
- (nullable id)getDataByKey:(nonnull NSString *)key;

/// Sets transferrable data by its key
/// @param data the transferable data (or nil)
/// @param key the data key
- (void)setData:(nullable id)data byKey:(nonnull NSString *)key;

#pragma mark - Core API: DTO data merging

/// Merges given data dictionary into the underlaying data dictionary
/// @param data data dictionary to append
- (void)mergeDataDictionary:(nonnull NSDictionary *)data;

#pragma mark - Core API: safe data getters by key

- (nonnull NSMutableDictionary *)safelyGetDictionaryByKey:(NSString *)key;
- (nonnull NSMutableArray *)safelyGetArrayByKey:(NSString *)key;
- (nonnull NSMutableString *)safelyGetStringByKey:(NSString *)key;
- (nullable NSNumber *)safelyGetNumberByKey:(NSString *)key;
- (nullable NSDate *)safelyGetDateByKey:(nonnull NSString *)key;

#pragma mark - Core API: data setters by key

- (void)setDictionary:(nullable NSDictionary *)data forKey:(NSString *)key;
- (void)setArray:(nullable NSArray *)data forKey:(NSString *)key;
- (void)setString:(nullable NSString *)data forKey:(NSString *)key;
- (void)setNumber:(nullable NSNumber *)data forKey:(NSString *)key;

#pragma mark - Convenience API

- (RollbarDTO *)safelyGetDataTransferObjectByKey:(NSString *)key;
- (void)setDataTransferObject:(RollbarDTO *)data
                       forKey:(NSString *)key;

- (RollbarTriStateFlag)safelyGetTriStateFlagByKey:(NSString *)key;
- (void)setTriStateFlag:(RollbarTriStateFlag)data
                 forKey:(NSString *)key;

- (BOOL)safelyGetBoolByKey:(NSString *)key
               withDefault:(BOOL)defaultValue;
- (void)setBool:(BOOL)data
         forKey:(NSString *)key;

- (NSUInteger)safelyGetUIntegerByKey:(NSString *)key
                         withDefault:(NSUInteger)defaultValue;
- (void)setUInteger:(NSUInteger)data
             forKey:(NSString *)key;

- (NSInteger)safelyGetIntegerByKey:(NSString *)key
                       withDefault:(NSInteger)defaultValue;
- (void)setInteger:(NSInteger)data
            forKey:(NSString *)key;

- (NSTimeInterval)safelyGetTimeIntervalByKey:(NSString *)key
                                 withDefault:(NSTimeInterval)defaultValue;
- (void)setTimeInterval:(NSTimeInterval)data
                 forKey:(NSString *)key;

- (nonnull NSDate *)safelyGetDateByKey:(nonnull NSString *)key
                            withDefault:(nonnull NSDate *)defaultValue;
- (void)setDate:(nullable NSDate *)data
         forKey:(nonnull NSString *)key;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarDTO_Protected_h
