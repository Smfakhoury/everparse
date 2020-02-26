module EverParse3d.Readable

module B = LowStar.Buffer
module HS = FStar.HyperStack
module HST = FStar.HyperStack.ST
module U32 = FStar.UInt32
module G = FStar.Ghost
module Seq = FStar.Seq

let perm #t b = B.lbuffer (G.erased bool) (B.length b)
  
let loc_perm #t #b p = B.loc_buffer p

let loc_perm_prop #t #b p = ()

let valid_perm h #t #b p =
  B.live h b /\
  B.loc_buffer b `B.loc_disjoint` loc_perm p /\
  B.live h p

let valid_perm_prop h #t #b p = ()

let valid_perm_frame h #t #b p l h' = ()

let perm_gsub #t #b p offset length = B.gsub p offset length

let perm_sub #t #b p offset length = B.sub p offset length

let perm_offset #t #b p offset = B.offset p offset

let perm_gsub_gsub #t #b p offset1 length1 offset2 length2 = ()

let perm_gsub_zero_length #t #b p =
  B.gsub_zero_length b;
  B.gsub_zero_length p

let loc_perm_gsub #t #b p offset length = ()

let valid_perm_gsub h #t #b p offset length = ()

let loc_perm_from_to_disjoint #t #b p from1 to1 from2 to2 = ()

let readable h #t #b p from to =
  valid_perm h p /\
  B.as_seq h (B.gsub p from (to `U32.sub` from)) `Seq.equal` Seq.create (U32.v to - U32.v from) (G.hide true)

let readable_prop h #t #b p from to = ()

let readable_gsub h #t #b p offset length from to = ()

let readable_split h #t #b p from mid to =
  Seq.lemma_split (B.as_seq h (B.gsub b from (to `U32.sub` from))) (U32.v mid - U32.v from);
  Seq.lemma_split (B.as_seq h (B.gsub p from (to `U32.sub` from))) (U32.v mid - U32.v from)

let readable_frame h #t #b p from to l h' = ()

let unreadable h #t #b p from to =
  valid_perm h p ==>
  B.as_seq h (B.gsub p from (to `U32.sub` from)) `Seq.equal` Seq.create (U32.v to - U32.v from) (G.hide false)

let unreadable_prop h #t #b p from to = ()

let readable_not_unreadable h #t #b p from to =
  let f () : Lemma
    (requires (readable h p from to /\ unreadable h p from to))
    (ensures False)
  = assert (valid_perm h p);
    let s = B.as_seq h (B.gsub p from (to `U32.sub` from)) in
    assert (s == Seq.create (U32.v to - U32.v from) (G.hide true));
    assert (Seq.index s 0 == G.hide true);
    assert (s == Seq.create (U32.v to - U32.v from) (G.hide false));
    assert (Seq.index s 0 == G.hide false);
    assert False
  in
  Classical.move_requires f ()

let unreadable_gsub h #t #b p offset length from to = ()

let unreadable_split h #t #b p from mid to =
  Seq.lemma_split (B.as_seq h (B.gsub b from (to `U32.sub` from))) (U32.v mid - U32.v from);
  Seq.lemma_split (B.as_seq h (B.gsub p from (to `U32.sub` from))) (U32.v mid - U32.v from)

let unreadable_empty h #t #b p i = ()

let unreadable_frame h #t #b p from to l h' = ()

let scrub #t #b p from to =
  B.fill (B.sub p from (to `U32.sub` from)) (G.hide false) (to `U32.sub` from)
