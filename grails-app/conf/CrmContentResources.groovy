modules = {
    fileuploader {
        resource url: 'js/fileuploader.js'
        resource url: 'css/fileuploader.css'
    }
    fileupload {
        dependsOn 'jquery'
        resource url: "css/jquery.fileupload.css"
        resource url: "js/jquery.ui.widget.js", attrs: [order: 10]
        resource url: "js/load-image.min.js", attrs: [order: 20]
        resource url: "js/jquery.iframe-transport.js", attrs: [order: 30]
        resource url: "js/jquery.fileupload.js", attrs: [order: 40]
        resource url: "js/jquery.fileupload-process.js", attrs: [order: 50]
        resource url: "js/jquery.fileupload-image.js", attrs: [order: 60]
        resource url: "js/canvas-to-blob.min.js", attrs: [order: 70]
    }
}
