
plugins {
   id("com.github.node-gradle.node") version "3.2.1"
}

import java.lang.module.ModuleDescriptor.Version
import com.github.gradle.node.yarn.task.YarnTask

apply(plugin = "java")

val globalEnv = System.getenv().toMutableMap()
val pathSep = System.getProperty("path.separator")

fun getEnvDirOrRelative(envVar: String, relDir: String) : File {
    var d = globalEnv.getOrDefault(envVar, "")
    if (d == "") {
        d = "${project.rootDir}/${relDir}"
    }

    var f = file(d)
    if (!f.exists()){
         throw RuntimeException(
            "Convert directory '${f}' does not exist relative.")
    }
    return f
}

project.buildDir = file("${project.rootDir}/build")

val convertDir = getEnvDirOrRelative("TECHMD_CONVERT_DIR", "tools/convert")
val toolsDir = getEnvDirOrRelative("TECHMD_TOOLS_DIR", "tools")
val useSystemNode = globalEnv.getOrDefault("TECHMD_USE_SYSTEM_NODE", "false") == "true"

if (!toolsDir.exists()) {
    throw RuntimeException("Tools dir 'tools' not available.")
}
if (!convertDir.exists()) {
    throw RuntimeException("Convert dir 'tools/convert' not available.")
}

// Import all functions
@Suppress("unchecked_cast", "nothing_to_inline")
inline fun <T> uncheckedCast(target: Any?): T = target as T
apply(from = "${toolsDir}/gradle/runCommand.gradle.kts")
val checkCmd = project.extensions.getByName("checkCommand")
                as (Array<String>, String?) -> Void

// RunCommand function.
fun List<String>.runCommand(
    workingDir: File = File(".")
): String? = runCatching {
    ProcessBuilder(this)
        .directory(workingDir)
        .start().also { it.waitFor() }
        .inputStream.bufferedReader().readText()
}.getOrNull()

fun  MutableMap<String, String>.addExecutableDirToPath(exe: String) {
    if(this["PATH"] != null && this["PATH"]!!.contains(exe)) {
        return
    }
    else if(exe.contains("/") || exe.contains("\\")) {
        this["PATH"] = file(exe).getParent() + if(this["PATH"] != null ) pathSep + this["PATH"] else ""
    }
}

node {
    download.set(!useSystemNode)
    version.set("17.7.1")
    npmInstallCommand.set("install")
    workDir.set(file("${project.buildDir}/node/nodejs"))
    npmWorkDir.set(file("${project.buildDir}/node/npm"))
    yarnWorkDir.set(file("${project.buildDir}/node/yarn"))
    nodeProjectDir.set(file("${toolsDir}"))
}

val binDir = file("${project.buildDir}/node_modules/.bin")

val pandocVersionMin = Version.parse("2.14")
val pandocExe = File(project.properties.getOrDefault("pandoc", "pandoc") as String)
val pythonExe = File(project.properties.getOrDefault("python", "python") as String)

val pythonPaths : Array<File> = arrayOf(file("${convertDir}/filters"))
val luaPaths : Array<File> = arrayOf(file("${convertDir}/filters"))

val mainFileMarkdown = file("${project.rootDir}/Content.md")
val outputFileHTML = file("${project.buildDir}/Content.html")
val outputFileJira = file("${project.buildDir}/Content.jira")
val outputFilePDF = file("${project.buildDir}/Content.pdf")

