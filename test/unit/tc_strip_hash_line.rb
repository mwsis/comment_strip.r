#! /usr/bin/env ruby

$:.unshift File.join(__dir__, '../..', 'lib')


require 'comment_strip'

require 'xqsr3/extensions/test/unit'
require 'test/unit'


class Test_HashLine_strip_1 < Test::Unit::TestCase

  include ::CommentStrip

  def test_nil

    assert_nil strip(nil, :Hash_Line)
    assert_nil ::CommentStrip.strip(nil, 'Hash_Line')
  end

  def test_empty

    assert_equal "", strip('', 'Hash_Line')
    assert_equal "", ::CommentStrip.strip('', :Hash_Line)
  end

  def test_code_with_single_line_no_comment

    input = <<-EOF
x=1
EOF
    expected = <<-EOF
x=1
EOF

    actual = strip(input, :Hash_Line)

    assert_equal expected, actual
  end

  def test_code_with_multiple_lines_no_comments

    input = <<-EOF
x=1
y="abc"
z=`pwd`
EOF
    expected = <<-EOF
x=1
y="abc"
z=`pwd`
EOF

    actual = strip(input, :Hash_Line)

    assert_equal expected, actual
  end

  def test_code_with_single_line_and_comment

    input = <<-EOF
x=1 # x=1
EOF
    expected = <<-EOF
x=1 
EOF

    actual = strip(input, :Hash_Line)

    assert_equal expected, actual
  end

  def test_code_with_multiple_lines_and_comments

  input = <<-EOF
x=1#x=1
y="abc"
z=`pwd` # comment
EOF
  expected = <<-EOF
x=1
y="abc"
z=`pwd` 
EOF

    actual = strip(input, :Hash_Line)

    assert_equal expected, actual
  end

  def test_streaming_with_multiple_lines_and_comments_to_completion

  input = <<-EOF
x=1#x=1
y="abc"
z=`pwd` # comment
EOF
  expected = <<-EOF
x=1
y="abc"
z=`pwd` 
EOF

    expected_blocks = [
      'x=1',
      'y="abc"',
      'z=`pwd` ',
    ]
    actual_blocks = []

    actual = strip(input, :hash_line) { |block| actual_blocks << block }

    assert_equal expected, actual
    assert_equal expected_blocks, actual_blocks
  end

  def test_streaming_with_multiple_lines_and_comments_stopping

  input = <<-EOF
x=1#x=1
y="abc"
z=`pwd` # comment
EOF

    expected_blocks = [
      'x=1',
      'y="abc"',
      'z=`pwd` ',
    ]
    actual_blocks = []

    actual = strip(input, :hash_line) do |block|

      actual_blocks << block

      return :stop if actual_blocks.size == 3
    end

    assert_nil actual
    assert_equal expected_blocks, actual_blocks
  end
end

# ############################## end of file ############################# #

