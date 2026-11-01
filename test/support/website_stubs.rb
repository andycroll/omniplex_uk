require_relative 'fixtures_helper'

# Serve the fixtures in place of omniplexcinemas.co.uk
module WebsiteStubs
  include FixturesHelper

  WEBSITE = 'https://www.omniplexcinemas.co.uk'.freeze
  HOME = "#{WEBSITE}/".freeze
  SHOWTIMES = "#{WEBSITE}/cinema/showtimes".freeze
  SUNDERLAND_DATES = %w(2026-11-02 2026-11-04 2026-12-05 2026-12-16 2027-05-25).freeze

  private

  def stub_website
    stub_request(:get, HOME).to_return(status: 200, body: home_html)
    stub_showtimes('OMP_SUND')
    stub_showtimes('OMP_BIRM')
    SUNDERLAND_DATES.each { |date| stub_showtimes('OMP_SUND', date) }
  end

  def stub_showtimes(site_code, date = nil)
    stub_request(:get, showtimes_url(site_code, date)).to_return(status: 200, body: showtimes_html(site_code, date))
  end

  def showtimes_url(site_code, date = nil)
    if date
      "#{SHOWTIMES}?sitecode=#{site_code}&action=processFilters&filterDate=#{date}"
    else
      "#{SHOWTIMES}?sitecode=#{site_code}"
    end
  end
end
