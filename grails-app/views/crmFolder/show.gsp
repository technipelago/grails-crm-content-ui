<%@ page import="grails.plugins.crm.content.CrmResourceFolder" %><!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmResourceFolder.label" args="[entityName, crmResourceFolder]"/></title>
</head>

<body>

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

<table id="file-list" class="table table-striped">
    <thead>
    <th><g:message code="crmResourceFolder.title.label" default="Title"/></th>
    <th><g:message code="crmResourceFolder.name.label" default="Name"/></th>
    <th><g:message code="crmContent.modified.label" default="Modified"/></th>
    <th style="text-align: right;"><g:message code="crmContent.length.label" default="Size"/></th>
    <th></th>
    </thead>
    <tbody>

    <g:if test="${crmResourceFolder.parent}">
        <tr>
            <td>
                <img src="${fam.icon(name: 'arrow_turn_left')}"/>
                <g:link action="show" id="${crmResourceFolder.parent.id}">
                    <g:fieldValue bean="${crmResourceFolder}" field="parent.title"/>
                </g:link>
            </td>
            <td colspan="3">
                <g:fieldValue bean="${crmResourceFolder}" field="parent.name"/>
            </td>
            <td>
                <g:if test="${crmResourceFolder.parent.shared}"><i class="icon-share"></i></g:if>
            </td>
        </tr>
    </g:if>

    <g:if test="${folders.isEmpty() && files.isEmpty()}">
        <tr>
            <td colspan="5"><g:message code="crmResourceFolder.empty.message" default="Folder is empty"/></td>
        </tr>
    </g:if>

    <g:each in="${folders}" var="folder" status="i">
        <tr>
            <td class="nowrap">
                <img src="${fam.icon(name: 'folder')}"/>
                <g:link action="show" id="${folder.id}">${folder.title.encodeAsHTML()}</g:link>
            </td>
            <td colspan="3">
                <g:link action="show" id="${folder.id}">${folder.name?.encodeAsHTML()}</g:link>
            </td>
            <td><g:if test="${folder.shared}"><i class="icon-share"></i></g:if></td>
        </tr>
    </g:each>

    <g:each in="${files}" var="res" status="i">
        <g:set var="metadata" value="${res.metadata}"/>
        <tr>
            <td class="nowrap">
                <img src="${crm.fileIcon(contentType: metadata.contentType)}"
                     alt="${metadata.contentType}" title="${metadata.contentType}"/>
                <g:link controller="crmContent" action="open" id="${res.id}" target="${controllerName}_doc"
                        title="${message(code: 'crmContent.open.help', default: 'Open Document')}">
                    ${res.title.encodeAsHTML()}
                </g:link>
            </td>
            <td>
                ${res.name?.encodeAsHTML()}
            </td>
            <td class="nowrap"><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></td>
            <td class="nowrap" style="text-align: right;">${metadata.size}</td>
            <td>
                <g:if test="${res.shared}">
                    <crm:resourceLink resource="${res}" target="_blank"><i
                            class="icon-share-alt"></i></crm:resourceLink>
                </g:if>
                <crm:hasPermission permission="${controllerName + ':edit'}">
                    <g:link controller="crmContent" action="edit"
                            params="${[id: res.id, referer: request.forwardURI]}"
                            title="${message(code: 'crmContent.edit.help', default: 'Edit Document')}">
                        <i class="icon-pencil"></i>
                    </g:link>
                </crm:hasPermission>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<g:uploadForm>
    <g:hiddenField name="id" value="${crmResourceFolder?.id}"/>
    <g:hiddenField name="selected" value="${selected?.id}"/>

    <div class="form-actions btn-toolbar">

        <crm:button type="link" action="edit" id="${crmResourceFolder.id}" visual="warning"
                    icon="icon-pencil icon-white"
                    label="crmResourceFolder.button.edit.label"
                    title="crmResourceFolder.button.edit.help"
                    permission="crmContent:edit"/>

        <crm:selectionMenu visual="primary">
            <crm:button action="index" icon="icon-search icon-white" visual="primary"
                        label="crmContent.button.find.label"/>
        </crm:selectionMenu>

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
                        <g:message code="crmContent.button.create.html.label" default="Create new HTML document"/>
                    </g:link>
                </li>
                <li>
                    <g:link controller="crmContent" action="create"
                            params="${[ref: 'crmResourceFolder@' + crmResourceFolder.id, referer: request.forwardURI, contentType: 'text/plain']}">
                        <g:message code="crmContent.button.create.text.label" default="Create new TEXT document"/>
                    </g:link>
                </li>
            </ul>
        </crm:button>
        <crm:hasPermission permission="crmContent:edit">
            <crm:button action="upload" icon="icon-upload"
                        label="crmContent.button.upload.label"
                        title="crmContent.button.upload.help"/>
            <input type="file" name="file" style="margin-left: 10px;"/>
        </crm:hasPermission>

        <g:if test="${folders || files}">
            <crm:hasPermission permission="crmContent:archive">
                <g:link action="archive" id="${crmResourceFolder.id}"
                        title="${message(code: 'crmResourceFolder.button.archive.help', default: 'Create ZIP archive of this folder')}">
                    <g:message code="crmResourceFolder.button.archive.label" default="Create archive"/>
                </g:link>
            </crm:hasPermission>
        </g:if>

    </div>

</g:uploadForm>

</body>
</html>
