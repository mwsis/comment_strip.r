#! /usr/bin/env ruby

$:.unshift File.join(__dir__, '../..', 'lib')


require 'comment_strip'

require 'xqsr3/extensions/test/unit'

require 'test/unit'

class Test_C_strip_1 < Test::Unit::TestCase

  include ::CommentStrip

  def test_nil

    assert_nil strip(nil, 'C')

    assert_nil ::CommentStrip.strip(nil, 'C')
  end

  def test_unrecognised_families

    unrecognised_families = %w{

      Python
      Perl
      Ruby

      Java
      Kotlin
      Scala

      Rust
    }

    unrecognised_families.each do |family|

      assert_raise_with_message(::RuntimeError, /family.*unrecognised/) { strip('', family) }
      assert_raise_with_message(::RuntimeError, /family.*unrecognised/) { ::CommentStrip.strip('', family) }
    end
  end

  def test_empty

    assert_equal "", strip('', 'C')
    assert_equal "", ::CommentStrip.strip('', :C)
  end

  def test_simple_main

    input = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 0;
}
EOF_main
    expected = input

    assert_equal expected, strip(input, 'C')
    assert_equal expected, ::CommentStrip.strip(input, 'C')
  end

  def test_x_1

    input = <<-EOF_main
#ifdef CLARA_PLATFORM_WINDOWS
                case '/': from = i+1; return SlashOpt;
#endif

        std::string description;
        std::string detail;
        std::string placeholder; // Only value if boundField takes an arg

        bool takesArg() const {
            return !placeholder.empty();
        }
EOF_main
    expected = <<-EOF_main
#ifdef CLARA_PLATFORM_WINDOWS
                case '/': from = i+1; return SlashOpt;
#endif

        std::string description;
        std::string detail;
        std::string placeholder; 

        bool takesArg() const {
            return !placeholder.empty();
        }
EOF_main

    actual = strip(input, 'C')
    actual = ::CommentStrip.strip(input, 'C')

    assert_equal expected, actual
  end

  def test_x_2

    input = <<-EOF_main

} // namespace something
EOF_main
    expected = <<-EOF_main

} 
EOF_main

    actual = strip(input, 'C')
    actual = ::CommentStrip.strip(input, 'C')

    assert_equal expected, actual
  end

  def test_x_3

    input = <<-EOF_main

#endif /* !LOG_PERROR */
EOF_main
      expected = <<-EOF_main

#endif 
EOF_main

    actual = strip(input, 'C')
    actual = ::CommentStrip.strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_1

    input = <<-EOF_main

        case '"': // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case '"': 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_2

    input = <<-EOF_main

        case '\"': // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case '\"': 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_3

    input = <<-EOF_main

        case '\'': // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case '\'': 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_4

    input = <<-EOF_main

        case '\\\\': // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case '\\\\': 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_5

    input = <<-EOF_main

        case '\\\\': // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case '\\\\': 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_single_quoted_characters_6

    input = <<-EOF_main

#define SOME_CHAR '\\x80' /* some char */
EOF_main
    expected = <<-EOF_main

#define SOME_CHAR '\\x80' 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_double_quoted_characters_1

    input = <<-EOF_main

        case "'": // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case "'": 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_double_quoted_characters_2

    input = <<-EOF_main

        case "\\"": // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case "\\"": 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_double_quoted_characters_3

    input = <<-EOF_main

        case "\\'": // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case "\\'": 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_double_quoted_characters_4

    input = <<-EOF_main

        case "\\\\": // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case "\\\\": 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_code_with_double_quoted_characters_5

    input = <<-EOF_main

        case "\\\\": // " this is the comment "
EOF_main
    expected = <<-EOF_main

        case "\\\\": 
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_simple_main_with_trailing_cppcomment

    input = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 0; // same as EXIT_SUCCESS
}
EOF_main
    expected = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 0; 
}
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_simple_main_with_trailing_cppcomment_and_divide_maths

    input = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 0 / 1; // same as EXIT_SUCCESS
}
EOF_main
    expected = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 0 / 1; 
}
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_simple_main_with_ccomment

    input = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 2; /* same as EXIT_SUCCESS */
}
EOF_main
    expected = <<-EOF_main
#include <stdio.h>
int main(int argc, char* argv[])
{
    return 2; 
}
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_ccomment_inline

    input = 'int i = func(/*x=*/x, /*y=*/y);'
    expected = 'int i = func(x, y);'

    assert_equal expected, strip(input, 'C')
  end

  def test_multiline_1

    input = <<-EOF_main

/** Some function description
 */
int func();
EOF_main
    expected = <<-EOF_main



int func();
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_multiline_2

    input = <<-EOF_main

/** Some function description
 */
int func();

/** Some other function description
 *
 */

int fn();
EOF_main
    expected = <<-EOF_main



int func();





int fn();
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_multiline_3

    input = <<-EOF_main

/** Some function description
 *
 * ABC
 */
int func();
EOF_main
    expected = <<-EOF_main





int func();
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_multiline_4

    input = <<-EOF_main

/** //////////////////////////////////
 *
 * ABC
 */
int func();
EOF_main
        expected = <<-EOF_main





int func();
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_comments_in_strings_1

    input = <<-EOF_main

        string s("//"); // THIS is the comment
EOF_main
    expected = <<-EOF_main

        string s("//"); 
EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_comments_in_strings_2

    input = <<-EOF_main

        string s("/*"); // THIS is the comment
EOF_main
    expected = <<-EOF_main

        string s("/*"); 
EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_comments_in_strings_3

    input = <<-EOF_main

        string s("/"); // THIS is the comment
EOF_main
    expected = <<-EOF_main

        string s("/"); 
EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_comments_in_strings_4

    input = <<-EOF_main

        string s("/* this is a comment */"); // this is THE comment
EOF_main
    expected = <<-EOF_main

        string s("/* this is a comment */"); 
EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_1

    input = <<-EOF_main
/* /////////////////////////////////////////////////////////////////////////
 * includes
 *
 * some thing or other
 */

#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else /* ? FASTFORMAT_MT */
# include <stlsoft/synch/null_mutex.hpp>
#endif /* FASTFORMAT_MT */

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif /* VC++ _DEBUG */

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) // suppresses "unreachable code"
#endif /* compiler */
EOF_main
    expected = <<-EOF_main






#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else 
# include <stlsoft/synch/null_mutex.hpp>
#endif 

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif 

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) 
#endif 
EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_2

    input = <<-EOF_main
/* /////////////////////////////////////////////////////////////////////////
 * includes
 */

#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else /* ? FASTFORMAT_MT */
# include <stlsoft/synch/null_mutex.hpp>
#endif /* FASTFORMAT_MT */

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif /* VC++ _DEBUG */

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) // suppresses "unreachable code"
#endif /* compiler */


#include <map>
#include <new>

#include <ctype.h>

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
# include <crtdbg.h>
#endif
EOF_main
    expected = <<-EOF_main




#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else 
# include <stlsoft/synch/null_mutex.hpp>
#endif 

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif 

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) 
#endif 


#include <map>
#include <new>

#include <ctype.h>

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
# include <crtdbg.h>
#endif
EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_real_sample_3

    input = <<-EOF_main
/* /////////////////////////////////////////////////////////////////////////
 * File:        src/fmt_cache.cpp
 *
 * Purpose:     Implementation file for FastFormat core API: format cache.
 *
 * Created:     18th September 2006
 * Updated:     7th August 2015
 *
 * Home:        http://www.fastformat.org/
 *
 * Copyright (c) 2006-2015, Matthew Wilson and Synesis Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the names of Matthew Wilson and Synesis Software nor the names
 *   of any contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ////////////////////////////////////////////////////////////////////// */



/* /////////////////////////////////////////////////////////////////////////
 * includes
 */

#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else /* ? FASTFORMAT_MT */
# include <stlsoft/synch/null_mutex.hpp>
#endif /* FASTFORMAT_MT */

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif /* VC++ _DEBUG */

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) // suppresses "unreachable code"
#endif /* compiler */


#include <map>
#include <new>
EOF_main

    expected = <<-EOF_main














































#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else 
# include <stlsoft/synch/null_mutex.hpp>
#endif 

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif 

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) 
#endif 


#include <map>
#include <new>
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, strip(input, 'C')
  end

  def test_real_sample_4

    input = <<-EOF_main
/* /////////////////////////////////////////////////////////////////////////
 * File:        src/fmt_cache.cpp
 *
 * Purpose:     Implementation file for FastFormat core API: format cache.
 *
 * Created:     18th September 2006
 * Updated:     7th August 2015
 *
 * Home:        http://www.fastformat.org/
 *
 * Copyright (c) 2006-2015, Matthew Wilson and Synesis Software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 * - Neither the names of Matthew Wilson and Synesis Software nor the names
 *   of any contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ////////////////////////////////////////////////////////////////////// */



/* /////////////////////////////////////////////////////////////////////////
 * includes
 */

#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else /* ? FASTFORMAT_MT */
# include <stlsoft/synch/null_mutex.hpp>
#endif /* FASTFORMAT_MT */

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif /* VC++ _DEBUG */

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) // suppresses "unreachable code"
#endif /* compiler */


#include <map>
#include <new>

#include <ctype.h>

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
# include <crtdbg.h>
#endif

/* /////////////////////////////////////////////////////////////////////////
 * Implementation selection
 */

//#define _FASTFORMAT_USE_TSS_CACHE
//#define _FASTFORMAT_USE_1PHASE_CACHE
#define _FASTFORMAT_USE_2PHASE_CACHE

/* /////////////////////////////////////////////////////////////////////////
 * Namespace
 */

#if !defined(FASTFORMAT_NO_NAMESPACE)
namespace fastformat
{
#endif /* !FASTFORMAT_NO_NAMESPACE */

/* /////////////////////////////////////////////////////////////////////////
 * Types & Non-local variables
 */

namespace
{
    void* operator_new(size_t cb)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
        return ::HeapAlloc(::GetProcessHeap(), 0, cb);
#else /* ? VC++ _DEBUG */
        return ::operator new(cb);
#endif /* VC++ _DEBUG */
    }

