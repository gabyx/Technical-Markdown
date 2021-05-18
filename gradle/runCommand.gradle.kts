
import java.lang.ProcessBuilder.Redirect

var checkCommand = { cmd: Array<String>, workingDir: File? ->

    val process = ProcessBuilder(*cmd)
            .directory(workingDir)
            .start()

    val exitCode = process.waitFor()
    val stdout = String(process.getInputStream().readAllBytes())
    val stderr = String(process.getErrorStream().readAllBytes())

    if (exitCode != 0){
        throw RuntimeException(
        "Command '$cmd' failed!\n\tOutput: '${stdout}'\n\tError: '${stderr}'")
    }
}

project.extensions.add("checkCommand", checkCommand)