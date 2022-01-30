import java.lang.module.ModuleDescriptor.Version

plugins {
  //id "com.liferay.yarn" version "7.2.6"
  id("org.siouan.frontend-jdk11") version "5.1.0"
}

@Suppress("unchecked_cast", "nothing_to_inline")
inline fun <T> uncheckedCast(target: Any?): T = target as T

apply(plugin = "java")
apply(from = "gradle/runCommand.gradle.kts")
val checkCmd = project.extensions.getByName("checkCommand")
                as (Array<String>, String?) -> Void

project.buildDir = file("${project.rootDir}/build")

// Node/Yarn frontend
frontend {
    nodeVersion.set("10.19.0")
    nodeInstallDirectory.set(file("${project.buildDir}/node"))
    yarnEnabled.set(true)
    yarnVersion.set("1.22.10")
    packageJsonDirectory.set(file("${project.rootDir}/tools"))
    installScript.set("install --modules-folder='${project.buildDir}/node_modules'")
    yarnInstallDirectory.set(file("${project.buildDir}/yarn"))
}

// Tweak to only run installFront once
tasks.named("installFrontend") {
    outputs.upToDateWhen({true})
}

val globalEnv = System.getenv()
val pathSep = System.getProperty("path.separator")
val binDir = file("${project.buildDir}/node_modules/.bin")

val pandocVersionMin = Version.parse("2.14")
val pandocExe: String = project.properties.getOrDefault("pandoc", "pandoc") as String
val pythonExe: String = project.properties.getOrDefault("python", "python") as String

val pythonPaths : Array<File> = arrayOf(file("${project.rootDir}/convert/pandoc/filters"))
val luaPaths : Array<File> = arrayOf(file("${project.rootDir}/convert/pandoc/filters"))

val mainFileMarkdown = file("${project.rootDir}/Content.md")
val outputFileHTML = file("${project.rootDir}/Content.html")
val outputFileJira = file("${project.rootDir}/Content.jira")
val outputFilePDF = file("${project.rootDir}/Content.pdf")

fun  MutableMap<String, String>.addExecutableDirToPath(exe: String) {
    if(exe.contains("/") || exe.contains("\\")) {
        this["PATH"] = file(exe).getParent() + if(this["PATH"] != null ) pathSep + this["PATH"] else ""
    }
}

fun List<String>.runCommand(
    workingDir: File = File(".")
): String? = runCatching {
    ProcessBuilder(this)
        .directory(workingDir)
        .start().also { it.waitFor() }
        .inputStream.bufferedReader().readText()
}.getOrNull()


fun checkPandocInstall(pandocExe: String){
    var pandocAvailable = false
    var version : String? = listOf<String>(pandocExe, "--version").runCommand()

    if(version != null){ 
        var m = Regex("""pandoc\s*(.*)""").find(version)
        if(m != null) {
            var v = Version.parse(m.groupValues[1])
            if(v.compareTo(pandocVersionMin) >= 0){
                pandocAvailable = true
            }
        }
    }

    if(!pandocAvailable) {
        throw RuntimeException(
            "Pandoc version should be >= ${pandocVersionMin.toString()}")
    } else {
        logger.quiet("Pandoc exectuable found.")
    }
}


val initBuild by tasks.register<Task>("initBuild") {
    group = "TechnicalMarkdown"
    description = "Setups node/yarn and modules."
    dependsOn("installFrontend")

    outputs.upToDateWhen({true})
}

val defineEnvironment by tasks.register<Task>("defineEnvironment") {
    outputs.upToDateWhen({true})

    doLast({
        
        pythonPaths.forEach {
            if(!it.exists()) {
                throw RuntimeException(
                    "Python path '${it.getAbsolutePath()}' does not exist.")
            }
        }

        luaPaths.forEach {
            if(!it.exists()) {
                throw RuntimeException(
                    "Lua path '$it' does not exist.")
            }
        }

        logger.quiet("Checking executables ...")
        checkCmd(arrayOf(pythonExe, "--version"), null)
        checkPandocInstall(pandocExe)

        logger.info("Pandoc Exe: $pandocExe")
        logger.info("Python Exe: $pythonExe")
        logger.info("Python Path: ${pythonPaths.contentToString()}")
        logger.info("Lua Path: ${luaPaths.contentToString()}")

    })
}