    void operator_delete(void* pv)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
        ::HeapFree(::GetProcessHeap(), 0, pv);
#else /* ? VC++ _DEBUG */
        ::operator delete(pv);
#endif /* VC++ _DEBUG */
    }


    struct pattern_record_base_t
    {
        unsigned                numFormatElements;
        unsigned                numResultElements;
        size_t                  cchPattern;
        format_element_t const* elements;
        format_element_t        elements_[2];   // Two, so can test packing
    };

/* That weird linker defect with VC++ 8+ raises its ugly head again
 * here, so we have to specialise in more details. Super-boring
 */
#if defined(STLSOFT_COMPILER_IS_MSVC) && \
    _MSC_VER >= 1400
    typedef stlsoft::basic_string_view<
        ff_char_t
    ,   std::char_traits<ff_char_t>
    ,   std::allocator<ff_char_t>
    >                                               pattern_t;
#else /* ? compiler */
# ifdef FASTFORMAT_USE_WIDE_STRINGS
    typedef stlsoft::wstring_view                   pattern_t;
# else /* ? FASTFORMAT_USE_WIDE_STRINGS */
    typedef stlsoft::string_view                    pattern_t;
# endif /* FASTFORMAT_USE_WIDE_STRINGS */
#endif /* compiler */

    struct pattern_record_t
        : public pattern_record_base_t
    {
    public: /// Member Types
        typedef pattern_record_t    class_type;
        typedef ff_char_t           char_type;

    public: /// Construction
        pattern_record_t(
            pattern_t               pattern
        ,   format_element_t const* elements
        ,   unsigned                numFormatElements
        ,   unsigned                numResultElements
        );

        void* operator new(size_t, size_t numFormatElements, size_t cchPattern);
#if !defined(STLSOFT_COMPILER_IS_BORLAND) || \
    __BORLANDC__ > 0x0582
        void operator delete(void*, size_t numFormatElements, size_t cchPattern);
#endif /* compiler */
        void operator delete(void*);

    public: /// Accessors
        pattern_t pattern() const;

    private: /// Implementation
        ff_char_t* get_pattern_memory_() const;
    };

    // A comparison function class that avoids any strcmp/memcmp
    // when the lengths are different
    struct pattern_fast_less_t
    {
        bool operator ()(pattern_t const& lhs, pattern_t const& rhs) const
        {
            size_t  lhsLen  =   lhs.size();
            size_t  rhsLen  =   rhs.size();

            if(lhsLen != rhsLen)
            {
                return lhsLen < rhsLen;
            }
            else
            {
                return lhs < rhs;
            }
        }

    };

    class format_cache
    {
    private: /// Member Types
#ifdef FASTFORMAT_MT
        typedef ::platformstl::thread_mutex             mutex_type_;
#else /* ? FASTFORMAT_MT */
        typedef ::stlsoft::null_mutex                   mutex_type_;
#endif /* FASTFORMAT_MT */
        typedef stlsoft::shared_ptr<pattern_record_t>   record_ptr_type_;
        typedef std::map<   pattern_t
                        ,   record_ptr_type_
#if !defined(UNIXSTL_OS_IS_MACOSX)
# if 1
                        ,   std::less<pattern_t>
# else /* ? 0 */
                        ,   pattern_fast_less_t
# endif /* 0 */

# if !defined(STLSOFT_COMPILER_IS_MWERKS)
#  if defined(_DEBUG) && \
      defined(PLATFORMSTL_OS_IS_WINDOWS) && \
      (  !defined(STLSOFT_COMPILER_IS_MSVC) || \
         _MSC_VER < 1400)
                        ,   winstl::processheap_allocator<pattern_t>
#  else /* ? VC++ _DEBUG */
                        ,   std::allocator<pattern_t>
#  endif /* VC++ _DEBUG */
# endif /* compiler */
#endif /* UNIXSTL_OS_IS_MACOSX */
                        >                               map_type_;
        typedef stlsoft::auto_buffer<format_element_t>  format_elements_type_;

    public: /// Construction
        void* operator new(size_t cb);
        void operator delete(void* pv);

    public:
        unsigned lookup_pattern(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_tss(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_1phase(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_2phase(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );

    private:
        mutex_type_     m_mx;
        map_type_       m_map;
    };

} // anonymous namespace

/* /////////////////////////////////////////////////////////////////////////
 * Implementation Functions
 */

// class ximpl_core

int ximpl_core::fastformat_impl_formatCache_init(void** ptoken)
{
    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_STATE_INTERNAL(NULL != ptoken, "token pointer must not be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    try
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        format_cache* cache = new format_cache();

        if(NULL == cache)
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            return FASTFORMAT_INIT_RC_OUT_OF_MEMORY;
        }

        *ptoken = cache;

        return FASTFORMAT_INIT_RC_SUCCESS;
    }
    catch(std::bad_alloc&)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_OUT_OF_MEMORY;
    }
    catch(std::exception&)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_UNSPECIFIED_EXCEPTION;
    }
    catch(...)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_UNSPECIFIED_ERROR;
    }
}

void ximpl_core::fastformat_impl_formatCache_uninit(void* token)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_STATE_INTERNAL(NULL != token, "token must not be null");

    delete static_cast<format_cache*>(token);
}

unsigned ximpl_core::fastformat_impl_formatCache_lookupPattern(
    void*                       token
,   ff_char_t const*            pattern
,   size_t                      cchPattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != token, "state pointer must be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    format_cache* cache = static_cast<format_cache*>(token);

    if(0 == cchPattern)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return 0;
    }
    else
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        pattern_t   p(pattern, cchPattern);

        return cache->lookup_pattern(p, elements);
    }
}


namespace
{

void* format_cache::operator new(size_t cb)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    return operator_new(cb);
}

void format_cache::operator delete(void* pv)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}


unsigned format_cache::lookup_pattern(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_FASTFORMAT_USE_TSS_CACHE)
    return this->lookup_pattern_tss(pattern, elements);
#elif defined(_FASTFORMAT_USE_1PHASE_CACHE)
    return this->lookup_pattern_1phase(pattern, elements);
#elif defined(_FASTFORMAT_USE_2PHASE_CACHE)
    return this->lookup_pattern_2phase(pattern, elements);
#else /* ? cache */
# error Implementation not discriminated
#endif /* cache */
}

unsigned format_cache::lookup_pattern_1phase(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != elements, "elements parameter may not be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    stlsoft::lock_scope<mutex_type_>    lock(m_mx);
    map_type_::const_iterator           it = m_map.find(pattern);

    if(it == m_map.end())
    {
        FASTFORMAT_COVER_MARK_ENTRY();

/*                                                  (1 + len) / 2

    " "                     1   =>  1           1
    "{0}"                   3   =>  1           2
    " {0}"                  4   =>  2           2
    " {0} "                 5   =>  3           3
    "{0} {0} "              8   =>  4           4
    " {0} {0} "             9   =>  5           5
    " {0} {0} {0}"          12  =>  6           6
    "{0} {0} {0} {0}"       15  =>  7           8
    "{0} {0} {0} {0} "      16  =>  8           8
    " {0} {0} {0} {0}"      16  =>  8           8
    " {0} {0} {0} {0} "     17  =>  9           9

    "{0,2}"                 5   =>  2           3
    " {0,2}"                6   =>  3           3
    "{0,2} "                6   =>  3           3
    " {0,2} "               7   =>  4           4
    " {0,2} {0,2} "         13  =>  7           7
    "{0,2}{0,2}{0,2}"       15  =>  6           8
    "{0,2} {0,2} {0,2} "    18  =>  9           9
    " {0,2} {0,2} {0,2}"    18  =>  9           9
    " {0,2} {0,2} {0,2} "   19  =>  10          10
*/

        format_elements_type_   formatElements(1 + pattern.size() / 2);
        unsigned                numFormatElements;
        unsigned                numResultElements;

        unsigned                n = fastformat_parseFormat(pattern.data(), pattern.size(), &formatElements[0], formatElements.size(), NULL, NULL);

        numFormatElements   =   n & 0xffff;
        numResultElements   =   n >> 16;

        STLSOFT_ASSERT(numFormatElements <= formatElements.size());

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
        // This code ensures that subsequent allocations made in this scope
        // to the MSVCRT heap will not be tracked.
        //
        // This is done because FF's caching can lead to false positivies in
        // leak reporting, which we don't want and you don't want. The
        // possible downside is that if FF has some genuine leaks in this
        // area, they may not be reported. Given the maturity of the project
        // we feel that this is a very low risk, and therfore worth taking.
        int prev = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
        _CrtSetDbgFlag(prev & ~_CRTDBG_ALLOC_MEM_DF);

        stlsoft::scoped_handle<int> scoperCrt(prev, _CrtSetDbgFlag);
#endif

        record_ptr_type_    ptr(new(numFormatElements, pattern.size()) pattern_record_t(pattern, &formatElements[0], numFormatElements, numResultElements));

        it = m_map.insert(std::make_pair(ptr->pattern(), ptr)).first;
    }

    FASTFORMAT_COVER_MARK_ENTRY();

    record_ptr_type_ recptr =   (*it).second;

    *elements               =   recptr->elements;

    FASTFORMAT_COVER_MARK_ENTRY();

    return (recptr->numFormatElements & 0xffff) | ((recptr->numResultElements & 0xffff) << 16);
}

unsigned format_cache::lookup_pattern_2phase(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != elements, "elements parameter may not be null");

#ifndef FASTFORMAT_MT

    return this->lookup_pattern_1phase(pattern, elements);

