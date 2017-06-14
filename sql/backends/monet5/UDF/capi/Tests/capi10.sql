
# test blob type

START TRANSACTION;

# blob
# blobs have the type:
#typedef struct {
#	size_t size;
#	void* data;
#} cudf_data_blob;

CREATE FUNCTION capi10(inp BLOB) RETURNS BLOB LANGUAGE C {
	result->initialize(result, inp.count);
	for(size_t i = 0; i < inp.count; i++) {
		if (inp.is_null(inp.data[i])) {
			result->data[i] = result->null_value;
		} else {
			result->data[i].data = malloc(inp.data[i].size);
			memcpy(result->data[i].data, inp.data[i].data, inp.data[i].size);
			result->data[i].size = inp.data[i].size;
		}
	}
};

CREATE TABLE blobs(i BLOB);
INSERT INTO blobs VALUES (BLOB '00FFFF00'), (NULL), (BLOB '');

SELECT capi10(i) FROM blobs;

DROP FUNCTION capi10;

# attempt to modify input of blobs
CREATE FUNCTION capi10(inp BLOB) RETURNS BLOB LANGUAGE C {
	result->initialize(result, inp.count);
	for(size_t i = 0; i < inp.count; i++) {
		if (inp.data[i].data && inp.data[i].size > 0) {
			((char*)inp.data[i].data)[0] = 'h';
		}
	}
};
SELECT capi10(i) FROM blobs;
ROLLBACK;
