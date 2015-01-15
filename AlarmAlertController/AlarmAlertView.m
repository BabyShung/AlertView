
#import "AlarmAlertView.h"

#define isIPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define titleFontSize 19
#define messageFontSize 16
#define buttonFontSize 17
#define centeredContentViewSize 290
#define fontColor [UIColor colorWithRed:72.0/255 green:80.0/255 blue:81.0/255 alpha:1]

#pragma mark - AlarmAlertButton

@interface AlarmAlertButton : UIButton

@property (nonatomic, strong) AlarmAlertButtonItem *item;

@end

@implementation AlarmAlertButton

@end

#pragma mark - AlarmAlertView

@interface AlarmAlertView ()

@property (nonatomic, strong) NSAttributedString *aTitle;
@property (nonatomic, strong) NSAttributedString *aMessage;
@property (nonatomic, strong) NSMutableArray *buttonItems;

@property (nonatomic, strong) AlarmAlertView *selfReference;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIWindow *KeyWindow;

@property (nonatomic, strong) UIView *hLine;
@property (nonatomic, strong) UIView *vLine;

@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottom;

@end

@implementation AlarmAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
{
    return [self initWithTitle:title message:message preferredStyle:AACentered];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(AlarmAlertStyle)style
{
    self = [super init];
    if (self) {
        _selfReference = self;
        _aTitle = title? [self attributeStringWithTitle:title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:titleFontSize], NSForegroundColorAttributeName : fontColor}] : nil;
        _aMessage = message? [self attributeStringWithTitle:message attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:messageFontSize], NSForegroundColorAttributeName : fontColor}] : nil;
        _theme = [AlarmAlertTheme defaultTheme];
        _theme.popupStyle = style;
        _buttonItems = [NSMutableArray array];
        
        self.KeyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    return self;
}

- (void)addActionWithTitle:(NSString *)title
{
    [self addActionWithTitle:title handler:nil];
}

- (void)addActionWithTitle:(NSString *)title handler:(void (^)(AlarmAlertButtonItem *item))handler
{
    [self addActionWithTitle:title style:AlertButtonStyleDefault handler:handler];
}

- (void)addActionWithTitle:(NSString *)title style:(AlertButtonStyle)style handler:(void (^)(AlarmAlertButtonItem *item))handler
{
    NSAttributedString *buttonString = [self attributeStringWithTitle:title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:buttonFontSize], NSForegroundColorAttributeName : fontColor}];
    
    AlarmAlertButtonItem *item = [AlarmAlertButtonItem defaultButtonItemWithTitle:buttonString andStyle:style];
    item.selectionHandler = handler;
    [self.buttonItems addObject:item];
}

#pragma mark - UI & Constraints

