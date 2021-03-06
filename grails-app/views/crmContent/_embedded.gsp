<%@ page import="org.codehaus.groovy.grails.commons.GrailsClassUtils; grails.plugins.crm.content.CrmResourceRef" contentType="text/html;charset=UTF-8" %>
<% if(multiple) { %>
<r:require module="fileupload"/>
<% } %>
<r:script>
    $(document).ready(function() {
        'use strict';
        <% if(multiple) { %>
        var url = "${createLink(controller: 'crmContent', action: 'attachDocument', params: [ref: reference, referer: request.forwardURI + '#' + view.id, status: defaultStatus ?: ''])}";
        $('#fileupload').fileupload({
            url: url,
            dataType: 'json',
            autoUpload: true,
            sequentialUploads: false,
            limitConcurrentUploads: 3,
            maxFileSize: 5000000, // 5 MB
            disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
            imageMaxWidth: <%=imageMaxWidth ?: 1920%>,
            imageMaxHeight: <%=imageMaxHeight ?: 1080%>,
            imageCrop: false
        }).on('fileuploadstart', function (e) {
            $('#progress').show();
        }).on('fileuploadstop', function (e) {
            setTimeout(function() { location.reload(); }, 3000);
        }).on('fileuploadprogressall', function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#progress .bar').css('width', progress + '%');
        }).on('fileuploadfail', function (e, data) {
            $('#progress').hide();
            $.each(data.files, function (index, file) {
                var error = $('<span class="label label-important"/>').text('File upload failed for ' + file);
                $("#crm-content-list").append(error);
            });
        }).prop('disabled', !$.support.fileInput).parent().addClass($.support.fileInput ? undefined : 'disabled');
        <% } %>
        $("#select-all-files").click(function (event) {
            var check = $(this).is(":checked");
            var $table = $(this).closest('table');
            $(":checkbox[name='id']", $table).prop('checked', check);
        });

        $("#updateAttachment a").click(function(ev) {
            ev.preventDefault();
            if(! confirm("${message(code: 'crmContent.button.update.confirm.message', default: 'Confirm status update')}")) {
                return;
            }
            var status = $(this).data('status');
            var $form = $(this).closest('form');
            var formData = $form.serialize();
            formData = formData + '&newStatus=' + status;
            $.post("${createLink(controller: 'crmContent', action: 'updateAttachment')}", formData, function(data) {
                window.location.reload();
            });
        });

        $('.crm-toggle').hover(function() {
            $(this).children().toggle();
        }, function() {
            $(this).children().toggle();
        });
    });
</r:script>

<style type="text/css">
    .crm-toggle img {
        max-width: none;
    }
</style>

<g:set var="shared" value="${false}"/>
<g:set var="editPermission" value="${false}"/>
<crm:hasPermission permission="${controllerName + ':edit'}">
    <g:set var="editPermission" value="${true}"/>
</crm:hasPermission>

