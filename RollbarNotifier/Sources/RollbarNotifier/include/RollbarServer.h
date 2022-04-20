#ifndef RollbarServer_h
#define RollbarServer_h

#import "RollbarServerConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// Server element of a payload DTO.
/// @note:
/// Can contain any additional arbitrary keys.
@interface RollbarServer : RollbarServerConfig

#pragma mark - Properties

/// Optional: cpu
/// @note:
/// A string up to 255 characters
@property (nonatomic, copy, nullable) NSString *cpu;

#pragma mark - Initializers

/// Initializer
/// @param cpu server CPU
/// @param host server host
/// @param root server code root
/// @param branch code branch
/// @param codeVersion code version
- (instancetype)initWithCpu:(nullable NSString *)cpu
                       host:(nullable NSString *)host
                       root:(nullable NSString *)root
                     branch:(nullable NSString *)branch
                codeVersion:(nullable NSString *)codeVersion;

/// Initializer
/// @param cpu server CPU
/// @param serverConfig server config element of a RollbarConfig
- (instancetype)initWithCpu:(nullable NSString *)cpu
               serverConfig:(nullable RollbarServerConfig *)serverConfig;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarServer_h
