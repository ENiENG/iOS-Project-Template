
#import "MBTextField.h"
#import "RFDrawImage.h"
#import "UIKit+App.h"
#import "UITextFiledDelegateChain.h"

@interface MBTextField ()
@property (strong, nonatomic) UITextFiledDelegateChain *trueDelegate;
@property (assign, nonatomic) BOOL noBorder;
@end

@implementation MBTextField
RFInitializingRootForUIView

- (void)onInit {
    // 文字距边框设定
    self.textEdgeInsets = UIEdgeInsetsMake(7, 10, 7, 10);

    // 获取焦点自动高亮
    // 只在非默认风格下设置背景图
    if (self.borderStyle == UITextBorderStyleNone) {
        self.noBorder = YES;
    }

    if (self.borderStyle != UITextBorderStyleRoundedRect) {
        self.borderStyle = UITextBorderStyleNone;
        if (!self.noBorder) {
            self.disabledBackground = [MBTextField disabledBackgroundImage];
            self.background = [MBTextField backgroundImage];
        }
    }

    [super setDelegate:self.trueDelegate];
}

- (void)afterInit {
    // 修改 place holder 文字样式
    if (self.placeholder) {
        self.placeholder = self.placeholder;
    }

    // 回车切换到下一个输入框或按钮，默认键盘样式
    if (self.nextField && self.returnKeyType == UIReturnKeyDefault) {
        if ([self.nextField isKindOfClass:[UITextField class]] || [self.nextField isKindOfClass:[UITextView class]]) {
            self.returnKeyType = UIReturnKeyNext;
        }
        else {
            self.returnKeyType = UIReturnKeySend;
        }
    }
}

#pragma mark - 修改 place holder 文字样式
- (void)setPlaceholder:(NSString *)placeholder {
    // iOS 6 无效果
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor globalPlaceholderTextColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:14] }];
}

#pragma mark - 修改默认文字框最低高度
- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.height = MAX(size.height, 36);
    return size;
}

#pragma mark - 文字距边框设定
- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.textEdgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

#pragma mark - 获取焦点自动高亮
+ (UIImage *)backgroundImage {
	return [[UIImage imageNamed:@"text_field_bg_normal"] resizableImageWithCapInsets:UIEdgeInsetsMakeWithSameMargin(3)];
}

+ (UIImage *)focusedBackgroundImage {
	return [[UIImage imageNamed:@"text_field_bg_focused"] resizableImageWithCapInsets:UIEdgeInsetsMakeWithSameMargin(3)];
}

+ (UIImage *)disabledBackgroundImage {
	return [[UIImage imageNamed:@"text_field_bg_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMakeWithSameMargin(3)];
}

- (BOOL)becomeFirstResponder {
    if (!self.noBorder) {
        self.background = [MBTextField focusedBackgroundImage];
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    if (!self.noBorder) {
        self.background = [MBTextField backgroundImage];
    }
    return [super resignFirstResponder];
}

#pragma mark - Delegate

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    self.trueDelegate.delegate = delegate;
}

- (UITextFiledDelegateChain *)trueDelegate {
    if (!_trueDelegate) {
        _trueDelegate = [UITextFiledDelegateChain new];
        [_trueDelegate setShouldReturn:^BOOL(UITextField *aTextField, id<UITextFieldDelegate> delegate) {
            MBTextField *textField = (id)aTextField;
            if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
                if (![delegate textFieldShouldReturn:textField]) {
                    return NO;
                }
            }
            if (![textField isKindOfClass:[MBTextField class]]) return YES;

            if ([textField.nextField isKindOfClass:[UITextField class]]
                || [textField.nextField isKindOfClass:[UITextView class]]) {
                [textField.nextField becomeFirstResponder];
            }
            if ([textField.nextField isKindOfClass:[UIControl class]]) {
                [(UIControl *)textField.nextField sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            return YES;
        }];

        [_trueDelegate setShouldChangeCharacters:^BOOL(UITextField *aTextField, NSRange inRange, NSString *replacementString, id<UITextFieldDelegate> delegate) {
            MBTextField *textField = (id)aTextField;

            if (textField.maxLength) {
                // Needs limit length
                if (!inRange.length) {
                    if (replacementString.length + textField.text.length > textField.maxLength) {
                        return NO;
                    }
                }
            }

            if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                return [delegate textField:aTextField shouldChangeCharactersInRange:inRange replacementString:replacementString];
            }
            return YES;
        }];
    }
    return _trueDelegate;
}
@end
