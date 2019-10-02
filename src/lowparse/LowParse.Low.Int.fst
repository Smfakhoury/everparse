module LowParse.Low.Int
open LowParse.Low.Combinators

module Aux = LowParse.Low.Int.Aux
module Unique = LowParse.Spec.Int.Unique
module Seq = FStar.Seq
module U8  = FStar.UInt8
module U16 = FStar.UInt16
module U32 = FStar.UInt32
module HST = FStar.HyperStack.ST
module HS = FStar.HyperStack
module B = LowStar.Buffer

inline_for_extraction
let read_u8 =
  leaf_reader_ext Aux.read_u8 parse_u8 (fun x -> Unique.parse_u8_unique x)

inline_for_extraction
let read_u16 =
  leaf_reader_ext Aux.read_u16 parse_u16 (fun x -> Unique.parse_u16_unique x)

inline_for_extraction
let read_u32 =
  leaf_reader_ext Aux.read_u32 parse_u32 (fun x -> Unique.parse_u32_unique x)

inline_for_extraction
let read_u64 =
  leaf_reader_ext Aux.read_u64 parse_u64 (fun x -> Unique.parse_u64_unique x)

inline_for_extraction
let read_u64_le =
  leaf_reader_ext Aux.read_u64_le parse_u64_le (fun x -> Unique.parse_u64_le_unique x)

inline_for_extraction
let serialize32_u8 : serializer32 serialize_u8 = fun v #rrel #rel b pos ->
  [@inline_let] let _ = Unique.serialize_u8_unique v in
  Aux.serialize32_u8 v b pos

inline_for_extraction
let serialize32_u16 : serializer32 serialize_u16 = fun v #rrel #rel b pos ->
  [@inline_let] let _ = Unique.serialize_u16_unique v in
  Aux.serialize32_u16 v b pos

inline_for_extraction
let serialize32_u32 : serializer32 serialize_u32 = fun v #rrel #rel b pos ->
  [@inline_let] let _ = Unique.serialize_u32_unique v in
  Aux.serialize32_u32 v b pos

inline_for_extraction
let serialize32_u64 : serializer32 serialize_u64 = fun v #rrel #rel b pos ->
  [@inline_let] let _ = Unique.serialize_u64_unique v in
  Aux.serialize32_u64 v b pos

inline_for_extraction
let serialize32_u64_le : serializer32 serialize_u64_le = fun v #rrel #rel b pos ->
  [@inline_let] let _ = Unique.serialize_u64_le_unique v in
  Aux.serialize32_u64_le v b pos

let write_u8 = leaf_writer_strong_of_serializer32 serialize32_u8 ()

let write_u16 = leaf_writer_strong_of_serializer32 serialize32_u16 ()

let write_u32 = leaf_writer_strong_of_serializer32 serialize32_u32 ()

let write_u64 = leaf_writer_strong_of_serializer32 serialize32_u64 ()

let write_u64_le = leaf_writer_strong_of_serializer32 serialize32_u64_le ()