<div id="crm-content-list">
    <g:uploadForm controller="crmContent">

        <table class="table table-striped">
            <g:if test="${list}">
                <thead>
                <th colspan="2"><g:message code="crmResourceRef.title.label" default="Title"/></th>
                <th><g:message code="crmContent.modified.label" default="Modified"/></th>
                <th><g:message code="crmContent.length.label" default="Size"/></th>
                <th style="text-align:right;">
                    <g:if test="${editPermission}">
                        <input type="checkbox" id="select-all-files" name="selectall" value="*"
                               style="vertical-align: top;margin-left: 3px;"/>
                    </g:if>
                </th>
                </thead>
            </g:if>
            <tbody>
            <g:each in="${list}" var="res" status="i">
                <g:set var="metadata" value="${res.metadata}"/>
                <g:set var="tags" value="${res.getTagValue()}"/>
                <g:if test="${res.shared}">
                    <g:set var="shared" value="${true}"/>
                </g:if>
                <tr class="status-${res.statusText} ${(i + 1) == params.int('selected') ? 'active' : ''}">
                    <td style="width:18px;" class="crm-toggle">
                        <g:if test="${editPermission}">
                            <g:link controller="crmContent" action="edit"
                                    params="${[id: res.id, referer: request.forwardURI + '#' + view.id]}"
                                    title="${message(code: 'crmContent.edit.help', default: 'Edit Document')}" class="hide">
                                <i class="icon-pencil"></i>
                            </g:link>
                        </g:if>
                        <a href="#">
                            <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
                             title="${metadata.contentType}"/>
                        </a>
                    </td>
                    <td>
                        <g:link controller="crmContent" action="open" id="${res.id}" target="${controllerName}_doc"
                                title="${message(code: 'crmContent.open.help', default: 'Open Document')}">
                            ${res.title.encodeAsHTML()}
                        </g:link>
                    </td>
                    <td><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></td>
                    <td>${metadata.size}</td>
                    <td style="text-align:right;">
                        <g:if test="${tags}">
                            <i class="icon-tag" title="${tags.join(', ')}"></i>
                        </g:if>
                        <g:if test="${res.restricted}">
                            <crm:resourceLink resource="${res}" target="_blank"><i
                                    class="icon-adjust"></i></crm:resourceLink>
                        </g:if>
                        <g:if test="${res.shared}">
                            <crm:resourceLink resource="${res}" target="_blank"><i
                                    class="icon-globe"></i></crm:resourceLink>
                        </g:if>
                        <g:if test="${editPermission}">
                            <input type="checkbox" name="id" value="${res.id}"
                                   style="vertical-align: top;margin-left: 3px;"/>
                        </g:if>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <g:if test="${editPermission}">

            <div id="progress" class="progress progress-info progress-striped hide">
                <div class="bar" style="width: 0%;"></div>
            </div>

            <g:hiddenField name="ref" value="${reference}"/>
            <g:hiddenField name="referer" value="${request.forwardURI + '#' + view.id}"/>
            <g:hiddenField name="status" value="${defaultStatus ?: ''}"/>

            <div class="form-actions btn-toolbar">
                <crm:button type="link" group="true" controller="crmContent" action="create"
                            params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/html']}"
                            visual="success" icon="icon-file icon-white" label="crmContent.button.create.label">
                    <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <g:link controller="crmContent" action="create"
                                    params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/html']}">
                                HTML
                            </g:link>
                        </li>
                        <li>
                            <g:link controller="crmContent" action="create"
                                    params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/plain']}">
                                TEXT
                            </g:link>
                        </li>
                    </ul>
                </crm:button>

                <g:if test="${list}">
                    <div class="btn-group">
                        <a href="#" class="btn btn-warning">
                            <i class="icon-cog icon-white"></i>
                            <g:message code="crmResourceRef.status.label" default="Status"/>
                        </a>
                        <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu" id="updateAttachment">
                            <g:each in="${CrmResourceRef.STATUS_TEXTS}" var="status">
                            <li>
                                <a href="#" data-id="${status.value}" data-status="${status.key}">
                                    ${message(code: 'crmResourceRef.status.' + status.key, default: status.key)}
                                </a>
                            </li>
                            </g:each>
                        </ul>
                    </div>

                    <crm:button action="deleteAttachment" group="true" visual="danger"
                                label="crmContent.button.delete.label" icon="icon-trash icon-white"
                                help="crmContent.button.delete.help"
                                confirm="crmContent.button.delete.confirm.message"/>
                </g:if>

                <g:if test="${multiple}">
                    <span class="btn btn-primary fileinput-button">
                        <i class="icon-upload icon-white"></i>
                        <span><g:message code="crmContent.button.upload.label" default="Add files..."/></span>
                        <input id="fileupload" type="file" name="file" style="margin-left:10px;" multiple="">
                    </span>
                </g:if>
                <g:else>
                    <crm:button action="attachDocument" visual="primary" icon="icon-upload icon-white"
                                label="crmContent.button.upload.label"/>
                    <input type="file" name="file" style="margin-left:10px;"/>
                </g:else>

                <g:if test="${(linkParams && shared) || (gallery && list)}">
                    <div class="btn-group">
                        <button class="btn btn-info dropdown-toggle" data-toggle="dropdown">
                            <i class="icon-info-sign icon-white"></i>
                            <g:message code="crmContent.button.view.label" default="View"/>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu">
                            <g:if test="${gallery && list}">
                                <li>
                                <g:link mapping="gallery" params="${gallery}">
                                    <g:message code="crmContent.photo.gallery.label" default="Photo Gallery"/>
                                </g:link>
                                </li>
                            </g:if>
                            <g:if test="${linkParams && shared}">
                                <li>
                                <g:link mapping="${mapping ?: 'public-folder'}" params="${linkParams}" target="_blank">
                                    <g:message code="crmContent.link.shared.label" default="Public folder"/>
                                </g:link>
                                </li>
                                <li>
                                    <a href="javascript:void(0)" onclick="copyFolderLinkToClipboard()">
                                        <g:message code="crmContent.copy.to.clipboard.label" default="Share link to folder"/>
                                    </a>
                                </li>
                            </g:if>
                        </ul>
                    </div>
                </g:if>
            </div>
        </g:if>

    </g:uploadForm>
</div>

<r:script>
<% if(shared) { %>
    function copyFolderLinkToClipboard() {
        var url = "${g.createLink(mapping: mapping ?: 'public-folder', params: linkParams, absolute: true)}";
        window.prompt("${message(code: 'crmContent.copy.to.clipboard.message', 'Copy to clipboard: Ctrl+C, Enter')}", url);
    }
    <% } %>
</r:script>