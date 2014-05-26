<%@ page contentType="text/html;charset=UTF-8" defaultCodec="html" %><!DOCTYPE html>
<html lang="en">
<head>
    <meta name="layout" content="minimal">
    <title><g:message code="crmContent.filebrowser.title" default="Select a file"/></title>
    <r:script>
        function select_file(url) {
            if(window.parent && window.parent.opener && window.parent.opener.CKEDITOR) {
                window.parent.opener.CKEDITOR.tools.callFunction("${params.CKEditorFuncNum}", url, '');
                self.close();
            }
        }

        $(document).ready(function() {
            $("#content-tree").load("${createLink(action: 'tree', params: [reference: identifier, pattern: pattern])}", function() {
                $("#content-tree label").click(function(ev) {
                    var $label = $(this);
                    $("#content-list").html("<p>Loading...</p>");
                    $("#content-list").load("${createLink(action: 'files', params: [pattern: pattern])}", {reference: $label.attr('for')}, function() {
                        $(".crm-filebrowser a").click(function(ev) {
                            ev.preventDefault();
                            select_file($(this).attr('href'));
                        });
                    });
                });
                $("#content-tree label:first").click();
            });
        });
    </r:script>

</head>

<body>

<div class="row-fluid">

    <div class="span3">
        <div class="row-fluid">
            <div class="well">
                <div id="content-tree"></div>
            </div>
        </div>
    </div>

    <div class="span9">
        <div class="row-fluid">

            <div id="content-list" style="min-height: 250px"></div>

            <g:uploadForm controller="crmContent" action="attachDocument">
                <g:hiddenField name="ref" value="${identifier}"/>
                <g:hiddenField name="status" value="${params.status ?: 'published'}"/>
                <g:hiddenField name="pattern" value="${pattern}"/>
                <g:hiddenField name="CKEditor" value="${params.CKEditor}"/>
                <g:hiddenField name="CKEditorFuncNum" value="${params.CKEditorFuncNum}"/>
                <g:hiddenField name="langCode" value="${params.langCode}"/>
                <g:hiddenField name="referer" value="${request.forwardURI - request.contextPath}?status=${params.status ?: 'published'}&reference=${identifier?.encodeAsIsoURL()}&pattern=${pattern ?: ''}&CKEditor=${params.CKEditor}&CKEditorFuncNum=${params.CKEditorFuncNum}&langCode=${params.langCode}"/>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary"><g:message code="crmContent.button.upload.label" default="Upload"/></button>
                    <input type="file" name="file"/>
                </div>
            </g:uploadForm>

        </div>
    </div>
</div>

</body>
</html>