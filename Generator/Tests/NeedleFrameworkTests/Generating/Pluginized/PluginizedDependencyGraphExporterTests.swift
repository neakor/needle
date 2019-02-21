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

import XCTest
@testable import NeedleFramework

class PluginizedDependencyGraphExporterTests: AbstractPluginizedGeneratorTests {

    let fixturesURL = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Fixtures/Pluginized")

    @available(OSX 10.12, *)
    func test_export_verifyContent() {
        let (components, pluginizedComponents, imports) = pluginizedSampleProjectParsed()
        let executor = MockSequenceExecutor()
        let exporter = PluginizedDependencyGraphExporter()

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("generated_pluginized.swift")
        let headerDocPath = fixturesURL.deletingLastPathComponent().appendingPathComponent("HeaderDoc.txt").path
        try? exporter.export(components, pluginizedComponents, with: imports, to: outputURL.path, using: executor, withTimeout: 10, include: headerDocPath)
        let generated = try? String(contentsOf: outputURL)
        XCTAssertNotNil(generated, "Could not read the generated file")

        XCTAssertTrue(generated!.contains("//\n//  Copyright © Uber Technologies, Inc. All rights reserved.\n//\n//  @generated by Needle\n//  swiftlint:disable custom_rules"))
        XCTAssertTrue(generated!.contains("import NeedleFoundation"))
        XCTAssertTrue(generated!.contains("import RxSwift"))
        XCTAssertTrue(generated!.contains("import UIKit"))
        XCTAssertTrue(generated!.contains("import ScoreSheet"))
        XCTAssertTrue(generated!.contains("import TicTacToeIntegrations"))
        XCTAssertTrue(generated!.contains("// MARK: - Registration"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedOutComponent\") { component in\n        return LoggedOutDependencyacada53ea78d270efa2fProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent\") { component in\n        return EmptyDependencyProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent->GameComponent->GameNonCoreComponent->ScoreSheetComponent\") { component in\n        return ScoreSheetDependencyea879b8e06763171478bProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent->LoggedInNonCoreComponent->ScoreSheetComponent\") { component in\n        return ScoreSheetDependency6fb80fa6e1ee31d9ba11Provider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent->GameComponent->GameNonCoreComponent\") { component in\n        return EmptyDependencyProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent->LoggedInNonCoreComponent\") { component in\n        return EmptyDependencyProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent->GameComponent\") { component in\n        return GameDependency1ab5926a977f706d3195Provider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: \"^->RootComponent->LoggedInComponent\") { component in\n        return EmptyDependencyProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__PluginExtensionProviderRegistry.instance.registerPluginExtensionProviderFactory(for: \"GameComponent\") { component in\n        return GamePluginExtensionProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("__PluginExtensionProviderRegistry.instance.registerPluginExtensionProviderFactory(for: \"LoggedInComponent\") { component in\n        return LoggedInPluginExtensionProvider(component: component)\n    }"))
        XCTAssertTrue(generated!.contains("// MARK: - Providers"))
        XCTAssertTrue(generated!.contains("/// ^->RootComponent->LoggedOutComponent\nprivate class LoggedOutDependencyacada53ea78d270efa2fProvider: LoggedOutDependency {\n    var mutablePlayersStream: MutablePlayersStream {\n        return rootComponent.mutablePlayersStream\n    }\n    private let rootComponent: RootComponent\n    init(component: NeedleFoundation.Scope) {\n        rootComponent = component.parent as! RootComponent\n    }\n}"))
        XCTAssertTrue(generated!.contains("/// ^->RootComponent->LoggedInComponent->GameComponent->GameNonCoreComponent->ScoreSheetComponent\nprivate class ScoreSheetDependencyea879b8e06763171478bProvider: ScoreSheetDependency {\n    var scoreStream: ScoreStream {\n        return (loggedInComponent.nonCoreComponent as! LoggedInNonCoreComponent).scoreStream\n    }\n    private let loggedInComponent: LoggedInComponent\n    init(component: NeedleFoundation.Scope) {\n        loggedInComponent = component.parent.parent.parent as! LoggedInComponent\n    }\n}"))
        XCTAssertTrue(generated!.contains("/// ^->RootComponent->LoggedInComponent->LoggedInNonCoreComponent->ScoreSheetComponent\nprivate class ScoreSheetDependency6fb80fa6e1ee31d9ba11Provider: ScoreSheetDependency {\n    var scoreStream: ScoreStream {\n        return loggedInNonCoreComponent.scoreStream\n    }\n    private let loggedInNonCoreComponent: LoggedInNonCoreComponent\n    init(component: NeedleFoundation.Scope) {\n        loggedInNonCoreComponent = component.parent as! LoggedInNonCoreComponent\n    }\n}"))
        XCTAssertTrue(generated!.contains("/// ^->RootComponent->LoggedInComponent->GameComponent\nprivate class GameDependency1ab5926a977f706d3195Provider: GameDependency {\n    var mutableScoreStream: MutableScoreStream {\n        return loggedInComponent.pluginExtension.mutableScoreStream\n    }\n    var playersStream: PlayersStream {\n        return rootComponent.playersStream\n    }\n    private let loggedInComponent: LoggedInComponent\n    private let rootComponent: RootComponent\n    init(component: NeedleFoundation.Scope) {\n        loggedInComponent = component.parent as! LoggedInComponent\n        rootComponent = component.parent.parent as! RootComponent\n    }\n}"))
        XCTAssertTrue(generated!.contains("/// GameComponent plugin extension\nprivate class GamePluginExtensionProvider: GamePluginExtension {\n    var scoreSheetBuilder: ScoreSheetBuilder {\n        return gameNonCoreComponent.scoreSheetBuilder\n    }\n    private unowned let gameNonCoreComponent: GameNonCoreComponent\n    init(component: NeedleFoundation.Scope) {\n        let gameComponent = component as! GameComponent\n        gameNonCoreComponent = gameComponent.nonCoreComponent as! GameNonCoreComponent\n    }\n}"))
        XCTAssertTrue(generated!.contains("/// LoggedInComponent plugin extension\nprivate class LoggedInPluginExtensionProvider: LoggedInPluginExtension {\n    var scoreSheetBuilder: ScoreSheetBuilder {\n        return loggedInNonCoreComponent.scoreSheetBuilder\n    }\n    var mutableScoreStream: MutableScoreStream {\n        return loggedInNonCoreComponent.mutableScoreStream\n    }\n    private unowned let loggedInNonCoreComponent: LoggedInNonCoreComponent\n    init(component: NeedleFoundation.Scope) {\n        let loggedInComponent = component as! LoggedInComponent\n        loggedInNonCoreComponent = loggedInComponent.nonCoreComponent as! LoggedInNonCoreComponent\n    }\n}"))
    }
}
