require_relative '../../test_helper'

class OmniplexUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil OmniplexUk::VERSION
  end
end
