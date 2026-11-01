# OmniplexUk

A simple gem to pull cinemas and performances from the [Omniplex Cinemas website](https://www.omniplexcinemas.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'omniplex_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniplex_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing classics,
encore and anniversary markers, language versions and years, and giving
Royal Ballet and Opera, Met Opera and National Theatre Live broadcasts the
standard prefixes.

No token or setup is needed. Omniplex's UK website runs on Admit One, but
with its own templates rather than the A1Web pages that cinebase's
`Cinebase::A1web` reads, so the gem has its own client. The gem covers the UK
venues only: Great Britain and Northern Ireland. The Republic of Ireland
venues are on omniplex.ie.

### Cinema

The venue list is cached for an hour. Ids are the website's site codes, such
as `OMP_KENN`. The gem holds each venue's address and coordinates, from the
address block and directions link on its listings page. High Wycombe and
Sutton have neither, so theirs come from OpenStreetMap.

``` ruby
OmniplexUk::Cinema.all
#=> [<OmniplexUk::Cinema ...>, <OmniplexUk::Cinema ...>, ...]

cinema = OmniplexUk::Cinema.new('OMP_KENN')
#=> <OmniplexUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Kennedy Centre',
  extended_address: '564-568 Falls Road',
  locality:         'Belfast',
  region:           'County Antrim',
  postal_code:      'BT11 9AB',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Omniplex'

cinema.full_name
#=> 'Omniplex Belfast - Kennedy Centre'

cinema.id
#=> 'OMP_KENN'

cinema.latitude
#=> 54.58149

cinema.url
#=> 'https://www.omniplexcinemas.co.uk/cinema/showtimes?sitecode=OMP_KENN'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The website lists one
day per page. The first page also lists every date the venue advertises, so
the gem then reads only those dates in the range, one after another over one
connection. A year's range for one venue is about 45 to 60 requests.

``` ruby
OmniplexUk::Performance.at('OMP_SUND', from: Date.today, to: Date.today + 2)
#=> [<OmniplexUk::Performance ...>, <OmniplexUk::Performance ...>, ...]

performance = OmniplexUk::Performance.at('OMP_SUND').first
#=> <OmniplexUk::Performance ...>

performance.film_name
#=> 'Clayface'

performance.language
#=> nil # e.g. 'Hindi' from '(Hindi)' in the title

performance.film_year
#=> nil # from the title, e.g. 1996 for 'Scream (1996) (Omniplex Classics)'

performance.dimension
#=> '2d'

performance.variant
#=> ['maxx']

performance.subtitled?
#=> false

performance.starting_at
#=> 2026-11-01 16:20:00 UTC

performance.booking_url
#=> 'https://www.omniplexcinemas.co.uk/booking/seats/sunderland/44797'

performance.cinema_name
#=> 'Sunderland'

performance.cinema_id
#=> 'OMP_SUND'
```

Booking links go straight to seat selection for the performance.

Variants come from the hall icons and tags on each showtime, and the film's
Event genre:

| Website | Variant |
| --- | --- |
| Event genre, LIVE broadcasts | `arts` |
| Audio Described | `audio_described` |
| Avenue | `avenue` |
| D-BOX | `dbox` |
| 4D E-Motion | `4d` |
| Infinity Vision, Infinity Vision 3D | `infinity_vision` |
| MAXX | `maxx` |
| Seniors Club | `senior` |
| Sensory Friendly | `relaxed` |
| Sofa Bed | `sofabed` |
| Subtitled | `subtitled` |

Infinity Vision 3D showings are also `3d`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live omniplexcinemas.co.uk
```

Fixtures in `test/fixtures` are pages captured from omniplexcinemas.co.uk,
trimmed to a few films and showtimes, with the Sunderland calendar cut to the
dates captured. They keep the site's mix of UTF-8 and Windows-1252 bytes.
`test/support/api_shapes.rb` describes the parts of the pages the gem reads.
The unit suite checks the fixtures against it and the live suite checks real
responses, held only in memory. When the website changes, update the shape
first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
