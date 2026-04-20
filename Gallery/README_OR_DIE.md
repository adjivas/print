file me.jpg
cwebp me.jpg -o myself.webp
dwebp the-battery.webp -o the-battery.png

    - gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=/tmp/mouse-gallery-compressed.fr.pdf public/mouse/gallery.fr.pdf
    - gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=/tmp/navi-gallery-compressed.fr.pdf public/navi/gallery.fr.pdf
    - cp -f /tmp/mouse-gallery-compressed.fr.pdf public/mouse/gallery.fr.pdf
    - cp -f /tmp/navi-gallery-compressed.fr.pdf public/navi/gallery.fr.pdf
