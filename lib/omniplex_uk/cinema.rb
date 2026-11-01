module OmniplexUk
  # The object representing a cinema on the Omniplex Cinemas website
  class Cinema < Cinebase::A1web::Cinema
    # @!attribute [r] id
    #   @return [String] the Admit One site code of the cinema, e.g. 'OMP_KENN'

    # @!method initialize(id)
    #   @param [String] id the cinema id, e.g. 'OMP_KENN' or 'omp_kenn'
    #   @return [OmniplexUk::Cinema]

    # @!method self.all
    #   Return basic cinema information for the UK cinemas: Great Britain
    #   and Northern Ireland, not the Republic of Ireland
    #   @return [Array<OmniplexUk::Cinema>]
    #   @example
    #     OmniplexUk::Cinema.all
    #     #=> [<OmniplexUk::Cinema>, <OmniplexUk::Cinema>, ...]

    # @!method adr
    #   Address of the cinema
    #   @return [Hash] contains :street_address, :extended_address,
    #   :locality, :region, :postal_code, :country_name
    #   @example
    #     cinema = OmniplexUk::Cinema.new('OMP_KENN')
    #     cinema.adr
    #     #=> {
    #           street_address:   'Kennedy Centre',
    #           extended_address: '564-568 Falls Road',
    #           locality:         'Belfast',
    #           region:           'County Antrim',
    #           postal_code:      'BT11 9AB',
    #           country_name:     'United Kingdom'
    #         }
    #   @note Uses method naming as at http://microformats.org/wiki/adr

    # @!method latitude
    #   @return [Float, nil]

    # @!method longitude
    #   @return [Float, nil]

    # @!method name
    #   The name of the cinema
    #   @return [String]
    #   @example
    #     OmniplexUk::Cinema.new('OMP_KENN').name
    #     #=> 'Belfast - Kennedy Centre'

    # @!method url
    #   The cinema's listings page, which also selects it on the website
    #   @return [String]
    #   @example
    #     OmniplexUk::Cinema.new('OMP_KENN').url
    #     #=> 'https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_KENN'

    # Addresses and coordinates from the address block and directions link
    # on each venue's listings page, except High Wycombe and Sutton, which
    # have neither and come from OpenStreetMap.
    LOCATIONS = {
      'OMP_ANTR' => {
        street_address: 'Junction One Retail Park', locality: 'Antrim', region: 'County Antrim',
        postal_code: 'BT41 4LL', latitude: 54.7297, longitude: -6.2311
      },
      'OMP_BANB' => {
        street_address: 'Unit 4-12, The Outlet', locality: 'Banbridge', region: 'County Down',
        postal_code: 'BT32 4GJ', latitude: 54.3326344, longitude: -6.2783001
      },
      'OMP_BANG' => {
        street_address: 'Valentines Road', locality: 'Bangor', region: 'County Down',
        postal_code: 'BT20 4JH', latitude: 54.6548005, longitude: -5.6631795
      },
      'OMP_BIRM' => {
        street_address: 'Great Park', extended_address: 'Rubery', locality: 'Birmingham',
        region: 'West Midlands', postal_code: 'B45 9JL', latitude: 52.39882, longitude: -2.00826
      },
      'OMP_CARR' => {
        street_address: 'Unit 3-4, Rodgers Quay', locality: 'Carrickfergus', region: 'County Antrim',
        postal_code: 'BT38 8BE', latitude: 54.7123617, longitude: -5.8125379
      },
      'OMP_CLYD' => {
        street_address: '23 Britannia Way', locality: 'Clydebank', region: 'West Dunbartonshire',
        postal_code: 'G81 2RZ', latitude: 55.9015, longitude: -4.4056
      },
      'OMP_CRAI' => {
        street_address: 'Highfield Heights', locality: 'Craigavon', region: 'County Armagh',
        postal_code: 'BT64 3AE', latitude: 54.4492, longitude: -6.3985
      },
      'OMP_DERR' => {
        street_address: 'Quayside Centre', extended_address: 'Strand Road', locality: 'Derry',
        region: 'County Londonderry', postal_code: 'BT48 7PX', latitude: 55.0002376, longitude: -7.3215562
      },
      'OMP_DOWN' => {
        street_address: '5 Owenbeg Avenue', locality: 'Downpatrick', region: 'County Down',
        postal_code: 'BT30 6FJ', latitude: 54.3237579, longitude: -5.7139260
      },
      'OMP_DUDO' => {
        street_address: 'Entertainment Village', extended_address: 'Dundonald', locality: 'Belfast',
        region: 'County Down', postal_code: 'BT16 1YG', latitude: 54.5874, longitude: -5.8189
      },
      'OMP_DUGA' => {
        street_address: 'Oaks Retail Park', extended_address: 'Oaks Road', locality: 'Dungannon',
        region: 'County Tyrone', postal_code: 'BT71 4AR', latitude: 54.5125018, longitude: -6.7616527
      },
      'OMP_GLAS' => {
        street_address: '7 Renfrew Street', locality: 'Glasgow', region: 'Glasgow City',
        postal_code: 'G2 3AB', latitude: 55.864976, longitude: -4.254477
      },
      'OMP_HIWY' => {
        street_address: 'Crest Road', locality: 'High Wycombe', region: 'Buckinghamshire',
        postal_code: 'HP11 1UA', latitude: 51.6131257, longitude: -0.7719008
      },
      'OMP_IPSW' => {
        street_address: '1 Buttermarket Shopping Centre', locality: 'Ipswich', region: 'Suffolk',
        postal_code: 'IP1 1DT', latitude: 52.0575, longitude: 1.1550
      },
      'OMP_KENN' => {
        street_address: 'Kennedy Centre', extended_address: '564-568 Falls Road', locality: 'Belfast',
        region: 'County Antrim', postal_code: 'BT11 9AB', latitude: 54.58149, longitude: -5.97779
      },
      'OMP_LARN' => {
        street_address: 'Larne Leisure Park', extended_address: 'Redlands Road', locality: 'Larne',
        region: 'County Antrim', postal_code: 'BT40 1FD', latitude: 54.8470005, longitude: -5.8102719
      },
      'OMP_LISB' => {
        street_address: 'Lisburn Leisure Park', extended_address: 'Governors Road', locality: 'Lisburn',
        region: 'County Antrim', postal_code: 'BT28 1LP', latitude: 54.507481, longitude: -6.051616
      },
      'OMP_NEWR' => {
        street_address: 'The Quays Shopping Centre', locality: 'Newry', region: 'County Down',
        postal_code: 'BT35 8QS', latitude: 54.1688, longitude: -6.3401
      },
      'OMP_OMAG' => {
        street_address: 'Kevlin Road', locality: 'Omagh', region: 'County Tyrone',
        postal_code: 'BT78 1JL', latitude: 54.5965088, longitude: -7.3006357
      },
      'OMP_SUND' => {
        street_address: '4 Lambton Street', locality: 'Sunderland', region: 'Tyne and Wear',
        postal_code: 'SR1 1TP', latitude: 54.9082446, longitude: -1.3800217
      },
      'OMP_SUTT' => {
        street_address: 'St Nicholas Centre', extended_address: 'St Nicholas Way', locality: 'Sutton',
        region: 'Greater London', postal_code: 'SM1 1AY', latitude: 51.3647655, longitude: -0.1953102
      },
      'OMP_WIGA' => {
        street_address: 'Unit 2, Robin Leisure Park', locality: 'Wigan', region: 'Greater Manchester',
        postal_code: 'WN5 0UJ', latitude: 53.54603, longitude: -2.65797
      }
    }.freeze

    # @return [String]
    def self.website
      Internal::Client::WEBSITE
    end

    # @api private
    # @return [OmniplexUk::Internal::Client]
    def self.client
      Internal::Client.new
    end

    # @api private
    def self.locations
      LOCATIONS
    end

    # Brand of the cinema
    # @return [String] which will always be 'Omniplex'
    def brand
      'Omniplex'.freeze
    end
  end
end
