<ul class="breadcrumb">
    <g:each in="${path}" var="p" status="i">
        <g:if test="${i == (path.size() - 1)}">
            <li class="active">${p}</li>
        </g:if>
        <g:else>
            <li><a href="#">${p}</a> <span class="divider">/</span></li>
        </g:else>
    </g:each>
</ul>

<table class="table table-striped table-bordered crm-filebrowser">
    <thead>
    <tr>
        <th>Filnamn</th>
        <th>Filtyp</th>
        <th>Datum</th>
        <th>Beskrivning</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${files}" var="img">
        <g:set var="metadata" value="${img.metadata}"/>
        <tr data-crm-url="${crm.createResourceLink(resource: img, base: base)}">
            <td><a href="${crm.createResourceLink(resource: img, base: base)}" target="_blank">${img.title ?: img.name}</a></td>
            <td>${metadata.contentType} ${metadata.size}</td>
            <td><g:formatDate type="datetime" date="${metadata.modified}"/></td>
            <td>${img.description ?: ''}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<g:unless test="${files}">
    <h5>Inga filer</h5>
</g:unless>