#else /* ? FASTFORMAT_MT */

    FASTFORMAT_COVER_MARK_ENTRY();

    { // Phase 1

        FASTFORMAT_COVER_MARK_ENTRY();

        stlsoft::lock_scope<mutex_type_>    lock(m_mx);
        map_type_::const_iterator           it = m_map.find(pattern);

        if(it != m_map.end())
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            record_ptr_type_ ptr = (*it).second;

            *elements           =   ptr->elements;

            return (ptr->numFormatElements & 0xffff) | ((ptr->numResultElements & 0xffff) << 16);
        }
    }

    FASTFORMAT_COVER_MARK_ENTRY();

    // If we have reached this point, we know that the pattern has not
    // yet been cached. So we parse it, and then attempt to cache it.

    format_elements_type_   formatElements(1 + pattern.size() / 2);
    unsigned                numFormatElements;
    unsigned                numResultElements;

    unsigned                n = fastformat_parseFormat(pattern.data(), pattern.size(), &formatElements[0], formatElements.size(), NULL, NULL);

    numFormatElements   =   n & 0xffff;
    numResultElements   =   n >> 16;

    FASTFORMAT_CONTRACT_ENFORCE_POSTCONDITION_RETURN_INTERNAL(numFormatElements <= formatElements.size(), "number of pattern elements calculated cannot be greater than the number specified available");

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
    // This code ensures that subsequent allocations made in this scope
    // to the MSVCRT heap will not be tracked.
    //
    // This is done because FF's caching can lead to false positivies in
    // leak reporting, which we don't want and you don't want. The
    // possible downside is that if FF has some genuine leaks in this
    // area, they may not be reported. Given the maturity of the project
    // we feel that this is a very low risk, and therfore worth taking.
    int prev = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
    _CrtSetDbgFlag(prev & ~_CRTDBG_ALLOC_MEM_DF);

    stlsoft::scoped_handle<int> scoperCrt(prev, _CrtSetDbgFlag);
#endif

    record_ptr_type_    ptr(new(numFormatElements, pattern.size()) pattern_record_t(pattern, &formatElements[0], numFormatElements, numResultElements));

    { // Phase 2

        FASTFORMAT_COVER_MARK_ENTRY();

        stlsoft::lock_scope<mutex_type_>    lock(m_mx);

        // We must check again, since another thread might have parsed and
        // inserted in the time between the end of phase 1 and now

        map_type_::const_iterator           it = m_map.find(pattern);

        if(it != m_map.end())
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            // It was inserted by another thread;
        }
        else
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            it = m_map.insert(std::make_pair(ptr->pattern(), ptr)).first;
        }

        record_ptr_type_ recptr =   (*it).second;

        *elements               =   recptr->elements;

        FASTFORMAT_COVER_MARK_ENTRY();

        return (recptr->numFormatElements & 0xffff) | ((recptr->numResultElements & 0xffff) << 16);
    }
#endif /* FASTFORMAT_MT */
}

namespace
{

    const size_t    offsetElement0  =   STLSOFT_RAW_OFFSETOF(pattern_record_base_t, elements_[0]);
    const size_t    offsetElement1  =   STLSOFT_RAW_OFFSETOF(pattern_record_base_t, elements_[1]);
    const size_t    sizeofElement   =   offsetElement1 - offsetElement0;

} // anonymous namespace

void* pattern_record_t::operator new(size_t /* cb */, size_t numFormatElements, size_t cchPattern)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    const size_t size   =   offsetElement0
                        +   ((numFormatElements < 2) ? 2 : numFormatElements) * sizeofElement
                        +   sizeof(ff_char_t) * (cchPattern + 1);

    return operator_new(size);
}

#if !defined(STLSOFT_COMPILER_IS_BORLAND) || \
    __BORLANDC__ > 0x0582
void pattern_record_t::operator delete(void* pv, size_t /* numFormatElements */, size_t /* cchPattern */)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}
#endif /* compiler */

void pattern_record_t::operator delete(void* pv)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}

inline ff_char_t* pattern_record_t::get_pattern_memory_() const
{
    const size_t    elementsSize    =   offsetElement0
                                    +   ((numFormatElements < 2) ? 2 : numFormatElements) * sizeofElement;

    return reinterpret_cast<char_type*>(const_cast<void*>(stlsoft::ptr_byte_offset(this, ptrdiff_t(elementsSize))));
}


pattern_record_t::pattern_record_t(
    pattern_t                   pattern
,   format_element_t const*     elements
,   unsigned                    numFormatElements
,   unsigned                    numResultElements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    this->numFormatElements =   numFormatElements;
    this->numResultElements =   numResultElements;
    this->cchPattern        =   pattern.size();

    char_type* embeddedPattern = get_pattern_memory_();

    ::memcpy(embeddedPattern, pattern.data(), sizeof(char_type) * pattern.size());
    embeddedPattern[pattern.size()] = '\0';

    this->elements = &this->elements_[0];

    {
        FASTFORMAT_COVER_MARK_ENTRY();

        format_element_t*   element =   &this->elements_[0];
        size_t              i       =   0;

        for(; i != numFormatElements; ++i, ++element, ++elements)
        {
            FASTFORMAT_COVER_MARK_ENTRY();

#if 1
            element->len        =   elements->len;
            element->ptr        =   embeddedPattern + (elements->ptr - pattern.data());
            element->index      =   elements->index;
            element->minWidth   =   elements->minWidth;
            element->maxWidth   =   elements->maxWidth;
            element->alignment  =   elements->alignment;
            element->fill       =   elements->fill;
#else /* ? 0 */
            ::memcpy(element, elements, sizeof(*element));
            element->ptr        =   embeddedPattern + (elements->ptr - pattern.data());
#endif /* 0 */

            STLSOFT_ASSERT(0 == ::memcmp(element->ptr, elements->ptr, element->len));
        }
    }
}

pattern_t pattern_record_t::pattern() const
{
    /// TODO: place a length record into the memory, between the elements and
    /// the pattern, and then this invocation will not have to do a strlen.
    return pattern_t(get_pattern_memory_(), cchPattern);
}


} // anonymous namespace

/* /////////////////////////////////////////////////////////////////////////
 * Namespace
 */

#if !defined(FASTFORMAT_NO_NAMESPACE)
} /* namespace fastformat */
#endif /* !FASTFORMAT_NO_NAMESPACE */

/* ///////////////////////////// end of file //////////////////////////// */
EOF_main

    expected = <<-EOF_main














































#include "ximpl_core.hpp"
#ifndef UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
# define UNIXSTL_NO_ATOMIC_INTEGER_OPERATIONS_ON_WINDOWS
#endif
#include <fastformat/internal/format_element.h>
#include <fastformat/internal/threading.h>
#include <fastformat/init_codes.h>
#include <fastformat/quality/contract.h>
#include <fastformat/quality/cover.h>

#ifdef FASTFORMAT_MT
# include <platformstl/synch/thread_mutex.hpp>
#else 
# include <stlsoft/synch/null_mutex.hpp>
#endif 

#include <stlsoft/memory/auto_buffer.hpp>
#include <stlsoft/smartptr/scoped_handle.hpp>
#include <stlsoft/smartptr/shared_ptr.hpp>
#include <stlsoft/string/string_view.hpp>
#include <stlsoft/synch/lock_scope.hpp>

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
# include <winstl/memory/processheap_allocator.hpp>
#endif 

#if defined(STLSOFT_COMPILER_IS_MSVC)
# pragma warning(disable : 4702) 
#endif 


#include <map>
#include <new>

#include <ctype.h>

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
# include <crtdbg.h>
#endif







#define _FASTFORMAT_USE_2PHASE_CACHE





#if !defined(FASTFORMAT_NO_NAMESPACE)
namespace fastformat
{
#endif 





namespace
{
    void* operator_new(size_t cb)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
        return ::HeapAlloc(::GetProcessHeap(), 0, cb);
#else 
        return ::operator new(cb);
#endif 
    }

    void operator_delete(void* pv)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_DEBUG) && \
    defined(PLATFORMSTL_OS_IS_WINDOWS)
        ::HeapFree(::GetProcessHeap(), 0, pv);
#else 
        ::operator delete(pv);
#endif 
    }


    struct pattern_record_base_t
    {
        unsigned                numFormatElements;
        unsigned                numResultElements;
        size_t                  cchPattern;
        format_element_t const* elements;
        format_element_t        elements_[2];   
    };




#if defined(STLSOFT_COMPILER_IS_MSVC) && \
    _MSC_VER >= 1400
    typedef stlsoft::basic_string_view<
        ff_char_t
    ,   std::char_traits<ff_char_t>
    ,   std::allocator<ff_char_t>
    >                                               pattern_t;
#else 
# ifdef FASTFORMAT_USE_WIDE_STRINGS
    typedef stlsoft::wstring_view                   pattern_t;
# else 
    typedef stlsoft::string_view                    pattern_t;
