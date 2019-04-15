import Foundation
import Core
import Utility

/// Here, we let the SPM script do all the argument parsing using the `ArgumentParser` from
/// Swift Package Manager's `Utility` package. This will then call into the `Core` framework,
/// allowing it to do the actual work under the hood.
do {
    let argParser = ArgumentParser(usage: "<command> <options>", overview: "Commands to run various tasks on the command line")
    
    let preBuildOption = argParser.add(option: "--prebuild",
                                       shortName: "-pre",
                                       kind: Bool.self,
                                       usage: "Runs pre-build tasks if present",
                                       completion: .none)
    
    let postBuildOption = argParser.add(option: "--postbuild",
                                        shortName: "-post",
                                        kind: Bool.self,
                                        usage: "Runs post-build tasks if present",
                                        completion: .none)
    
    let forProdOption = argParser.add(option: "--production",
                                      shortName: "-prod",
                                      kind: Bool.self,
                                      usage: "Runs setup for production if present, non-production if absent.",
                                      completion: .none)
    
    let srcRootPathOption = argParser.add(option: "--sourceroot",
                                          shortName: "-src",
                                          kind: String.self,
                                          usage: "Provides the git source root of the current project",
                                          completion: .none)
    
    
    let args = Array(CommandLine.arguments.dropFirst())
    let result = try argParser.parse(args)
    print("Result: \(result)")
    
    guard let srcRoot = result.get(srcRootPathOption) else {
        throw ArgumentParserError.expectedArguments(argParser, ["--sourceroot"])
    }
    
    let forProd = result.get(forProdOption) ?? false

    
    let runPrebuild = result.get(preBuildOption) ?? false
    if runPrebuild {
        print("Running pre-build scripts...")
        try Core.runPreBuild(sourceRootPath: srcRoot, forProd: forProd)
    }
    
    let runPostBuild = result.get(postBuildOption) ?? false
    if runPostBuild {
        print("Running post-build scripts...")
        try Core.runPostBuild(sourceRootPath: srcRoot, forProd: forProd)
    }
    
    // You need to pick one of pre- or post-build, otherwise this basically does nothing.
    if (!runPrebuild && !runPostBuild) {
        throw ArgumentParserError.expectedArguments(argParser, [
            "--prebuild",
            "--postbuild"
        ])
    }
} catch {
    // An error has occurred somewhere along the way.
    debugPrint("Error: \(error)")
    exit(1)
}

