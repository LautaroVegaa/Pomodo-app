// Root build.gradle.kts — NO aplicar plugins aquí (solo declararlos)
plugins {
    // Declarados con apply false para evitar que se apliquen en el root
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    // Declaraciones de Flutter en false para evitar tareas duplicadas
    id("dev.flutter.flutter-gradle-plugin") apply false
    id("dev.flutter.flutter-plugin-loader") apply false
}

// Si tu proyecto ya define versiones en settings.gradle, no pongas versiones acá.
// No hace falta nada más en este archivo.
