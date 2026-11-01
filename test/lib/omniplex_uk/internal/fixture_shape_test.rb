require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_home_page_fixture_matches_shape
    assert_home_page_shape(decoded(home_html))
  end

  def test_listings_fixtures_match_shape
    Dir[File.expand_path('../../../../fixtures/website/showtimes-*.html', __FILE__)].each do |path|
      assert_listings_shape(decoded(File.binread(path)))
    end
  end

  private

  def decoded(html)
    html.force_encoding(Encoding::UTF_8).scrub
  end
end
