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

<g:set var="rows" value="${files.collate(4)}"/>
<g:each in="${rows}" var="row">
    <ul class="thumbnails crm-filebrowser">
        <g:each in="${row}" var="img">
            <g:set var="metadata" value="${img.metadata}"/>
            <li class="span3">
                <a href="${crm.createResourceLink(resource: img, base: base)}" class="thumbnail" style="min-height: 150px;" target="_blank">
                    <img src="${crm.createResourceLink(resource: img)}"
                         width="150" height="120" alt="${img.title ?: img.name}"/>
                </a>
                <h5 class="center"><a href="${crm.createResourceLink(resource: img, base: base)}" target="_blank">${img.title ?: img.name}</a></h5>

                <p class="muted center">
                    ${metadata.contentType} ${metadata.size}<br/>
                    <g:formatDate type="datetime" date="${metadata.modified}"/>
                </p>

                <p>${img.description ?: ''}</p>
            </li>
        </g:each>
    </ul>
</g:each>

<g:unless test="${files}">
    <h5>Inga bilder</h5>
</g:unless>