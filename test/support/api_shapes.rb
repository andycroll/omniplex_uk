# The parts of Omniplex pages the gem reads. Checked against the trimmed
# fixtures and, in the live suite, against real pages held only in memory.
module ApiShapes
  SITE_CODE = /\AOMP_[A-Z]{4}\z/
  UK_REGIONS = %w(England NorthernIreland Scotland).freeze
  BOOKING_URL = %r{\Ahttps://www\.omniplexcinemas\.co\.uk/booking/seats/[a-z-]+/\d+\z}
  MILLISECOND_MIDNIGHT = /\A\d{10}000\z/

  private

  def assert_home_page_shape(html)
    groups = html.scan(OmniplexUk::Internal::Client::REGION_OR_VENUE)
    regions = groups.filter_map(&:first)
    codes = groups.filter_map(&:last)

    assert_empty UK_REGIONS - regions
    refute_empty codes
    codes.each { |code| assert_match SITE_CODE, code }
  end

  def assert_listings_shape(html)
    timestamps = html[OmniplexUk::Internal::Listings::ADVERTISED_DATES, 1].to_s.split(',')
    refute_empty timestamps
    timestamps.each { |milliseconds| assert_match MILLISECOND_MIDNIGHT, milliseconds.strip }
    assert_match OmniplexUk::Internal::Listings::PAGE_DATE, html

    films = html.scan(OmniplexUk::Internal::Listings::FILM)
    refute_empty films
    showtimes = html.scan(OmniplexUk::Internal::Listings::SHOWTIME)
    refute_empty showtimes
    showtimes.each { |_hour, _minute, href, _box| assert_match BOOKING_URL, href }
  end
end
