/******************************************************************************
 * $Id: metainfo.h 1636 2007-04-02 20:38:23Z joshe $
 *
 * Copyright (c) 2005 Transmission authors and contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *****************************************************************************/

#ifndef TR_METAINFO_H
#define TR_METAINFO_H 1

#include "transmission.h"

int tr_metainfoParseFile( tr_info_t *, const char * tag,
                          const char * path, int save );
int tr_metainfoParseData( tr_info_t *, const char * tag,
                          uint8_t * data, size_t size, int save );
int tr_metainfoParseHash( tr_info_t *, const char * tag, const char * hash );
void tr_metainfoFree( tr_info_t * inf );
void tr_metainfoRemoveSaved( const char * hashString, const char * tag );

#endif
