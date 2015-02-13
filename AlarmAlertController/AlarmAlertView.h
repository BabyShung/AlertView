
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 667.0)

@class AlarmAlertTheme, AlarmAlertButton, AlarmAlertButtonItem;

typedef NS_ENUM(NSInteger, AlertButtonStyle) {
    AlertButtonStyleDefault = 0,
    AlertButtonCancel,
    AlertButtonDestructive
};

typedef NS_ENUM(NSUInteger, AlarmAlertStyle) {
    AAActionSheet = 0, // action sheet, from the bottom
    AACentered // transparent, and view centered
};

@interface AlarmAlertView : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly) NSArray *buttonItems;
@property (nonatomic, copy) AlarmAlertTheme *theme;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(AlarmAlertStyle)style;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                subViewOfView:(UIView *)superView;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   customView:(UIView *)customView
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView;

//adding buttons (similar to UIAlertController)
- (void)addActionWithTitle:(NSString *)title;
- (void)addActionWithTitle:(NSString *)title handler:(void (^)(AlarmAlertButtonItem *item, AlarmAlertView *alertView))handler;
- (void)addActionWithTitle:(NSString *)title style:(AlertButtonStyle)style handler:(void (^)(AlarmAlertButtonItem *item, AlarmAlertView *alertView))handler;
- (void)addActionWithTitle:(NSString *)title titleColor:(UIColor *)color style:(AlertButtonStyle)style handler:(void (^)(AlarmAlertButtonItem *item, AlarmAlertView *alertView))handler;

- (void)show;
- (void)dismiss;

@end

typedef void(^SelectionHandler) (AlarmAlertButtonItem *item, AlarmAlertView *alertView);

@interface AlarmAlertButtonItem : NSObject

@property (nonatomic, copy) NSAttributedString *buttonTitle;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) SelectionHandler selectionHandler;
@property (nonatomic) AlertButtonStyle buttonStyle;

- (instancetype)initWithTitle:(NSString *)title andButtonTitleColor:(UIColor *)color andStyle:(AlertButtonStyle)style andAlignment:(NSTextAlignment)alignment;
- (void)changeToActionSheetButtonStyle:(UIColor *)themeColor;

@end

@interface AlarmAlertTheme : NSObject

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *backgroundColor; //content view (Default white)
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat titleFontSize;
@property (nonatomic, assign) CGFloat messageFontSize;
@property (nonatomic, assign) BOOL ifTwoBtnsShouldInOneLine;//if two buttons, in one row or not
@property (nonatomic, assign) UIEdgeInsets contentViewInsets; //Inset of labels, images,buttons
@property (nonatomic, assign) AlarmAlertStyle popupStyle; //center,action sheet,full screen
@property (nonatomic, assign) CGFloat contentVerticalPadding; // Spacing between each vertical element

- (instancetype)initWithDefaultTheme;

@end
