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

import static javax.servlet.http.HttpServletResponse.SC_OK
import static javax.servlet.http.HttpServletResponse.SC_NOT_FOUND

import grails.converters.JSON
import grails.plugins.crm.core.WebUtils
import grails.plugins.crm.core.SearchUtils
import org.apache.tools.zip.*
import grails.plugins.crm.core.TenantUtils

class CrmFolderController {

    static allowedMethods = [list: ['GET', 'POST'], create: ['GET', 'POST'], edit: ['GET', 'POST'], show: 'GET', delete: 'POST']

    static WHITE_LIST = [
            'name',
            'title',
            'description',
            'shared'
    ]

    def grailsApplication
    def crmSecurityService
    def crmContentService
    def selectionService
    def userTagService

    def index() {
        // If any query parameters are specified in the URL, let them override the last query stored in session.
        def cmd = new CrmContentQueryCommand()
        def query = params.getSelectionQuery()
        bindData(cmd, query ?: WebUtils.getTenantData(request, 'crmContentQuery'))
        [cmd: cmd]
    }

    def list() {
        def baseURI = new URI('bean://crmContentService/list')
        def query = params.getSelectionQuery()
        def uri

        switch (request.method) {
            case 'GET':
                uri = params.getSelectionURI() ?: selectionService.addQuery(baseURI, query)
                break
            case 'POST':
                uri = selectionService.addQuery(baseURI, query)
                WebUtils.setTenantData(request, 'crmContentQuery', query)
        }

        params.max = Math.min(params.max ? params.int('max') : 10, 100)

        try {
            def result = selectionService.select(uri, params)
            if (result.totalCount == 1) {
                // If we only got one record, show the record immediately.
                redirect action: "show", params: selectionService.createSelectionParameters(uri) + [id: result.head().ident()]
            } else {
                return [crmContentList: result, crmContentTotal: result.totalCount, selection: uri]
            }
        } catch (Exception e) {
            log.error("Failed to execute query [$uri]", e)
            flash.error = e.message
            [crmContentList: [], crmContentTotal: 0, selection: uri]
        }
    }

    def clearQuery() {
        WebUtils.setTenantData(request, 'crmContentQuery', null)
        redirect(action: 'index')
    }