# endif 
#endif 

    struct pattern_record_t
        : public pattern_record_base_t
    {
    public: 
        typedef pattern_record_t    class_type;
        typedef ff_char_t           char_type;

    public: 
        pattern_record_t(
            pattern_t               pattern
        ,   format_element_t const* elements
        ,   unsigned                numFormatElements
        ,   unsigned                numResultElements
        );

        void* operator new(size_t, size_t numFormatElements, size_t cchPattern);
#if !defined(STLSOFT_COMPILER_IS_BORLAND) || \
    __BORLANDC__ > 0x0582
        void operator delete(void*, size_t numFormatElements, size_t cchPattern);
#endif 
        void operator delete(void*);

    public: 
        pattern_t pattern() const;

    private: 
        ff_char_t* get_pattern_memory_() const;
    };

    
    
    struct pattern_fast_less_t
    {
        bool operator ()(pattern_t const& lhs, pattern_t const& rhs) const
        {
            size_t  lhsLen  =   lhs.size();
            size_t  rhsLen  =   rhs.size();

            if(lhsLen != rhsLen)
            {
                return lhsLen < rhsLen;
            }
            else
            {
                return lhs < rhs;
            }
        }

    };

    class format_cache
    {
    private: 
#ifdef FASTFORMAT_MT
        typedef ::platformstl::thread_mutex             mutex_type_;
#else 
        typedef ::stlsoft::null_mutex                   mutex_type_;
#endif 
        typedef stlsoft::shared_ptr<pattern_record_t>   record_ptr_type_;
        typedef std::map<   pattern_t
                        ,   record_ptr_type_
#if !defined(UNIXSTL_OS_IS_MACOSX)
# if 1
                        ,   std::less<pattern_t>
# else 
                        ,   pattern_fast_less_t
# endif 

# if !defined(STLSOFT_COMPILER_IS_MWERKS)
#  if defined(_DEBUG) && \
      defined(PLATFORMSTL_OS_IS_WINDOWS) && \
      (  !defined(STLSOFT_COMPILER_IS_MSVC) || \
         _MSC_VER < 1400)
                        ,   winstl::processheap_allocator<pattern_t>
#  else 
                        ,   std::allocator<pattern_t>
#  endif 
# endif 
#endif 
                        >                               map_type_;
        typedef stlsoft::auto_buffer<format_element_t>  format_elements_type_;

    public: 
        void* operator new(size_t cb);
        void operator delete(void* pv);

    public:
        unsigned lookup_pattern(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_tss(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_1phase(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );
        unsigned lookup_pattern_2phase(
            pattern_t                   pattern
        ,   format_element_t const**    elements
        );

    private:
        mutex_type_     m_mx;
        map_type_       m_map;
    };

} 







int ximpl_core::fastformat_impl_formatCache_init(void** ptoken)
{
    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_STATE_INTERNAL(NULL != ptoken, "token pointer must not be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    try
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        format_cache* cache = new format_cache();

        if(NULL == cache)
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            return FASTFORMAT_INIT_RC_OUT_OF_MEMORY;
        }

        *ptoken = cache;

        return FASTFORMAT_INIT_RC_SUCCESS;
    }
    catch(std::bad_alloc&)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_OUT_OF_MEMORY;
    }
    catch(std::exception&)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_UNSPECIFIED_EXCEPTION;
    }
    catch(...)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return FASTFORMAT_INIT_RC_UNSPECIFIED_ERROR;
    }
}

void ximpl_core::fastformat_impl_formatCache_uninit(void* token)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_STATE_INTERNAL(NULL != token, "token must not be null");

    delete static_cast<format_cache*>(token);
}

unsigned ximpl_core::fastformat_impl_formatCache_lookupPattern(
    void*                       token
,   ff_char_t const*            pattern
,   size_t                      cchPattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != token, "state pointer must be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    format_cache* cache = static_cast<format_cache*>(token);

    if(0 == cchPattern)
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        return 0;
    }
    else
    {
        FASTFORMAT_COVER_MARK_ENTRY();

        pattern_t   p(pattern, cchPattern);

        return cache->lookup_pattern(p, elements);
    }
}


namespace
{

void* format_cache::operator new(size_t cb)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    return operator_new(cb);
}

void format_cache::operator delete(void* pv)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}


unsigned format_cache::lookup_pattern(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

#if defined(_FASTFORMAT_USE_TSS_CACHE)
    return this->lookup_pattern_tss(pattern, elements);
#elif defined(_FASTFORMAT_USE_1PHASE_CACHE)
    return this->lookup_pattern_1phase(pattern, elements);
#elif defined(_FASTFORMAT_USE_2PHASE_CACHE)
    return this->lookup_pattern_2phase(pattern, elements);
#else 
# error Implementation not discriminated
#endif 
}

unsigned format_cache::lookup_pattern_1phase(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != elements, "elements parameter may not be null");

    FASTFORMAT_COVER_MARK_ENTRY();

    stlsoft::lock_scope<mutex_type_>    lock(m_mx);
    map_type_::const_iterator           it = m_map.find(pattern);

    if(it == m_map.end())
    {
        FASTFORMAT_COVER_MARK_ENTRY();


























        format_elements_type_   formatElements(1 + pattern.size() / 2);
        unsigned                numFormatElements;
        unsigned                numResultElements;

        unsigned                n = fastformat_parseFormat(pattern.data(), pattern.size(), &formatElements[0], formatElements.size(), NULL, NULL);

        numFormatElements   =   n & 0xffff;
        numResultElements   =   n >> 16;

        STLSOFT_ASSERT(numFormatElements <= formatElements.size());

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
        
        
        
        
        
        
        
        
        int prev = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
        _CrtSetDbgFlag(prev & ~_CRTDBG_ALLOC_MEM_DF);

        stlsoft::scoped_handle<int> scoperCrt(prev, _CrtSetDbgFlag);
#endif

        record_ptr_type_    ptr(new(numFormatElements, pattern.size()) pattern_record_t(pattern, &formatElements[0], numFormatElements, numResultElements));

        it = m_map.insert(std::make_pair(ptr->pattern(), ptr)).first;
    }

    FASTFORMAT_COVER_MARK_ENTRY();

    record_ptr_type_ recptr =   (*it).second;

    *elements               =   recptr->elements;

    FASTFORMAT_COVER_MARK_ENTRY();

    return (recptr->numFormatElements & 0xffff) | ((recptr->numResultElements & 0xffff) << 16);
}

unsigned format_cache::lookup_pattern_2phase(
    pattern_t                   pattern
,   format_element_t const**    elements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    FASTFORMAT_CONTRACT_ENFORCE_PRECONDITION_PARAMS_INTERNAL(NULL != elements, "elements parameter may not be null");

#ifndef FASTFORMAT_MT

    return this->lookup_pattern_1phase(pattern, elements);

#else 

    FASTFORMAT_COVER_MARK_ENTRY();

    { 

        FASTFORMAT_COVER_MARK_ENTRY();

        stlsoft::lock_scope<mutex_type_>    lock(m_mx);
        map_type_::const_iterator           it = m_map.find(pattern);

        if(it != m_map.end())
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            record_ptr_type_ ptr = (*it).second;

            *elements           =   ptr->elements;

            return (ptr->numFormatElements & 0xffff) | ((ptr->numResultElements & 0xffff) << 16);
        }
    }

    FASTFORMAT_COVER_MARK_ENTRY();

    
    

    format_elements_type_   formatElements(1 + pattern.size() / 2);
    unsigned                numFormatElements;
    unsigned                numResultElements;

    unsigned                n = fastformat_parseFormat(pattern.data(), pattern.size(), &formatElements[0], formatElements.size(), NULL, NULL);

    numFormatElements   =   n & 0xffff;
    numResultElements   =   n >> 16;

    FASTFORMAT_CONTRACT_ENFORCE_POSTCONDITION_RETURN_INTERNAL(numFormatElements <= formatElements.size(), "number of pattern elements calculated cannot be greater than the number specified available");

#if defined(_DEBUG) && \
    defined(STLSOFT_COMPILER_IS_MSVC)
    
    
    
    
    
    
    
    
    int prev = _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG);
    _CrtSetDbgFlag(prev & ~_CRTDBG_ALLOC_MEM_DF);

    stlsoft::scoped_handle<int> scoperCrt(prev, _CrtSetDbgFlag);
#endif

    record_ptr_type_    ptr(new(numFormatElements, pattern.size()) pattern_record_t(pattern, &formatElements[0], numFormatElements, numResultElements));

    { 

        FASTFORMAT_COVER_MARK_ENTRY();

        stlsoft::lock_scope<mutex_type_>    lock(m_mx);

        
        

        map_type_::const_iterator           it = m_map.find(pattern);

        if(it != m_map.end())
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            
        }
        else
        {
            FASTFORMAT_COVER_MARK_ENTRY();

            it = m_map.insert(std::make_pair(ptr->pattern(), ptr)).first;
        }

        record_ptr_type_ recptr =   (*it).second;

        *elements               =   recptr->elements;

        FASTFORMAT_COVER_MARK_ENTRY();

        return (recptr->numFormatElements & 0xffff) | ((recptr->numResultElements & 0xffff) << 16);
    }
#endif 
}

namespace
{

    const size_t    offsetElement0  =   STLSOFT_RAW_OFFSETOF(pattern_record_base_t, elements_[0]);
    const size_t    offsetElement1  =   STLSOFT_RAW_OFFSETOF(pattern_record_base_t, elements_[1]);
    const size_t    sizeofElement   =   offsetElement1 - offsetElement0;

} 

void* pattern_record_t::operator new(size_t , size_t numFormatElements, size_t cchPattern)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    const size_t size   =   offsetElement0
                        +   ((numFormatElements < 2) ? 2 : numFormatElements) * sizeofElement
                        +   sizeof(ff_char_t) * (cchPattern + 1);

    return operator_new(size);
}

#if !defined(STLSOFT_COMPILER_IS_BORLAND) || \
    __BORLANDC__ > 0x0582
void pattern_record_t::operator delete(void* pv, size_t , size_t )
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}
#endif 

void pattern_record_t::operator delete(void* pv)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    operator_delete(pv);
}

inline ff_char_t* pattern_record_t::get_pattern_memory_() const
{
    const size_t    elementsSize    =   offsetElement0
                                    +   ((numFormatElements < 2) ? 2 : numFormatElements) * sizeofElement;

    return reinterpret_cast<char_type*>(const_cast<void*>(stlsoft::ptr_byte_offset(this, ptrdiff_t(elementsSize))));
}


pattern_record_t::pattern_record_t(
    pattern_t                   pattern
,   format_element_t const*     elements
,   unsigned                    numFormatElements
,   unsigned                    numResultElements
)
{
    FASTFORMAT_COVER_MARK_ENTRY();

    this->numFormatElements =   numFormatElements;
    this->numResultElements =   numResultElements;
    this->cchPattern        =   pattern.size();

    char_type* embeddedPattern = get_pattern_memory_();

    ::memcpy(embeddedPattern, pattern.data(), sizeof(char_type) * pattern.size());
    embeddedPattern[pattern.size()] = '\0';

    this->elements = &this->elements_[0];

    {
        FASTFORMAT_COVER_MARK_ENTRY();

        format_element_t*   element =   &this->elements_[0];
        size_t              i       =   0;

        for(; i != numFormatElements; ++i, ++element, ++elements)
        {
            FASTFORMAT_COVER_MARK_ENTRY();

#if 1
            element->len        =   elements->len;
            element->ptr        =   embeddedPattern + (elements->ptr - pattern.data());
            element->index      =   elements->index;
            element->minWidth   =   elements->minWidth;
            element->maxWidth   =   elements->maxWidth;
            element->alignment  =   elements->alignment;
            element->fill       =   elements->fill;
#else 
            ::memcpy(element, elements, sizeof(*element));
            element->ptr        =   embeddedPattern + (elements->ptr - pattern.data());
#endif 

            STLSOFT_ASSERT(0 == ::memcmp(element->ptr, elements->ptr, element->len));
        }
    }
}

