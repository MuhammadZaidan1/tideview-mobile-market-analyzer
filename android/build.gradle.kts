allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Balikin rute folder build biar Flutter tau nyari APK-nya di mana
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Fix Namespace Otomatis (Ini yang udah bikin error lu ilang)
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            val namespace = try {
                android.javaClass.getMethod("getNamespace").invoke(android)
            } catch (e: Exception) { null }

            if (namespace == null) {
                try {
                    android.javaClass.getMethod("setNamespace", String::class.java)
                        .invoke(android, "com.isar.${project.name.replace("-", "_")}")
                } catch (e: Exception) {
                    // Abaikan jika bukan module android
                }
            }

            // FIX (Fase 4): "android:attr/lStar not found" khusus di
            // isar_flutter_libs -- paksa compileSdk module ini samain sama
            // compileSdk app (36), biar resource-nya ke-link konsisten.
            try {
                android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(android, 36)
            } catch (e: Exception) {
                try {
                    android.javaClass.getMethod("setCompileSdkVersion", String::class.java)
                        .invoke(android, "android-36")
                } catch (e2: Exception) {
                    // Abaikan kalau dua-duanya gak cocok sama versi AGP yang dipakai
                }
            }
        }
    }

    // FIX (Fase 4): "android:attr/lStar not found" pas build release --
    // paksa satu versi androidx.core konsisten di semua module (termasuk
    // isar_flutter_libs), biar resource-nya gak nabrak pas verifyReleaseResources.
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.13.1")
            force("androidx.core:core:1.13.1")
        }
    }
}

// 3. Tambahan penting biar urutan build-nya bener
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}