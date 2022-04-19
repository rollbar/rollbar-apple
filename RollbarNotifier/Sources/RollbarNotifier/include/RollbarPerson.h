@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// RollbarPerson DTO.
/// Models a monitored system user.
@interface RollbarPerson : RollbarDTO

#pragma mark - properties

/// Required: id.
///
/// A string up to 40 characters identifying this user in your system.
///
/// The user affected by this event. Will be indexed by ID, username, and email.
/// People are stored in Rollbar keyed by ID. If you send a multiple different usernames/emails for the
/// same ID, the last received values will overwrite earlier ones.
@property (nonatomic, copy, nonnull) NSString *ID;

/// Optional: username.
///
/// A string up to 255 characters
@property (nonatomic, copy, nullable) NSString *username;

/// Optional: email.
///
/// A string up to 255 characters
@property (nonatomic, copy, nullable) NSString *email;

#pragma mark - initializers

/// Initialiazes a RollbarPerson.
/// @param ID person ID
/// @param username person username
/// @param email person email
- (instancetype)initWithID:(nonnull NSString *)ID
                  username:(nullable NSString *)username
                     email:(nullable NSString *)email;

/// Initialiazes a RollbarPerson.
/// @param ID person ID
/// @param username person username
- (instancetype)initWithID:(nonnull NSString *)ID
                  username:(nullable NSString *)username;
/// Initialiazes a RollbarPerson.
/// @param ID person ID
/// @param email person email
- (instancetype)initWithID:(nonnull NSString *)ID
                     email:(nullable NSString *)email;

/// Initialiazes a RollbarPerson.
/// @param ID person ID
- (instancetype)initWithID:(nonnull NSString *)ID;

/// Hides perameterless initializer.
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
