<%@ page import="grails.plugins.crm.content.CrmResourceFolder" contentType="text/html;charset=UTF-8" defaultCodec="html" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="blank">
    <title>${crmResource.name}</title>
</head>

<body>

<g:set var="reference" value="${crmResource.reference}"/>

<h2>
    <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
         title="${metadata.contentType}"/>
    ${crmResource.name}
</h2>

<dl>
    <dt><g:message code="crmContent.contentType.label"/></dt>
    <dd>${metadata.contentType}</dd>

    <dt><g:message code="crmContent.length.label"/></dt>
    <dd>${metadata.bytes} bytes</dd>

    <dt><g:message code="crmResourceRef.status.label"/></dt>
    <dd>${message(code: 'crmResourceRef.status.' + crmResource.statusText, default: crmResource.statusText)}</dd>

    <dt><g:message code="crmContent.modified.label"/></dt>
    <dd><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></dd>
<!--
    <dt><g:message code="crmResourceRef.ref.label"/></dt>
    <dd>${reference}</dd>
-->
    <g:if test="${(reference instanceof CrmResourceFolder)}">
        <dt><g:message code="crmContent.link.label"/></dt>
        <dd><crm:resourceLink resource="${crmResource}"><crm:createResourceLink
                resource="${crmResource}"/></crm:resourceLink></dd>
    </g:if>

</dl>

<p>
    <g:message code="crmContent.no.preview.message"/>
</p>

<g:link class="btn btn-success" controller="crmContent" action="open"
        params="${[id:crmResource.id, disposition:'attachment']}">
    <i class="icon-file icon-white"></i>
    <g:message
            code="crmContent.button.open.label" default="Open"/></g:link>

</body>
</html>
