#ifndef RollbarConfigUtil_h
#define RollbarConfigUtil_h

@import Foundation;

@class RollbarConfig;

NS_ASSUME_NONNULL_BEGIN

/// Configuration utility
@interface RollbarConfigUtil : NSObject

/// Returns default configuration file name
+ (nonnull NSString *)getDefaultConfigFileName;

/// Returns default configuration files directory
+ (nonnull NSString *)getDefaultConfigDirectory;

/// Returns default configuration file path
+ (nonnull NSString *)getDefaultConfigFilePath;

/// Creates configuration object
/// @param filePath configuration file path
/// @param error loading error (if any)
+ (nullable RollbarConfig *)createRollbarConfigFromFile:(nonnull NSString *)filePath
                                                  error:(NSError * _Nullable *)error;

/// Creates configuration object from the default configuration file
/// @param error error (if any)
+ (nullable RollbarConfig *)createRollbarConfigFromDefaultFile:(NSError * _Nullable *)error;

/// Saves a config object into a file
/// @param rollbarConfig a config object
/// @param filePath file path to save to
/// @param error erorr (if any)
+ (BOOL)saveRollbarConfig:(RollbarConfig *)rollbarConfig
                   toFile:(nonnull NSString *)filePath
                    error:(NSError * _Nullable *)error;

/// Saves a config object into the default configuration  file
/// @param rollbarConfig a config object
/// @param error erorr (if any)
+ (BOOL)saveRollbarConfig:(RollbarConfig *)rollbarConfig
                    error:(NSError * _Nullable *)error;

/// Deletes a file
/// @param filePath file path
/// @param error error (if any)
+ (BOOL)deleteFile:(nonnull NSString *)filePath
             error:(NSError * _Nullable *)error;

/// Deletes the default configuration file
/// @param error error (if any)
+ (BOOL)deleteDefaultRollbarConfigFile:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarConfigUtil_h
