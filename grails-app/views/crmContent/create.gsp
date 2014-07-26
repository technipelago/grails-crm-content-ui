<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title><g:message code="crmContent.create.title" args="${[reference]}"/></title>
    <% if (contentType == 'text/html') { %>
    <ckeditor:resources/>
    <r:script>
        $(document).ready(function () {
            var stylesheet = ["${resource(dir: 'less', file: 'bootstrap.less.css', plugin: 'twitter-bootstrap')}",
            "${resource(dir: 'less', file: 'crm-ui-bootstrap.less.css', plugin: 'crm-ui-bootstrap')}",
            "${resource(dir: 'less', file: 'responsive.less.css', plugin: 'twitter-bootstrap')}"];
            <% if (css) { %>
            stylesheet.push("${resource(css)}");
            <% } %>
            var editor = CKEDITOR.replace('content',
                {
                    customConfig: "${resource(dir: 'js', file: 'crm-ckeditor-config.js', plugin: 'crm-content-ui')}",
                    stylesSet: "crm-web-styles:${resource(dir: 'js', file: 'crm-ckeditor-styles.js', plugin: 'crm-content-ui')}",
                    baseHref: "${createLink(controller: 'static')}",
                    contentsCss: stylesheet,
                    language: 'en'
                });
        });
    </r:script>
    <% } %>
</head>

<body>

<crm:header title="crmContent.create.title" subtitle="${reference?.encodeAsHTML()}" args="${[reference]}"/>

<g:form action="create">

    <g:hiddenField name="ref" value="${ref}"/>
    <g:hiddenField name="referer" value="${referer}"/>
    <g:hiddenField name="contentType" value="${contentType}"/>

    <div class="row-fluid">
        <g:textArea id="content" name="text" cols="70" rows="18" class="span12" value="${text}"/>
    </div>

    <div class="form-actions">
        <crm:button visual="success" icon="icon-ok icon-white" label="crmContent.button.save.label"/>
        <g:textField name="name" required="" class="input-large"
                     placeholder="${message(code: 'crmContent.filename.label', default: 'Filename')}"
                     style="margin-top: 9px;margin-left:5px;"/>
    </div>
</g:form>
</body>
</html>