- (void)initializeViews
{
    self.maskView = [[UIView alloc] init];
    [self.maskView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.maskView.alpha = 0.0;
    self.maskView.backgroundColor = (self.theme.popupStyle == AAFullscreen)? [UIColor whiteColor]:[UIColor colorWithWhite:0.0f alpha:0.5f];
    [self.KeyWindow addSubview:self.maskView];
    
    self.contentView = [[UIView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = self.theme.backgroundColor;
    self.contentView.layer.cornerRadius = self.theme.popupStyle == AACentered ? self.theme.cornerRadius : 0.0f;
    [self.maskView addSubview:self.contentView];
    
    if (self.aTitle) {
        UILabel *title = [self multilineLabelWithAttributedString:self.aTitle];
        [self.contentView addSubview:title];
    }
    
    if (self.aMessage) {
        UILabel *label = [self multilineLabelWithAttributedString:self.aMessage];
        [self.contentView addSubview:label];
    }
    
    self.hLine = [self getLineView];
    [self.contentView addSubview:self.hLine];
    if ([self twoButtonsOnly]) {
        self.vLine = [self getLineView];
        [self.contentView addSubview:self.vLine];
    }
    
    if (self.buttonItems.count >0) {
        for (AlarmAlertButtonItem *item in self.buttonItems){
            
            if (self.buttonItems.count > 2) {
                item.cornerRadius = 3;
                item.backgroundColor = [UIColor orangeColor];
                item.buttonHeight = 45;
            }
            
            AlarmAlertButton *button = [self buttonItem:item];
            [self.contentView addSubview:button];
        }
    }
    
    [self setupLayoutAndContraints];
}

- (void)setupLayoutAndContraints
{
    [self addSameDirectionConstraint:NSLayoutAttributeTop fromSubView:self.maskView toSuperView:self.KeyWindow withPadding:0];
    [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:self.maskView toSuperView:self.KeyWindow withPadding:0];
    [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:self.maskView toSuperView:self.KeyWindow withPadding:0];
    [self addSameDirectionConstraint:NSLayoutAttributeBottom fromSubView:self.maskView toSuperView:self.KeyWindow withPadding:0];

    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop)
     {
         if (index == 0) {//title label
             //padding to top
             [self addSameDirectionConstraint:NSLayoutAttributeTop fromSubView:view toSuperView:self.contentView withPadding:self.theme.popupContentInsets.top];
             
             //leftRight padding
             [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:self.theme.popupContentInsets.left];
             [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:-self.theme.popupContentInsets.right];
         }else {
             UIView *previousSubView = [self.contentView.subviews objectAtIndex:index - 1];
             if (previousSubView) {
                 if ([view isKindOfClass:[UIButton class]]) {//is a button, set height constraint
                     AlarmAlertButton *button = (AlarmAlertButton *)view;
                     //height
                     [self addWidthHeightContraint:NSLayoutAttributeHeight forView:view constant:button.item.buttonHeight];
                     [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                     
                     if ([self twoButtonsOnly]) {
                         //padding to top
                         [self addTopBottomConstraintFromTopView:self.hLine toButtomView:view withPadding:0];
                         //leftRight
                         if (button.item == self.buttonItems[0]) {
                             [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:0];
                             [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.vLine withPadding:-1];
                         }else{
                             [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.vLine withPadding:1];
                             [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:0];
                         }
                     }else if (self.buttonItems.count == 1){
                         //padding to top
                         [self addTopBottomConstraintFromTopView:self.hLine toButtomView:view withPadding:0];
                         //leftRight padding
                         [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:0];
                         [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:0];
                     }else if (self.buttonItems.count > 2){
                         //padding to top
                         [self addTopBottomConstraintFromTopView:previousSubView toButtomView:view withPadding:self.theme.contentVerticalPadding + 3];
                         //leftRight
                         [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:self.theme.popupContentInsets.left];
                         [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:-self.theme.popupContentInsets.right];
                     }
                 }
                 else if ([view isKindOfClass:[UILabel class]]) {
                     //padding to top
                     [self addTopBottomConstraintFromTopView:previousSubView toButtomView:view withPadding:self.theme.contentVerticalPadding];
                     //leftRight padding
                     [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:self.theme.popupContentInsets.left];
                     [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:-self.theme.popupContentInsets.right];
                 }
                 else if (view == self.hLine) {
                     //padding to top
                     [self addTopBottomConstraintFromTopView:previousSubView toButtomView:view withPadding:self.theme.contentVerticalPadding + 5];
                     //height
                     [self addWidthHeightContraint:NSLayoutAttributeHeight forView:view constant:0.5];
                     //leftRight padding
                     [self addSameDirectionConstraint:NSLayoutAttributeLeft fromSubView:view toSuperView:self.contentView withPadding:0];
                     [self addSameDirectionConstraint:NSLayoutAttributeRight fromSubView:view toSuperView:self.contentView withPadding:0];
                 }
                 else if (view == self.vLine) {
                     //padding to top
                     [self addTopBottomConstraintFromTopView:self.hLine toButtomView:view withPadding:0];
                     //centerX
                     [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
                     //width
                     [self addWidthHeightContraint:NSLayoutAttributeWidth forView:view constant:0.5];
                     //to contentView bottom
                     [self addSameDirectionConstraint:NSLayoutAttributeBottom fromSubView:view toSuperView:self.contentView withPadding:0];
                 }
             }
         }
         
         if (index == self.contentView.subviews.count - 1) {//buttom padding
             [self addSameDirectionConstraint:NSLayoutAttributeBottom fromSubView:view toSuperView:self.contentView withPadding:(self.buttonItems.count <= 2)?0:-(self.theme.popupContentInsets.bottom + 0.0f)];
         }
         
         [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
         [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
         [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
         [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
     }];
    
    //contentView w/h less than maskView
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.maskView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    if (self.theme.popupStyle == AAFullscreen) {
        self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:isIPad?0.5:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewWidth];
        self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else if (self.theme.popupStyle == AAActionSheet) {
        self.contentViewHeight = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:isIPad?0.6:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewHeight];
        self.contentViewBottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewBottom];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else {//centered style
        if (isIPad) {
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0];
        }else {
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:0 constant:centeredContentViewSize];
        }
        [self.maskView addConstraint:self.contentViewWidth];
        self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
}

#pragma mark - Presentation

- (void)show
{
    [self showViewAnimated:YES];
}

- (void)showViewAnimated:(BOOL)flag
{
    [self initializeViews];
    [self setOriginConstraints];
    [self.maskView needsUpdateConstraints];
    [self.maskView layoutIfNeeded];
    [self setPresentedConstraints];
    [self addMotionEffect:self.contentView];
    
    //dismiss keyboard
    [self.KeyWindow endEditing:YES];
    
    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 1.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)dismiss
{
    [self dismissViewAnimated:YES];
}

- (void)dismissViewAnimated:(BOOL)flag
{
    [self dismissViewAnimated:flag withButtonTitle:nil];
}

- (void)dismissViewAnimated:(BOOL)flag withButtonTitle:(NSString *)title
{
    [self setOriginConstraints];
    
    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 0.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self.maskView removeFromSuperview];
                         self.maskView = nil;
                         self.contentView = nil;
                         self.selfReference = nil;//finally remove self reference
                     }];
}

- (void)setOriginConstraints
{
    if (self.theme.popupStyle == AACentered) {
        self.contentViewCenterYConstraint.constant = 0;
        self.contentViewCenterXConstraint.constant = 0;
    }
    else if (self.theme.popupStyle == AAActionSheet) {
        self.contentViewBottom.constant = self.KeyWindow.bounds.size.height;
    }
}

- (void)setPresentedConstraints
{
    if (self.theme.popupStyle == AACentered) {
        self.contentViewCenterYConstraint.constant = 0;
        self.contentViewCenterXConstraint.constant = 0;
    }
    else if (self.theme.popupStyle == AAActionSheet) {
        self.contentViewBottom.constant = 0;
    }
}

#pragma mark - Helpers

- (BOOL)twoButtonsOnly
{
    return self.buttonItems.count == 2? YES : NO;
}

- (void)actionButtonPressed:(AlarmAlertButton *)sender
{
    if (sender.item.selectionHandler) {
        sender.item.selectionHandler(sender.item);
    }
    [self dismissViewAnimated:YES withButtonTitle:[sender attributedTitleForState:UIControlStateNormal].string];
}

- (UILabel *)multilineLabelWithAttributedString:(NSAttributedString *)attributedString
{
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setAttributedText:attributedString];
    [label setNumberOfLines:0];
    return label;
}

- (UIImageView *)centeredImageViewForImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return imageView;
}

