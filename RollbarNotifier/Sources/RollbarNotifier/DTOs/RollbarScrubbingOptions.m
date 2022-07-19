#import "RollbarScrubbingOptions.h"

#pragma mark - constants

static BOOL const DEFAULT_ENABLED_FLAG = YES;

#pragma mark - data field keys

static NSString * const DFK_ENABLED = @"enabled";
static NSString * const DFK_SCRUB_FIELDS = @"scrubFields";       // scrab these
static NSString * const DFK_SAFELIST_FIELDS = @"safeListFields"; // do not scrub these

#pragma mark - class implementation

@implementation RollbarScrubbingOptions

#pragma mark - initializers

- (instancetype)initWithEnabled:(BOOL)enabled
                    scrubFields:(NSArray<NSString *> *)scrubFields
                 safeListFields:(NSArray<NSString *> *)safeListFields {

    self = [super initWithDictionary:@{
        DFK_ENABLED:[NSNumber numberWithBool:enabled],
        DFK_SCRUB_FIELDS:scrubFields,
        DFK_SAFELIST_FIELDS:safeListFields
    }];
    return self;

}

- (instancetype)initWithScrubFields:(NSArray<NSString *> *)scrubFields
                    safeListFields:(NSArray<NSString *> *)safeListFields {

    return [self initWithEnabled:DEFAULT_ENABLED_FLAG
                     scrubFields:[scrubFields mutableCopy]
                  safeListFields:[safeListFields mutableCopy]
            ];
}

- (instancetype)initWithScrubFields:(NSArray<NSString *> *)scrubFields {
    
    return [self initWithScrubFields:scrubFields safeListFields:@[]];
}

- (instancetype)init {

    // init with the default set of scrub-fields:
    return [self initWithScrubFields:@[
        @"Password",
        @"passwd",
        @"confirm_password",
        @"password_confirmation",
        @"accessToken",
        @"auth_token",
        @"authentication",
        @"secret",
    ]];
}

#pragma mark - property accessors

- (BOOL)enabled {
    NSNumber *result = [self safelyGetNumberByKey:DFK_ENABLED];
    return [result boolValue];
}

- (NSArray<NSString *> *)scrubFields {
    NSArray *result = [self safelyGetArrayByKey:DFK_SCRUB_FIELDS];
    return result;
}

- (NSArray<NSString *> *)safeListFields {
    NSArray<NSString *> *result = [self safelyGetArrayByKey:DFK_SAFELIST_FIELDS];
    return result;
}

@end


@implementation RollbarMutableScrubbingOptions

#pragma mark - initializers

-(instancetype)init {
    
    if (self = [super init]) {
        return self;
    }
    return nil;
}

#pragma mark - property accessors

@dynamic enabled;

- (void)setEnabled:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_ENABLED];
}

- (NSMutableArray<NSString *> *)scrubFields {
    NSMutableArray<NSString *> *result = [self safelyGetArrayByKey:DFK_SCRUB_FIELDS];
    return result;
}

- (void)setScrubFields:(NSArray<NSString *> *)scrubFields {
    [self setArray:[scrubFields mutableCopy] forKey:DFK_SCRUB_FIELDS];
}

- (NSMutableArray<NSString *> *)safeListFields {
    NSMutableArray<NSString *> *result = [self safelyGetArrayByKey:DFK_SAFELIST_FIELDS];
    return result;
}

- (void)setSafeListFields:(NSArray<NSString *> *)whitelistFields {
    [self setArray:[whitelistFields mutableCopy] forKey:DFK_SAFELIST_FIELDS];
}

#pragma mark - methods

- (void)addScrubField:(NSString *)field {
//    self.scrubFields =
//    [self.scrubFields arrayByAddingObject:field];
    [self.scrubFields addObject:field];
}

- (void)removeScrubField:(NSString *)field {
//    NSMutableArray *mutableCopy = self.scrubFields.mutableCopy;
//    [mutableCopy removeObject:field];
//    self.scrubFields = mutableCopy.copy;
    [self.scrubFields removeObject:field];
}

- (void)addScrubSafeListField:(NSString *)field {
//    self.safeListFields = [self.safeListFields arrayByAddingObject:field];
    [self.safeListFields addObject:field];
}

- (void)removeScrubSafeListField:(NSString *)field {
//    NSMutableArray *mutableCopy = self.safeListFields.mutableCopy;
//    [mutableCopy removeObject:field];
//    self.safeListFields = mutableCopy.copy;
    [self.safeListFields removeObject:field];
}


@end
