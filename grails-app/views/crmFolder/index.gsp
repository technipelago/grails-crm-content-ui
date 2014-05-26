<%@ page import="grails.plugins.crm.content.CrmResourceFolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmContent.find.title" args="[entityName]"/></title>
</head>

<body>

<crm:header title="crmContent.find.title" args="[entityName]"/>

<div class="row-fluid">
    <div class="span9">

        <g:form action="list">

            <fieldset>
                <f:with bean="cmd">
                    <f:field property="name" label="crmContentQueryCommand.name.label" input-autofocus="" input-class="span6"
                             input-placeholder="${message(code: 'crmContentQueryCommand.name.placeholder', default: '')}"/>
                </f:with>
            </fieldset>

            <div class="form-actions btn-toolbar">
                <crm:selectionMenu visual="primary">
                    <crm:button action="list" icon="icon-search icon-white" visual="primary"
                                label="crmContent.button.find.label"/>
                </crm:selectionMenu>
                <crm:button type="link" group="true" action="create" visual="success" icon="icon-file icon-white"
                            label="crmResourceFolder.button.create.label" permission="crmContent:create"/>
                <g:link action="clearQuery" class="btn btn-link"><g:message code="crmContent.button.query.clear.label"
                                                                            default="Reset fields"/></g:link>
            </div>

        </g:form>

    </div>

    <div class="span3">

        <crm:pluginViews location="sidebar" var="view">
            <g:render template="${view.template}" model="${view.model}" plugin="${view.plugin}"/>
        </crm:pluginViews>

    </div>
</div>

</body>
</html>
