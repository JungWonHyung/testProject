#include <string>
#include <cmath>

#include "unicode/unistr.h"
#include "alfons/fontManager.h"
#include "alfons/textShaper.h"
#include "alfons/font.h"
#include "alfons/scrptrun.h"
#include "alfons/inputSource.h"
#include "VectorFont.h"

using namespace std;

namespace ratiobike {
    static alfons::FontManager fontMan;

    static void print2y(bool u, bool l)
    {
        if( u ) {
            if( l ) {
                printf("█");
            } else {
                printf("▀");
            }
        } else {
            if( l ) {
                printf("▄");
            } else {
                printf(" ");
            }
        }
    }

    VectorFont::VectorFont(string name, vector<string> fontUrls)
        : m_name(name), m_faceSources()
    {
        for(auto url: fontUrls) {
            m_faceSources.push_back(new alfons::InputSource(url) );
        }
    }

    VectorFont::~VectorFont()
    {
        for(auto source: m_faceSources) {
            delete source;
        }

        m_faceSources.clear();
    }

    void VectorFont::onMemoryWarning()
    {
        fontMan.unload();
    }

    void VectorFont::render(string str, uint32_t fSize, char* buf, uint32_t maxWidth, uint32_t maxHeight)
    {
        alfons::TextShaper shaper;
        
        shared_ptr<alfons::Font> font = fontMan.getFont(m_name, alfons::Font::Properties(fSize));

        if( font->faces().empty() ) {
            for( auto source : m_faceSources) {
                font->addFace(fontMan.addFontFace(*source, fSize));
            }
        }

        alfons::LineLayout line = shaper.shape(font, str);
        uint32_t byteWidth = ((maxWidth + 7) >> 3);
    
        float xf = 0.0, yf = 0.0;
        uint32_t xOffset, yOffset;
    
        for(auto s: line.shapes()) {
            float glyph_xoffset = 0.0f;
        
            printf("    %04x: (%f, %f) %f : %d : %04x\n", s.codepoint, s.position.x, s.position.y, line.advance(s), s.face, s.flags);
            if( !s.isSpace ) {
                auto glyph = line.font().face(s.face).createGlyph(s.codepoint);
                glyph_xoffset = glyph->x0;
                int x0 = glyph->x0;
                int y0 = glyph->y0;
                int x1 = glyph->x1;
                int y1 = glyph->y1;
                int xdiff = x1 - x0;
                int ydiff = y1 - y0;

                xf += glyph_xoffset;
                yf = line.ascent() + glyph->y0;
                xOffset = (uint32_t)round(xf);
                yOffset = (uint32_t)round(yf);
            
                printf("Glyph: %d (%d, %d), (%d, %d)\n", glyph->isValid(), x0, y0, x1, y1);
                auto buffer = glyph->getBuffer();
                for( int iy = 0; iy < ydiff; iy ++ ) {
                    for( int ix = 0; ix < xdiff; ix++ ) {
                        if( buffer[iy * xdiff + ix] & 0x80 ) {
                            uint32_t rx = xOffset + s.position.x + ix;
                            uint32_t ry = yOffset + s.position.y + iy;
                            buf[ry * byteWidth + (rx >> 3)] |= (0x80 >> (rx & 7));
                        }
                    }
                }
            }

            xf += line.advance(s) - glyph_xoffset;
        }

        printf("  line:dir = %d, scale = %f, size = (%f, %f), Y = (%f - %f)\n", line.direction(), line.scale(),
               line.advance(), line.height(), line.ascent(), line.descent());

        return;
    }

    /* Script run 문장별 script 예제
    // 원하는 font를 만든다.
    string styleStr = condensed ? "Condensed" : "Regular";
    // Script를 조사하고 해당 font들이 있는지 확인한다.

    auto uText = icu::UnicodeString::fromUTF8(str);
    ScriptRun scriptRun(uText.getBuffer(), uText.length());
    shared_ptr<alfons::Font> font = fontMan.getFont(styleStr, alfons::Font::Properties(fSize));

    outer_cont:
    while(scriptRun.next()) {
    auto scriptFaceIt = faceMap.find( scriptRun.getScriptCode() );
    FontDesc& scriptFaceDesc = ( scriptFaceIt != faceMap.end() ) ? scriptFaceIt->second : fallBackFont;
    string family = scriptFaceDesc.family;

    // face가 없음
    printf("Script Code: %d\n", scriptRun.getScriptCode());
        
    alfons::Font::Faces faces = font->faces();
        
    for( auto& face : faces ) {
    printf("compare: %s => %s\n", face->getFullName().c_str(), family.c_str());
    if( face->getFullName().compare(0, family.size(), family) == 0)  goto outer_cont;
    }

    shared_ptr<alfons::FontFace> toLoad;
    if( &scriptFaceDesc == &fallBackFont ) {
    toLoad = fontMan.addFontFace(alfons::InputSource(family + "." + fallBackFont.ext), fSize);
    } else {
    toLoad = fontMan.addFontFace(alfons::InputSource(family + "-" + styleStr
    + "." + scriptFaceDesc.ext), fSize);
    }
    font->addFace(toLoad);
    toLoad->load();
    printf("ADD FONT %s %s %d\n", family.c_str(), styleStr.c_str(), fSize);
    }

    */

                                                             
}
