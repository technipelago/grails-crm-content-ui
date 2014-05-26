<%@ page import="grails.plugins.crm.content.CrmResourceFolder" contentType="text/html;charset=UTF-8" defaultCodec="html" %>
<!DOCTYPE html>
<html>
<head>
    <title>${crmResource.name}</title>
</head>

<body>

<h2>
    <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
         title="${metadata.contentType}"/>
    ${crmResource.name}
</h2>

<p>
    <g:message code="crmContent.no.preview.message"/>
</p>

<g:link class="btn btn-success" controller="crmContent" action="open" params="${[id:crmResource.id, disposition:'attachment']}">
    <i class="icon-file icon-white"></i>
    <g:message code="crmContent.button.open.label" default="Open"/>
</g:link>

</body>
</html>
