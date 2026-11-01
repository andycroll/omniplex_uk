require_relative '../../test_helper'

class OmniplexUk::CinemaTest < Minitest::Test
  include WebsiteStubs

  GREAT_BRITAIN = %w(OMP_BIRM OMP_HIWY OMP_IPSW OMP_SUND OMP_SUTT OMP_WIGA OMP_CLYD OMP_GLAS).freeze
  NORTHERN_IRELAND = %w(
    OMP_ANTR OMP_BANB OMP_BANG OMP_DUDO OMP_KENN OMP_CARR OMP_CRAI
    OMP_DERR OMP_DOWN OMP_DUGA OMP_LARN OMP_LISB OMP_NEWR OMP_OMAG
  ).freeze
  POSTCODE = /\A[A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}\z/

  def setup
    stub_website
    OmniplexUk::Cinema.instance_variable_set(:@venues_hash, nil)
  end

  def test_reads_omniplexcinemas_co_uk
    assert_equal 'https://www.omniplexcinemas.co.uk', OmniplexUk::Cinema.website
  end

  def test_new_stores_upcase_string_id
    assert_equal 'OMP_KENN', OmniplexUk::Cinema.new('omp_kenn').id
  end

  def test_all_returns_uk_venues_only
    cinemas = OmniplexUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(OmniplexUk::Cinema) })
    assert_equal GREAT_BRITAIN + NORTHERN_IRELAND, cinemas.map(&:id)
  end

  def test_all_leaves_out_the_republic_of_ireland
    refute_includes OmniplexUk::Cinema.all.map(&:id), 'OMP_RATH'
    assert_equal '', OmniplexUk::Cinema.new('OMP_RATH').name
  end

  def test_all_reads_the_home_page_once_an_hour
    2.times { OmniplexUk::Cinema.all }

    assert_requested :get, HOME, times: 1
  end

  def test_name_full_name_and_slug
    cinema = OmniplexUk::Cinema.new('OMP_KENN')

    assert_equal 'Belfast - Kennedy Centre', cinema.name
    assert_equal 'Omniplex Belfast - Kennedy Centre', cinema.full_name
    assert_equal 'omniplex-belfast-kennedy-centre', cinema.slug
  end

  def test_brand
    assert_equal 'Omniplex', OmniplexUk::Cinema.new('OMP_SUND').brand
  end

  def test_url_selects_the_venue_on_the_website
    expected = 'https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_SUND'

    assert_equal expected, OmniplexUk::Cinema.new('OMP_SUND').url
  end

  def test_adr
    expected = {
      street_address:   'Kennedy Centre',
      extended_address: '564-568 Falls Road',
      locality:         'Belfast',
      region:           'County Antrim',
      postal_code:      'BT11 9AB',
      country_name:     'United Kingdom'
    }

    assert_equal expected, OmniplexUk::Cinema.new('OMP_KENN').adr
  end

  def test_coordinates
    cinema = OmniplexUk::Cinema.new('OMP_SUND')

    assert_in_delta 54.9082446, cinema.latitude
    assert_in_delta(-1.3800217, cinema.longitude)
  end

  def test_every_venue_has_an_address_and_coordinates
    OmniplexUk::Cinema.all.each do |cinema|
      refute_empty cinema.street_address, cinema.id
      refute_empty cinema.locality, cinema.id
      refute_empty cinema.region, cinema.id
      assert_match POSTCODE, cinema.postal_code, cinema.id
      assert_kind_of Float, cinema.latitude, cinema.id
      assert_kind_of Float, cinema.longitude, cinema.id
    end
  end

  def test_coordinates_are_in_the_uk
    OmniplexUk::Cinema::LOCATIONS.each do |id, location|
      assert_includes 49.9..60.9, location[:latitude], id
      assert_includes(-8.2..1.8, location[:longitude], id)
    end
  end

  def test_unknown_cinema_has_no_location
    cinema = OmniplexUk::Cinema.new('OMP_ZZZZ')

    assert_equal '', cinema.name
    assert_nil cinema.latitude
  end
end
