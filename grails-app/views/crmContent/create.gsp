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
    <r:script>
        $(document).ready(function () {
            $('.crm-filenames a').click(function(ev) {
                ev.preventDefault();
                $('#filename').val($(this).attr('href'));
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmContent.create.title" subtitle="${reference?.encodeAsHTML()}" args="${[reference]}"/>

<g:form action="create" class="form-search">

    <g:hiddenField name="ref" value="${ref}"/>
    <g:hiddenField name="referer" value="${referer}"/>
    <g:hiddenField name="contentType" value="${contentType}"/>

    <div class="row-fluid">
        <g:textArea id="content" name="text" cols="70" rows="18" class="span12" value="${text}" autofocus=""/>
    </div>

    <div class="form-actions">
        <crm:button visual="success" icon="icon-ok icon-white" label="crmContent.button.save.label"/>
        <div class="input-append">
            <g:textField id="filename" name="name" required="" class="input-large"
                         placeholder="${message(code: 'crmContent.filename.label', default: 'Filename')}"
                         style="margin-top: 4px;margin-left:5px;"/>
            <g:if test="${filenames}">
                <div class="btn-group" style="margin-top: 4px;">
                    <button class="btn dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu crm-filenames">
                        <g:each in="${filenames}" var="f">
                            <li><a href="${f.key}">${f.value}</a></li>
                        </g:each>
                    </ul>
                </div>
            </g:if>
        </div>
    </div>
</g:form>
</body>
</html>