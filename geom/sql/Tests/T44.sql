-- Conformance Item T44
SELECT Contains(forests.boundary, named_places.boundary) FROM forests, named_places WHERE forests.name = 'Green Forest' AND named_places.name = 'Ashton';