pattern_t pattern_record_t::pattern() const
{
    
    
    return pattern_t(get_pattern_memory_(), cchPattern);
}


} 





#if !defined(FASTFORMAT_NO_NAMESPACE)
} 
#endif 


EOF_main

    assert_equal expected, strip(input, 'C')
  end

  def test_real_sample_5

    input = <<-EOF_main
/*****************************************************************************
/*                             Start of crcmodel.c                            
/*****************************************************************************
/*                                                                            
/* Author : Ross Williams (ross@guest.adelaide.edu.au.).                      
/* Date   : 3 June 1993.                                                      
/* Status : Public domain.                                                    
/*                                                                            
/* Description : This is the implementation (.c) file for the reference       
/* implementation of the Rocksoft^tm Model CRC Algorithm. For more            
/* information on the Rocksoft^tm Model CRC Algorithm, see the document       
/* titled "A Painless Guide to CRC Error Detection Algorithms" by Ross        
/* Williams (ross@guest.adelaide.edu.au.). This document is likely to be in   
/* "ftp.adelaide.edu.au/pub/rocksoft".                                        
/*                                                                            
/* Note: Rocksoft is a trademark of Rocksoft Pty Ltd, Adelaide, Australia.    
/*                                                                            
/*****************************************************************************
/*                                                                            
/* Implementation Notes                                                       
/* --------------------                                                       
/* To avoid inconsistencies, the specification of each function is not echoed 
/* here. See the header file for a description of these functions.            
/* This package is light on checking because I want to keep it short and      
/* simple and portable (i.e. it would be too messy to distribute my entire    
/* C culture (e.g. assertions package) with this package.                     
/*                                                                            */
/******************************************************************************/

#include "crcmodel.h"

/******************************************************************************/

/* The following definitions make the code more readable. */

#define BITMASK(X) (1L << (X))
#define MASK32 0xFFFFFFFFL
#define LOCAL static

/******************************************************************************/

LOCAL ulong reflect (ulong v, int b)
/* Returns the value v with the bottom b [0,32] bits reflected. */
/* Example: reflect(0x3e23L,3) == 0x3e26                        */
EOF_main
    expected = <<-EOF_main





























#include "crcmodel.h"





#define BITMASK(X) (1L << (X))
#define MASK32 0xFFFFFFFFL
#define LOCAL static



LOCAL ulong reflect (ulong v, int b)


EOF_main
    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_6

    input = <<-EOF_main







#include "catch_xmlwriter.h"

#include "catch_enforce.h"

#include <iomanip>

using uchar = unsigned char;

namespace Catch {

namespace {

    size_t trailingBytes(unsigned char c) {
        if ((c & 0xE0) == 0xC0) {
            return 2;
        }
        if ((c & 0xF0) == 0xE0) {
            return 3;
        }
        if ((c & 0xF8) == 0xF0) {
            return 4;
        }
        CATCH_INTERNAL_ERROR("Invalid multibyte utf-8 start byte encountered");
    }

    uint32_t headerValue(unsigned char c) {
        if ((c & 0xE0) == 0xC0) {
            return c & 0x1F;
        }
        if ((c & 0xF0) == 0xE0) {
            return c & 0x0F;
        }
        if ((c & 0xF8) == 0xF0) {
            return c & 0x07;
        }
        CATCH_INTERNAL_ERROR("Invalid multibyte utf-8 start byte encountered");
    }

    void hexEscapeChar(std::ostream& os, unsigned char c) {
        std::ios_base::fmtflags f(os.flags());
        os << "\\x"
            << std::uppercase << std::hex << std::setfill('0') << std::setw(2)
            << static_cast<int>(c);
        os.flags(f);
    }

} 

    XmlEncode::XmlEncode( std::string const& str, ForWhat forWhat )
    :   m_str( str ),
        m_forWhat( forWhat )
    {}

    void XmlEncode::encodeTo( std::ostream& os ) const {
        
        

        for( std::size_t idx = 0; idx < m_str.size(); ++ idx ) {
            uchar c = m_str[idx];
            switch (c) {
            case '<':   os << "&lt;"; break;
            case '&':   os << "&amp;"; break;

            case '>':
                
                if (idx > 2 && m_str[idx - 1] == ']' && m_str[idx - 2] == ']')
                    os << "&gt;";
                else
                    os << c;
                break;

            case '\"':
                if (m_forWhat == ForAttributes)
                    os << "&quot;";
                else
                    os << c;
                break;

            default:
                // Check for control characters and invalid utf-8
                // Escape control characters in standard ascii
                // see http://stackoverflow.com/questions/404107/why-are-control-characters-illegal-in-xml-1-0
                if (c < 0x09 || (c > 0x0D && c < 0x20) || c == 0x7F) {
                    hexEscapeChar(os, c);
                    break;
                }

                // Plain ASCII: Write it to stream
                if (c < 0x7F) {
                    os << c;
                    break;
                }

                // UTF-8 territory
                // Check if the encoding is valid and if it is not, hex escape bytes.
                // Important: We do not check the exact decoded values for validity, only the encoding format
                // First check that this bytes is a valid lead byte:
                // This means that it is not encoded as 1111 1XXX
                // Or as 10XX XXXX
                if (c <  0xC0 ||
                    c >= 0xF8) {
                    hexEscapeChar(os, c);
                    break;
                }

                auto encBytes = trailingBytes(c);
                // Are there enough bytes left to avoid accessing out-of-bounds memory?
                if (idx + encBytes - 1 >= m_str.size()) {
                    hexEscapeChar(os, c);
                    break;
                }
                // The header is valid, check data
                // The next encBytes bytes must together be a valid utf-8
                // This means: bitpattern 10XX XXXX and the extracted value is sane (ish)
                bool valid = true;
                uint32_t value = headerValue(c);
                for (std::size_t n = 1; n < encBytes; ++n) {
                    uchar nc = m_str[idx + n];
                    valid &= ((nc & 0xC0) == 0x80);
                    value = (value << 6) | (nc & 0x3F);
                }

                if (
                    // Wrong bit pattern of following bytes
                    (!valid) ||
                    // Overlong encodings
                    (value < 0x80) ||
                    (0x80 <= value && value < 0x800   && encBytes > 2) ||
                    (0x800 < value && value < 0x10000 && encBytes > 3) ||
                    // Encoded value out of range
                    (value >= 0x110000)
                    ) {
                    hexEscapeChar(os, c);
                    break;
                }

                // If we got here, this is in fact a valid(ish) utf-8 sequence
                for (std::size_t n = 0; n < encBytes; ++n) {
                    os << m_str[idx + n];
                }
                idx += encBytes - 1;
                break;
            }
        }
    }

    std::ostream& operator << ( std::ostream& os, XmlEncode const& xmlEncode ) {
        xmlEncode.encodeTo( os );
        return os;
    }

    XmlWriter::ScopedElement::ScopedElement( XmlWriter* writer )
    :   m_writer( writer )
    {}

    XmlWriter::ScopedElement::ScopedElement( ScopedElement&& other ) noexcept
    :   m_writer( other.m_writer ){
        other.m_writer = nullptr;
    }
    XmlWriter::ScopedElement& XmlWriter::ScopedElement::operator=( ScopedElement&& other ) noexcept {
        if ( m_writer ) {
            m_writer->endElement();
        }
        m_writer = other.m_writer;
        other.m_writer = nullptr;
        return *this;
    }


    XmlWriter::ScopedElement::~ScopedElement() {
        if( m_writer )
            m_writer->endElement();
    }

    XmlWriter::ScopedElement& XmlWriter::ScopedElement::writeText( std::string const& text, bool indent ) {
        m_writer->writeText( text, indent );
        return *this;
    }

    XmlWriter::XmlWriter( std::ostream& os ) : m_os( os )
    {
        writeDeclaration();
    }

    XmlWriter::~XmlWriter() {
        while( !m_tags.empty() )
            endElement();
    }

    XmlWriter& XmlWriter::startElement( std::string const& name ) {
        ensureTagClosed();
        newlineIfNecessary();
        m_os << m_indent << '<' << name;
        m_tags.push_back( name );
        m_indent += "  ";
        m_tagIsOpen = true;
        return *this;
    }

    XmlWriter::ScopedElement XmlWriter::scopedElement( std::string const& name ) {
        ScopedElement scoped( this );
        startElement( name );
        return scoped;
    }

    XmlWriter& XmlWriter::endElement() {
        newlineIfNecessary();
        m_indent = m_indent.substr( 0, m_indent.size()-2 );
        if( m_tagIsOpen ) {
            m_os << "/>";
            m_tagIsOpen = false;
        }
        else {
            m_os << m_indent << "</" << m_tags.back() << ">";
        }
        m_os << std::endl;
        m_tags.pop_back();
        return *this;
    }

    XmlWriter& XmlWriter::writeAttribute( std::string const& name, std::string const& attribute ) {
        if( !name.empty() && !attribute.empty() )
            m_os << ' ' << name << "=\"" << XmlEncode( attribute, XmlEncode::ForAttributes ) << '"';
        return *this;
    }

    XmlWriter& XmlWriter::writeAttribute( std::string const& name, bool attribute ) {
        m_os << ' ' << name << "=\"" << ( attribute ? "true" : "false" ) << '"';
        return *this;
    }

    XmlWriter& XmlWriter::writeText( std::string const& text, bool indent ) {
        if( !text.empty() ){
            bool tagWasOpen = m_tagIsOpen;
            ensureTagClosed();
            if( tagWasOpen && indent )
                m_os << m_indent;
            m_os << XmlEncode( text );
            m_needsNewline = true;
        }
        return *this;
    }

