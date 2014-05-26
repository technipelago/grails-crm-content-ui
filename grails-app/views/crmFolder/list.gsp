<%@ page import="grails.plugins.crm.content.CrmResourceFolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmContent.list.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmContent.list.title" subtitle="crmContent.totalCount.label"
            args="[entityName, crmContentTotal]"/>

<div class="row-fluid">
    <div class="span9">

        <table class="table table-striped">
            <thead>
            <tr>

                <crm:sortableColumn property="title"
                                    title="${message(code: 'crmResourceFolder.title.label', default: 'Title')}"/>

                <th><g:message code="crmResourceFolder.name.label" default="Folder Name"/></th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${crmContentList}" status="i" var="content">
                <tr>
                    <td>
                        <g:link controller="${content.folder ? 'crmFolder' : 'crmContent'}" action="show" id="${content.id}">
                            <img src="${fam.icon(name: content.icon)}"/>
                            <g:fieldValue bean="${content}" field="title"/>
                        </g:link>
                    </td>
                    <td title="${content.path ? (content.path*.name).join('/') : ''}">
                        ${content.name.encodeAsHTML()}
                    </td>
                    <td><g:if test="${content.folder && content.shared}"><i class="icon-share"></i></g:if></td>
                </tr>
            </g:each>
            </tbody>
        </table>

        <crm:paginate total="${crmContentTotal}"/>

        <div class="form-actions btn-toolbar">
            <crm:selectionMenu visual="primary"/>
            <div class="btn-group">
                <crm:button type="link" action="create" visual="success" icon="icon-file icon-white"
                            label="crmResourceFolder.button.create.label" permission="crmContent:create"/>
            </div>
        </div>

    </div>

    <div class="span3">

        <crm:pluginViews location="sidebar" var="view">
            <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
        </crm:pluginViews>

    </div>
</div>

</body>
</html>
