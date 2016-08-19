<%@ page import="grails.plugins.crm.content.CrmResourceRef; grails.plugins.crm.content.CrmResourceFolder" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmResourceFolder.label" args="[entityName, crmResourceFolder]"/></title>
    <% if (multiple) { %>
    <r:require module="fileupload"/>
    <% } %>
    <r:script>
        $(document).ready(function() {
            'use strict';
        <% if (multiple) { %>
        var url = "${
            createLink(controller: 'crmFolder', action: 'upload', params: [id: crmResourceFolder.id, referer: "${createLink(action: 'show', id: crmResourceFolder.id)}"])}";
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
            var $form = $('#updateForm');
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
</head>

<body>

<g:set var="editPermission" value="${false}"/>
<crm:hasPermission permission="${controllerName + ':edit'}">
    <g:set var="editPermission" value="${true}"/>
</crm:hasPermission>

<div class="row-fluid">
    <div class="span9">

        <header class="page-header clearfix">
            <h1 title="${crmResourceFolder.path.join(' &raquo; ')}">
                ${crmResourceFolder.title.encodeAsHTML()}
                <crm:favoriteIcon bean="${crmResourceFolder}"/>
                <g:if test="${crmResourceFolder.shared}"><i class="icon-share"></i></g:if>
                <g:if test="${crmResourceFolder.parent}"><small>${crmResourceFolder.parent.path.join('/').encodeAsHTML()}</small></g:if>
            </h1>
        </header>

        <g:if test="${crmResourceFolder.description}">
            <p style="width: 60%;">
                <g:decorate include="abbreviate" max="500">
                    <g:fieldValue bean="${crmResourceFolder}" field="description"/>
                </g:decorate>
            </p>
        </g:if>

        <g:if test="${crmResourceFolder.shared}">
            <div class="alert alert-error">
                <h4><g:message code="crmResourceFolder.shared.title"/></h4>
            </div>
        </g:if>

        <g:form controller="crmContent" name="updateForm">

            <table id="file-list" class="table table-striped">
                <thead>
                <th colspan="2"><g:message code="crmResourceFolder.title.label" default="Title"/></th>
                <th><g:message code="crmResourceFolder.name.label" default="Name"/></th>
                <th><g:message code="crmContent.modified.label" default="Modified"/></th>
                <th style="text-align: right;"><g:message code="crmContent.length.label" default="Size"/></th>
                <th style="width: 18px; text-align:right;"></th>
                <g:if test="${editPermission && files}">
                    <th style="text-align:right;">
                        <input type="checkbox" id="select-all-files" name="selectall" value="*"
                               style="vertical-align: top;"/>
                    </th>
                </g:if>
                </thead>

                <tbody>
                <g:if test="${crmResourceFolder.parentId}">
                    <tr>
                        <td style="width:18px;">
                            <g:link action="show" id="${crmResourceFolder.parentId}">
                                <i class="icon-step-backward"></i>
                            </g:link>
                        </td>
                        <td>
                            <g:link action="show" id="${crmResourceFolder.parentId}">
                                <g:fieldValue bean="${crmResourceFolder}" field="parent.title"/>
                            </g:link>
                        </td>
                        <td colspan="3">
                            <g:fieldValue bean="${crmResourceFolder}" field="parent.name"/>
                        </td>
                        <td style="width: 18px; text-align:right;">
                            <g:if test="${crmResourceFolder.parent.shared}"><i class="icon-share"></i></g:if>
                        </td>
                        <g:if test="${editPermission && files}">
                            <td style="text-align:right;"></td>
                        </g:if>
                    </tr>
                </g:if>

                <g:if test="${folders.isEmpty() && files.isEmpty()}">
                    <tr>
                        <td colspan="${editPermission ? 7 : 6}"><g:message code="crmResourceFolder.empty.message"
                                                                           default="Folder is empty"/></td>
                    </tr>
                </g:if>

                <g:each in="${folders}" var="folder" status="i">
                    <tr>
                        <td style="width:18px;">
                            <img src="${fam.icon(name: 'folder')}"/>
                        </td>
                        <td class="nowrap">
                            <g:link action="show" id="${folder.id}">${folder.title.encodeAsHTML()}</g:link>
                        </td>
                        <td colspan="3">
                            <g:link action="show" id="${folder.id}">${folder.name?.encodeAsHTML()}</g:link>
                        </td>
                        <td style="width: 18px; text-align:right;">
                            <g:if test="${folder.shared}"><i class="icon-share"></i></g:if>
                        </td>
                        <g:if test="${editPermission && files}">
                            <td style="text-align:right;"></td>
                        </g:if>
                    </tr>
                </g:each>

                <g:each in="${files}" var="res" status="i">
                    <g:set var="metadata" value="${res.metadata}"/>
                    <g:set var="tags" value="${res.getTagValue()}"/>
                    <tr>
                        <td style="width:18px;" class="crm-toggle">
                            <g:if test="${editPermission}">
                                <g:link controller="crmContent" action="edit"
                                        params="${[id: res.id, referer: request.forwardURI]}" style="display: none;"
                                        title="${message(code: 'crmContent.edit.help', default: 'Edit Document')}">
                                    <i class="icon-pencil"></i>
                                </g:link>
                            </g:if>
                            <a href="#">
                                <img src="${crm.fileIcon(contentType: metadata.contentType)}"
                                     alt="${metadata.contentType}" title="${metadata.contentType}"/>
                            </a>
                        </td>
                        <td class="nowrap">
                            <g:link controller="crmContent" action="open" id="${res.id}" target="${controllerName}_doc"
                                    title="${message(code: 'crmContent.open.help', default: 'Open Document')}">
                                ${res.title.encodeAsHTML()}
                            </g:link>
                        </td>
                        <td>
                            ${res.name?.encodeAsHTML()}
                        </td>
                        <td class="nowrap"><g:formatDate date="${metadata.modified ?: metadata.created}"
                                                         type="datetime"/></td>
                        <td class="nowrap" style="text-align: right;">${metadata.size}</td>
                        <td style="width: 18px; text-align:right;">
                            <g:if test="${tags}">
                                <i class="icon-tag" title="${tags.join(', ')}"></i>
                            </g:if>
                            <g:if test="${res.shared}">
                                <crm:resourceLink resource="${res}" target="_blank"><i
                                        class="icon-share"></i></crm:resourceLink>
                            </g:if>
                        </td>
                        <g:if test="${editPermission}">
                            <td style="text-align:right;">
                                <input type="checkbox" name="id" value="${res.id}"
                                       style="vertical-align: top;"/>
                            </td>
                        </g:if>
                    </tr>
                </g:each>
                </tbody>
            </table>
        </g:form>

        <div id="progress" class="progress progress-info progress-striped hide">
            <div class="bar" style="width: 0%;"></div>
        </div>

        <g:uploadForm>
            <g:hiddenField name="id" value="${crmResourceFolder?.id}"/>
            <g:hiddenField name="selected" value="${selected?.id}"/>

            <div class="form-actions btn-toolbar">

                <crm:selectionMenu visual="primary">
                    <crm:button action="index" icon="icon-search icon-white" visual="primary"
                                label="crmContent.button.find.label"/>
                </crm:selectionMenu>

                <div class="btn-group">
                    <crm:button type="link" action="edit" id="${crmResourceFolder.id}" visual="warning"
                                icon="icon-pencil icon-white"
                                label="crmResourceFolder.button.edit.label"
                                title="crmResourceFolder.button.edit.help"
                                permission="crmContent:edit"/>
                    <g:if test="${files}">
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
                    </g:if>
                </div>

                <crm:button type="link" group="true" action="create" params="${['parent.id': crmResourceFolder.id]}"
                            visual="success"
                            icon="icon-folder-open icon-white"
                            label="crmResourceFolder.button.create.label"
                            title="crmResourceFolder.button.create.help"
                            permission="crmContent:create">
                    <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <g:link action="copy" id="${crmResourceFolder?.id}"
                                    onclick="return confirm('Är du säker på att du vill kopiera denna mapp och allt dess innehåll till en ny mapp?')">
                                <g:message code="crmFolder.button.copy.label" default="Copy Folder"/>
                            </g:link>
                        </li>
                        <li>
                            <g:link controller="crmContent" action="create"
                                    params="${[ref: 'crmResourceFolder@' + crmResourceFolder.id, referer: request.forwardURI, contentType: 'text/html']}">
                                <g:message code="crmContent.button.create.html.label"
                                           default="Create new HTML document"/>
                            </g:link>
                        </li>
                        <li>
                            <g:link controller="crmContent" action="create"
                                    params="${[ref: 'crmResourceFolder@' + crmResourceFolder.id, referer: request.forwardURI, contentType: 'text/plain']}">
                                <g:message code="crmContent.button.create.text.label"
                                           default="Create new TEXT document"/>
                            </g:link>
                        </li>
                    </ul>
                </crm:button>

                <g:if test="${folders || files}">
                    <crm:hasPermission permission="crmContent:archive">
                        <g:link action="archive" id="${crmResourceFolder.id}" class="btn btn-info"
                                title="${message(code: 'crmResourceFolder.button.archive.help', default: 'Create ZIP archive of this folder')}">
                            <g:message code="crmResourceFolder.button.archive.label" default="Create archive"/>
                        </g:link>
                    </crm:hasPermission>
                </g:if>

                <g:if test="${editPermission}">

                    <g:if test="${multiple}">
                        <span class="btn btn-primary fileinput-button">
                            <i class="icon-upload icon-white"></i>
                            <span><g:message code="crmContent.button.upload.label" default="Add files..."/></span>
                            <input id="fileupload" type="file" name="file" style="margin-left:6px;" multiple="">
                        </span>
                    </g:if>
                    <g:else>
                        <crm:button action="upload" visual="primary" icon="icon-upload icon-white"
                                    label="crmContent.button.upload.label"/>
                        <input type="file" name="file" style="width: 150px; margin-left:6px;"/>
                    </g:else>

                </g:if>

            </div>

        </g:uploadForm>

    </div>

    <div class="span3">
        <g:render template="/tags" plugin="crm-tags" model="${[bean: crmResourceFolder]}"/>
    </div>
</div>
</body>
</html>
