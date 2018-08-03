#pragma once

#include <stdint.h>
#include <string>
#include <vector>

#define TREXPORT __attribute__((visibility ("default")))

namespace alfons {
    class InputSource;
}

namespace ratiobike {
    
    TREXPORT class VectorFont {
    private:
        std::string  m_name;
        
        std::vector<alfons::InputSource *> m_faceSources;
        
    public:
        TREXPORT VectorFont(std::string name, std::vector<std::string> fontUrls);
        TREXPORT ~VectorFont();
        TREXPORT static void onMemoryWarning();

    /**
     * str를 rendering한 bitmap을 buf에 채워줌
     */
        TREXPORT void render(std::string str, uint32_t fSize, char* buf, uint32_t maxWidth, uint32_t maxHeight);
    };
}

