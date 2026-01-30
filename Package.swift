// swift-tools-version:5.9
import PackageDescription

var exclude: [String] = []

#if os(Linux)
// Linux doesn't support CoreML, and will attempt to import the coreml source directory
exclude.append("coreml")
exclude.append("ggml/ggml-metal")
#endif

let package = Package(
    name: "SwiftWhisper",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "SwiftWhisper", targets: ["SwiftWhisper"])
    ],
    targets: [
        .target(name: "SwiftWhisper", dependencies: [.target(name: "whisper_cpp")]),
        .target(name: "whisper_cpp",
                exclude: exclude,
                cSettings: [
                    .headerSearchPath("."),
                    .headerSearchPath("ggml"),
                    .headerSearchPath("ggml/include"),
                    .headerSearchPath("ggml/ggml-cpu"),
                    .headerSearchPath("ggml/ggml-cpu/arch/arm"),
                    .define("GGML_VERSION", to: "\"0.9.4\""),
                    .define("GGML_COMMIT", to: "\"v1.8.2\""),
                    .define("WHISPER_VERSION", to: "\"1.8.2\""),
                    .define("GGML_USE_ACCELERATE", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_USE_COREML", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_COREML_ALLOW_FALLBACK", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                ],
                linkerSettings: [
                    .linkedFramework("Accelerate", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                ]),
        .testTarget(name: "WhisperTests", dependencies: [.target(name: "SwiftWhisper")],
                    resources: [.copy("TestResources/")])
    ],
    cxxLanguageStandard: .cxx17
)
