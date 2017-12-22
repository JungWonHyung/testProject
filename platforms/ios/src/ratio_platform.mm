#include "ratio_platform.h"
#include "TangramMap/iosPlatform.h"

namespace Tangram {
    __strong TGHttpHandler* dummy_handler;
}
namespace ratiobike {

    static std::shared_ptr<Tangram::Platform> dummy_platform;


    std::shared_ptr<Tangram::Platform> get_platform()
        {
            if(!dummy_platform) {
              Tangram::dummy_handler = [[TGHttpHandler alloc] initWithCachePath:@"/tangram_cache"
                                                     cacheMemoryCapacity:4*1024*1024
                                                       cacheDiskCapacity:30*1024*1024];
                dummy_platform = std::static_pointer_cast<Tangram::Platform>
                    (std::make_shared<Tangram::iOSPlatform>(nullptr));
            }
    
            return dummy_platform;
        }

    void delegateToMainThread(std::function<void(void)> func) {
        dispatch_async(dispatch_get_main_queue(), ^{
                func();
            });
    }

}
