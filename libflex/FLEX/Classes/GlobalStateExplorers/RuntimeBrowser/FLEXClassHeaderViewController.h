//
//  FLEXClassHeaderViewController.h
//  FLEX
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLEXClassHeaderViewController : UIViewController
- (instancetype)initWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls headerText:(NSString *)headerText title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
