/*
 * Copyright (c) 2014 Goran Ehrsson.
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


package grails.plugins.crm.content

import javax.servlet.http.HttpServletResponse

/**
 * Photo Gallery.
 */
class CrmGalleryController {

    def crmCoreService
    def crmContentService

    def index(Long t, String domain, Long id) {
        def reference
        try {
            reference = crmCoreService.getReference("$domain@$id")
        } catch (Exception e) {
            log.error("Failed to load domain instance [$domain@$id]", e)
            response.sendError(HttpServletResponse.SC_BAD_REQUEST)
            return
        }
        if (reference) {
            if (reference.hasProperty('tenantId') && (reference.tenantId != t)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN)
                return
            }
            def photos = getPhotos(reference)
            if (photos) {
                def template = grailsApplication.config.crm.content.gallery.template ?: 'web/gallery.html'
                def parser = grailsApplication.config.crm.content.gallery.parser ?: ''
                return [tenant: t, bean: reference, result: photos.sort { it.name }, template: template, parser: parser]
            }
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND)
    }

    private List<CrmResourceRef> getPhotos(reference) {
        def filter = crmContentService.getDefaultImageFilter()
        def photos = []
        for (name in filter) {
            def tmp = crmContentService.findResourcesByReference(reference, [name: '*' + name, status: CrmResourceRef.STATUS_SHARED])
            if (tmp) {
                photos.addAll(tmp)
            }
        }
        return photos
    }
}
