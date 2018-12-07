//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// A filter that performs checks based on source file content, including
/// pluginized components and non-core components.
class PluginizedContentFilter: FileFilter {

    /// Initializer.
    ///
    /// - parameter content: The content to be filtered.
    init(content: String) {
        self.content = content
    }

    /// Execute the filter.
    ///
    /// - returns: `true` if the
    func filter() -> Bool {
        let baseFilter = ContentFilter(content: content)
        if baseFilter.filter() {
            return true
        }

        // Use simple string matching first since it's more performant.
        if !content.contains("PluginizedComponent") && !content.contains("NonCoreComponent") && !content.contains("Dependency") && !content.contains("PluginExtension") {
            return false
        }

        // Match actual inheritances using Regex.
        let containsPluginizedComponentInheritance = (Regex(": *(\(needleModuleName).)PluginizedComponent *<").firstMatch(in: content) != nil)
        if containsPluginizedComponentInheritance {
            return true
        }
        let containsNonCoreComponentInheritance = (Regex(": *(\(needleModuleName).)NonCoreComponent *<").firstMatch(in: content) != nil)
        if containsNonCoreComponentInheritance {
            return true
        }
        let containsDependencyInheritance = (Regex(": *(\(needleModuleName).)Dependency").firstMatch(in: content) != nil)
        if containsDependencyInheritance {
            return true
        }
        let containsPluginExtensionInheritance = (Regex(": *(\(needleModuleName).)PluginExtension").firstMatch(in: content) != nil)
        if containsPluginExtensionInheritance {
            return true
        }
        let containsForcedPresidioComponentInheritance = (Regex(": *(Presidio.)PluginExtension").firstMatch(in: content) != nil)
        if containsForcedPresidioComponentInheritance {
            return true
        }
        let containsForcedPresidioDependencyInheritance = (Regex(": *(Presidio.)Dependency").firstMatch(in: content) != nil)
        if containsForcedPresidioDependencyInheritance {
            return true
        }

        return false
    }

    // MARK: - Private

    private let content: String
}