val compileLess by tasks.register<Exec>("compileLess") {

    group = "TechnicalMarkdown"
    description = "Compile Less"
    dependsOn(initBuild, defineEnvironment)

    val lessMainFile = fileTree("${project.rootDir}/convert/css/src/"){ include("main.less") }.getFiles().elementAt(0)
    val lessFiles = fileTree("${project.rootDir}/convert/css/src/"){ include("*.less") }.getFiles()
    val cssFile = file("${project.rootDir}/convert/css/main.css")

    inputs.files(lessMainFile, lessFiles)
    outputs.file(cssFile)

    val lessCompiler =  file("$binDir/lessc")

    doFirst({
        println("Executing Less Compilation: '$lessMainFile' -> '$cssFile'")
    })

    executable(lessCompiler)
    args("--include-path=convert/css/src", lessMainFile, cssFile)

    workingDir(project.rootDir)
}

fun getFileSizeMb(file: File) : Long {
    return file.length() / 1024*1024
}

data class PandocSettings(
    val pandocExe: String,
    val workingDir: File,
    val env: Map<String, String>)


fun createPandocSettings(): PandocSettings {
        var env = globalEnv.toMutableMap()
        //logger.quiet("First PATH: '${env["PATH"]}")
        //env.addExecutableDirToPath(pythonExe)
        //env.addExecutableDirToPath(pandocExe)
        env["ROOT_DIR"] = "${project.rootDir}"
        env["PYTHON_PATH"] = env.getOrDefault("PYTHON_PATH", "") + pathSep + pythonPaths.joinToString(separator = pathSep)
        env["LUA_PATH"] = env.getOrDefault("LUA_PATH", "") + pathSep + luaPaths.flatMap({v -> listOf("$v/?", "$v/?.lua") }).joinToString(separator=";")

        return PandocSettings(pandocExe, project.rootDir, env)
}

val pandocSettings = createPandocSettings()

// A task that displays a greeting
abstract class PandocTask @Inject constructor() : Exec() {

    @get:Optional
    @get:Input
    abstract val additionalArgs: Property<Array<String>>
    @get:Input
    abstract val exportType: Property<String>
    @get:Input
    abstract val failIfWarning: Property<Boolean>
    @get:Input
    abstract val verbose: Property<Boolean>

    @get:InputFile
    abstract val inputFile: Property<File>

    @get:InputDirectory
    abstract val markdownFiles: Property<FileTree>
    @get:InputDirectory
    abstract val assetFiles: Property<FileTree>
    @get:InputDirectory
    abstract val literatureFiles: Property<FileTree>
    @get:InputDirectory
    abstract val convertFiles: Property<FileTree>

    @get:OutputFile
    abstract val outputFile: Property<File>

    fun makePandocArgs(exportType: String, verbose: Boolean, failIfWarning: Boolean = true) : Array<String> {
    return arrayOf(
            if(failIfWarning) "--fail-if-warnings" else null,
            if(verbose) "--verbose" else null,
            "--data-dir=convert/pandoc",
            "--defaults=pandoc-dirs.yaml",
            "--defaults=pandoc-general.yaml",
            "--defaults=pandoc-$exportType.yaml",
            "--defaults=pandoc-filters.yaml").filterNotNull().toTypedArray()
    }

