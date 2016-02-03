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

import grails.converters.JSON
import grails.transaction.Transactional
import org.springframework.web.context.request.RequestContextHolder

import javax.servlet.http.HttpServletResponse
import grails.plugins.crm.core.TenantUtils

class CrmContentController {

    static allowedMethods = [show: 'GET', open: 'GET', preview: 'GET', edit: ['GET', 'POST'], delete: ['POST', 'DELETE']]

    static WHITE_LIST = [
            'name',
            'title',
            'description'
    ]

    private static final int DEFAULT_CACHE_SECONDS = 60

    def grailsApplication
    def crmCoreService
    def crmSecurityService
    def crmContentService
    def userTagService

    @Transactional
    def create(String ref, String referer, String contentType, String name, String text) {
        def reference = crmCoreService.getReference(ref)
        def css = grailsApplication.config.crm.content.editor.css
        switch (request.method) {
            case "GET":
                [contentType: contentType, ref: ref, reference: reference, referer: referer, css: css,
                 text       : 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.']
                break
            case "POST":
                if (!name) {
                    name = "unknown"
                }
                // If we store the document in a shared folder, the document gets status = shared.
                def status = (reference instanceof CrmResourceFolder) && reference.shared ? 'shared' : 'published'
                crmContentService.createResource(text, name, reference, [contentType: contentType, status: status])
                flash.success = message(code: 'crmResourceRef.created.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), name])
                redirect uri: referer - request.contextPath
                break
        }
    }

    @Transactional
    def edit() {
        def crmResourceRef = CrmResourceRef.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmResourceRef) {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), params.id])
            redirect controller: 'crmFolder', action: 'index'
            return
        }
        def reference = crmResourceRef.reference
        def folder = (reference instanceof CrmResourceFolder) ? reference : null
        def folders = CrmResourceFolder.findAllByTenantId(TenantUtils.tenant).sort { it.path.join('/') }
        def css = grailsApplication.config.crm.content.editor.css
        switch (request.method) {
            case 'GET':
                return [crmResourceRef   : crmResourceRef, metadata: crmContentService.getMetadata(crmResourceRef.resource),
                        crmResourceFolder: folder, folders: folders, css: css]
            case 'POST':
                if (params.version) {
                    def version = params.version.toLong()
                    if (crmResourceRef.version > version) {
                        crmResourceRef.errors.rejectValue('version', 'crmResourceRef.optimistic.locking.failure',
                                [message(code: 'crmResourceRef.label', default: 'Content')] as Object[],
                                "Another user has updated this content while you were editing")
                        render view: 'edit', model: [crmResourceRef   : crmResourceRef, metadata: crmContentService.getMetadata(crmResourceRef.resource),
                                                     crmResourceFolder: folder, folders: folders, css: css]
                        return
                    }
                }
                // Bind trivial properties.
                bindData(crmResourceRef, params, [include: WHITE_LIST])

                // Bind folder.
                if (params.ref) {
                    reference = crmCoreService.getReference(params.ref)
                    if ((reference instanceof CrmResourceFolder) && (reference.tenantId == crmResourceRef.tenantId)) {
                        crmResourceRef.setReference(reference)
                    }
                }
                // Bind status.
                if (params.status) {
                    crmResourceRef.statusText = params.status
                }

                def metadata = crmResourceRef.metadata
                def contentType = params.contentType
                if (contentType) {
                    def update = false
                    def inputStream
                    if (contentType != metadata.contentType) {
                        update = true
                    }
                    if (contentType.startsWith('text')) {
                        update = true
                        if (params.text) {
                            inputStream = new ByteArrayInputStream(params.text.getBytes('UTF-8'))
                        } else {
                            inputStream = new ByteArrayInputStream(''.getBytes())
                        }
                    }
                    // TODO: Should it be possible to change contentType without re-writing content???
                    // What if different content types has different providers?
                    // A safer solution is to always create a new resource (and copy bytes) if content type changes.
                    if (update) {
                        crmContentService.updateResource(crmResourceRef, inputStream, contentType)
                    }
                }

                if (!crmResourceRef.save(flush: true)) {
                    render view: 'edit', model: [crmResourceRef   : crmResourceRef, metadata: crmContentService.getMetadata(crmResourceRef.resource),
                                                 crmResourceFolder: folder, folders: folders, css: css]
                    return
                }

                def existing = crmResourceRef.getTagValue()
                def tags = params.tags
                if (tags) {
                    tags = tags.split(',').findAll { it.trim() } // Convert to list with non-empty elements
                    // Removed tags
                    for (t in existing) {
                        if (!tags.contains(t)) {
                            crmResourceRef.deleteTagValue(t)
                        }
                    }
                    for (t in tags) {
                        if (!existing.contains(t)) {
                            crmResourceRef.setTagValue(t)
                        }
                    }
                } else if (existing) {
                    // Delete all existing tags
                    for (t in existing) {
                        crmResourceRef.deleteTagValue(t)
                    }
                }

                def fileItem = request.getFile("file")
                if (fileItem && !fileItem.isEmpty()) {
                    try {
                        crmContentService.updateResource(crmResourceRef, fileItem.inputStream, fileItem.contentType)
                    } catch (Exception e) {
                        log.error("Failed to upload file: ${fileItem.originalFilename}", e)
                        flash.error = message(code: "crmContent.upload.error", args: [fileItem.originalFilename], default: "Failed to upload file {0}")
                    }
                }

                if (!flash.error) {
                    def username = crmSecurityService.currentUser?.username
                    def updateEvent = [tenant: crmResourceRef.tenantId, id: crmResourceRef.id, user: username, name: crmResourceRef.name]
                    event(for: "crmResourceRef", topic: "updated", data: updateEvent)
                    flash.success = message(code: 'crmResourceRef.updated.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), crmResourceRef.toString()])
                }
                if (params.stay) {
                    redirect action: 'edit', id: crmResourceRef.id
                } else if (params.referer) {
                    redirect uri: params.referer - request.contextPath
                } else {
                    redirect action: 'show', id: crmResourceRef.id
                }
                break
        }
    }

    def show(Long id) {
        def crmResourceRef = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmResourceRef) {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceRef.label', default: 'Folder'), id])
            redirect(controller: "crmFolder", action: "index")
            return
        }
        def reference = crmResourceRef.reference
        def folder = (reference instanceof CrmResourceFolder) ? reference : null
        def childDocuments = crmContentService.findResourcesByReference(crmResourceRef)
        def childReference = crmCoreService.getReferenceIdentifier(crmResourceRef)
        def css = grailsApplication.config.crm.content.editor.css
        [crmResourceRef: crmResourceRef, crmResourceFolder: folder, children: childDocuments, childReference: childReference,
         metadata      : crmResourceRef.metadata, css: css]
    }

    @Transactional
    def delete(Long id) {
        def ref = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
        def parent
        if (ref) {
            def tombstone = ref.toString()
            parent = ref.reference
            crmContentService.deleteReference(ref)
            flash.warning = message(code: 'crmResourceRef.deleted.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), tombstone])
        } else {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), id])
        }
        if (params.referer) {
            redirect(url: params.referer - request.contextPath)
        } else {
            if (parent instanceof CrmResourceFolder) {
                redirect(controller: "crmFolder", action: "show", id: parent.id)
            } else {
                redirect(controller: "crmFolder", action: "index")
            }
        }
    }

    @Transactional
    def createFavorite() {
        def crmResourceRef = CrmResourceRef.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmResourceRef) {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), params.id])
            redirect controller: 'crmFolder', action: 'index'
            return
        }
        userTagService.tag(crmResourceRef, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)

        redirect(action: 'show', id: params.id)
    }

    @Transactional
    def deleteFavorite() {
        def crmResourceRef = CrmResourceRef.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmResourceRef) {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceRef.label', default: 'Content'), params.id])
            redirect controller: 'crmFolder', action: 'index'
            return
        }
        userTagService.untag(crmResourceRef, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)
        redirect(action: 'show', id: params.id)
    }

    def open(Long id) {
        def ref = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
        def status = HttpServletResponse.SC_NOT_FOUND

        if (!ref) {
            response.sendError(status)
            return
        }

        if (ref.shared) {
            redirect uri: crm.createResourceLink(resource: ref)
            return
        }

        try {
            def metadata = ref.metadata
            if (params.boolean('preview') && !isPreviewPossible(metadata.contentType)) {
                render(template: 'metadata', plugin: 'crm-content-ui', model: [metadata: metadata, crmResource: ref])
                return
            }
            def modified = ref.getLastModified()
            modified = modified - (modified % 1000) // Remove milliseconds.
            response.setContentType(metadata.contentType)
            response.setDateHeader("Last-Modified", modified)
            def requestETag = request.getHeader("ETag")
            if (requestETag && (requestETag == metadata.hash)) {
                if (log.isDebugEnabled()) {
                    log.debug "Not modified (ETag)"
                }
                response.setStatus(HttpServletResponse.SC_NOT_MODIFIED)
                response.outputStream.flush()
                return
            } else {
                def ms = request.getDateHeader("If-Modified-Since")
                if (modified <= ms) {
                    if (log.isDebugEnabled()) {
                        log.debug "Not modified (If-Modified-Since)"
                    }
                    response.setStatus(HttpServletResponse.SC_NOT_MODIFIED)
                    response.outputStream.flush()
                    return
                }
            }

            def len = metadata.bytes
            response.setContentLength(len.intValue())
            response.setHeader("ETag", metadata.hash)

            response.setContentLength(len.intValue())
            def encoding = ref.encoding
            if (encoding) {
                response.setCharacterEncoding(encoding)
            }
            response.setHeader("Content-disposition", "${params.disposition ?: 'inline'}; filename=${ref.name}; size=$len")
            cacheThis(response, DEFAULT_CACHE_SECONDS, ref.shared)
            def out = response.outputStream
            ref.writeTo(out)
            out.flush()
            status = HttpServletResponse.SC_OK

            def username = crmSecurityService.currentUser?.username
            event(for: 'crmContent', topic: 'opened', data: [tenant: ref.tenantId, id: ref.id, user: username, name: ref.name])
        } catch (SocketException e) {
            log.error("Client aborted while opening resource: ${ref.resource}: ${e.message}")
            status = HttpServletResponse.SC_NO_CONTENT
        } catch (Exception e) {
            log.error("Error while previewing resource: ${ref.resource}", e)
        }

        if (status == HttpServletResponse.SC_OK) {
            RequestContextHolder.currentRequestAttributes().setRenderView(false)
        } else {
            response.sendError(status)
        }
    }

    def preview() {
        params.preview = true
        forward(action: 'open')
    }

    private void cacheThis(HttpServletResponse response, int seconds, boolean shared = false) {
        response.setHeader("Pragma", "")
        response.setHeader("Cache-Control", "${shared ? 'public' : 'private,no-store'},max-age=$seconds")
        Calendar cal = Calendar.getInstance()
        cal.add(Calendar.SECOND, seconds)
        response.setDateHeader("Expires", cal.getTimeInMillis())
    }

    private boolean isPreviewPossible(String contentType) {
        (contentType == 'application/pdf') || contentType.startsWith('text') || contentType.startsWith('image')
    }

    @Transactional
    def attachDocument(String ref) {
        def instance = crmCoreService.getReference(ref)
        if (instance && crmCoreService.isDomainClass(instance)) {
            if (!instance.ident()) {
                log.error("User [${crmSecurityService.currentUser?.username}] tried to attach a file to a transient instance [${instance.tenantId}#$ref]")
                response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                return
            } else if (instance?.hasProperty('tenantId') && (instance.tenantId != TenantUtils.tenant)) {
                crmSecurityService.alert(request, "forbidden",
                        "User [${crmSecurityService.currentUser?.username}] tried to attach a file to [${instance.tenantId}#$ref] from tenant [${TenantUtils.tenant}]")
                response.sendError(HttpServletResponse.SC_FORBIDDEN)
                return
            }
        } else {
            log.error("User [${crmSecurityService.currentUser?.username}] tried to attach a file to an invalid domain reference [$ref]")
            response.sendError(HttpServletResponse.SC_BAD_REQUEST)
            return
        }

        if (request.xhr) {
            def files = []
            def fileItem = request.getFile("file")
            if (fileItem?.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST)
                return
            } else if (fileItem) {
                try {
                    def opts = [:]
                    if (params.status) {
                        opts.status = params.status
                    } else if ((instance instanceof CrmResourceFolder) && instance.shared) {
                        opts.status = 'shared'
                    } else if (instance instanceof CrmResourceRef) {
                        opts.status = instance.statusText // Same status as the parent/owner
                    } else {
                        opts.status = 'published'
                    }
                    def resource = crmContentService.createResource(fileItem.inputStream, fileItem.originalFilename, fileItem.size, fileItem.contentType, instance, opts)
                    for (tag in params.list('tags')) {
                        resource.setTagValue(tag)
                    }
                    files << [name        : resource.name,
                              size        : resource.metadata.bytes,
                              url         : createLink(controller: 'crmContent', action: 'open', id: resource.id),
                              thumbnailUrl: createLink(controller: 'crmContent', action: 'open', id: resource.id),
                              deleteUrl   : createLink(controller: 'crmContent', action: 'deleteAttachment', id: resource.id),
                              deleteType  : "DELETE"
                    ]
                } catch (Exception e) {
                    files << [name: fileItem.originalFilename, size: fileItem.size, error: e.message]
                }
            }
            def result = [files: files]
            render result as JSON
        } else {
            def resource
            def fileItem = request.getFile("file")
            if (fileItem?.isEmpty()) {
                flash.error = message(code: "crmContent.upload.empty", default: "You must select a file to upload")
            } else if (fileItem) {
                try {
                    def opts = [:]
                    if (params.status) {
                        opts.status = params.status
                    } else if ((instance instanceof CrmResourceFolder) && instance.shared) {
                        opts.status = 'shared'
                    } else if (instance instanceof CrmResourceRef) {
                        opts.status = instance.statusText // Same status as the parent/owner
                    } else {
                        opts.status = 'published'
                    }
                    resource = crmContentService.createResource(fileItem.inputStream, fileItem.originalFilename, fileItem.size, fileItem.contentType, instance, opts)
                    for (tag in params.list('tags')) {
                        resource.setTagValue(tag)
                    }
                    flash.success = message(code: "crmContent.upload.success", args: [resource.toString()], default: "Resource [{0}] uploaded")
                } catch (Exception e) {
                    log.error("Failed to upload file: ${fileItem.originalFilename}", e)
                    flash.error = message(code: "crmContent.upload.error", args: [fileItem.originalFilename], default: "Failed to upload file {0}")
                }
            }

            if (params.referer) {
                redirect(url: params.referer - request.contextPath)
            } else if (resource?.id) {
                redirect(action: "show", id: resource.id)
            } else {
                redirect(controller: "crmFolder", action: "index")
            }
        }
    }

    /**
     * Update properties on one or more CrmResourceRef instances.
     *
     * param (List) id instances to update
     * param (String) newStatus sets the status
     *
     * @return
     */
    @Transactional
    def updateAttachment() {
        def idList = params.list('id')
        def files = []

        CrmResourceRef.withTransaction {
            for (id in idList) {
                def res = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
                if (!res) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND)
                    return
                }
                if (params.newStatus) {
                    res.setStatusText(params.newStatus)
                }
                res.save()
                files << res.name
            }
        }

        if (request.xhr) {
            def result = [files: files]
            render result as JSON
        } else {
            flash.warning = message(code: 'crmResourceRef.updated.message',
                    args: [message(code: 'crmResourceRef.label', default: 'Content'), files.join(', ')],
                    default: "Resource [{1}] deleted")
            if (params.referer) {
                redirect(url: params.referer - request.contextPath)
            } else {
                redirect(controller: "crmFolder", action: "index")
            }
        }
    }

    @Transactional
    def deleteAttachment() {
        def idList = params.list('id')
        def files = []

        for (id in idList) {
            def res = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
            if (!res) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            def filename = res.name
            crmContentService.deleteReference(res)
            files << filename
        }

        if (request.xhr) {
            def result = [files: files.collect { [(it): true] }]
            render result as JSON
        } else {
            flash.warning = message(code: 'crmResourceRef.deleted.message',
                    args: [message(code: 'crmResourceRef.label', default: 'Content'), files.join(', ')],
                    default: "Resource [{1}] deleted")
            if (params.referer) {
                redirect(url: params.referer - request.contextPath)
            } else {
                redirect(controller: "crmFolder", action: "index")
            }
        }
    }

    def test() {
        [date: new Date().toString()]
    }


    def browse(String reference, String pattern) {
        def domainInstance
        def status = params.status
        if (reference) {
            domainInstance = crmCoreService.getReference(reference)
            if (!domainInstance) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            def tenant = TenantUtils.tenant
            if (domainInstance.hasProperty('tenantId') && domainInstance.tenantId != tenant) {
                log.warn "Forbidden access to $reference in tenant ${tenant} from ${request.remoteAddr}"
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            if (!status) {
                if (domainInstance instanceof CrmResourceRef) {
                    status = domainInstance.statusText
                }
            }
        }
        if (!status) {
            status = 'published'
        }
        def referer = "${request.forwardURI - request.contextPath}?status=${status}" +
                "&reference=${reference?.encodeAsIsoURL()}&pattern=${pattern ?: ''}&CKEditor=${params.CKEditor}" +
                "&CKEditorFuncNum=${params.CKEditorFuncNum}&langCode=${params.langCode}".toString()
        [reference: domainInstance, identifier: reference, pattern: pattern, referer: referer]
    }

    def tree(String reference, String pattern) {
        def domainInstance
        if (reference) {
            domainInstance = crmCoreService.getReference(reference)
            if (!domainInstance) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            def tenant = TenantUtils.tenant
            if (domainInstance.hasProperty('tenantId') && domainInstance.tenantId != tenant) {
                log.warn "Forbidden access to $reference in tenant ${tenant} from ${request.remoteAddr}"
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
        }

        def root = new Node(null, 'root', [type: 'folder'])

        if (domainInstance) {
            def node = new Node(root, domainInstance.toString(), [type: 'folder', id: reference, open: true])
        }
        def folders = crmContentService.list()
        addFolders(folders, root)
        [node: root, reference: domainInstance, identifier: reference]
    }

    private void addFolders(Collection folders, Node parent) {
        for (folder in folders) {
            def node = new Node(parent, folder.toString(), [type: 'folder', id: crmCoreService.getReferenceIdentifier(folder)])
            addFolders(folder.folders, node)
        }
    }

    def files(String reference, String pattern) {
        def tenant = TenantUtils.tenant
        def domainInstance
        if (reference) {
            domainInstance = crmCoreService.getReference(reference)
            if (!domainInstance) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            if (domainInstance.hasProperty('tenantId') && domainInstance.tenantId != tenant) {
                log.warn "Forbidden access to $reference in tenant ${tenant} from ${request.remoteAddr}"
                response.sendError(HttpServletResponse.SC_FORBIDDEN)
                return
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND)
            return
        }
        def filter
        if (pattern == 'image') {
            filter = { crmContentService.isImage(it) }
        } else if (pattern) {
            filter = { it.name ==~ pattern }
        } else {
            filter = { true }
        }
        def files = crmContentService.findResourcesByReference(domainInstance).findAll(filter).findAll {
            it.shared || (it.published && (it.tenantId == tenant))
        }
        def path = crmContentService.getAbsolutePath(domainInstance)
        if (path) {
            path = path.split('/')
        } else {
            path = [domainInstance.toString()]
        }
        def baseUrl = grailsApplication.config.crm.web.url ?: ''
        withFormat {
            html {
                def model = [reference: domainInstance, identifier: reference, base: baseUrl, path: path, files: files]
                if (pattern == 'image') {
                    render view: 'images', model: model
                } else {
                    render view: 'files', model: model
                }
            }
            json {
                def result = files.collect { ref ->
                    def md = ref.metadata
                    def result = [id         : ref.id, name: ref.name, title: ref.title, base: baseUrl, path: path, bytes: md.bytes, size: md.size,
                                  contentType: md.contentType, status: ref.statusText, modified: md.modified]
                    def ctrl
                    if (domainInstance instanceof CrmResourceFolder) {
                        if (!(domainInstance.sharedPath || ref.shared || (ref.published && (ref.tenantId == tenant)))) {
                            throw new RuntimeException("Can't link to a non-shared resource [$ref]")
                        }
                        ctrl = 'r'
                    } else {
                        if (!(ref.shared || (ref.published && (ref.tenantId == tenant)))) {
                            throw new RuntimeException("Can't link to a non-shared resource [$ref]")
                        }
                        ctrl = 's'
                    }
                    //def url = g.createLink(absolute: false, controller: ctrl).toString()
                    def url = baseUrl + '/' + ctrl
                    def absolutePath = crmContentService.getAbsolutePath(ref, true)
                    if (absolutePath) {
                        result.url = "${url}/${ref.tenantId}/${absolutePath}"
                    } else {
                        throw new RuntimeException("Trying to use tag [createResourceLink] with a non-shared resource [$ref]")
                    }
                    return result
                }
                render result as JSON
            }
        }
    }
}
