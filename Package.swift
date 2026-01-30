// swift-tools-version:5.9
import PackageDescription

var whisperExclude: [String] = []
var metalTargets: [Target] = []
var metalDependency: [Target.Dependency] = []

#if os(Linux)
// Linux doesn't support CoreML or Metal
whisperExclude.append("coreml")
#else
metalTargets = [
    .target(name: "ggml_metal",
            exclude: ["CMakeLists.txt"],
            resources: [.copy("Resources/ggml-metal.metal")],
            cSettings: [
                .unsafeFlags(["-fno-objc-arc"]),
                .headerSearchPath("."),
                .headerSearchPath("../whisper_cpp/ggml/include"),
                .headerSearchPath("../whisper_cpp/ggml"),
                .headerSearchPath("../whisper_cpp/include"),
                .define("GGML_USE_METAL"),
                .define("GGML_USE_CPU"),
                .define("GGML_VERSION", to: "\"0.9.4\""),
                .define("GGML_COMMIT", to: "\"v1.8.2\""),
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
            ]),
]
metalDependency = [.target(name: "ggml_metal")]
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
                dependencies: metalDependency,
                exclude: whisperExclude,
                cSettings: [
                    .headerSearchPath("."),
                    .headerSearchPath("ggml"),
                    .headerSearchPath("ggml/include"),
                    .headerSearchPath("ggml/ggml-cpu"),
                    .headerSearchPath("ggml/ggml-cpu/arch/arm"),
                    .define("GGML_VERSION", to: "\"0.9.4\""),
                    .define("GGML_COMMIT", to: "\"v1.8.2\""),
                    .define("WHISPER_VERSION", to: "\"1.8.2\""),
                    .define("GGML_USE_CPU"),
                    .define("GGML_USE_METAL", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("GGML_USE_ACCELERATE", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_USE_COREML", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .define("WHISPER_COREML_ALLOW_FALLBACK", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                ],
                linkerSettings: [
                    .linkedFramework("Accelerate", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .linkedFramework("Metal", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                    .linkedFramework("MetalKit", .when(platforms: [.macOS, .macCatalyst, .iOS])),
                ]),
        .testTarget(name: "WhisperTests", dependencies: [.target(name: "SwiftWhisper")],
                    resources: [.copy("TestResources/")])
    ] + metalTargets,
    cxxLanguageStandard: .cxx17
)
