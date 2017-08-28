CKEDITOR.addTemplates("crm", {
        // The name of sub folder which hold the shortcut preview images of the
        // templates.
        imagesPath: CKEDITOR.getUrl(CKEDITOR.plugins.getPath('templates') + 'templates/images/'),

        // The templates definitions.
        templates: [
        <g:each in="${files}" var="file" status="i">
            ${i ? ',' : ''} {
            title: "${file.title}",
            image: 'template1.gif',
            description: "${file.description}",
            html: '${raw(file.text.readLines().collect{it.replace('\'', '\\\'')}.join("'\n + '"))}'
        }
        </g:each>
        ]
    }
);