    XmlWriter& XmlWriter::writeComment( std::string const& text ) {
        ensureTagClosed();
        m_os << m_indent << "<!--" << text << "-->";
        m_needsNewline = true;
        return *this;
    }

    void XmlWriter::writeStylesheetRef( std::string const& url ) {
        m_os << "<?xml-stylesheet type=\"text/xsl\" href=\"" << url << "\"?>\n";
    }

    XmlWriter& XmlWriter::writeBlankLine() {
        ensureTagClosed();
        m_os << '\n';
        return *this;
    }

    void XmlWriter::ensureTagClosed() {
        if( m_tagIsOpen ) {
            m_os << ">" << std::endl;
            m_tagIsOpen = false;
        }
    }

    void XmlWriter::writeDeclaration() {
        m_os << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    }

    void XmlWriter::newlineIfNecessary() {
        if( m_needsNewline ) {
            m_os << std::endl;
            m_needsNewline = false;
        }
    }
}
EOF_main

    expected = <<-EOF_main







#include "catch_xmlwriter.h"

#include "catch_enforce.h"

#include <iomanip>

using uchar = unsigned char;

namespace Catch {

namespace {

    size_t trailingBytes(unsigned char c) {
        if ((c & 0xE0) == 0xC0) {
            return 2;
        }
        if ((c & 0xF0) == 0xE0) {
            return 3;
        }
        if ((c & 0xF8) == 0xF0) {
            return 4;
        }
        CATCH_INTERNAL_ERROR("Invalid multibyte utf-8 start byte encountered");
    }

    uint32_t headerValue(unsigned char c) {
        if ((c & 0xE0) == 0xC0) {
            return c & 0x1F;
        }
        if ((c & 0xF0) == 0xE0) {
            return c & 0x0F;
        }
        if ((c & 0xF8) == 0xF0) {
            return c & 0x07;
        }
        CATCH_INTERNAL_ERROR("Invalid multibyte utf-8 start byte encountered");
    }

    void hexEscapeChar(std::ostream& os, unsigned char c) {
        std::ios_base::fmtflags f(os.flags());
        os << "\\x"
            << std::uppercase << std::hex << std::setfill('0') << std::setw(2)
            << static_cast<int>(c);
        os.flags(f);
    }

} 

    XmlEncode::XmlEncode( std::string const& str, ForWhat forWhat )
    :   m_str( str ),
        m_forWhat( forWhat )
    {}

    void XmlEncode::encodeTo( std::ostream& os ) const {
        
        

        for( std::size_t idx = 0; idx < m_str.size(); ++ idx ) {
            uchar c = m_str[idx];
            switch (c) {
            case '<':   os << "&lt;"; break;
            case '&':   os << "&amp;"; break;

            case '>':
                
                if (idx > 2 && m_str[idx - 1] == ']' && m_str[idx - 2] == ']')
                    os << "&gt;";
                else
                    os << c;
                break;

            case '\"':
                if (m_forWhat == ForAttributes)
                    os << "&quot;";
                else
                    os << c;
                break;

            default:
                
                
                
                if (c < 0x09 || (c > 0x0D && c < 0x20) || c == 0x7F) {
                    hexEscapeChar(os, c);
                    break;
                }

                
                if (c < 0x7F) {
                    os << c;
                    break;
                }

                
                
                
                
                
                
                if (c <  0xC0 ||
                    c >= 0xF8) {
                    hexEscapeChar(os, c);
                    break;
                }

                auto encBytes = trailingBytes(c);
                
                if (idx + encBytes - 1 >= m_str.size()) {
                    hexEscapeChar(os, c);
                    break;
                }
                
                
                
                bool valid = true;
                uint32_t value = headerValue(c);
                for (std::size_t n = 1; n < encBytes; ++n) {
                    uchar nc = m_str[idx + n];
                    valid &= ((nc & 0xC0) == 0x80);
                    value = (value << 6) | (nc & 0x3F);
                }

                if (
                    
                    (!valid) ||
                    
                    (value < 0x80) ||
                    (0x80 <= value && value < 0x800   && encBytes > 2) ||
                    (0x800 < value && value < 0x10000 && encBytes > 3) ||
                    
                    (value >= 0x110000)
                    ) {
                    hexEscapeChar(os, c);
                    break;
                }

                
                for (std::size_t n = 0; n < encBytes; ++n) {
                    os << m_str[idx + n];
                }
                idx += encBytes - 1;
                break;
            }
        }
    }

    std::ostream& operator << ( std::ostream& os, XmlEncode const& xmlEncode ) {
        xmlEncode.encodeTo( os );
        return os;
    }

    XmlWriter::ScopedElement::ScopedElement( XmlWriter* writer )
    :   m_writer( writer )
    {}

    XmlWriter::ScopedElement::ScopedElement( ScopedElement&& other ) noexcept
    :   m_writer( other.m_writer ){
        other.m_writer = nullptr;
    }
    XmlWriter::ScopedElement& XmlWriter::ScopedElement::operator=( ScopedElement&& other ) noexcept {
        if ( m_writer ) {
            m_writer->endElement();
        }
        m_writer = other.m_writer;
        other.m_writer = nullptr;
        return *this;
    }


    XmlWriter::ScopedElement::~ScopedElement() {
        if( m_writer )
            m_writer->endElement();
    }

    XmlWriter::ScopedElement& XmlWriter::ScopedElement::writeText( std::string const& text, bool indent ) {
        m_writer->writeText( text, indent );
        return *this;
    }

    XmlWriter::XmlWriter( std::ostream& os ) : m_os( os )
    {
        writeDeclaration();
    }

    XmlWriter::~XmlWriter() {
        while( !m_tags.empty() )
            endElement();
    }

    XmlWriter& XmlWriter::startElement( std::string const& name ) {
        ensureTagClosed();
        newlineIfNecessary();
        m_os << m_indent << '<' << name;
        m_tags.push_back( name );
        m_indent += "  ";
        m_tagIsOpen = true;
        return *this;
    }

    XmlWriter::ScopedElement XmlWriter::scopedElement( std::string const& name ) {
        ScopedElement scoped( this );
        startElement( name );
        return scoped;
    }

    XmlWriter& XmlWriter::endElement() {
        newlineIfNecessary();
        m_indent = m_indent.substr( 0, m_indent.size()-2 );
        if( m_tagIsOpen ) {
            m_os << "/>";
            m_tagIsOpen = false;
        }
        else {
            m_os << m_indent << "</" << m_tags.back() << ">";
        }
        m_os << std::endl;
        m_tags.pop_back();
        return *this;
    }

    XmlWriter& XmlWriter::writeAttribute( std::string const& name, std::string const& attribute ) {
        if( !name.empty() && !attribute.empty() )
            m_os << ' ' << name << "=\"" << XmlEncode( attribute, XmlEncode::ForAttributes ) << '"';
        return *this;
    }

    XmlWriter& XmlWriter::writeAttribute( std::string const& name, bool attribute ) {
        m_os << ' ' << name << "=\"" << ( attribute ? "true" : "false" ) << '"';
        return *this;
    }

    XmlWriter& XmlWriter::writeText( std::string const& text, bool indent ) {
        if( !text.empty() ){
            bool tagWasOpen = m_tagIsOpen;
            ensureTagClosed();
            if( tagWasOpen && indent )
                m_os << m_indent;
            m_os << XmlEncode( text );
            m_needsNewline = true;
        }
        return *this;
    }

    XmlWriter& XmlWriter::writeComment( std::string const& text ) {
        ensureTagClosed();
        m_os << m_indent << "<!--" << text << "-->";
        m_needsNewline = true;
        return *this;
    }

    void XmlWriter::writeStylesheetRef( std::string const& url ) {
        m_os << "<?xml-stylesheet type=\"text/xsl\" href=\"" << url << "\"?>\n";
    }

    XmlWriter& XmlWriter::writeBlankLine() {
        ensureTagClosed();
        m_os << '\n';
        return *this;
    }

    void XmlWriter::ensureTagClosed() {
        if( m_tagIsOpen ) {
            m_os << ">" << std::endl;
            m_tagIsOpen = false;
        }
    }

    void XmlWriter::writeDeclaration() {
        m_os << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    }

    void XmlWriter::newlineIfNecessary() {
        if( m_needsNewline ) {
            m_os << std::endl;
            m_needsNewline = false;
        }
    }
}
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_7

    input = <<-EOF_main
#if defined(RECLS_CPP_NO_METHOD_PROPERTY_SUPPORT)
 /* Do not define RECLS_CPP_METHOD_PROPERTY_SUPPORT */
#else /* ? RECLS_CPP_???_METHOD_PROPERTY_SUPPORT */
# elif defined(STLSOFT_COMPILER_IS_DMC)
#  if __DMC__ >= 0x0846
#   define RECLS_CPP_METHOD_PROPERTY_SUPPORT */
#  endif /* __DMC__ */
# elif defined(STLSOFT_COMPILER_IS_GCC)
 /* Do not define RECLS_CPP_METHOD_PROPERTY_SUPPORT */
# elif defined(STLSOFT_COMPILER_IS_INTEL)
#  define RECLS_CPP_METHOD_PROPERTY_SUPPORT
# elif defined(STLSOFT_COMPILER_IS_MSVC)
#  if _MSC_VER >= 1310
#   define RECLS_CPP_METHOD_PROPERTY_SUPPORT
#  endif /* _MSC_VER */
# elif defined(STLSOFT_COMPILER_IS_MWERKS)
#  define RECLS_CPP_METHOD_PROPERTY_SUPPORT
# endif /* compiler */
#endif /* RECLS_CPP_???_METHOD_PROPERTY_SUPPORT */

EOF_main
    expected = <<-EOF_main
#if defined(RECLS_CPP_NO_METHOD_PROPERTY_SUPPORT)
 
#else 
# elif defined(STLSOFT_COMPILER_IS_DMC)
#  if __DMC__ >= 0x0846
#   define RECLS_CPP_METHOD_PROPERTY_SUPPORT */
#  endif 
# elif defined(STLSOFT_COMPILER_IS_GCC)
 