    def create() {
        def crmResourceFolder = new CrmResourceFolder(tenantId: TenantUtils.tenant)

        bindData(crmResourceFolder, params, [include: WHITE_LIST])
        bindParentFolder(crmResourceFolder, params['parent.id'], CrmResourceFolder.findAllByTenantId(TenantUtils.tenant))

        if (request.method == 'POST') {
            if (crmResourceFolder.save(flush: true)) {
                flash.success = message(code: 'crmResourceFolder.created.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), crmResourceFolder.toString()])
                redirect action: 'show', id: crmResourceFolder.id
                return
            }
        }

        [crmResourceFolder: crmResourceFolder, parentList: CrmResourceFolder.findAllByTenantId(TenantUtils.tenant).sort {
            it.path.join('/')
        }]
    }

    def upload() {
        def crmResourceFolder = CrmResourceFolder.get(params.id)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), params.id])
            redirect action: 'index'
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
                    } else if (crmResourceFolder.shared) {
                        opts.status = 'shared'
                    } else {
                        opts.status = 'published'
                    }
                    def resource = crmContentService.createResource(fileItem.inputStream, fileItem.originalFilename, fileItem.size, fileItem.contentType, crmResourceFolder, opts)
                    files << [name: resource.name,
                              size: resource.metadata.bytes,
                              url: createLink(controller: 'crmContent', action: 'open', id: resource.id),
                              thumbnailUrl: createLink(controller: 'crmContent', action: 'open', id: resource.id),
                              deleteUrl: createLink(controller: 'crmFolder', action: 'deleteFile', id: resource.id),
                              deleteType: "DELETE"
                    ]
                } catch (Exception e) {
                    files << [name: fileItem.originalFilename, size: fileItem.size, error: e.message]
                }
            }
            def result = [files: files]
            render result as JSON
        } else {
            def fileItem = request.getFile("file")
            if (fileItem?.isEmpty()) {
                flash.error = message(code: "crmContent.upload.empty", default: "You must select a file to upload")
            } else if (fileItem) {
                try {
                    def opts = [:]
                    if (params.status) {
                        opts.status = params.status
                    } else if (crmResourceFolder.shared) {
                        opts.status = 'shared'
                    } else {
                        opts.status = 'published'
                    }
                    def ref = crmContentService.createResource(fileItem, crmResourceFolder, opts)
                    flash.success = message(code: "crmContent.upload.success", args: [ref.toString()], default: "Resource [{0}] uploaded")
                } catch (Exception e) {
                    log.error("Failed to upload file: ${fileItem.originalFilename}", e)
                    flash.error = message(code: "crmContent.upload.error", args: [fileItem.originalFilename], default: "Failed to upload file {0}")
                }
            }

            if (params.referer) {
                redirect(url: params.referer)
            } else {
                redirect(action: "show", id: params.id)
            }
        }
    }

    def deleteFile() {
        def idList = params.list('id')
        def folderId
        def files = []

        for(id in idList) {
            def res = CrmResourceRef.findByIdAndTenantId(id, TenantUtils.tenant)
            if (!res) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND)
                return
            }
            if(! folderId) {
                folderId = res.reference?.id
            }
            def filename = res.name
            crmContentService.deleteReference(res)
            files << filename
        }

        if(request.xhr) {
            def result = [files: files.collect{[(it): true]}]
            render result as JSON
        } else {
            flash.warning = message(code: 'crmResourceRef.deleted.message',
                    args: [message(code: 'crmResourceRef.label', default: 'Content'), files.join(', ')],
                    default: "Resource [{1}] deleted")
            if (params.referer) {
                redirect(url: params.referer - request.contextPath)
            } else {
                redirect(controller: "crmFolder", action: folderId ? "show" : "index", id: folderId)
            }
        }
    }

    def edit() {

        def crmResourceFolder = CrmResourceFolder.get(params.id)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), params.id])
            redirect action: 'index'
            return
        }

        def subFolders = crmResourceFolder.getSubFolders()
        def possibleParents = CrmResourceFolder.createCriteria().list() {
            eq('tenantId', TenantUtils.tenant)
            if (subFolders) {
                not {
                    inList('id', subFolders*.ident())
                }
            }
        }.sort { it.path.join('/') }

        switch (request.method) {
            case 'GET':
                return [crmResourceFolder: crmResourceFolder, parentList: possibleParents,
                        folders          : crmResourceFolder.folders, files: crmResourceFolder.files]
            case 'POST':
                if (params.version) {
                    def version = params.version.toLong()
                    if (crmResourceFolder.version > version) {
                        crmResourceFolder.errors.rejectValue('version', 'crmResourceFolder.optimistic.locking.failure',
                                [message(code: 'crmResourceFolder.label', default: 'Folder')] as Object[],
                                "Another user has updated this Folder while you were editing")
                        render view: 'edit', model: [crmResourceFolder: crmResourceFolder, parentList: possibleParents,
                                                     folders          : crmResourceFolder.folders, files: crmResourceFolder.files]
                        return
                    }
                }

                bindData(crmResourceFolder, params, [include: WHITE_LIST])
                bindParentFolder(crmResourceFolder, params['parent.id'], possibleParents)

                if (!crmResourceFolder.save(flush: true)) {
                    render view: 'edit', model: [crmResourceFolder: crmResourceFolder, parentList: possibleParents,
                                                 folders          : crmResourceFolder.folders, files: crmResourceFolder.files]
                    return
                }

                flash.success = message(code: 'crmResourceFolder.updated.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), crmResourceFolder.toString()])
                redirect action: 'show', id: crmResourceFolder.id
                break
        }
    }

    private void bindParentFolder(CrmResourceFolder crmResourceFolder, Object parentId, Collection<CrmResourceFolder> possibleParents) {
        if (parentId) {
            def parent = CrmResourceFolder.get(Long.valueOf(parentId))
            if (parent != null && parent.tenantId == crmResourceFolder.tenantId) {
                if (possibleParents.find { it.id == parent.id }) {
                    crmResourceFolder.parent = parent
                } else {
                    log.warn("Folder \"$parent\" [${parent.id}] cannot be parent of \"$crmResourceFolder\" [${crmResourceFolder.id}]")
                    log.warn(possibleParents.toString())
                }
            }
        } else {
            crmResourceFolder.parent = null
        }
    }

    def show(Long id) {
        def crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), id])
            redirect(action: "index")
            return
        }
        def files = crmResourceFolder.files ?: []
        def uploadMultiple = grailsApplication.config.crm.content.upload.multiple ?: false
        [crmResourceFolder: crmResourceFolder, folders: crmResourceFolder.folders, files: files, multiple: uploadMultiple]
    }

    def delete(Long id) {
        def crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(id, TenantUtils.tenant)
        if (crmResourceFolder) {
            def parent = crmResourceFolder.parent
            def tombstone = crmContentService.deleteFolder(crmResourceFolder)
            flash.warning = message(code: 'crmResourceFolder.deleted.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), tombstone])
            if (parent) {
                redirect action: "show", id: parent.ident()
            } else {
                redirect(action: "index")
            }
        } else {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), id])
            redirect(action: "index")
        }
    }

    def copy(Long id) {
        CrmResourceFolder crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(id, TenantUtils.tenant)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceRef.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), id])
            redirect(action: "index")
            return
        }
        def newName = getUniqueName(crmResourceFolder.parent, crmResourceFolder.name)
        CrmResourceFolder newFolder = crmContentService.copy(crmResourceFolder, crmResourceFolder.parent,
                newName, "Kopia av ${crmResourceFolder.title}")
        flash.success = message(code: 'crmResourceFolder.copied.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), newFolder.name], default: "Folder copied to [{1}]. You are now looking at the new folder.")
        redirect(action: "show", id: newFolder.id)
    }

    private String getUniqueName(CrmResourceFolder folder, String basename) {
        int revision = 0
        String name = basename
        while (CrmResourceFolder.createCriteria().count() {
            if (folder != null) {
                eq('parent', folder)
            } else {
                isNull('parent')
            }
            eq('name', name)
        }) {
            if (revision) {
                name = "Kopia($revision) av $basename"
            } else {
                name = "Kopia av $basename"
            }
            revision++
        }
        return name
    }

    def createFavorite() {
        def crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), params.id])
            redirect action: 'index'
            return
        }
        userTagService.tag(crmResourceFolder, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)

        redirect(action: 'show', id: params.id)
    }

    def deleteFavorite() {
        def crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(params.id, TenantUtils.tenant)
        if (!crmResourceFolder) {
            flash.error = message(code: 'crmResourceFolder.not.found.message', args: [message(code: 'crmResourceFolder.label', default: 'Folder'), params.id])
            redirect action: 'index'
            return
        }
        userTagService.untag(crmResourceFolder, grailsApplication.config.crm.tag.favorite, crmSecurityService.currentUser?.username, TenantUtils.tenant)
        redirect(action: 'show', id: params.id)
    }

    /**
     * Create a ZIP archive that includes all documents in a folder.
     *
     * @attr id primary key of CrmResourceFolder to archive
     * @attr archive name of ZIP archive, defaults to folder name
     * @return ZIP archive is returned in the HTTP response
     */
    def archive() {
        def crmResourceFolder = CrmResourceFolder.findByIdAndTenantId(params.id, TenantUtils.tenant)
        def tempFile = File.createTempFile('crm', '.zip')
        tempFile.deleteOnExit()
        ZipOutputStream zos = new ZipOutputStream(tempFile.newOutputStream())
        /* ZipOutputStream from ANT (org.apache.tools.zip) allows setting of encoding.
        * Without this, filenames with scandinavian characters will be messed up.
        * This was not possible in Sun JDK until JDK7 so we use ANT's implementation here.
        * http://download.java.net/jdk7/docs/api/java/util/zip/ZipFile.html#ZipFile%28java.io.File,%20java.nio.charset.Charset%29
        */
        zos.encoding = "Cp437"
        try {
            addFolder(zos, crmResourceFolder)
        } finally {
            zos.close()
        }
        def archiveName = params.archive ?: crmResourceFolder.name
        WebUtils.attachmentHeaders(response, "application/zip", archiveName + '.zip')
        response.setContentLength(tempFile.length().intValue())
        tempFile.withInputStream { is ->
            response.outputStream << is
        }
        tempFile.delete()
    }

    private void addFolder(ZipOutputStream zos, CrmResourceFolder folder) {
        for (f in folder.folders) {
            addFolder(zos, f)
        }
        for (res in folder.files) {
            def path = crmContentService.getAbsolutePath(res, false)
            zos.putNextEntry(new ZipEntry(path))
            res.writeTo(zos)
            zos.closeEntry()
        }
    }

    def autoCompleteFolder = {
        def result = CrmResourceFolder.createCriteria().list([sort: 'name', order: 'asc']) {
            projections {
                distinct('name')
            }
            eq('tenantId', TenantUtils.tenant)
            if (params.term) {
                ilike('name', SearchUtils.wildcard(params.term))
            }
        }
        render result as JSON
    }
}
