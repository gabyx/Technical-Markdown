
import java.lang.ProcessBuilder.Redirect

var checkCommand = { cmd: Array<String>, workingDir: File? ->

    val process = ProcessBuilder(*cmd)
            .directory(workingDir)
            .start()

    val exitCode = process.waitFor()
    
    val stderr = String(process.getErrorStream().readAllBytes())
    val stdout = String(process.getInputStream().readAllBytes())
    if (exitCode != 0){
        throw RuntimeException(
        "Command '$cmd' failed!\n\tOutput: '${stdout}'\n\tError: '${stderr}'")
    }

    stdout
}

project.extensions.add("checkCommand", checkCommand)
