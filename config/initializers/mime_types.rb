# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "application/vnd.oasis.opendocument.text", :odt

CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST = [
  "video/3gpp2",  # .3g2,3GPP2 audio/video container
  "audio/3gpp2",  # .3g2,3GPP2 audio/video container
  "video/3gpp", # .3gp,3GPP audio/video container
  "audio/3gpp", # .3gp,3GPP audio/video container
  "application/x-7z-compressed", # .7z,7-zip archive
  "audio/aac", # .aac,AAC audio
  "application/x-abiword",  # .abw,AbiWord document
  "application/x-freearc",  # .arc,Archive document (multiple files embedded)
  "video/x-msvideo", # .avi,AVI: Audio Video Interleave
  "image/avif", # .avif,AVIF image
  "application/vnd.amazon.ebook", # .azw,Amazon Kindle eBook format
  # "application/octet-stream", # .bin,Any kind of binary data
  "image/bmp", # .bmp,Windows OS/2 Bitmap Graphics
  "application/x-bzip", # .bz,BZip archive
  "application/x-bzip2", # .bz2,BZip2 archive
  "application/x-cdf", # .cda,CD audio
  # "application/x-csh",  # .csh,C-Shell script
  # "text/css", # .css,Cascading Style Sheets (CSS)
  "text/csv", # .csv,Comma-separated values (CSV)
  "application/msword", # .doc,Microsoft Word
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document", # .docx,Microsoft Word (OpenXML)
  # "application/vnd.ms-fontobject",  # .eot,MS Embedded OpenType fonts
  "application/epub+zip", # .epub,Electronic publication (EPUB)
  "image/gif", # .gif,Graphics Interchange Format (GIF)
  "application/gzip", # .gz,GZip Compressed Archive
  "text/html", # .htm .html,HyperText Markup Language (HTML)
  "image/vnd.microsoft.icon", # .ico,Icon format
  "text/calendar", # .ics,iCalendar format
  # "application/java-archive", # .jar,Java Archive (JAR)
  "image/jpeg", # .jpeg .jpg,JPEG images
  # "text/javascript",  # .js,JavaScript
  "application/json", # .json,JSON format
  "application/ld+json", # .jsonld,JSON-LD format
  "audio/midi", # .mid,Musical Instrument Digital Interface (MIDI)
  "audio/x-midi", # .midi,Musical Instrument Digital Interface (MIDI)
  # "text/javascript", # .js/.mjs,JavaScript / Javascript module
  "audio/mpeg", # .mp3,MP3 audio
  "video/mp4",  # .mp4,MP4 video
  "video/mpeg", # .mpeg,MPEG Video
  # "application/vnd.apple.installer+xml",  # .mpkg,Apple Installer Package
  "application/vnd.oasis.opendocument.presentation", # .odp,OpenDocument presentation document
  "application/vnd.oasis.opendocument.spreadsheet", # .ods,OpenDocument spreadsheet document
  "application/vnd.oasis.opendocument.text", # .odt,OpenDocument text document
  "audio/ogg",  # .oga,OGG audio
  "video/ogg",  # .ogv,OGG video
  "application/ogg", # .ogx,OGG
  "audio/opus", # .opus,Opus audio
  "font/otf", # .otf,OpenType font
  "application/pdf", # .pdf,Adobe Portable Document Format (PDF)
  # "application/x-httpd-php",  # .php,Hypertext Preprocessor (Personal Home Page)
  "image/png", # .png,Portable Network Graphics
  "application/vnd.ms-powerpoint", # .ppt,Microsoft PowerPoint
  "application/vnd.openxmlformats-officedocument.presentationml.presentation", # .pptx,Microsoft PowerPoint (OpenXML)
  "application/vnd.rar", # .rar,RAR archive
  "application/rtf", # .rtf,Rich Text Format (RTF)
  # "application/x-sh", # .sh,Bourne shell script
  "image/svg+xml", # .svg,Scalable Vector Graphics (SVG)
  # "application/x-shockwave-flash",  # .swf,Small web format (SWF) or Adobe Flash document
  "application/x-tar", # .tar,Tape Archive (TAR)
  "image/tiff", # .tif .tiff,Tagged Image File Format (TIFF)
  "video/mp2t", # .ts,MPEG transport stream
  "font/ttf", # .ttf,TrueType Font
  "text/plain", # .txt,Text
  "application/vnd.visio", # .vsd,Microsoft Visio
  "audio/wav",  # .wav,Waveform Audio Format
  "audio/webm", # .weba,WEBM audio
  "video/webm", # .webm,WEBM video
  "image/webp", # .webp,WEBP image
  # "font/woff",  # .woff,Web Open Font Format (WOFF)
  # "font/woff2", # .woff2,Web Open Font Format (WOFF)
  "application/xhtml+xml", # .xhtml,XHTML
  "application/vnd.ms-excel", # .xls,Microsoft Excel
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", # .xlsx,Microsoft Excel (OpenXML)
  "application/xml", # .xml,XML
  "application/vnd.mozilla.xul+xml", # .xul,XUL
  "application/zip", # .zip,ZIP archive
].freeze

OUTLOOK_MESSAGE_FILE_TYPE_ALLOW_LIST = CASE_ATTACHMENT_FILE_TYPE_ALLOW_LIST
