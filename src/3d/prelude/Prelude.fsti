(*
   Copyright 2019 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
module Prelude
include Prelude.StaticHeader
include ResultOps
module U32 = FStar.UInt32
module U16 = FStar.UInt16
module U64 = FStar.UInt64

////////////////////////////////////////////////////////////////////////////////
// Some generic helpers
////////////////////////////////////////////////////////////////////////////////
let is_range_okay (size offset access_size:U32.t)
  : bool
  = let open U32 in
    size >=^ access_size &&
    size -^ access_size >=^ offset

////////////////////////////////////////////////////////////////////////////////
// Parsers
////////////////////////////////////////////////////////////////////////////////

inline_for_extraction
noextract
val parser_kind (nz:bool) : Type0

inline_for_extraction
noextract
val parser (#nz:bool) (k:parser_kind nz) (t:Type0) : Type0

inline_for_extraction
noextract
val glb (#nz1:bool) (k1:parser_kind nz1)
        (#nz2:bool) (k2:parser_kind nz2)
    : parser_kind (nz1 && nz2)

/// Parser: return
inline_for_extraction
noextract
val ret_kind : parser_kind false

inline_for_extraction noextract
val parse_ret (#t:Type) (v:t)
  : Tot (parser ret_kind t)

/// Parser: bind
inline_for_extraction
noextract
val and_then_kind (#nz1:_) (k1:parser_kind nz1)
                  (#nz2:_) (k2:parser_kind nz2)
    : parser_kind (nz1 || nz2)

inline_for_extraction noextract
val parse_dep_pair (#nz1:_) (#k1:parser_kind nz1) (#t1: Type0) (p1: parser k1 t1)
                   (#nz2:_) (#k2:parser_kind nz2) (#t2: (t1 -> Tot Type0)) (p2: (x: t1) -> parser k2 (t2 x))
  : Tot (parser (and_then_kind k1 k2) (dtuple2 t1 t2) )

/// Parser: sequencing
inline_for_extraction noextract
val parse_pair (#nz1:_) (#k1:parser_kind nz1) (#t1:_) (p1:parser k1 t1)
               (#nz2:_) (#k2:parser_kind nz2) (#t2:_) (p2:parser k2 t2)
  : Tot (parser (and_then_kind k1 k2) (t1 * t2))

/// Parser: filter
let refine t (f:t -> bool) = x:t{f x}

inline_for_extraction
noextract
val filter_kind (#nz:_) (k:parser_kind nz) : parser_kind nz

inline_for_extraction noextract
val parse_filter (#nz:_) (#k:parser_kind nz) (#t:_) (p:parser k t) (f:(t -> bool))
  : Tot (parser (filter_kind k) (refine t f))


inline_for_extraction noextract
val parse_weaken_left (#nz:_)  (#k:parser_kind nz) (#t:_) (p:parser k t)
                      (#nz':_) (k':parser_kind nz')
  : Tot (parser (glb k' k) t)

inline_for_extraction noextract
val parse_weaken_right (#nz:_)  (#k:parser_kind nz) (#t:_) (p:parser k t)
                       (#nz':_) (k':parser_kind nz')
  : Tot (parser (glb k k') t)

inline_for_extraction
noextract
val impos_kind : parser_kind true

/// Parser: unreachable, for default cases of exhaustive pattern matching
inline_for_extraction noextract
val parse_impos (_:unit)
  : parser impos_kind False

let t_ite (e:bool) (a:Type) (b:Type) = if e then a else b

val parse_ite (#nz:_) (#k:parser_kind nz) (#a:Type) (#b:Type) (e:bool)
              (p1:squash e -> parser k a)
              (p2:squash (not e) -> parser k b)
  : Tot (parser k (t_ite e a b))

////////////////////////////////////////////////////////////////////////////////
// Variable-sized list whose size in bytes is exactly n
////////////////////////////////////////////////////////////////////////////////
val nlist (n:U32.t) (t:Type0) : Type0

/// Lists/arrays
inline_for_extraction
noextract
val kind_nlist : parser_kind false

inline_for_extraction noextract
val parse_nlist (n:U32.t) (#k:parser_kind true) (#t:_) (p:parser k t)
  : Tot (parser kind_nlist (nlist n t))


////////////////////////////////////////////////////////////////////////////////
// Variable-sized element whose size in bytes is at most n
////////////////////////////////////////////////////////////////////////////////
val t_at_most (n:U32.t) (t:Type0) : Type0

/// Lists/arrays
inline_for_extraction
noextract
val kind_t_at_most : parser_kind false

inline_for_extraction noextract
val parse_t_at_most (n:U32.t) (#k:parser_kind true) (#t:_) (p:parser k t)
  : Tot (parser kind_t_at_most (t_at_most n t))

////////////////////////////////////////////////////////////////////////////////
// Readers
////////////////////////////////////////////////////////////////////////////////

inline_for_extraction noextract
val reader (#nz:_) (#k:parser_kind nz) (#t:_) (p:parser k t) : Type u#1

inline_for_extraction noextract
val read_filter (#nz:_)
                (#k: parser_kind nz)
                (#t: Type0)
                (#p: parser k t)
                (p32: reader p)
                (f: (t -> bool))
    : reader (parse_filter p f)

////////////////////////////////////////////////////////////////////////////////
// Base types
////////////////////////////////////////////////////////////////////////////////


/// UINT8
let ___UINT8 : eqtype = FStar.UInt8.t
inline_for_extraction noextract
val kind____UINT8 : parser_kind true
val parse____UINT8 : parser kind____UINT8 ___UINT8
val read____UINT8 : reader parse____UINT8

/// UInt16
let ___UINT16 : eqtype = U16.t
inline_for_extraction noextract
val kind____UINT16 : parser_kind true
val parse____UINT16 : parser kind____UINT16 ___UINT16
val read____UINT16 : reader parse____UINT16

/// UInt32
let ___UINT32 : eqtype = U32.t
inline_for_extraction noextract
val kind____UINT32 : parser_kind true
val parse____UINT32 : parser kind____UINT32 ___UINT32
val read____UINT32 : reader parse____UINT32

/// UInt64
let ___UINT64 : eqtype = U64.t
inline_for_extraction noextract
val kind____UINT64 : parser_kind true
val parse____UINT64 : parser kind____UINT64 ___UINT64
val read____UINT64 : reader parse____UINT64

inline_for_extraction noextract
let kind_unit : parser_kind false = ret_kind
let parse_unit : parser kind_unit unit = parse_ret ()
inline_for_extraction noextract
val read_unit
  : reader (parse_ret ())

////////////////////////////////////////////////////////////////////////////////
//Convenience lemmas for bounded arithmetic, especially on bitfields
////////////////////////////////////////////////////////////////////////////////

let max_int_sizes
  : squash FStar.UInt.(
      max_int 10 == 1023 /\
      max_int 8 == 255
    )
  = let open FStar.UInt in
    normalize_term_spec (max_int 10)