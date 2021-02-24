#include "BaseWrapper.h"
#include "EverParse.h"
#include "Base.h"
void BaseEverParseError(char *x, char *y, char *z);
static char* BaseStructNameOfErr(uint64_t err) {
	switch (EverParseFieldIdOfResult(err)) {
		case 1: return "Triangle2._point";
		case 2: return "Triangle2._point";
		case 3: return "Triangle2._triangle";
		case 4: return "Triangle._point";
		case 5: return "Triangle._point";
		case 6: return "TaggedUnion._int_payload";
		case 7: return "TaggedUnion._int_payload";
		case 8: return "TaggedUnion._int_payload";
		case 9: return "TaggedUnion._integer";
		case 10: return "Smoker._smoker";
		case 11: return "Smoker._smoker";
		case 12: return "ReadPair._Pair";
		case 13: return "ReadPair._Pair";
		case 14: return "OrderedPair._orderedPair";
		case 15: return "OrderedPair._orderedPair";
		case 16: return "HelloWorld._point";
		case 17: return "HelloWorld._point";
		case 18: return "GetFieldPtr._T";
		case 19: return "GetFieldPtr._T";
		case 20: return "Base._Pair";
		case 21: return "Base._Pair";
		case 22: return "Base._Mine";
		case 23: return "Base._Mine";
		case 24: return "Base._Dummy"; 
		default: return "";
	}
}

static char* BaseFieldNameOfErr(uint64_t err) {
	switch (EverParseFieldIdOfResult(err)) {
		case 1: return "x";
		case 2: return "y";
		case 3: return "corners";
		case 4: return "x";
		case 5: return "y";
		case 6: return "value8";
		case 7: return "value16";
		case 8: return "value32";
		case 9: return "size";
		case 10: return "age";
		case 11: return "cigarettesConsumed";
		case 12: return "first";
		case 13: return "second";
		case 14: return "lesser";
		case 15: return "greater";
		case 16: return "x";
		case 17: return "y";
		case 18: return "f1";
		case 19: return "f2";
		case 20: return "first";
		case 21: return "second";
		case 22: return "f";
		case 23: return "g";
		case 24: return "dummy"; 
		default: return "";
	}
}

BOOLEAN BaseCheckDummy(uint8_t *base, uint32_t len) {
	uint64_t result = BaseValidateDummy(len, base, 0);
	if (EverParseResultIsError(result)) {
		BaseEverParseError(
	BaseStructNameOfErr(result),
			BaseFieldNameOfErr (result),
			EverParseErrorReasonOfResult(result));
		return FALSE;
	}
	return TRUE;
}