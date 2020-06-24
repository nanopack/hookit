require 'minitest/autorun'
require 'hookit/hook'

class HookTest < Minitest::Test
  def test_hook
    assert_equal true, false
  end
end
