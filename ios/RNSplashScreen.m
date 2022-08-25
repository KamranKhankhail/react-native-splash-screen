/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waiting = true;
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
    if (!addedJsLoadErrorObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsLoadError:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
        addedJsLoadErrorObserver = true;
    }

    while (waiting) {
        NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop mainRunLoop] runUntilDate:later];
    }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
    if (!loadingView) {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"SplashViewController"];
        // [[[NSBundle mainBundle] loadNibNamed:splashScreen owner:self options:nil] objectAtIndex:0];
        CGRect frame = rootView.frame;
        frame.origin = CGPointMake(0, 0);
        // loadingView.frame = frame;

        /**
         * Dynamic Splash code starts he;re
         */
        UIView *mainContainer = [[UIView alloc] initWithFrame:frame];
        UIImageView *ivSplash =[[UIImageView alloc] initWithFrame:frame];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSInteger lastDisplayedIdx = [prefs integerForKey:@"lastDisplayedIdx"];
        [prefs setInteger:(lastDisplayedIdx+1)%28 forKey:@"lastDisplayedIdx"];
        [prefs synchronize];
        
        NSString* imgName = @"SplashScreen";
        
        if (lastDisplayedIdx != 0) {
            imgName = [NSString stringWithFormat:@"SplashScreen%ld", (long)lastDisplayedIdx];
        }
        
        UIImage *splashImage = [UIImage imageNamed: imgName];
        
        ivSplash.image=splashImage;
        
        [mainContainer addSubview:ivSplash];
        
        loadingView = vc.view;
        
        [loadingView addSubview:mainContainer];
        /**
         * Dynamic Splash code starts here
         */
    }
    waiting = false;
    
    [rootView addSubview:loadingView];
}

+ (void)hide {
    if (waiting) {
        dispatch_async(dispatch_get_main_queue(), ^{
            waiting = false;
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [loadingView removeFromSuperview];
        });
    }
}

+ (void) jsLoadError:(NSNotification*)notification
{
    // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise the splash screen will remain forever, which is a hassle to debug.
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) {
    [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    [RNSplashScreen show];
}

@end
