require_relative '../../test_helper'

class OmniplexUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  TODAY = Date.new(2026, 11, 1)

  def setup
    stub_website
    OmniplexUk::Cinema.instance_variable_set(:@venues_hash, nil)
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('OMP_SUND')

    assert(performances.all? { |p| p.instance_of?(OmniplexUk::Performance) })
    assert_equal 19, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_each_advertised_date_once
    performances_at('omp_sund')

    assert_requested :get, showtimes_url('OMP_SUND'), times: 1
    SUNDERLAND_DATES.each { |date| assert_requested :get, showtimes_url('OMP_SUND', date), times: 1 }
    assert_not_requested :get, showtimes_url('OMP_SUND', '2026-11-01')
  end

  def test_at_only_reads_dates_in_the_range
    performances = OmniplexUk::Performance.at('OMP_SUND', from: TODAY + 1, to: TODAY + 2)

    assert_equal [Date.new(2026, 11, 2)], performances.map(&:showing_on).uniq
    assert_requested :get, showtimes_url('OMP_SUND'), times: 1
    assert_not_requested :get, showtimes_url('OMP_SUND', '2026-11-04')
  end

  def test_at_rejects_a_backwards_range
    assert_raises(ArgumentError) { OmniplexUk::Performance.at('OMP_SUND', from: TODAY, to: TODAY - 1) }
  end

  def test_unknown_cinema_has_no_performances
    assert_empty OmniplexUk::Performance.at('OMP_ZZZZ', from: TODAY, to: TODAY + 365)
    assert_not_requested :get, %r{/cinema/showtimes}
  end

  def test_at_sets_cinema_details
    performances = performances_at('OMP_SUND')

    assert_equal ['OMP_SUND'], performances.map(&:cinema_id).uniq
    assert_equal ['Sunderland'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_a_performance
    performance = performances_at('OMP_SUND').detect { |p| p.booking_url.end_with?('/44797') }

    assert_equal 'Clayface', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 16, 20), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(maxx), performance.variant
    assert_equal 'https://www.omniplexcinemas.co.uk/booking/seats/sunderland/44797', performance.booking_url
  end

  def test_summer_dates_and_times
    performance = performances_at('OMP_SUND').last

    assert_equal 'Romeo & Juliet', performance.film_name
    assert_equal Cinebase::Event.new(name: 'Royal Ballet and Opera'), performance.event
    assert_equal Date.new(2027, 5, 25), performance.showing_on
    assert_equal Time.utc(2027, 5, 25, 18, 15), performance.starting_at
    assert_equal %w(arts), performance.variant
  end

  def test_premium_screens_and_seats
    variants = performances_at('OMP_SUND').map(&:variant).uniq

    assert_includes variants, %w(avenue infinity_vision)
    assert_includes variants, %w(infinity_vision maxx)
    assert_includes variants, %w(sofabed)
  end

  def test_subtitled_and_seniors_screenings
    performances = performances_at('OMP_SUND')

    assert_equal ['Clayface'], performances.select(&:subtitled?).map(&:film_name)
    assert_equal ['Wild Horse Nine'], performances.select { |p| p.variant.include?('senior') }.map(&:film_name)
  end

  def test_event_genre_is_arts
    performance = performances_at('OMP_SUND').detect { |p| p.showing_on == Date.new(2026, 12, 5) }

    assert_equal "Andre Rieu's 2026 Christmas Concert: Let It Snow", performance.film_name
    assert_equal %w(arts), performance.variant
  end

  def test_audio_described_screenings
    performances = performances_at('OMP_BIRM')

    assert_equal [%w(audio_described), %w(audio_described maxx)], performances.map(&:variant)
  end

  def test_anniversary_titles
    performance = performances_at('OMP_SUND').detect { |p| p.booking_url.end_with?('/44815') }

    assert_equal "Pan's Labyrinth", performance.film_name
  end

  def test_infinity_vision_3d_in_4d
    showing = glasgow_showings.detect { |s| s.booking_url.end_with?('/3821') }
    attributes = OmniplexUk::Performance.send(:attributes, showing)

    assert_equal '3d', attributes[:dimension]
    assert_equal %w(4d infinity_vision), attributes[:variant].sort
  end

  def test_live_broadcasts_without_a_genre_are_arts
    showing = glasgow_showings.first.with(title: 'Carmen - LIVE- The Royal Opera 26-27', tags: [])
    attributes = OmniplexUk::Performance.send(:attributes, showing)

    assert_equal 'Royal Ballet and Opera: Carmen', attributes[:film_name]
    assert_equal %w(arts), attributes[:variant]
  end

  def test_language_from_a_country
    showing = glasgow_showings.first.with(title: 'Jak zyc, zeby nie zwariowac (Poland)')
    attributes = OmniplexUk::Performance.send(:attributes, showing)

    assert_equal 'Jak zyc, zeby nie zwariowac', attributes[:film_name]
    assert_equal 'Polish', attributes[:language]
  end

  private

  def performances_at(cinema_id)
    OmniplexUk::Performance.at(cinema_id, from: TODAY, to: TODAY + 365)
  end

  def glasgow_showings
    stub_showtimes('OMP_GLAS', '2026-12-16')
    html = OmniplexUk::Internal::Client.new.showtimes('OMP_GLAS', Date.new(2026, 12, 16))
    OmniplexUk::Internal::Listings.new(html).showings
  end
end
