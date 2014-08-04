<%@ page import="grails.plugins.crm.content.CrmResourceRef" contentType="text/html;charset=UTF-8" %>
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
    });
</r:script>

<div id="crm-content-list">
    <g:uploadForm controller="crmContent">

        <table class="table table-striped">
            <g:if test="${list}">
                <thead>
                <th><g:message code="crmResourceRef.title.label" default="Title"/></th>
                <th><g:message code="crmContent.modified.label" default="Modified"/></th>
                <th><g:message code="crmContent.length.label" default="Size"/></th>
                <th style="text-align:right;">
                    <crm:hasPermission permission="${controllerName + ':edit'}">
                        <input type="checkbox" id="select-all-files" name="selectall" value="*"
                               style="vertical-align: top;margin-left: 3px;"/>
                    </crm:hasPermission>
                </th>
                </thead>
            </g:if>
            <tbody>
            <g:each in="${list}" var="res" status="i">
                <g:set var="metadata" value="${res.metadata}"/>
                <tr class="status-${res.statusText} ${(i + 1) == params.int('selected') ? 'active' : ''}">
                    <td>
                        <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
                             title="${metadata.contentType}"/>
                        <g:link controller="crmContent" action="open" id="${res.id}" target="${controllerName}_doc"
                                title="${message(code: 'crmContent.open.help', default: 'Open Document')}">
                            ${res.title.encodeAsHTML()}
                        </g:link>
                    </td>
                    <td><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></td>
                    <td>${metadata.size}</td>
                    <td style="text-align:right;">
                        <g:if test="${res.shared}">
                            <crm:resourceLink resource="${res}" target="_blank"><i
                                    class="icon-share-alt"></i></crm:resourceLink>
                        </g:if>
                        <crm:hasPermission permission="${controllerName + ':edit'}">
                            <g:link controller="crmContent" action="edit"
                                    params="${[id: res.id, referer: request.forwardURI + '#' + view.id]}"
                                    title="${message(code: 'crmContent.edit.help', default: 'Edit Document')}">
                                <i class="icon-pencil"></i>
                            </g:link>
                            <input type="checkbox" name="id" value="${res.id}"
                                   style="vertical-align: top;margin-left: 3px;"/>
                        </crm:hasPermission>
                    </td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <crm:hasPermission permission="${controllerName + ':edit'}">

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
                            <i class="icon-adjust icon-white"></i>
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

                <g:if test="${gallery && list}">
                    <g:link mapping="gallery" class="btn btn-info" params="${gallery}">
                        <i class="icon-picture icon-white"></i>
                        <g:message code="crmContent.photo.gallery.label" default="Photo Gallery"/>
                    </g:link>
                </g:if>
            </div>
        </crm:hasPermission>

    </g:uploadForm>
</div>