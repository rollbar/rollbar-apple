#ifndef RollbarScrubbingOptions_h
#define RollbarScrubbingOptions_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Scrubbing setting of a configuration
@interface RollbarScrubbingOptions : RollbarDTO

#pragma mark - properties

/// Enables scrubbing
@property (nonatomic) BOOL enabled;

/// Fields to scrub from the payload
@property (nonnull, nonatomic, strong) NSArray<NSString *> *scrubFields;

/// Adds a scrubbing field to use
/// @param field a scrubbing field
- (void)addScrubField:(NSString *)field;

/// Removes a scrubbing field from usage
/// @param field a scrubbing field
- (void)removeScrubField:(NSString *)field;

/// Fields to not scrub from the payload even if they mention among scrubFields
@property (nonnull, nonatomic, strong) NSArray<NSString *> *safeListFields;

/// Adds a scrubbing field to the safe list
/// @param field a scrubbing field
- (void)addScrubSafeListField:(NSString *)field;

/// Removes a scrubbing field from the safe list
/// @param field a scrubbing field
- (void)removeScrubSafeListField:(NSString *)field;

#pragma mark - initializers

/// Initializer
/// @param enabled scrubbing enabling flag
/// @param scrubFields scrubbing fields
/// @param safeListFields safe list of fields (to never scrub)
- (instancetype)initWithEnabled:(BOOL)enabled
                    scrubFields:(NSArray<NSString *> *)scrubFields
                 safeListFields:(NSArray<NSString *> *)safeListFields;

/// Initializer
/// @param scrubFields scrubbing fields
/// @param safeListFields safe list of fields (to never scrub)
- (instancetype)initWithScrubFields:(NSArray<NSString *> *)scrubFields
                     safeListFields:(NSArray<NSString *> *)safeListFields;

/// Initializer
/// @param scrubFields scrubbing fields
- (instancetype)initWithScrubFields:(NSArray<NSString *> *)scrubFields;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarScrubbingOptions_h
