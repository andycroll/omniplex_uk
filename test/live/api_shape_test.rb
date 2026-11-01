require_relative 'live_helper'

# The home page and one venue's listings page: two requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_pages_are_readable
    client = OmniplexUk::Internal::Client.new

    assert_home_page_shape(client.send(:get, '/'))
    assert_listings_shape(client.showtimes('OMP_KENN'))
  ensure
    client.close
  end
end
