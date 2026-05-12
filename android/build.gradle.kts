allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ===================================================================
// 🚀 NUCLEAR OVERRIDE V5: THE ABSOLUTE FINISHER (SDK 35 + CORE FIX)
// ===================================================================
subprojects {
    // FIX: Maksa versi androidx.core agar AAPT nggak nyari lStar yang salah
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
        }
    }

    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val android = extensions.getByName("android")
            
            try {
                // 1. Paksa Compile SDK & Build Tools ke 35
                val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Any::class.java)
                setCompileSdkVersion.invoke(android, 35)
                
                val setBuildToolsVersion = android.javaClass.getMethod("setBuildToolsVersion", String::class.java)
                setBuildToolsVersion.invoke(android, "35.0.0")

                // 2. Paksa Target SDK ke 35
                val getDefaultConfig = android.javaClass.getMethod("getDefaultConfig")
                val defaultConfig = getDefaultConfig.invoke(android)
                val setTargetSdk = defaultConfig.javaClass.getMethod("setTargetSdk", Integer::class.java)
                setTargetSdk.invoke(defaultConfig, 35)

                // 3. NAMESPACE & MANIFEST STRIPPER (Isar Fix)
                val methods = android.javaClass.methods
                val getNamespace = methods.find { it.name == "getNamespace" }
                val setNamespace = methods.find { it.name == "setNamespace" && it.parameterCount == 1 }

                if (getNamespace?.invoke(android) == null && setNamespace != null) {
                    val generatedNamespace = "com.tideview.${project.name.replace("-", "_").replace(".", "_")}"
                    setNamespace.invoke(android, generatedNamespace)
                    
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        var content = manifestFile.readText()
                        if (content.contains("package=")) {
                            content = content.replace(Regex("""package="[^"]*""""), "")
                            manifestFile.writeText(content)
                        }
                    }
                }
            } catch (e: Exception) {
                // Abaikan jika bukan module android
            }
        }
    }
}
// ===================================================================

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}  