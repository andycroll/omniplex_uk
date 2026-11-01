require_relative '../../../test_helper'

class OmniplexUk::Internal::ListingsTest < Minitest::Test
  include FixturesHelper

  def test_dates_are_the_advertised_london_dates
    expected = %w(2026-11-01 2026-11-02 2026-11-04 2026-12-05 2026-12-16 2027-05-25).map { |date| Date.iso8601(date) }

    assert_equal expected, listings('OMP_SUND').dates
  end

  def test_date_is_the_day_listed
    assert_equal Date.new(2026, 11, 4), listings('OMP_SUND', '2026-11-04').date
  end

  def test_showings
    showing = listings('OMP_SUND').showings.first

    assert_equal '371766', showing.film_id
    assert_equal 'Clayface', showing.title
    assert_equal Date.new(2026, 11, 1), showing.date
    assert_equal Time.utc(2026, 11, 1, 16, 20), showing.starting_at
    assert_equal 'https://www.omniplexcinemas.co.uk/booking/seats/sunderland/44797', showing.booking_url
    assert_equal ['MAXX'], showing.tags
  end

  def test_single_digit_hours
    html = listings_html('OMP_SUND', '2026-12-16').sub('Doomsday at 10:00 in', 'Doomsday at 9:30 in')
    showing = OmniplexUk::Internal::Listings.new(html).showings.first

    assert_equal Time.utc(2026, 12, 16, 9, 30), showing.starting_at
  end

  def test_hall_icons_and_tags
    tags = %w(OMP_SUND OMP_BIRM).flat_map { |code| listings(code).showings.map(&:tags) } +
           [listings('OMP_SUND', '2026-11-02'), listings('OMP_SUND', '2026-11-04'),
            listings('OMP_GLAS', '2026-12-16')].flat_map { |page| page.showings.map(&:tags) }

    assert_includes tags, ['MAXX', 'Audio Described']
    assert_includes tags, ['Sofa Bed']
    assert_includes tags, ['Subtitled']
    assert_includes tags, ['Seniors Club']
    assert_includes tags, ['Infinity Vision 3D', '4D E-Motion']
  end

  def test_sold_out_badges_are_not_tags
    tags = listings('OMP_GLAS', '2026-12-16').showings.map(&:tags)

    assert_includes tags, []
  end

  def test_event_genre_tags_every_showing
    showing = listings('OMP_SUND', '2027-05-25').showings.first

    assert_equal 'Romeo & Juliet - LIVE - The Royal Ballet 26-27', showing.title
    assert_equal ['Event'], showing.tags
  end

  def test_page_without_listings
    listings = OmniplexUk::Internal::Listings.new('<html></html>')

    assert_empty listings.dates
    assert_nil listings.date
    assert_empty listings.showings
  end

  private

  def listings(site_code, date = nil)
    OmniplexUk::Internal::Listings.new(listings_html(site_code, date))
  end

  def listings_html(site_code, date = nil)
    showtimes_html(site_code, date).force_encoding(Encoding::UTF_8).scrub
  end
end