fun checkPandocInstall(pandocExe: File){
    var pandocAvailable = false
    var version : String? = listOf<String>(pandocExe.getPath(), "--version").runCommand()

    if(version != null){ 
        var m = Regex("""pandoc\s*(.*)""").find(version)
        if(m != null) {
            var v = Version.parse(m.groupValues[1])
            println("Pandoc version: ${v}")
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

val initBuild by tasks.register<YarnTask>("initBuild") {
    group = "TechnicalMarkdown"
    description = "Setups node/yarn and modules."
    args.set(listOf("install", "--modules-folder", "${project.buildDir}/node_modules"))

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
        checkCmd(arrayOf(pythonExe.getPath(), "--version"), null)
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

    val lessMainFile = fileTree("${convertDir}/css/src/"){ include("main.less") }.getFiles().elementAt(0)
    val lessFiles = fileTree("${convertDir}/css/src/"){ include("*.less") }.getFiles()
    val cssFile = file("${convertDir}/css/main.css")

    inputs.files(lessMainFile, lessFiles)
    outputs.file(cssFile)

    val lessCompiler =  file("$binDir/lessc")

    doFirst({
        println("Executing Less Compilation: '$lessMainFile' -> '$cssFile'")
    })

    executable(lessCompiler)
    args("--include-path=${convertDir}/css/src", lessMainFile, cssFile)

    workingDir(project.rootDir)
}

val buildCSS by tasks.register<Copy>("copyLess") {
    dependsOn(compileLess)
    from("${convertDir}/css/main.css")
    into("${project.buildDir}/css")
}

val copyAssets by tasks.register<Copy>("copyAssets") {
    from("${project.rootDir}/files")
    into("${project.buildDir}/files")
}

fun getFileSizeMb(file: File) : Long {
    return file.length() / 1024*1024
}

data class PandocSettings(
    val pandocExe: File,
    val dataDir: File,
    val resourceDir: File,
    val workingDir: File,
    val env: Map<String, String>)


fun createPandocSettings(): PandocSettings {
        var env = globalEnv.toMutableMap()
        //env.addExecutableDirToPath(pythonExe)
        //env.addExecutableDirToPath(pandocExe)
        env["TECHMD_ROOT_DIR"] = "${project.rootDir}"
        env["PYTHON_PATH"] = env.getOrDefault("PYTHON_PATH", "") + pathSep + pythonPaths.joinToString(separator = pathSep)

        return PandocSettings(pandocExe, convertDir, convertDir, project.rootDir, env)
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

    fun makePandocArgs(exportType: String, 
                       verbose: Boolean, 
                       failIfWarning: Boolean = true, 
                       dataDir: File,
                       resourceDir: File) : Array<String> {
    return arrayOf(
            if(failIfWarning) "--fail-if-warnings" else null,
            if(verbose) "--verbose" else null,
            "--data-dir=${dataDir.getPath()}",
            "--resource-path=${resourceDir.getPath()}",
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
        markdownFiles.convention(project.fileTree("${project.rootDir}/chapters/"){include("**/*.md", "**/*.html", "**/*.tex")})
        assetFiles.convention(project.fileTree("${project.rootDir}/files/"){ include("**/*") })
        literatureFiles.convention(project.fileTree("${project.rootDir}/literature/"){ include("**/*") })
        convertFiles.convention(project.fileTree("${settings.dataDir}/"){ include("**/*") })

        inputs.files(inputFile, markdownFiles, assetFiles, convertFiles, literatureFiles)
        outputs.file(outputFile)

        executable(settings.pandocExe)

        args(*makePandocArgs(exportType.get(), 
                             verbose.get(), 
                             failIfWarning.get(), 
                             settings.dataDir, 
                             settings.resourceDir))

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
    description = "Convert Tables"
    dependsOn(initBuild, defineEnvironment)

    inputs.files("${convertDir}/scripts/convert-tables.py",
                 fileTree("${project.rootDir}/chapters/tables"){include("**/*.html", "**/*.md")})
    outputs.files(fileTree("${project.rootDir}/chapters/tables-tex"){include("**/*.tex")})

    executable(pythonExe)
    args(file("${convertDir}/scripts/convert-tables.py"),
         "--root-dir",
         "${project.rootDir}",
         "--data-dir", 
         "${convertDir}",
         "--config",
        "${project.rootDir}/includes/convert-tables.json",
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
    dependsOn(initBuild, defineEnvironment, convertTables, buildCSS, copyAssets)
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
             "--config", file("${project.rootDir}/tools/gradle/browser-sync-config.js"),
             "--files", outputFileHTML,
             "--files", "**/*.css",
             "--startPath", "build",
             "--index", outputFileHTML.getName())

        workingDir(project.rootDir)
}

val packageHTML = tasks.register<Copy>("package-html") {
    dependsOn(buildHTML)
    from("${project.buildDir}")
    include("files/**", "css/**", "Content.html")
    exclude("files/generated/**")
    into("${project.rootDir}/docs/html-package")
}
