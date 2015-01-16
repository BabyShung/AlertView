
#import "AlarmAlertView.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define isIPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define buttonFontSize 16
#define defaultFontColor [UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1]

#pragma mark - AlarmAlertButton

@interface AlarmAlertButton : UIButton

@property (nonatomic, strong) AlarmAlertButtonItem *item;

@end

@implementation AlarmAlertButton

@end

#pragma mark - AlarmAlertView

@interface AlarmAlertView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSMutableArray *buttonItems;

@property (nonatomic, strong) AlarmAlertView *selfReference;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *KeyWindow;

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
    return [self initWithTitle:title message:message preferredStyle:style subViewOfView:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                subViewOfView:(UIView *)superView
{
    return [self initWithTitle:title message:message preferredStyle:AACentered subViewOfView:superView];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView
{
    self = [super init];
    if (self) {
        _theme = [[AlarmAlertTheme alloc] initWithDefaultTheme];//init theme first
        _selfReference = self;//it will be removed when dismissed
        _title = title;
        _message = message;
        _theme.popupStyle = style;
        _buttonItems = [NSMutableArray array];
        self.KeyWindow = superView;
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
    [self addActionWithTitle:title titleColor:self.theme.buttonTitleColor style:style handler:handler];
}

- (void)addActionWithTitle:(NSString *)title titleColor:(UIColor *)color style:(AlertButtonStyle)style handler:(void (^)(AlarmAlertButtonItem *item))handler
{
    AlarmAlertButtonItem *item = [[AlarmAlertButtonItem alloc] initWithTitle:title andButtonTitleColor:color andStyle:style];
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
    
    if (!self.KeyWindow) {
        self.KeyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [self.KeyWindow addSubview:self.maskView];
    
    self.contentView = [[UIView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = self.theme.backgroundColor;
    self.contentView.layer.cornerRadius = self.theme.popupStyle == AACentered ? self.theme.cornerRadius : 0.0f;
    [self.maskView addSubview:self.contentView];
    
    if (self.title) {
        NSAttributedString *aTitle = [AlarmAlertView attributeStringWithTitle:self.title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:self.theme.titleFontSize], NSForegroundColorAttributeName : self.theme.titleColor}];
        UILabel *title = [self multilineLabelWithAttributedString:aTitle];
        [self.contentView addSubview:title];
    }
    
    if (self.message) {
        NSAttributedString *aMessage = [AlarmAlertView attributeStringWithTitle:self.message attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.theme.messageFontSize], NSForegroundColorAttributeName : self.theme.messageColor}];
        UILabel *label = [self multilineLabelWithAttributedString:aMessage];
        [self.contentView addSubview:label];
    }
    
    self.hLine = [self getLineView];//a horizontal line is already needed
    [self.contentView addSubview:self.hLine];
    
    if ([self twoButtonsOnly] && ![self isActionSheet]) {
        self.vLine = [self getLineView];
        [self.contentView addSubview:self.vLine];
    }
    
    if (self.buttonItems.count >0) {
        for (AlarmAlertButtonItem *item in self.buttonItems){
            if (self.buttonItems.count > 2 || [self isActionSheet]) {
                [item changeToSolidStyle];
            }
            AlarmAlertButton *button = [self buttonItem:item];
            [self.contentView addSubview:button];
        }
    }
    
    //after initing and adding, setup the contraints
    [self setupLayoutAndContraints];
}

- (void)setupLayoutAndContraints
{
     NSDictionary *views = @{@"maskView":self.maskView};
    NSDictionary *metrics = @{@"cTop":@(self.theme.contentViewInsets.top),
                              @"cLeft":@(self.theme.contentViewInsets.left),
                              @"cRight":@(self.theme.contentViewInsets.right),
                              @"topDownPadding":@(self.theme.contentVerticalPadding),
                              @"topDownPaddingMore":@(self.theme.contentVerticalPadding + 5)
                              };
    
    [self.KeyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[maskView]|" options:kNilOptions metrics:nil views:views]];
    [self.KeyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[maskView]|" options:kNilOptions metrics:nil views:views]];
    
    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop)
     {
         if (index == 0) {
             //padding to the top of contentView
             [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(cTop)-[view]" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
             
             //leftRight padding
             [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(cLeft)-[view]-(cRight)-|" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
         }else {
             UIView *previousSubView = [self.contentView.subviews objectAtIndex:index - 1];
             if (previousSubView) {
                 
                 //**** several cases: is Button or Label or HLine or VLine ****
                 
                 if ([view isKindOfClass:[UIButton class]]) {//is a button, set height constraint
                     AlarmAlertButton *button = (AlarmAlertButton *)view;
                     NSDictionary *btnDict = @{@"btnHeight":@(button.item.buttonHeight)};
                     
                     //height
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(btnHeight)]" options:kNilOptions metrics:btnDict views:NSDictionaryOfVariableBindings(view)]];
                     [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                     
                     if (self.buttonItems.count > 2 || [self isActionSheet]){
                         //padding to top
                         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousSubView]-(topDownPadding)-[view]" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(previousSubView,view)]];

                         //leftRight
                         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(cLeft)-[view]-(cRight)-|" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
                     }
                     else if ([self twoButtonsOnly]) {
                         NSDictionary *relatedViews = @{@"view":view,
                                                        @"hLine":self.hLine,
                                                        @"vLine":self.vLine};
                         
                         //padding to top
                         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hLine][view]" options:kNilOptions metrics:nil views:relatedViews]];
                         
                         //leftRight
                         if (button.item == self.buttonItems[0]) {
                             [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view][vLine]" options:kNilOptions metrics:nil views:relatedViews]];
                         }else{
                             [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[vLine][view]|" options:kNilOptions metrics:nil views:relatedViews]];
                         }
                     }else if (self.buttonItems.count == 1){
                         NSDictionary *relatedViews = @{@"view":view,
                                                        @"hLine":self.hLine};
                         //padding to top
                         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hLine][view]" options:kNilOptions metrics:nil views:relatedViews]];
                         //leftRight padding
                         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                     }
                 }
                 else if ([view isKindOfClass:[UILabel class]]) {
                     //padding to top
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousSubView]-(topDownPadding)-[view]" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(previousSubView,view)]];
                     //leftRight padding
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(cLeft)-[view]-(cRight)-|" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
                 }
                 else if (view == self.hLine) {
                     //padding to top
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousSubView]-(topDownPaddingMore)-[view]" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(previousSubView,view)]];
                     //height
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(0.5)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                     //leftRight padding
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                 }
                 else if (view == self.vLine) {
                     NSDictionary *relatedViews = @{@"view":view,
                                                    @"hLine":self.hLine};
                     //padding to top
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hLine][view]" options:kNilOptions metrics:nil views:relatedViews]];
                     //centerX
                     [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
                     //width
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(0.5)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                     //to contentView bottom
                     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                 }
             }
         }
         
         if (index == self.contentView.subviews.count - 1) {//buttom padding
             NSDictionary *metrics = @{@"padding":@((self.buttonItems.count > 2 || [self isActionSheet]) ? (self.theme.contentViewInsets.bottom + 0.0f) : 0)};
             [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-(padding)-|" options:kNilOptions metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
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
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:0.85 constant:0];
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
                     completion:nil];
}

- (void)dismiss
{
    [self dismissViewAnimated:YES];
}

- (void)dismissViewAnimated:(BOOL)flag
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

- (void)actionButtonPressed:(AlarmAlertButton *)sender
{
    if (sender.item.selectionHandler) {
        sender.item.selectionHandler(sender.item);
    }
    [self dismissViewAnimated:YES];
}

#pragma mark - Helpers

- (BOOL)twoButtonsOnly
{
    return self.buttonItems.count == 2? YES : NO;
}

- (BOOL)isActionSheet
{
    return self.theme.popupStyle == AAActionSheet? YES : NO;
}

- (UILabel *)multilineLabelWithAttributedString:(NSAttributedString *)attributedString
{
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setAttributedText:attributedString];
    [label setNumberOfLines:0];
    return label;
}

- (AlarmAlertButton *)buttonItem:(AlarmAlertButtonItem *)item
{
    AlarmAlertButton *button = [[AlarmAlertButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setAttributedTitle:item.buttonTitle forState:UIControlStateNormal];
    NSAttributedString *alphaString = [self attributedStringChangeColorAlpha:item.buttonTitle];
    [button setAttributedTitle:alphaString forState:UIControlStateHighlighted];
    [button setBackgroundColor:item.backgroundColor];
    [button.layer setCornerRadius:item.cornerRadius];
    [button.layer setBorderColor:item.borderColor.CGColor];
    [button.layer setBorderWidth:item.borderWidth];
    button.item = item;
    return button;
}

- (NSAttributedString*) attributedStringChangeColorAlpha:(NSAttributedString *)string
{
    NSMutableAttributedString* attributedString = [string mutableCopy];
    {
        [attributedString beginEditing];
        [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            UIColor* alphaColor = value;
            UIColor *final = [alphaColor colorWithAlphaComponent:0.7];
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:final range:range];
        }];        [attributedString endEditing];
    }
    return [attributedString copy];
}

