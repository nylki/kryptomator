/*
arc4.h
Copyright (c) 2006-2007 Thomas Dixon

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/
#ifndef _ARC4_H
#define _ARC4_H

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char u8;
typedef unsigned long u32;

typedef struct arc4_state
{      
    u8 state[256], /* State array, aka 's-box' */
       x, /* Indexes. x,y instead of i,j */
       y;
} arc4_state;

void arc4_init(struct arc4_state *sp/*struct pointer*/, void *key, u32 key_len/*in bytes*/);
void arc4_crypt(struct arc4_state *sp, void *in, void *out, u32 len/*of both buffers in bytes*/);

#ifdef __cplusplus
}
#endif

#endif /* arc4.h */