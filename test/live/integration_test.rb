require_relative 'live_helper'

# The home page, then one request for each date Kennedy Centre advertises
class LiveIntegrationTest < Minitest::Test
  def test_cinemas_and_their_performances
    cinemas = OmniplexUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(OmniplexUk::Cinema) })
    assert_operator cinemas.size, :>=, 20
    assert_empty cinemas.map(&:id) - OmniplexUk::Cinema::LOCATIONS.keys

    kennedy = cinemas.detect { |cinema| cinema.id == 'OMP_KENN' }
    assert_equal 'Belfast - Kennedy Centre', kennedy.name

    today = Date.today
    performances = OmniplexUk::Performance.at('OMP_KENN', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(OmniplexUk::Performance) })
    assert_operator performances.count, :>, 50
    assert_operator performances.map(&:showing_on).max, :>, today + 14
    assert(performances.all? { |p| p.booking_url.match?(ApiShapes::BOOKING_URL) })
  end
end