+ (NSAttributedString *)attributeStringWithTitle:(NSString *)title attributes:(NSDictionary *)dict
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
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        return;
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

@end

#pragma mark - AlarmAlertButtonItem

@implementation AlarmAlertButtonItem

- (instancetype)initWithTitle:(NSString *)title andButtonTitleColor:(UIColor *)color andStyle:(AlertButtonStyle)style
{
    self = [super init];
    if (self) {
        self.buttonStyle = style;
        self.cornerRadius = 0;
        self.backgroundColor = [UIColor whiteColor];
        self.buttonHeight = 48;
        UIColor *buttonTitleColor = color;
        switch (style) {
            case AlertButtonStyleDefault:
                //do nothing
                break;
            case AlertButtonCancel:
                buttonTitleColor = [defaultFontColor colorWithAlphaComponent:.8];
                break;
            case AlertButtonDestructive:
                self.backgroundColor = [UIColor redColor];
                break;
            default:
                break;
        }
        NSAttributedString *buttonString = [AlarmAlertView attributeStringWithTitle:title attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:buttonFontSize], NSForegroundColorAttributeName : buttonTitleColor}];
        self.buttonTitle = buttonString;
    }
    return self;
}

- (void)changeToSolidStyle
{
    self.cornerRadius = 3;
    self.backgroundColor = [defaultFontColor colorWithAlphaComponent:.8];
    self.buttonHeight = 45;
    NSAttributedString *buttonString = [AlarmAlertView attributeStringWithTitle:self.buttonTitle.string attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:buttonFontSize], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.buttonTitle = buttonString;
}

@end

#pragma mark - AlarmAlertTheme

@implementation AlarmAlertTheme

- (instancetype)initWithDefaultTheme
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIColor *color = defaultFontColor;
        self.titleColor = self.messageColor = self.buttonTitleColor=color;
        self.cornerRadius = 6.0f;
        self.titleFontSize = 18.f;
        self.messageFontSize = 15.f;
        self.contentViewInsets = UIEdgeInsetsMake(17.0f, 15.0f, 17.0f, 15.0f);
        self.popupStyle = AACentered;
        self.contentVerticalPadding = 10.0f;
    }
    return self;
}

@end
