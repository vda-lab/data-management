# Create documents from asciidoc

- from asciidoc to pdf: `asciidoctor-pdf index.adoc`
- from asciidoc to html: `asciidoctor -r asciidoctor-multipage -b multipage_html5 index.adoc`

Or better: use

- `make index.html`
- `make index.pdf`
- `make clean`