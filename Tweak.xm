#import <Preferences/Preferences.h>

@interface PSSliderTableCell (chew) <UIAlertViewDelegate, UITextFieldDelegate>
-(void) presentPopup;
-(void) typeMinus;
@end

#define kSuperSlidersEntryAlertTag 34853452
#define kSuperSlidersErrorAlertTag 85383998

%hook PSSliderTableCell

static UIAlertView * alert = nil;

-(id) initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(PSSpecifier*)arg3 {
    if ([arg3 propertyForKey:@"cellClass"] == nil) {
        [arg3 setProperty:[NSNumber numberWithInt:1] forKey:@"showValue"];
        PSSliderTableCell* o = %orig;
        CGRect frame = [o frame];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if ([arg3 propertyForKey:@"maximumValueImage"] != nil || [arg3 propertyForKey:@"rightImagePromise"] != nil) {
            button.frame = CGRectMake(frame.size.width-85, 0, 50, frame.size.height);
        }
        else {
            button.frame = CGRectMake(frame.size.width-50, 0, 50, frame.size.height);
        }
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setTitle:@"" forState:UIControlStateNormal];
        [button addTarget:o action:@selector(presentPopup) forControlEvents:UIControlEventTouchUpInside];
        [o addSubview:button];
        return o;
    }
    else {
        return %orig;
    }
}

-(void) layoutSubviews {
    %orig;
    if ([self.specifier propertyForKey:@"rightImage"] != nil) {
        for (UIView* s in self.control.subviews) {
            if ([s isKindOfClass:[UILabel class]]) {
                s.frame =  CGRectMake(self.frame.size.width-86, s.frame.origin.y, s.frame.size.width, s.frame.size.height);
            }
        }
    }
}

%new
- (void)presentPopup {
    alert = [[UIAlertView alloc] initWithTitle:self.specifier.name
             message:[NSString stringWithFormat:@"Please enter a value between %i and %i.", (int)[[self.specifier propertyForKey:@"min"] floatValue], (int)[[self.specifier propertyForKey:@"max"] floatValue]]
             delegate:self
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@"Enter"
             , nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = kSuperSlidersEntryAlertTag;
    [alert show];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:0] resignFirstResponder];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    BOOL needsNegate = [[self.specifier propertyForKey:@"min"] floatValue] < 0;
    BOOL needsPoint = [[self.specifier propertyForKey:@"max"] floatValue] - [[self.specifier propertyForKey:@"min"] floatValue] <= 10;
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && (needsNegate || needsPoint)) {
        UIToolbar* toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        UIBarButtonItem* buttonOne = [[UIBarButtonItem alloc] initWithTitle:@"Negate" style:UIBarButtonItemStylePlain target:self action:@selector(typeMinus)];
        UIBarButtonItem* buttonTwo = [[UIBarButtonItem alloc] initWithTitle:@"Point" style:UIBarButtonItemStylePlain target:self action:@selector(typePoint)];
        NSArray* buttons = nil;
        if (needsPoint && needsNegate) {
            buttons = [NSArray arrayWithObjects:buttonOne, buttonTwo, nil];
        }
        else if (needsPoint) {
            buttons = [NSArray arrayWithObjects:buttonTwo, nil];
        }
        else if (needsNegate) {
            buttons = [NSArray arrayWithObjects:buttonOne, nil];
        }
        [toolBar setItems:buttons animated:NO];
        [[alert textFieldAtIndex:0] setInputAccessoryView:toolBar];
    }
    [[alert textFieldAtIndex:0] becomeFirstResponder];
}
%new
-(void)typeMinus {
    if (alert) {
        NSString* text = [alert textFieldAtIndex:0].text;
        if ([text hasPrefix:@"-"]) {
            [alert textFieldAtIndex:0].text = [text substringFromIndex:1];
        }
        else {
            [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"-%@", text];
        }
    }
}
%new
-(void)typePoint {
    if (alert) {
        NSString* text = [alert textFieldAtIndex:0].text;
        [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"%@.", text];
    }
}
%new
- (void)alertView : (UIAlertView*)alertView clickedButtonAtIndex : (NSInteger)buttonIndex {
    if (alertView.tag == kSuperSlidersEntryAlertTag && buttonIndex == 1) {
        CGFloat value = [[alertView textFieldAtIndex:0].text floatValue];
        [[alertView textFieldAtIndex:0] resignFirstResponder];
        if (value <= [[self.specifier propertyForKey:@"max"] floatValue] && value >= [[self.specifier propertyForKey:@"min"] floatValue]) {
            [PSRootController setPreferenceValue:[NSNumber numberWithInt:value] specifier:self.specifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setValue:[NSNumber numberWithInt:value]];
        }
        else {
            UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                  message:@"Ensure you enter a valid value."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil
                                  , nil];
            errorAlert.tag = kSuperSlidersErrorAlertTag;
            [errorAlert show];
        }
    }
    else if (alertView.tag == kSuperSlidersErrorAlertTag) {
        [self presentPopup];
    }
}

%end
