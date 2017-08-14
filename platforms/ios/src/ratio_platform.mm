#include "ratio_platform.h"
#include "TangramMap/iosPlatform.h"

@interface FakeViewController : TGMapViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end

@implementation FakeViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        self.httpHandler = [[TGHttpHandler alloc] initWithCachePath:@"/tangram_cache"
                                                cacheMemoryCapacity:4*1024*1024
                                                  cacheDiskCapacity:30*1024*1024];
    }
    return self;
}

@end

namespace ratiobike {

    static std::shared_ptr<Tangram::Platform> dummy_platform;

    std::shared_ptr<Tangram::Platform> get_platform()
        {
            if(!dummy_platform) {
                __strong TGMapViewController* _viewController
                    = [[FakeViewController alloc] initWithNibName: nil bundle: nil];
                dummy_platform = std::static_pointer_cast<Tangram::Platform>
                    (std::make_shared<Tangram::iOSPlatform>(_viewController));
            }
    
            return dummy_platform;
        }

    void delegateToMainThread(std::function<void(void)> func) {
        dispatch_async(dispatch_get_main_queue(), ^{
                func();
            });
    }

}
