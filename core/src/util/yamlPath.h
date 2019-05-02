// Helper Functions for parsing YAML nodes
// NOTE: To be used in multiple YAML parsing modules once SceneLoader aptly modularized

#pragma once

#include "yaml-cpp/yaml.h"

namespace Tangram {

// A YamlPath encodes the location of a node in a yaml document in a string,
// e.g. "lorem.ipsum#0" identifies root["lorem"]["ipsum"][0]
struct YamlPath {
    YamlPath();
    YamlPath(const std::string& path);
    YamlPath add(int index);
    YamlPath add(const std::string& key);
    // Follow this path from a root node and set 'out' to the result.
    // Returns true if the path exists up to the final token (i.e. the output
    // may be a new node), otherwise returns false and leaves 'out' unchanged.
    bool get(YAML::Node root, YAML::Node& out);
    std::string codedPath;
};

struct YamlPathBuffer {

    struct PathElement {
        size_t index;
        const std::string* key;
        PathElement(size_t index, const std::string* key) : index(index), key(key) {}
    };

    std::vector<PathElement> m_path;

    void pushMap(const std::string* _p) { m_path.emplace_back(0, _p);}
    void pushSequence() { m_path.emplace_back(0, nullptr); }
    void increment() { m_path.back().index++; }
    void pop() { m_path.pop_back(); }
    YamlPath toYamlPath();
};



}
