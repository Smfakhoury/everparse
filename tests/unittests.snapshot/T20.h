/* 
  This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
  KreMLin invocation: krml -I ../../src/lowparse -skip-compilation -tmpdir ../unittests.snapshot -bundle LowParse.\* -drop FStar.Tactics.\* -drop FStar.Reflection.\* T10.fst T11.fst T11_z.fst T12.fst T12_z.fst T13.fst T13_x.fst T14.fst T14_x.fst T15_body.fst T15.fst T16.fst T16_x.fst T17.fst T17_x_a.fst T17_x_b.fst T18.fst T18_x_a.fst T18_x_b.fst T19.fst T1.fst T20.fst T21.fst T22_body_a.fst T22_body_b.fst T22.fst T23.fst T24.fst T24_y.fst T25_bpayload.fst T25.fst T25_payload.fst T26.fst T27.fst T28.fst T29.fst T2.fst T30.fst T31.fst T32.fst T33.fst T34.fst T35.fst T36.fst T3.fst T4.fst T5.fst T6.fst T6le.fst T7.fst T8.fst T8_z.fst T9_b.fst T9.fst Tag2.fst Tag.fst Tagle.fst -warn-error +9
  F* version: 74c6d2a5
  KreMLin version: 1bd260eb
 */

#include "kremlib.h"
#ifndef __T20_H
#define __T20_H

#include "LowParse.h"
#include "T4.h"
#include "T11_z.h"
#include "Tag2.h"


#define T20_X_x 0
#define T20_X_y 1
#define T20_X_w 2
#define T20_X_v 3
#define T20_X_t 4
#define T20_X_z 5
#define T20_X_Unknown_tag2 6

typedef uint8_t T20_t20__tags;

typedef struct T20_t20__s
{
  T20_t20__tags tag;
  union {
    Prims_list__FStar_Bytes_bytes *case_X_y;
    uint16_t case_X_w;
    uint16_t case_X_v;
    uint16_t case_X_t;
    uint16_t case_X_z;
    struct 
    {
      uint8_t v;
      uint16_t x;
    }
    case_X_Unknown_tag2;
  }
  ;
}
T20_t20_;

bool T20_uu___is_X_x(T20_t20_ projectee);

bool T20_uu___is_X_y(T20_t20_ projectee);

Prims_list__FStar_Bytes_bytes *T20___proj__X_y__item___0(T20_t20_ projectee);

bool T20_uu___is_X_w(T20_t20_ projectee);

uint16_t T20___proj__X_w__item___0(T20_t20_ projectee);

bool T20_uu___is_X_v(T20_t20_ projectee);

uint16_t T20___proj__X_v__item___0(T20_t20_ projectee);

bool T20_uu___is_X_t(T20_t20_ projectee);

uint16_t T20___proj__X_t__item___0(T20_t20_ projectee);

bool T20_uu___is_X_z(T20_t20_ projectee);

uint16_t T20___proj__X_z__item___0(T20_t20_ projectee);

bool T20_uu___is_X_Unknown_tag2(T20_t20_ projectee);

uint8_t T20___proj__X_Unknown_tag2__item__v(T20_t20_ projectee);

uint16_t T20___proj__X_Unknown_tag2__item__x(T20_t20_ projectee);

Tag2_tag2 T20_tag_of_t20(T20_t20_ x);

uint32_t T20_t20_validator(Tag2_tag2 k, LowParse_Slice_slice input, uint32_t pos);

uint32_t T20_t20_jumper(Tag2_tag2 k, LowParse_Slice_slice input, uint32_t pos);

#define __T20_H_DEFINED
#endif