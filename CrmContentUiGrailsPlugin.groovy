import grails.plugins.crm.content.CrmResourceRef

class CrmContentUiGrailsPlugin {
    def groupId = "grails.crm"
    def version = "1.2.12"
    def grailsVersion = "2.2 > *"
    def dependsOn = [:]
    def loadAfter = ['crmContent']
    def pluginExcludes = [
            "grails-app/views/crmContent/test.gsp",
            "grails-app/views/error.gsp"
    ]
    def title = "Content Admin User Interface for GR8 CRM"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
This plugin provide user interface for administration of content in GR8 CRM.
Content can be any type of media like plain text, Microsoft Word, PDF, and images.
Content can be stored in folders or attached to any type of domain instance.
This plugin depends on the base plugin crm-content that provide low level content services.
'''
    def documentation = "http://grails.org/plugin/crm-content-ui"
    def license = "APACHE"
    def organization = [name: "Technipelago AB", url: "http://www.technipelago.se/"]
    def issueManagement = [system: "github", url: "https://github.com/technipelago/grails-crm-content-ui/issues"]
    def scm = [url: "https://github.com/technipelago/grails-crm-content-ui"]

    def features = {
        crmContent {
            description "Content Management"
            link controller: 'crmFolder'
            permissions {
                guest "crmFolder:index,list,show,clearQuery", "crmContent:show,preview,open"
                partner "crmFolder:index,list,show,clearQuery", "crmContent:show,preview,open"
                user "crmFolder,crmContent:*", "*:attachDocument,deleteDocument"
                admin "crmFolder,crmContent:*"
            }
            statistics { tenant ->
                def total = CrmResourceRef.countByTenantId(tenant)
                def usage // TODO come up with better usage calculation!
                if (total == 0) {
                    usage = 'none'
                } else if (total < 20) {
                    usage = 'low'
                } else if (total < 500) {
                    usage = 'medium'
                } else {
                    usage = 'high'
                }
                return [objects: total, usage: usage]
            }
        }
    }
}