# elif defined(STLSOFT_COMPILER_IS_INTEL)
#  define RECLS_CPP_METHOD_PROPERTY_SUPPORT
# elif defined(STLSOFT_COMPILER_IS_MSVC)
#  if _MSC_VER >= 1310
#   define RECLS_CPP_METHOD_PROPERTY_SUPPORT
#  endif 
# elif defined(STLSOFT_COMPILER_IS_MWERKS)
#  define RECLS_CPP_METHOD_PROPERTY_SUPPORT
# endif 
#endif 

EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_8

    input = <<-EOF_main
/*****************************************************************************
/*                             Start of crcmodel.c                            
/*****************************************************************************
/*                                                                            
/* Author : Ross Williams (ross@guest.adelaide.edu.au.).                      
/* Date   : 3 June 1993.                                                      
/* Status : Public domain.                                                    
/*                                                                            
/* Description : This is the implementation (.c) file for the reference       
/* implementation of the Rocksoft^tm Model CRC Algorithm. For more            
/* information on the Rocksoft^tm Model CRC Algorithm, see the document       
/* titled "A Painless Guide to CRC Error Detection Algorithms" by Ross        
/* Williams (ross@guest.adelaide.edu.au.). This document is likely to be in   
/* "ftp.adelaide.edu.au/pub/rocksoft".                                        
/*                                                                            
/* Note: Rocksoft is a trademark of Rocksoft Pty Ltd, Adelaide, Australia.    
/*                                                                            
/*****************************************************************************
/*                                                                            
/* Implementation Notes                                                       
/* --------------------                                                       
/* To avoid inconsistencies, the specification of each function is not echoed 
/* here. See the header file for a description of these functions.            
/* This package is light on checking because I want to keep it short and      
/* simple and portable (i.e. it would be too messy to distribute my entire    
/* C culture (e.g. assertions package) with this package.                     
/*                                                                            */
/******************************************************************************/

#include "crcmodel.h"

/******************************************************************************/

/* The following definitions make the code more readable. */

#define BITMASK(X) (1L << (X))
#define MASK32 0xFFFFFFFFL
#define LOCAL static

/******************************************************************************/

LOCAL ulong reflect (ulong v, int b)
/* Returns the value v with the bottom b [0,32] bits reflected. */
/* Example: reflect(0x3e23L,3) == 0x3e26                        */
{
	int   i;
	ulong t = v;
	for (i=0; i<b; i++)
	{
		if (t & 1L)
			v|=  BITMASK((b-1)-i);
		else
			v&= ~BITMASK((b-1)-i);
		t>>=1;
	}
	return v;
}

/******************************************************************************/

LOCAL ulong widmask (p_cm_t p_cm)
/* Returns a longword whose value is (2^p_cm->cm_width)-1.     */
/* The trick is to do this portably (e.g. without doing <<32). */
{
	return (((1L<<(p_cm->cm_width-1))-1L)<<1)|1L;
}

/******************************************************************************/

void cm_ini (p_cm_t p_cm)
{
	p_cm->cm_reg = p_cm->cm_init;
}

/******************************************************************************/

void cm_nxt (p_cm_t p_cm, int ch)
{
	int   i;
	ulong uch  = (ulong) ch;
	ulong topbit = BITMASK(p_cm->cm_width-1);

	if (p_cm->cm_refin)
		uch = reflect(uch,8);

	p_cm->cm_reg ^= (uch << (p_cm->cm_width-8));
	for (i=0; i<8; i++)
	{
		if (p_cm->cm_reg & topbit)
			p_cm->cm_reg = (p_cm->cm_reg << 1) ^ p_cm->cm_poly;
		else
			p_cm->cm_reg <<= 1;

		p_cm->cm_reg &= widmask(p_cm);
	}
}

/******************************************************************************/

void cm_blk (p_cm_t p_cm, p_ubyte_ blk_adr, ulong blk_len)
{
	while (blk_len--)
		cm_nxt(p_cm,*blk_adr++);
}

/******************************************************************************/

ulong cm_crc (p_cm_t p_cm)
{
	if (p_cm->cm_refot)
		return p_cm->cm_xorot ^ reflect(p_cm->cm_reg,p_cm->cm_width);
	else
		return p_cm->cm_xorot ^ p_cm->cm_reg;
}

/******************************************************************************/

ulong cm_tab (p_cm_t p_cm, int index)
{
	int   i;
	ulong r;
	ulong topbit = BITMASK(p_cm->cm_width-1);
	ulong inbyte = (ulong) index;

	if (p_cm->cm_refin)
		inbyte = reflect(inbyte,8);

	r = inbyte << (p_cm->cm_width-8);
	for (i=0; i<8; i++)
	{
		if (r & topbit)
			r = (r << 1) ^ p_cm->cm_poly;
		else
			r<<=1;
	}
	if (p_cm->cm_refin)
		r = reflect(r,p_cm->cm_width);
	return r & widmask(p_cm);
}

/******************************************************************************/
/*                             End of crcmodel.c                              */
/******************************************************************************/
EOF_main
    expected = <<-EOF_main





























#include "crcmodel.h"





#define BITMASK(X) (1L << (X))
#define MASK32 0xFFFFFFFFL
#define LOCAL static



LOCAL ulong reflect (ulong v, int b)


{
	int   i;
	ulong t = v;
	for (i=0; i<b; i++)
	{
		if (t & 1L)
			v|=  BITMASK((b-1)-i);
		else
			v&= ~BITMASK((b-1)-i);
		t>>=1;
	}
	return v;
}



LOCAL ulong widmask (p_cm_t p_cm)


{
	return (((1L<<(p_cm->cm_width-1))-1L)<<1)|1L;
}



void cm_ini (p_cm_t p_cm)
{
	p_cm->cm_reg = p_cm->cm_init;
}



void cm_nxt (p_cm_t p_cm, int ch)
{
	int   i;
	ulong uch  = (ulong) ch;
	ulong topbit = BITMASK(p_cm->cm_width-1);

	if (p_cm->cm_refin)
		uch = reflect(uch,8);

	p_cm->cm_reg ^= (uch << (p_cm->cm_width-8));
	for (i=0; i<8; i++)
	{
		if (p_cm->cm_reg & topbit)
			p_cm->cm_reg = (p_cm->cm_reg << 1) ^ p_cm->cm_poly;
		else
			p_cm->cm_reg <<= 1;

		p_cm->cm_reg &= widmask(p_cm);
	}
}



void cm_blk (p_cm_t p_cm, p_ubyte_ blk_adr, ulong blk_len)
{
	while (blk_len--)
		cm_nxt(p_cm,*blk_adr++);
}



ulong cm_crc (p_cm_t p_cm)
{
	if (p_cm->cm_refot)
		return p_cm->cm_xorot ^ reflect(p_cm->cm_reg,p_cm->cm_width);
	else
		return p_cm->cm_xorot ^ p_cm->cm_reg;
}



ulong cm_tab (p_cm_t p_cm, int index)
{
	int   i;
	ulong r;
	ulong topbit = BITMASK(p_cm->cm_width-1);
	ulong inbyte = (ulong) index;

	if (p_cm->cm_refin)
		inbyte = reflect(inbyte,8);

	r = inbyte << (p_cm->cm_width-8);
	for (i=0; i<8; i++)
	{
		if (r & topbit)
			r = (r << 1) ^ p_cm->cm_poly;
		else
			r<<=1;
	}
	if (p_cm->cm_refin)
		r = reflect(r,p_cm->cm_width);
	return r & widmask(p_cm);
}




EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_9

    input = <<-EOF_main
/*
 * This source file is part of the bstring string library.  This code was
 * written by Paul Hsieh in 2002-2010, and is covered by either the 3-clause 
 * BSD open source license or GPL v2.0. Refer to the accompanying documentation 
 * for details on usage and license.
 */

/*
 * bstest.c
 *
 * This file is the C unit test for Bstrlib.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <limits.h>
#include <ctype.h>
#include "bstrlib.h"
#include "bstraux.h"

static bstring dumpOut[16];
static int rot = 0;

static char * dumpBstring (const struct tagbstring * b) {
	rot = (rot + 1) % (unsigned)16;
	if (dumpOut[rot] == NULL) {
		dumpOut[rot] = bfromcstr ("");
		if (dumpOut[rot] == NULL) return "FATAL INTERNAL ERROR";
	}
	dumpOut[rot]->slen = 0;
	if (b == NULL) {
		bcatcstr (dumpOut[rot], "NULL");
	} else {
		static char msg[256];
		sprintf (msg, "%p", (void *)b);
		bcatcstr (dumpOut[rot], msg);

		if (b->slen < 0) {
			sprintf (msg, ":[err:slen=%d<0]", b->slen);
			bcatcstr (dumpOut[rot], msg);
		} else {
			if (b->mlen > 0 && b->mlen < b->slen) {
				sprintf (msg, ":[err:mlen=%d<slen=%d]", b->mlen, b->slen);
				bcatcstr (dumpOut[rot], msg);
			} else {
				if (b->mlen == -1) {
					bcatcstr (dumpOut[rot], "[p]");
				} else if (b->mlen < 0) {
					bcatcstr (dumpOut[rot], "[c]");
				}
				bcatcstr (dumpOut[rot], ":");
				if (b->data == NULL) {
					bcatcstr (dumpOut[rot], "[err:data=NULL]");
				} else {
					bcatcstr (dumpOut[rot], "\"");
					bcatcstr (dumpOut[rot], (const char *) b->data);
					bcatcstr (dumpOut[rot], "\"");
				}
			}
		}
	}
	return (char *) dumpOut[rot]->data;
}

static int test0_0 (const char * s, const char * res) {
bstring b0 = bfromcstr (s);
int ret = 0;

	if (s == NULL) {
		if (res != NULL) ret++;
		printf (".\tbfromcstr (NULL) = %s\n", dumpBstring (b0));
		return ret;
	}

	ret += (res == NULL) || ((int) strlen (res) != b0->slen)
	       || (0 != memcmp (res, b0->data, b0->slen));
	ret += b0->data[b0->slen] != '\0';

	printf (".\tbfromcstr (\"%s\") = %s\n", s, dumpBstring (b0));
	bdestroy (b0);
	return ret;
}

static int test0_1 (const char * s, int len, const char * res) {
bstring b0 = bfromcstralloc (len, s);
int ret = 0;

	if (s == NULL) {
		if (res != NULL) ret++;
		printf (".\tbfromcstralloc (*, NULL) = %s\n", dumpBstring (b0));
		return ret;
	}

	ret += (res == NULL) || ((int) strlen (res) != b0->slen)
	       || (0 != memcmp (res, b0->data, b0->slen));
	ret += b0->data[b0->slen] != '\0';
	ret += len > b0->mlen;

	printf (".\tbfromcstralloc (%d, \"%s\") = %s\n", len, s, dumpBstring (b0));
	bdestroy (b0);
	return ret;
}

#define EMPTY_STRING ""
#define SHORT_STRING "bogus"
#define LONG_STRING  "This is a bogus but reasonably long string.  Just long enough to cause some mallocing."

static int test0 (void) {
int ret = 0;

	printf ("TEST: bstring bfromcstr (const char * str);\n");

	/* tests with NULL */
	ret += test0_0 (NULL, NULL);

	/* normal operation tests */
	ret += test0_0 (EMPTY_STRING, EMPTY_STRING);
	ret += test0_0 (SHORT_STRING, SHORT_STRING);
	ret += test0_0 (LONG_STRING, LONG_STRING);
	printf ("\t# failures: %d\n", ret);

	printf ("TEST: bstring bfromcstralloc (int len, const char * str);\n");

	/* tests with NULL */
	ret += test0_1 (NULL,  0, NULL);
	ret += test0_1 (NULL, 30, NULL);

	/* normal operation tests */
	ret += test0_1 (EMPTY_STRING,  0, EMPTY_STRING);
	ret += test0_1 (EMPTY_STRING, 30, EMPTY_STRING);
	ret += test0_1 (SHORT_STRING,  0, SHORT_STRING);
	ret += test0_1 (SHORT_STRING, 30, SHORT_STRING);
	ret += test0_1 ( LONG_STRING,  0,  LONG_STRING);
	ret += test0_1 ( LONG_STRING, 30,  LONG_STRING);
	printf ("\t# failures: %d\n", ret);

	return ret;
}

