module Employee

(* This file has been automatically generated by EverParse. *)
open FStar.Bytes
module U8 = FStar.UInt8
module U16 = FStar.UInt16
module U32 = FStar.UInt32
module U64 = FStar.UInt64
module LP = LowParse.Spec.Base
module LPI = LowParse.Spec.AllIntegers
module L = FStar.List.Tot
module BY = FStar.Bytes


(* Type of field name*)
include Employee_name

type employee = {
  name : employee_name;
  salary : U16.t;
}

inline_for_extraction noextract let employee_parser_kind = LP.strong_parser_kind 4 258 None

val employee_parser: LP.parser employee_parser_kind employee

noextract val employee_serializer: LP.serializer employee_parser

noextract val employee_bytesize (x:employee) : GTot nat

noextract val employee_bytesize_eq (x:employee) : Lemma (employee_bytesize x == Seq.length (LP.serialize employee_serializer x))