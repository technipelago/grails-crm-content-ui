import grails.util.Environment

class BootStrap {

    def grailsApplication
    def crmContentService

    def init = { servletContext ->

        if (Environment.current == Environment.DEVELOPMENT || Environment.current == Environment.TEST) {
            def templates
            if (grailsApplication.warDeployed) {
                templates = grailsApplication.mainContext.getResources("**/WEB-INF/templates/text/**/*.*")?.toList().collect { it.file }
            } else {
                templates = new File("./src/templates/text/sv").listFiles()
            }
            if (templates) {
                def folder = crmContentService.createFolder(null, "templates", "Templates", "", "")
                for (file in templates.findAll{!it.hidden}) {
                    crmContentService.createResource(file, null, folder, [status: "shared"])
                }
            }
        }
    }

    def destroy = {

    }
}