EOF_main
    expected = <<-EOF_main













#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <limits.h>
#include <ctype.h>
#include "bstrlib.h"
#include "bstraux.h"

static bstring dumpOut[16];
static int rot = 0;

static char * dumpBstring (const struct tagbstring * b) {
	rot = (rot + 1) % (unsigned)16;
	if (dumpOut[rot] == NULL) {
		dumpOut[rot] = bfromcstr ("");
		if (dumpOut[rot] == NULL) return "FATAL INTERNAL ERROR";
	}
	dumpOut[rot]->slen = 0;
	if (b == NULL) {
		bcatcstr (dumpOut[rot], "NULL");
	} else {
		static char msg[256];
		sprintf (msg, "%p", (void *)b);
		bcatcstr (dumpOut[rot], msg);

		if (b->slen < 0) {
			sprintf (msg, ":[err:slen=%d<0]", b->slen);
			bcatcstr (dumpOut[rot], msg);
		} else {
			if (b->mlen > 0 && b->mlen < b->slen) {
				sprintf (msg, ":[err:mlen=%d<slen=%d]", b->mlen, b->slen);
				bcatcstr (dumpOut[rot], msg);
			} else {
				if (b->mlen == -1) {
					bcatcstr (dumpOut[rot], "[p]");
				} else if (b->mlen < 0) {
					bcatcstr (dumpOut[rot], "[c]");
				}
				bcatcstr (dumpOut[rot], ":");
				if (b->data == NULL) {
					bcatcstr (dumpOut[rot], "[err:data=NULL]");
				} else {
					bcatcstr (dumpOut[rot], "\"");
					bcatcstr (dumpOut[rot], (const char *) b->data);
					bcatcstr (dumpOut[rot], "\"");
				}
			}
		}
	}
	return (char *) dumpOut[rot]->data;
}

static int test0_0 (const char * s, const char * res) {
bstring b0 = bfromcstr (s);
int ret = 0;

	if (s == NULL) {
		if (res != NULL) ret++;
		printf (".\tbfromcstr (NULL) = %s\n", dumpBstring (b0));
		return ret;
	}

	ret += (res == NULL) || ((int) strlen (res) != b0->slen)
	       || (0 != memcmp (res, b0->data, b0->slen));
	ret += b0->data[b0->slen] != '\0';

	printf (".\tbfromcstr (\"%s\") = %s\n", s, dumpBstring (b0));
	bdestroy (b0);
	return ret;
}

static int test0_1 (const char * s, int len, const char * res) {
bstring b0 = bfromcstralloc (len, s);
int ret = 0;

	if (s == NULL) {
		if (res != NULL) ret++;
		printf (".\tbfromcstralloc (*, NULL) = %s\n", dumpBstring (b0));
		return ret;
	}

	ret += (res == NULL) || ((int) strlen (res) != b0->slen)
	       || (0 != memcmp (res, b0->data, b0->slen));
	ret += b0->data[b0->slen] != '\0';
	ret += len > b0->mlen;

	printf (".\tbfromcstralloc (%d, \"%s\") = %s\n", len, s, dumpBstring (b0));
	bdestroy (b0);
	return ret;
}

#define EMPTY_STRING ""
#define SHORT_STRING "bogus"
#define LONG_STRING  "This is a bogus but reasonably long string.  Just long enough to cause some mallocing."

static int test0 (void) {
int ret = 0;

	printf ("TEST: bstring bfromcstr (const char * str);\n");

	
	ret += test0_0 (NULL, NULL);

	
	ret += test0_0 (EMPTY_STRING, EMPTY_STRING);
	ret += test0_0 (SHORT_STRING, SHORT_STRING);
	ret += test0_0 (LONG_STRING, LONG_STRING);
	printf ("\t# failures: %d\n", ret);

	printf ("TEST: bstring bfromcstralloc (int len, const char * str);\n");

	
	ret += test0_1 (NULL,  0, NULL);
	ret += test0_1 (NULL, 30, NULL);

	
	ret += test0_1 (EMPTY_STRING,  0, EMPTY_STRING);
	ret += test0_1 (EMPTY_STRING, 30, EMPTY_STRING);
	ret += test0_1 (SHORT_STRING,  0, SHORT_STRING);
	ret += test0_1 (SHORT_STRING, 30, SHORT_STRING);
	ret += test0_1 ( LONG_STRING,  0,  LONG_STRING);
	ret += test0_1 ( LONG_STRING, 30,  LONG_STRING);
	printf ("\t# failures: %d\n", ret);

	return ret;
}

EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end

  def test_real_sample_10

    input = <<-EOF_main
// Scintilla source code edit control
/** @file CharacterSet.h
 ** Encapsulates a set of characters. Used to test if a character is within a set.
 **/
// Copyright 2007 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

class CharacterSet {
	int size;
	bool valueAfter;
	bool *bset;
public:
	enum setBase {
		setNone=0,
		setLower=1,
		setUpper=2,
		setDigits=4,
		setAlpha=setLower|setUpper,
		setAlphaNum=setAlpha|setDigits
	};
	CharacterSet(setBase base=setNone, const char *initialSet="", int size_=0x80, bool valueAfter_=false) {
		size = size_;
		valueAfter = valueAfter_;
		bset = new bool[size];
		for (int i=0; i < size; i++) {
			bset[i] = false;
		}
		AddString(initialSet);
		if (base & setLower)
			AddString("abcdefghijklmnopqrstuvwxyz");
		if (base & setUpper)
			AddString("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
		if (base & setDigits)
			AddString("0123456789");
	}
	~CharacterSet() {
		delete []bset;
		bset = 0;
		size = 0;
	}
	void Add(int val) {
		PLATFORM_ASSERT(val >= 0);
		PLATFORM_ASSERT(val < size);
		bset[val] = true;
	}
	void AddString(const char *CharacterSet) {
		for (const char *cp=CharacterSet; *cp; cp++) {
			int val = static_cast<unsigned char>(*cp);
			PLATFORM_ASSERT(val >= 0);
			PLATFORM_ASSERT(val < size);
			bset[val] = true;
		}
	}
	bool Contains(int val) const {
		PLATFORM_ASSERT(val >= 0);
		return (val < size) ? bset[val] : valueAfter;
	}
};
EOF_main

    expected = <<-EOF_main







class CharacterSet {
	int size;
	bool valueAfter;
	bool *bset;
public:
	enum setBase {
		setNone=0,
		setLower=1,
		setUpper=2,
		setDigits=4,
		setAlpha=setLower|setUpper,
		setAlphaNum=setAlpha|setDigits
	};
	CharacterSet(setBase base=setNone, const char *initialSet="", int size_=0x80, bool valueAfter_=false) {
		size = size_;
		valueAfter = valueAfter_;
		bset = new bool[size];
		for (int i=0; i < size; i++) {
			bset[i] = false;
		}
		AddString(initialSet);
		if (base & setLower)
			AddString("abcdefghijklmnopqrstuvwxyz");
		if (base & setUpper)
			AddString("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
		if (base & setDigits)
			AddString("0123456789");
	}
	~CharacterSet() {
		delete []bset;
		bset = 0;
		size = 0;
	}
	void Add(int val) {
		PLATFORM_ASSERT(val >= 0);
		PLATFORM_ASSERT(val < size);
		bset[val] = true;
	}
	void AddString(const char *CharacterSet) {
		for (const char *cp=CharacterSet; *cp; cp++) {
			int val = static_cast<unsigned char>(*cp);
			PLATFORM_ASSERT(val >= 0);
			PLATFORM_ASSERT(val < size);
			bset[val] = true;
		}
	}
	bool Contains(int val) const {
		PLATFORM_ASSERT(val >= 0);
		return (val < size) ? bset[val] : valueAfter;
	}
};
EOF_main

    actual = strip(input, 'C')

    assert_equal expected, actual
  end
end

# ############################## end of file ############################# #


