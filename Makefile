index.html: index.adoc rdbms.adoc nosql.adoc arangodb.adoc arangodb_apis.adoc $(wildcard assets/*)
	asciidoctor -r asciidoctor-multipage -b multipage_html5 index.adoc

index.pdf: index.adoc rdbms.adoc nosql.adoc arangodb.adoc arangodb_apis.adoc $(wildcard assets/*)
	asciidoctor-pdf index.adoc

clean:
	rm _*.html
	rm index.html
	rm index.pdf
