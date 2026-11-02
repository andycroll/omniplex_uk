module OmniplexUk
  # A single screening of a film on the Omniplex Cinemas website
  class Performance < Cinebase::A1web::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [String] :language (nil) audio language, e.g. 'Polish'
    #   @option options [Time] :starting_at listed start time of the performance

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, audio_described, maxx, senior ...)
    #   @return <Array[String]>

    # Omniplex's hall icons and showtime tags, beyond those A1Web chains
    # share. Avenue, D-BOX, 4D E-Motion, MAXX and Sofa Bed are Omniplex's
    # premium screens and seats.
    VARIANTS = {
      '4D E-Motion' => '4d',
      'Audio Described' => 'audio_described',
      'Avenue' => 'avenue',
      'D-BOX' => 'dbox',
      'Event' => 'arts',
      'Infinity Vision' => 'infinity_vision',
      'Infinity Vision 3D' => 'infinity_vision',
      'MAXX' => 'maxx',
      'Seniors Club' => 'senior',
      'Sensory Friendly' => 'relaxed',
      'Sofa Bed' => 'sofabed'
    }.freeze

    # Broadcasts the website gives no Event genre
    LIVE_EVENT = /\bLIVE\b|\ANT Live\b|\bThe Met Opera\b/
    COUNTRY_LANGUAGES = { 'Poland' => 'Polish' }.freeze
    COUNTRY = /\((#{COUNTRY_LANGUAGES.keys.join('|')})\)/

    # Performances within an inclusive range of showing dates. The website
    # lists one day per page, so this reads the venue's advertised dates
    # from its first page, then one page for each other date in the range.
    # @param [String] cinema_id id of the cinema, e.g. 'OMP_KENN'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<OmniplexUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = cinema_class.new(cinema_id)
      if cinema.url.empty?
        []
      else
        showings = listings(cinema.id, from..to).flat_map(&:showings)
        performances = showings.map do |showing|
          new(attributes(showing).merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
        performances.sort_by(&:starting_at)
      end
    end

    # @api private
    def self.cinema_class
      Cinema
    end

    # @api private
    def self.title_sanitizer
      Internal::TitleSanitizer
    end

    # @api private
    def self.variants
      super.merge(VARIANTS)
    end

    def self.listings(site_code, dates)
      client = cinema_class.client
      first = Internal::Listings.new(client.showtimes(site_code))
      first.dates.select { |date| dates.cover?(date) }.map do |date|
        if date == first.date
          first
        else
          Internal::Listings.new(client.showtimes(site_code, date))
        end
      end
    ensure
      client&.close
    end
    private_class_method :listings

    def self.attributes(showing)
      attributes = super
      attributes[:language] ||= COUNTRY_LANGUAGES[showing.title[COUNTRY, 1]]
      attributes
    end
    private_class_method :attributes

    def self.variant(showing)
      variant = super
      variant << 'arts' if showing.title.match?(LIVE_EVENT)
      variant.uniq
    end
    private_class_method :variant
  end
end
