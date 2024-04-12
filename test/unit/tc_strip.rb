#! /usr/bin/env ruby

$:.unshift File.join(__dir__, '../..', 'lib')


require 'comment_strip'

require 'xqsr3/extensions/test/unit'
require 'test/unit'


class Test_strip_1 < Test::Unit::TestCase

  include ::CommentStrip

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

      assert_raise_with_message(::ArgumentError, /family.*unrecognised/) { strip('', family) }
      assert_raise_with_message(::ArgumentError, /family.*unrecognised/) { ::CommentStrip.strip('', family) }
    end
  end
end

