//
//  FLEXClassHeaderGenerator.h
//  FLEX
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXClassHeaderGenerator : NSObject
+ (NSString *)headerForClass:(Class)cls;
+ (NSString *)headerForClassHierarchy:(Class)cls;
+ (nullable NSString *)imagePathForClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
