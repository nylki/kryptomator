/*
arc4.c
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

#include "arc4.h"

/* expects valid params only (i.e. no null shit) */
void arc4_init(struct arc4_state *sp, void *key, u32 key_len)
{
    u8 j = 0, k, *_key = key;
    u32 i;
    for (i = 0; i < 256; i++)
        sp->state[i] = i;
    
    for (i = 0; i < 256; i++) {
        j += _key[i % key_len] + sp->state[i];

        k = sp->state[i];
        sp->state[i] = sp->state[j];
        sp->state[j] = k;
    }
    sp->x = sp->y = 0;
}

/* in and out can be the same buffer */
void arc4_crypt(struct arc4_state *sp, void *in, void *out, u32 len)
{
    u8 j, *_out = out, *_in = in;
    u32 i;
    for (i = 0; i < len; i++) {
        sp->y += sp->state[++sp->x];
        
        j = sp->state[sp->x];
        sp->state[sp->x] = sp->state[sp->y];
        sp->state[sp->y] = j;
        
        _out[i] = (_in[i] ^ sp->state[(u8)(sp->state[sp->x] + sp->state[sp->y])]);
    }
}