- (AlarmAlertButton *)buttonItem:(AlarmAlertButtonItem *)item
{
    AlarmAlertButton *button = [[AlarmAlertButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setAttributedTitle:item.buttonTitle forState:UIControlStateNormal];
    [button setBackgroundColor:item.backgroundColor];
    [button.layer setCornerRadius:item.cornerRadius];
    [button.layer setBorderColor:item.borderColor.CGColor];
    [button.layer setBorderWidth:item.borderWidth];
    button.item = item;
    return button;
}

- (NSAttributedString *)attributeStringWithTitle:(NSString *)title attributes:(NSDictionary *)dict
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc] init];
    [finalDict addEntriesFromDictionary:dict];
    [finalDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:title attributes:finalDict];
    return result;
}

- (void)addMotionEffect:(UIView *)view
{
    // Motion effects
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    [view addMotionEffect:group];
}

- (UIView *)getLineView
{
    UIView *view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000];
    return view;
}

- (NSLayoutConstraint *)addSameDirectionConstraint:(NSLayoutAttribute)attribute fromSubView:(UIView*)view toSuperView:(UIView*)superView withPadding:(CGFloat)padding
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:superView
                                                                  attribute:attribute
                                                                 multiplier:1
                                                                   constant:padding];
    [view.superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)addTopBottomConstraintFromTopView:(UIView*)topView toButtomView:(UIView*)buttomView withPadding:(CGFloat)padding
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:buttomView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:topView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:padding];
    [topView.superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)addWidthHeightContraint:(NSLayoutAttribute)attribute forView:(UIView *)view constant:(CGFloat)constant
{
    if (attribute == NSLayoutAttributeHeight || attribute == NSLayoutAttributeWidth) {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:constant];
        [view.superview addConstraint:constraint];
        return constraint;
    }
    return nil;
}

@end

#pragma mark - AlarmAlertButtonItem

@implementation AlarmAlertButtonItem

+ (AlarmAlertButtonItem *)defaultButtonItemWithTitle:(NSAttributedString *)title andStyle:(AlertButtonStyle)style
{
    AlarmAlertButtonItem *item = [[AlarmAlertButtonItem alloc] init];
    item.buttonTitle = title;
    item.buttonStyle = style;
    item.cornerRadius = 0;
    item.backgroundColor = [UIColor whiteColor];
    item.buttonHeight = 50;
    switch (style) {
        case AlertButtonStyleDefault:
            
            break;
        case AlertButtonCancel:
            
            break;
        case AlertButtonDestructive:
            item.backgroundColor = [UIColor redColor];
            break;
        default:
            break;
    }
    return item;
}

@end

@implementation AlarmAlertTheme

+ (AlarmAlertTheme *)defaultTheme
{
    AlarmAlertTheme *defaultTheme = [[AlarmAlertTheme alloc] init];
    defaultTheme.backgroundColor = [UIColor whiteColor];
    defaultTheme.cornerRadius = 6.0f;
    defaultTheme.popupContentInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
    defaultTheme.popupStyle = AACentered;
    defaultTheme.contentVerticalPadding = 10.0f;
    return defaultTheme;
}

@end
