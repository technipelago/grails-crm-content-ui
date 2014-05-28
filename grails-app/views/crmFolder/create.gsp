<%@ page import="grails.plugins.crm.core.TenantUtils; grails.plugins.crm.content.CrmResourceFolder" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceFolder.label', default: 'Folder')}"/>
    <title><g:message code="crmResourceFolder.create.title" args="[entityName, crmResourceFolder]"/></title>
</head>

<body>

<crm:header title="crmResourceFolder.create.title" args="[entityName, crmResourceFolder]"/>

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

        <g:form class="form-horizontal" action="create">

            <f:with bean="crmResourceFolder">
                <g:if test="${crmResourceFolder.parent?.id}">
                    <f:field property="parent">
                        <g:select name="parent.id" from="${parentList}" optionKey="id" optionValue="${{it.path.join('/')}}"
                                  value="${crmResourceFolder.parent.id}" noSelection="['': '']"/>
                    </f:field>
                </g:if>
                <f:field property="title">
                    <g:textField name="title" value="${crmResourceFolder.title}" class="span8" autofocus=""
                                 placeholder="${message(code: 'crmResourceFolder.title.placeholder', default: '')}"/>
                </f:field>
                <f:field property="name" input-class="span8"
                                         input-placeholder="${message(code: 'crmResourceFolder.name.placeholder', default: '')}"/>
                <f:field property="description" input-class="span8" input-rows="4"
                         input-placeholder="${message(code: 'crmResourceFolder.description.placeholder', default: '')}"/>
            </f:with>

            <div class="form-actions">
                <crm:button visual="success" icon="icon-ok icon-white" label="crmResourceFolder.button.save.label"/>
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
