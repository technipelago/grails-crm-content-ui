/*
 * Copyright (c) 2015 Goran Ehrsson.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import grails.plugins.crm.content.CrmResourceRef

class CrmContentUiGrailsPlugin {
    def groupId = ""
    // TODO When version number is updated you MUST also update version number in web-app/js/crm-ckeditor-config.js
    def version = "2.4.5"
    def grailsVersion = "2.4 > *"
    def dependsOn = [:]
    def loadAfter = ['crmContent']
    def pluginExcludes = [
            "src/groovy/grails/plugins/crm/content/CrmContentUiTestSecurityDelegate.groovy",
            "grails-app/views/crmContent/test.gsp",
            "grails-app/views/error.gsp"
    ]
    def title = "Content Management User Interface for GR8 CRM"
    def author = "Goran Ehrsson"
    def authorEmail = "goran@technipelago.se"
    def description = '''\
This plugin provide user interface for administration of content in GR8 CRM.
Content can be any type of media like plain text, Microsoft Word, PDF, and images.
Content can be stored in folders or attached to any type of domain instance.
This plugin depends on the base plugin crm-content that provide low level content services.
'''
    def documentation = "http://gr8crm.github.io/plugins/crm-content-ui/"
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
                user "crmFolder,crmContent,crmGallery:*", "*:attachDocument,deleteDocument"
                admin "crmFolder,crmContent,crmGallery:*"
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
