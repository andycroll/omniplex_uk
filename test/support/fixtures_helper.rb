# Read fixtures from disk: pages captured from www.omniplexcinemas.co.uk,
# trimmed to a few films and showtimes, with the Sunderland calendar cut
# to the dates captured. They keep the site's mixed UTF-8 and
# Windows-1252 bytes and follow the shape in api_shapes.rb.
module FixturesHelper
  private

  def home_html
    read_fixture('website/home.html')
  end

  def showtimes_html(site_code, date = nil)
    read_fixture("website/#{["showtimes-#{site_code}", date].compact.join('-')}.html")
  end

  def read_fixture(filepath)
    File.binread(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
