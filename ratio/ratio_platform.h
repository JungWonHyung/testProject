#pragma once

#include "platform.h"

namespace ratiobike {

    std::shared_ptr<Tangram::Platform> get_platform();

    void delegateToMainThread(std::function<void(void)> func);
}
