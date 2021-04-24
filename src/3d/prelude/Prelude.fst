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
module BF = LowParse.BitFields
module LP = LowParse.Spec.Base
module LPC = LowParse.Spec.Combinators
module LPL = LowParse.Low.Base
module LPLC = LowParse.Low.Combinators
module U16 = FStar.UInt16
module U32 = FStar.UInt32
module U64 = FStar.UInt64

////////////////////////////////////////////////////////////////////////////////
// Parsers
////////////////////////////////////////////////////////////////////////////////

let parser_kind_prop
  (nz: bool)
  (wk: weak_kind)
  (k: LP.parser_kind)
: Tot prop
= (nz ==> (k.LP.parser_kind_low > 0)) /\
  begin match wk with
  | WeakKindStrongPrefix -> k.LP.parser_kind_subkind == Some LP.ParserStrong
  | WeakKindConsumesAll -> k.LP.parser_kind_subkind == Some LP.ParserConsumesAll
  | _ -> True
  end

inline_for_extraction
noextract
let parser_kind (nz:bool) (wk: weak_kind) =
  k:LP.parser_kind { parser_kind_prop nz wk k }

let parser k t = LP.parser k t

let is_weaker_than #nz1 #wk1 (k:parser_kind nz1 wk1)
                   #nz2 #wk2 (k':parser_kind nz2 wk2) = k `LP.is_weaker_than` k'

inline_for_extraction
noextract
let glb k1 k2
    = LP.glb k1 k2

let is_weaker_than_refl #nz #wk (k:parser_kind nz wk)
  : Lemma (ensures (is_weaker_than k k))
          [SMTPat (is_weaker_than k k)]
  = ()

let is_weaker_than_glb #nz1 #wk1 (k1:parser_kind nz1 wk1)
                       #nz2 #wk2 (k2:parser_kind nz2 wk2)
  : Lemma (is_weaker_than (glb k1 k2) k1 /\
           is_weaker_than (glb k1 k2) k2)
          [SMTPatOr
            [[SMTPat (is_weaker_than (glb k1 k2) k1)];
             [SMTPat (is_weaker_than (glb k1 k2) k2)]]]
  = ()

/// Parser: return
inline_for_extraction
noextract
let ret_kind = LPC.parse_ret_kind
inline_for_extraction noextract
let parse_ret #t (v:t)
  : Tot (parser ret_kind t)
  = LPC.parse_ret #t v

/// Parser: bind
inline_for_extraction
noextract
let and_then_kind k1 k2
    = LPC.and_then_kind k1 k2
inline_for_extraction noextract
let parse_dep_pair p1 p2
  = LPC.parse_dtuple2 p1 p2

/// Parser: sequencing
inline_for_extraction noextract
let parse_pair p1 p2
  = LPC.nondep_then p1 p2

/// Parser: map
let injective_map a b = (a -> Tot b) //{LPC.synth_injective f}

inline_for_extraction
noextract
let filter_kind k = LPC.parse_filter_kind k
inline_for_extraction noextract
let parse_filter p f
  = LPC.parse_filter p f

