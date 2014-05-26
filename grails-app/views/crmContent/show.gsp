<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceRef.label', default: 'File')}"/>
    <title>${crmResourceRef.title.encodeAsHTML()}</title>
    <g:if test="${metadata.contentType == 'text/html'}">
        <r:script>
        $(document).ready(function() {
          $('#preview').load(function(){
            var $head = $('#preview').contents().find('head');
            $head.append('<link href="${resource(dir: 'less', file: 'bootstrap.less.css', plugin: 'twitter-bootstrap')}" rel="stylesheet" type="text/css" />');
            $head.append('<link href="${resource(dir: 'less', file: 'crm-ui-bootstrap.less.css', plugin: 'crm-ui-bootstrap')}" rel="stylesheet" type="text/css" />');
            $head.append('<link href="${resource(dir: 'less', file: 'responsive.less.css', plugin: 'twitter-bootstrap')}" rel="stylesheet" type="text/css" />');
            <% if(css) { %>
            $head.append('<link href="${resource(css)}" rel="stylesheet" type="text/css" />');
            <% } %>
            });
          });
        </r:script>
    </g:if>
</head>

<body>

<header class="page-header clearfix">
    <h1>
        ${crmResourceRef.title.encodeAsHTML()}
        <img src="${crm.fileIcon(contentType: metadata.contentType)}"/>
        <crm:favoriteIcon bean="${crmResourceRef}"/>
        <small>${crmResourceRef.reference.encodeAsHTML()}</small>
    </h1>
</header>

<g:if test="${crmResourceRef.shared}">
    <div class="alert alert-error">
        <h4><g:message code="crmResourceRef.shared.title"/></h4>
        <g:set var="resourceURL" value="${crm.createResourceLink(resource: crmResourceRef)}"/>
        <a href="${resourceURL}" target="_blank">${resourceURL}</a>
    </div>
</g:if>

<g:uploadForm>
    <g:hiddenField name="id" value="${crmResourceRef.id}"/>

    <div class="tabbable">
        <ul class="nav nav-tabs">
        <li class="active"><a href="#main"data-toggle="tab"><g:message code="crmContent.tab.main.label"
                                                                       default="Preview"/></a></li>
    <li><a href="#misc" data-toggle="tab"><g:message code="crmContent.tab.misc.label" default="Settings"/></a></li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane active" id="main">
            <div class="row-fluid">
                <iframe id="preview"
                        src="${g.createLink(action: 'open', params: [id: crmResourceRef.id, preview: true])}"
                        width="98.3%" height="320"></iframe>
            </div>
        </div>

        <div class="tab-pane" id="misc">
            <div class="row-fluid">
                <div class="span4">

                    <dl>
                        <dt><g:message code="crmResourceRef.name.label" default="Filename"/></dt>
                        <dd>${fieldValue(bean: crmResourceRef, field: 'name')}</dd>

                        <dt><g:message code="crmResourceRef.title.label" default="Title"/></dt>
                        <dd>${fieldValue(bean: crmResourceRef, field: 'title')}</dd>

                        <g:if test="${crmResourceRef.description}">
                            <dt><g:message code="crmResourceRef.description.label" default="Description"/></dt>
                            <dd>${fieldValue(bean: crmResourceRef, field: 'description')}</dd>
                        </g:if>
                    </dl>
                </div>

                <div class="span4">
                    <dl>
                        <dt><g:message code="crmContent.length.label" default="Length"/></dt>
                        <dd>${metadata.size}</dd>

                        <dt><g:message code="crmContent.contentType.label" default="MIME Type"/></dt>
                        <dd>${metadata.contentType}</dd>

                        <dt><g:message code="crmResourceRef.status.label" default="Status"/></dt>
                        <dd>${message(code: 'crmResourceRef.status.' + crmResourceRef.statusText, default: crmResourceRef.statusText)}</dd>
                    </dl>
                </div>

                <div class="span4">
                    <dl>
                        <dt><g:message code="crmContent.created.label" default="Created"/></dt>
                        <dd><g:formatDate date="${metadata.created}" type="datetime"/></dd>

                        <dt><g:message code="crmContent.modified.label" default="Modified"/></dt>
                        <dd><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></dd>
                    </dl>
                </div>

            </div>
        </div>
    </div>

    <div class="form-actions">

        <crm:button type="link" action="open" id="${crmResourceRef.id}" visual="info" target="_blank"
                    icon="icon-eye-open icon-white"
                    label="crmContent.button.open.label"
                    title="crmContent.button.open.help"
                    permission="crmContent:open"/>

        <crm:button type="link" action="edit" params="${[id: crmResourceRef.id, referer: params.referer]}"
                    visual="warning"
                    icon="icon-pencil icon-white"
                    label="crmContent.button.edit.label"
                    title="crmContent.button.edit.help"
                    permission="crmContent:edit"/>

        <g:if test="${params.referer}">
            <crm:button type="url" href="${params.referer}" label="crmContent.button.back.label" icon="icon-remove"/>
        </g:if>
        <g:elseif test="${crmResourceFolder}">
            <crm:button type="link" controller="crmFolder" action="show" id="${crmResourceFolder.ident()}"
                        label="crmContent.button.back.label" title="${crmResourceFolder.toString()}"
                        icon="icon-remove"/>
        </g:elseif>

    </div>
</g:uploadForm>

</div>

</body>
</html>
