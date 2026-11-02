require 'cgi/escape'

module OmniplexUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads the venue list and daily listings from omniplexcinemas.co.uk,
    # Omniplex's Admit One site. A venue's listings take one request per
    # day, so requests share one kept-alive connection until #close.
    class Client
      WEBSITE = 'https://www.omniplexcinemas.co.uk'.freeze
      SHOWTIMES_PATH = '/cinema/showtimes'.freeze

      # The home page's site picker groups venues by region. The Ireland
      # region is the Republic, served by omniplex.ie.
      REGION_OR_VENUE = /data-region="(\w+)"|data-name="([^"]*)" data-sitecode="(\w+)"/
      UK_REGIONS = %w(England NorthernIreland Scotland Wales).freeze

      # Pages claim ISO-8859-1 but mix UTF-8 with Windows-1252 apostrophes
      LEGACY_ENCODING = Encoding::Windows_1252

      def initialize
        @http = Cinebase::Http.new(keep_alive: true)
      end

      # UK venues in the home page's site picker
      # @return [Array<Hash>] with :url, :name and :code, e.g.
      #   { url: 'https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_KENN',
      #     name: 'Belfast - Kennedy Centre', code: 'OMP_KENN' }
      def venues
        region = nil
        venues = get('/').scan(REGION_OR_VENUE).filter_map do |group, name, code|
          if group
            region = group
            nil
          elsif UK_REGIONS.include?(region)
            { url: showtimes_url(code), name: CGI.unescapeHTML(name).strip, code: code }
          end
        end
        venues.uniq { |venue| venue[:code] }
      end

      # One day's listings for a venue, or its default day's without a date.
      # Each page also lists every advertised date.
      # @param [String] site_code e.g. 'OMP_KENN'
      # @param [Date, nil] date
      # @return [String]
      def showtimes(site_code, date = nil)
        get(showtimes_path(site_code, date))
      end

      # @param [String] site_code e.g. 'OMP_KENN'
      # @return [String] the venue's listings page; it also selects the venue
      #   on the website for later visits
      def showtimes_url(site_code)
        WEBSITE + showtimes_path(site_code)
      end

      def close
        @http.close
      end

      private

      def showtimes_path(site_code, date = nil)
        query = { sitecode: site_code }
        query.merge!(action: 'processFilters', filterDate: date.iso8601) if date
        "#{SHOWTIMES_PATH}?#{URI.encode_www_form(query)}"
      end

      def get(path)
        decode(@http.get(WEBSITE + path))
      end

      def decode(body)
        body.scrub do |bytes|
          bytes.force_encoding(LEGACY_ENCODING).encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        end
      end
    end
  end
end