/// Parser: weakening kinds
inline_for_extraction noextract
let parse_weaken #nz #wk (#k:parser_kind nz wk) #t (p:parser k t)
                 #nz' #wk' (k':parser_kind nz' wk' {k' `is_weaker_than` k})
  : Tot (parser k' t)
  = LP.weaken k' p

/// Parser: weakening kinds
inline_for_extraction noextract
let parse_weaken_left #nz #wk #k p k'
  = LP.weaken (glb k' k) p

/// Parser: weakening kinds
inline_for_extraction noextract
let parse_weaken_right #nz #wk #k p k'
  = LP.weaken (glb k k') p

inline_for_extraction
noextract
let impos_kind =
  LPC.(strong_parser_kind 1 1 (Some ParserKindMetadataFail))

/// Parser: unreachable, for default cases of exhaustive pattern matching
inline_for_extraction noextract
let parse_impos ()
  : parser impos_kind False
  = let p : LP.bare_parser False = fun b -> None in
    LP.parser_kind_prop_equiv impos_kind p;
    p

let parse_ite e p1 p2
  = if e then p1 () else p2 ()


let nlist (n:U32.t) (t:Type) = list t

/// Lists/arrays
inline_for_extraction
noextract
let kind_nlist =
  let open LP in
  {
    parser_kind_low = 0;
    parser_kind_high = None;
    parser_kind_subkind = Some ParserStrong;
    parser_kind_metadata = None
  }

inline_for_extraction noextract
let parse_nlist n #wk #k #t p
  = let open LowParse.Spec.FLData in
    let open LowParse.Spec.List in
    parse_weaken
            #false #WeakKindStrongPrefix #(parse_fldata_kind (U32.v n) parse_list_kind) #(list t)
            (LowParse.Spec.FLData.parse_fldata (LowParse.Spec.List.parse_list p) (U32.v n))
            #false kind_nlist

////////////////////////////////////////////////////////////////////////////////
module B32 = FStar.Bytes
let t_at_most (n:U32.t) (t:Type) = t & B32.bytes
let kind_t_at_most = kind_nlist
inline_for_extraction noextract
let parse_t_at_most n #wk #k #t p
  = let open LowParse.Spec.FLData in
    let open LowParse.Spec.List in
    parse_weaken
            #false 
            #WeakKindStrongPrefix
            (LowParse.Spec.FLData.parse_fldata 
                (LPC.nondep_then p LowParse.Spec.Bytes.parse_all_bytes)
                (U32.v n))
            #false
            kind_t_at_most

////////////////////////////////////////////////////////////////////////////////
let t_exact (n:U32.t) (t:Type) = t
let kind_t_exact = kind_nlist
inline_for_extraction noextract
let parse_t_exact n #nz #wk #k #t p
  = let open LowParse.Spec.FLData in
    let open LowParse.Spec.List in
    parse_weaken
            #false 
            #WeakKindStrongPrefix
            (LowParse.Spec.FLData.parse_fldata 
                p
                (U32.v n))
            #false
            kind_t_exact

////////////////////////////////////////////////////////////////////////////////
// Readers
////////////////////////////////////////////////////////////////////////////////

inline_for_extraction noextract
let reader p = LPLC.leaf_reader p

inline_for_extraction noextract
let read_filter p32 f
    = LPLC.read_filter p32 f

// ////////////////////////////////////////////////////////////////////////////////
// // Validators
// ////////////////////////////////////////////////////////////////////////////////
inline_for_extraction noextract
let validator #nz #wk (#k:parser_kind nz wk) (#t:Type) (p:parser k t)
  : Type
  = LPL.validator #k #t p

inline_for_extraction noextract
let validator_no_read #nz #wk (#k:parser_kind nz wk) (#t:Type) (p:parser k t)
  : Type
  = LPL.validator_no_read #k #t p

let parse_nlist_total_fixed_size_aux
  (n:U32.t) (#wk: _) (#k:parser_kind true wk) #t (p:parser k t)
  (x: LP.bytes)
: Lemma
  (requires (
    let open LP in
    k.parser_kind_subkind == Some ParserStrong /\
    k.parser_kind_high == Some k.parser_kind_low /\
    U32.v n % k.parser_kind_low == 0 /\
    k.parser_kind_metadata == Some ParserKindMetadataTotal /\
    Seq.length x >= U32.v n
  ))
  (ensures (
    Some? (LP.parse (parse_nlist n p) x)
  ))
= let x' = Seq.slice x 0 (U32.v n) in
  LowParse.Spec.List.parse_list_total_constant_size p (U32.v n / k.LP.parser_kind_low) x';
  LP.parser_kind_prop_equiv LowParse.Spec.List.parse_list_kind (LowParse.Spec.List.parse_list p)

let parse_nlist_total_fixed_size_kind_correct
  (n:U32.t) (#wk: _) (#k:parser_kind true wk) #t (p:parser k t)
: Lemma
  (requires (
    let open LP in
    k.parser_kind_subkind == Some ParserStrong /\
    k.parser_kind_high == Some k.parser_kind_low /\
    U32.v n % k.parser_kind_low == 0 /\
    k.parser_kind_metadata == Some ParserKindMetadataTotal
  ))
  (ensures (
    LP.parser_kind_prop (LP.total_constant_size_parser_kind (U32.v n)) (parse_nlist n p)
  ))
= LP.parser_kind_prop_equiv (LowParse.Spec.FLData.parse_fldata_kind (U32.v n) LowParse.Spec.List.parse_list_kind) (parse_nlist n p);
  LP.parser_kind_prop_equiv (LP.total_constant_size_parser_kind (U32.v n)) (parse_nlist n p);
  Classical.forall_intro (Classical.move_requires (parse_nlist_total_fixed_size_aux n p))

inline_for_extraction noextract
let validate_nlist_total_constant_size_mod_ok (n:U32.t) #wk (#k:parser_kind true wk) (#t: Type) (p:parser k t)
  : Pure (validator_no_read (parse_nlist n p))
  (requires (
    let open LP in
    k.parser_kind_subkind == Some ParserStrong /\
    k.parser_kind_high == Some k.parser_kind_low /\
    k.parser_kind_metadata == Some ParserKindMetadataTotal /\
    k.parser_kind_low < 4294967296 /\
    U32.v n % k.LP.parser_kind_low == 0
  ))
  (ensures (fun _ -> True))
= 
      (fun #rrel #rel sl len pos ->
         let h = FStar.HyperStack.ST.get () in
         [@inline_let]
         let _ =
           parse_nlist_total_fixed_size_kind_correct n p;
           LPL.valid_facts (parse_nlist n p) h sl (LPL.uint64_to_uint32 pos);
           LPL.valid_facts (LP.strengthen (LP.total_constant_size_parser_kind (U32.v n)) (parse_nlist n p)) h sl (LPL.uint64_to_uint32 pos)
         in
         LPL.validate_total_constant_size_no_read (LP.strengthen (LP.total_constant_size_parser_kind (U32.v n)) (parse_nlist n p)) (FStar.Int.Cast.uint32_to_uint64 n) () sl len pos
      )

inline_for_extraction noextract
let validate_nlist_constant_size_mod_ko (n:U32.t) (#wk: _) (#k:parser_kind true wk) #t (p:parser k t)
  : Pure (validator_no_read (parse_nlist n p))
  (requires (
    let open LP in
    k.parser_kind_subkind == Some ParserStrong /\
    k.parser_kind_high == Some k.parser_kind_low /\
    U32.v n % k.LP.parser_kind_low <> 0
  ))
  (ensures (fun _ -> True))
= 
  (fun #rrel #rel sl len pos ->
     let h = FStar.HyperStack.ST.get () in
     [@inline_let]
     let _ =
       LPL.valid_facts (parse_nlist n p) h sl (LPL.uint64_to_uint32 pos)
     in
     [@inline_let]
     let f () : Lemma
       (requires (LPL.valid (parse_nlist n p) h sl (LPL.uint64_to_uint32 pos)))
       (ensures False)
     = let sq = LPL.bytes_of_slice_from h sl (LPL.uint64_to_uint32 pos) in
       let sq' = Seq.slice sq 0 (U32.v n) in
       LowParse.Spec.List.list_length_constant_size_parser_correct p sq' ;
       let Some (l, _) = LP.parse (parse_nlist n p) sq in
       assert (U32.v n == FStar.List.Tot.length l `Prims.op_Multiply` k.LP.parser_kind_low) ;
       FStar.Math.Lemmas.cancel_mul_mod (FStar.List.Tot.length l) k.LP.parser_kind_low ;
       assert (U32.v n % k.LP.parser_kind_low == 0)
     in
     [@inline_let]
     let _ = Classical.move_requires f () in
     validator_error_list_size_not_multiple
  )

inline_for_extraction noextract
let validate_nlist_total_constant_size' (n:U32.t) #wk (#k:parser_kind true wk) #t (p:parser k t)
  : Pure (validator_no_read (parse_nlist n p))
  (requires (
    let open LP in
    k.parser_kind_subkind == Some ParserStrong /\
    k.parser_kind_high == Some k.parser_kind_low /\
    k.parser_kind_metadata == Some ParserKindMetadataTotal /\
    k.parser_kind_low < 4294967296
  ))
  (ensures (fun _ -> True))
= fun #rrel #rel sl len pos ->
  if n `U32.rem` U32.uint_to_t k.LP.parser_kind_low = 0ul
  then validate_nlist_total_constant_size_mod_ok n p sl len pos
  else validate_nlist_constant_size_mod_ko n p sl len pos

inline_for_extraction noextract
let validate_nlist_total_constant_size (n_is_const: bool) (n:U32.t) #wk (#k:parser_kind true wk) (#t: Type) (p:parser k t)
: Pure (validator_no_read (parse_nlist n p))
  (requires (
    let open LP in
    k.parser_kind_subkind = Some ParserStrong /\
    k.parser_kind_high = Some k.parser_kind_low /\
    k.parser_kind_metadata = Some ParserKindMetadataTotal /\
    k.parser_kind_low < 4294967296
  ))
  (ensures (fun _ -> True))
=
  if
    if k.LP.parser_kind_low = 1
    then true
    else if n_is_const
    then U32.v n % k.LP.parser_kind_low = 0
    else false
  then
    validate_nlist_total_constant_size_mod_ok n p
  else if
    if n_is_const
    then U32.v n % k.LP.parser_kind_low <> 0
    else false
  then
    validate_nlist_constant_size_mod_ko n p
  else
    validate_nlist_total_constant_size' n p

module LUT = LowParse.Spec.ListUpTo

inline_for_extraction
noextract
let cond_string_up_to
  (#t: eqtype)
  (terminator: t)
  (x: t)
: Tot bool
= x = terminator

let cstring
  (t: eqtype)
  (terminator: t)
: Tot Type0
= LUT.parse_list_up_to_t (cond_string_up_to terminator)

let parse_string_kind = {
  LP.parser_kind_low = 1;
  LP.parser_kind_high = None;
  LP.parser_kind_subkind = Some LP.ParserStrong;
  LP.parser_kind_metadata = None;
}

let parse_string
  #k #t p terminator
=
  LowParse.Spec.Base.parser_kind_prop_equiv k p;
  LP.weaken parse_string_kind (LUT.parse_list_up_to (cond_string_up_to terminator) p (fun _ _ _ -> ()))


let all_bytes = B32.bytes
let parse_all_bytes_kind = LowParse.Spec.Bytes.parse_all_bytes_kind
let parse_all_bytes = LowParse.Spec.Bytes.parse_all_bytes

inline_for_extraction noextract
let is_zero (x: FStar.UInt8.t) : Tot bool = x = 0uy

let all_zeros = list (LowParse.Spec.Combinators.parse_filter_refine is_zero)
let parse_all_zeros_kind = LowParse.Spec.List.parse_list_kind
let parse_all_zeros = LowParse.Spec.List.parse_list (LowParse.Spec.Combinators.parse_filter LowParse.Spec.Int.parse_u8 is_zero)


////////////////////////////////////////////////////////////////////////////////
// Base types
////////////////////////////////////////////////////////////////////////////////

/// UINT8
inline_for_extraction noextract
let kind____UINT8 = LowParse.Spec.Int.parse_u8_kind
let parse____UINT8 = LowParse.Spec.Int.parse_u8
let read____UINT8 = LowParse.Low.Int.read_u8

/// UInt16BE
inline_for_extraction noextract
let kind____UINT16BE = LowParse.Spec.BoundedInt.parse_u16_kind
let parse____UINT16BE = LowParse.Spec.Int.parse_u16
let read____UINT16BE = LowParse.Low.Int.read_u16

/// UInt32BE
inline_for_extraction noextract
let kind____UINT32BE = LowParse.Spec.BoundedInt.parse_u32_kind
let parse____UINT32BE = LowParse.Spec.Int.parse_u32
let read____UINT32BE = LowParse.Low.Int.read_u32

/// UInt64BE
inline_for_extraction noextract
let kind____UINT64BE = LowParse.Spec.Int.parse_u64_kind
let parse____UINT64BE = LowParse.Spec.Int.parse_u64
let read____UINT64BE = LowParse.Low.Int.read_u64


/// UInt16
inline_for_extraction noextract
let kind____UINT16 = LowParse.Spec.BoundedInt.parse_u16_kind
let parse____UINT16 = LowParse.Spec.BoundedInt.parse_u16_le
let read____UINT16 = LowParse.Low.BoundedInt.read_u16_le

/// UInt32
inline_for_extraction noextract
let kind____UINT32 = LowParse.Spec.BoundedInt.parse_u32_kind
let parse____UINT32 = LowParse.Spec.BoundedInt.parse_u32_le
let read____UINT32 = LowParse.Low.BoundedInt.read_u32_le


/// UInt64
inline_for_extraction noextract
let kind____UINT64 = LowParse.Spec.Int.parse_u64_kind
let parse____UINT64 = LowParse.Spec.Int.parse_u64_le
let read____UINT64 = LowParse.Low.Int.read_u64_le
  
inline_for_extraction noextract
let read_unit
  : LPL.leaf_reader (parse_ret ())
  = LPLC.read_ret ()