    public fun setup(settings: PandocSettings, project: Project, desc: String) {
        group = "TechnicalMarkdown"
        description = "Pandoc Build: '$desc'"

        failIfWarning.convention(true)
        verbose.convention(false)
        additionalArgs.convention(arrayOf())
        markdownFiles.convention(project.fileTree("${project.rootDir}/chapters/"){include("**/*.md", "**/*.html")})
        assetFiles.convention(project.fileTree("${project.rootDir}/files/"){ include("**/*") })
        literatureFiles.convention(project.fileTree("${project.rootDir}/literature/"){ include("**/*") })
        convertFiles.convention(project.fileTree("${project.rootDir}/convert/"){ 
            include("pandoc/**/*")
            include("scripts/**/*")
            include("css/**/*.css")
        })

        inputs.files(inputFile, markdownFiles, assetFiles, convertFiles, literatureFiles)
        outputs.file(outputFile)

        executable(settings.pandocExe)

        args(*makePandocArgs(exportType.get(), verbose.get(), failIfWarning.get()))
        if(additionalArgs.isPresent()){
            args(*additionalArgs.get())
        }
        args("-o",
             outputFile.get(),
             inputFile.get())


        environment(settings.env)
        workingDir(project.rootDir)

        doFirst({
            logger.quiet("Executing Pandoc: '$desc'")
            logger.quiet("PATH: '${settings.env["PATH"]}")
            logger.quiet("PYTHON_PATH: '${settings.env["PYTHON_PATH"]}'")
            logger.quiet("LUA_PATH: '${settings.env["LUA_PATH"]}'")
        })

        doLast({
            logger.quiet(
                " ==============================================\n"+
                " =  Pandoc Build: '$desc' successful!\n"+
                " =============================================="
            )
            logger.quiet("Outfile: '${outputFile.get()}', size: ${outputFile.get().length() / (1024.0*1024.0)} mb");
        })
    }
}

val convertTables = tasks.create<Exec>("convert-tables") {
    group = "TechnicalMarkdown"
    description = "Converte Tables"
    dependsOn(initBuild, defineEnvironment)

    inputs.files("convert/scripts/convert-tables.py",
                 fileTree("${project.rootDir}/chapters/tables"){include("**/*.html")})
    outputs.files(fileTree("${project.rootDir}/chapters/tables-tex"){include("**/*.tex")})

    executable(pythonExe)
    args(file("${project.rootDir}/convert/scripts/convert-tables.py"),
         "--config",
         file("${project.rootDir}/convert/scripts/tables.json"),
         "--parallel")

    environment(pandocSettings.env)
    workingDir("${project.rootDir}")
}

val transformMath = project.task<Copy>("transform-math") {
    group = "TechnicalMarkdown"
    description = "Transform Math"
    dependsOn(initBuild, defineEnvironment)

    from("${project.rootDir}/includes/Math.html")
    rename("(.*)\\.html", "$1.tex")
    into("${project.rootDir}/includes/generated")

    // Take only `\command` lines.
    filter { line: String ->
        if(line.startsWith("\\")) {
            line
        } else {
            null
        }
    }
}

val buildHTML = tasks.register<PandocTask>("build-html") {
    dependsOn(initBuild, defineEnvironment, convertTables, compileLess)
    inputFile.set(mainFileMarkdown)
    exportType.set("html")
    verbose.set(true)
    additionalArgs.set(arrayOf("--toc"))
    outputFile.set(outputFileHTML)
    this.setup(pandocSettings, project, "md -> html")
}

val buildPDF = tasks.register<PandocTask>("build-pdf-tex",) {
    dependsOn(initBuild, defineEnvironment, convertTables, transformMath)
    inputFile.set(mainFileMarkdown)
    exportType.set("latex")
    verbose.set(false)
    outputFile.set(outputFilePDF)
    this.setup(pandocSettings, project, "md -> latex -> pdf")
}

val buildJira = tasks.register<PandocTask>("build-jira",) {
    dependsOn(initBuild, defineEnvironment, convertTables, transformMath)
    inputFile.set(mainFileMarkdown)
    exportType.set("jira")
    verbose.set(false)
    failIfWarning.set(false)
    outputFile.set(outputFileJira)
    this.setup(pandocSettings, project, "md -> jira")
}


val viewHTML = tasks.register<Exec>("view-html") {

        group = "TechnicalMarkdown"
        description = "View HTML Output: '$name'"
        dependsOn(initBuild)

        val browserSync =  file("$binDir/browser-sync")

        executable(browserSync)
        args("start",
             "--server",
             "--config", file("${project.rootDir}/gradle/browser-sync-config.js"),
             "--files", outputFileHTML,
             "--files", "**/*.css",
             "--index", outputFileHTML.getName())

        workingDir(project.rootDir)
}

