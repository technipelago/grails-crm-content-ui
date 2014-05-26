<%@ page import="grails.plugins.crm.content.CrmResourceFolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmResourceFolder.edit.title" args="[entityName, crmResourceFolder]"/></title>
</head>

<body>

<crm:header title="crmResourceFolder.edit.title" args="[entityName, crmResourceFolder]"/>

<g:hasErrors bean="${crmResourceFolder}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmResourceFolder}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<div class="row-fluid">
    <div class="span9">

        <g:form class="form-horizontal" action="edit"
                id="${crmResourceFolder?.id}">
            <g:hiddenField name="version" value="${crmResourceFolder?.version}"/>

            <f:with bean="crmResourceFolder">
                <f:field property="parent">
                    <g:select name="parent.id" from="${parentList}" optionKey="id" optionValue="${{it.path.join('/')}}"
                              value="${crmResourceFolder.parent?.id}" noSelection="['': '']"/>
                </f:field>
                <f:field property="title" input-autofocus="" input-class="span8"
                         input-placeholder="${message(code: 'crmResourceFolder.title.placeholder', default: '')}"/>
                <f:field property="name" input-class="span4"
                                         input-placeholder="${message(code: 'crmResourceFolder.name.placeholder', default: '')}"/>
                <f:field property="description" input-class="span8" input-rows="4"
                         input-placeholder="${message(code: 'crmResourceFolder.description.placeholder', default: '')}"/>
                <f:field property="shared"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="warning" icon="icon-ok icon-white" label="crmFolder.button.update.label"/>
                <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                            label="crmResourceFolder.button.delete.label"
                            confirm="crmResourceFolder.button.delete.confirm.message" args="${[folders.size(), files.size()]}"
                            permission="crmFolder:delete"/>
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
