#include "EverParse.h"
#include "BoundedSumWhere.h"
void BoundedSumWhereEverParseError(char *x, char *y, char *z);
static char* BoundedSumWhereStructNameOfErr(uint64_t err) {
	switch (EverParseFieldIdOfResult(err)) {
		case 1: return "_boundedSum";
		case 2: return "_boundedSum";
		case 3: return "_boundedSum"; 
		default: return "";
	}
}

static char* BoundedSumWhereFieldNameOfErr(uint64_t err) {
	switch (EverParseFieldIdOfResult(err)) {
		case 1: return "__precondition";
		case 2: return "left";
		case 3: return "right"; 
		default: return "";
	}
}

BOOLEAN BoundedSumWhereCheckBoundedSum(uint32_t bound, uint8_t *base, uint32_t len) {
	InputBuffer s;
	s.base = base;
	s.len = len;
	uint64_t result = BoundedSumWhereValidateBoundedSum(bound, s, 0);
	if (EverParseResultIsError(result)) {
		BoundedSumWhereEverParseError(
	BoundedSumWhereStructNameOfErr(result),
			BoundedSumWhereFieldNameOfErr (result),
			EverParseErrorReasonOfResult(result));
		return FALSE;
	}
	return TRUE;
}

