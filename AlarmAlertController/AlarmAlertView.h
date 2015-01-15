
#import <UIKit/UIKit.h>

@class AlarmAlertTheme, AlarmAlertButton, AlarmAlertButtonItem;

typedef NS_ENUM(NSInteger, AlertButtonStyle) {
    AlertButtonStyleDefault = 0,
    AlertButtonCancel,
    AlertButtonDestructive
};

typedef NS_ENUM(NSUInteger, AlarmAlertStyle) {
    AAActionSheet = 0, // Displays from the bottom.
    AACentered, // Displays in the center of the screen.
    AAFullscreen // Displays a fullscreen viewcontroller.
};

@interface AlarmAlertView : NSObject

@property (nonatomic, strong) AlarmAlertTheme *theme;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message;
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(AlarmAlertStyle)style;

- (void)addActionWithTitle:(NSString *)title;
- (void)addActionWithTitle:(NSString *)title handler:(void (^)(AlarmAlertButtonItem *item))handler;
- (void)addActionWithTitle:(NSString *)title style:(AlertButtonStyle)style handler:(void (^)(AlarmAlertButtonItem *item))handler;

- (void)show;
- (void)dismiss;

@end

typedef void(^SelectionHandler) (AlarmAlertButtonItem *item);

@interface AlarmAlertButtonItem : NSObject

@property (nonatomic, strong) NSAttributedString *buttonTitle;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) SelectionHandler selectionHandler;
@property (nonatomic) AlertButtonStyle buttonStyle;

- (instancetype)initWithTitle:(NSString *)title andButtonTitleColor:(UIColor *)color andStyle:(AlertButtonStyle)style;
- (void)changeToSolidStyle;

@end

@interface AlarmAlertTheme : NSObject

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *buttonTitleColor;
@property (nonatomic, strong) UIColor *backgroundColor; //content view (Default white)
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIEdgeInsets popupContentInsets; //Inset of labels, images,buttons
@property (nonatomic, assign) AlarmAlertStyle popupStyle; //center,action sheet,full screen
@property (nonatomic, assign) CGFloat contentVerticalPadding; // Spacing between each vertical element

- (instancetype)initWithDefaultTheme;

@end
