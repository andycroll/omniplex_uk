require_relative '../../../test_helper'

class OmniplexUk::Internal::ClientTest < Minitest::Test
  include WebsiteStubs

  def setup
    stub_website
    @client = OmniplexUk::Internal::Client.new
  end

  def teardown
    @client.close
    super
  end

  def test_venues_are_uk_sites_with_their_listings_url
    venue = @client.venues.detect { |v| v[:code] == 'OMP_DUDO' }
    expected = {
      url: 'https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_DUDO',
      name: 'Belfast - Dundonald',
      code: 'OMP_DUDO'
    }

    assert_equal expected, venue
    assert_equal 22, @client.venues.size
  end

  def test_showtimes_for_a_date
    html = @client.showtimes('OMP_SUND', Date.new(2026, 11, 4))

    assert_includes html, 'Wild Horse Nine'
  end

  def test_requests_share_one_connection
    start = Net::HTTP.method(:start)
    connections = 0
    counting = lambda do |*args, **options|
      connections += 1
      start.call(*args, **options)
    end

    Net::HTTP.stub(:start, counting) do
      @client.showtimes('OMP_SUND')
      @client.showtimes('OMP_SUND', Date.new(2026, 11, 2))
    end

    assert_equal 1, connections
  end

  def test_decodes_utf8_and_windows_1252_in_one_page
    html = @client.showtimes('OMP_SUND')

    assert html.valid_encoding?
    assert_includes html, 'the city’s premier'
    assert_includes html, '50–100ms'
  end

  def test_http_errors_omit_the_body
    stub_request(:get, HOME).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { @client.venues }

    assert_equal 'HTTP error 500 from www.omniplexcinemas.co.uk', error.message
  end

  def test_retries_transient_errors
    stub_request(:get, HOME).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: home_html)

    Cinebase::Http.stub(:pause, nil) do
      assert_equal 22, @client.venues.size
    end
  end
end
