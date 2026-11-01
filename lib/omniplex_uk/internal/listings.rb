require 'cgi/escape'
require 'date'

module OmniplexUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads one day's showtimes, and the venue's advertised dates, from a
    # listings page.
    class Listings
      # The calendar's dates are local midnights in milliseconds, so dates
      # in British Summer Time fall at 23:00 UTC the day before
      ADVERTISED_DATES = /allowedDatesTimestamps = \[([\d,\s]*)\]/
      PAGE_DATE = /var defaultDate = "(\d{4}-\d{2}-\d{2})"/
      FILM = %r{
        <p\sclass="font-medium\stext-lg[^"]*">\s*<a\s[^>]*>(.*?)</a>\s*</p>
        \s*<img\s[^>]*id="favourite([^"]+)"
      }mx
      GENRES = %r{/images/ratings/[^"]*"[^>]*>\s*<p[^>]*>([^<]*)</p>}
      SHOWTIME = %r{<a aria-label="[^"]*? at (\d{1,2}):(\d{2}) in [^"]*" href="([^"]*)"[^>]*>(.*?)</a>}m
      ICON = %r{<img src="[^"]*/([\w-]+)\.(?:png|svg)"}
      TAG = %r{<span class="text-xs[^"]*">([^<]*)</span>}

      # Hall icons on a showtime, named as the website names them
      ICONS = {
        '4d_emotion' => '4D E-Motion',
        'avenue' => 'Avenue',
        'infinity3d_icon' => 'Infinity Vision 3D',
        'infinity_icon' => 'Infinity Vision',
        'omniplex_mobile-app-2025_svgs_audio-described-alt' => 'Audio Described',
        'omniplex_mobile-app-2025_svgs_dbox-orange' => 'D-BOX',
        'omniplex_mobile-app-2025_svgs_maxx' => 'MAXX',
        'sofabed' => 'Sofa Bed'
      }.freeze

      # Films whose genres include it are live and recorded events
      EVENT_GENRE = 'Event'.freeze
      MILLISECONDS = 1000
      TIME_ZONE = 'Europe/London'.freeze

      # @return [Date, nil] the day this page lists
      attr_reader :date

      # @param [String] html a listings page
      def initialize(html)
        @html = html
        page_date = html[PAGE_DATE, 1]
        @date = Date.iso8601(page_date) if page_date
      end

      # @return [Array<Date>] every date the venue advertises, in order
      def dates
        timestamps = @html[ADVERTISED_DATES, 1].to_s.split(',')
        timestamps.map { |milliseconds| local_date(milliseconds.to_i / MILLISECONDS) }.uniq.sort
      end

      # @return [Array<Cinebase::A1web::Showing>]
      def showings
        if date
          @html.split(FILM).drop(1).each_slice(3).flat_map do |title, film_id, markup|
            film_showings(text(title), film_id, markup.to_s)
          end
        else
          []
        end
      end

      private

      def film_showings(title, film_id, markup)
        genres = markup[GENRES, 1].to_s.split(',').map(&:strip)
        film_tags = genres.include?(EVENT_GENRE) ? [EVENT_GENRE] : []
        markup.scan(SHOWTIME).map do |hour, minute, href, box|
          Cinebase::A1web::Showing.new(
            film_id: film_id, title: title, date: date, starting_at: starting_at(hour.to_i, minute.to_i),
            booking_url: CGI.unescapeHTML(href), tags: film_tags + tags(box)
          )
        end
      end

      def tags(box)
        icons = box.scan(ICON).flatten.filter_map { |icon| ICONS[icon] }
        icons + box.scan(TAG).flatten.map { |tag| text(tag) }
      end

      def local_date(seconds)
        TZInfo::Timezone.get(TIME_ZONE).to_local(Time.at(seconds).utc).to_date
      end

      def starting_at(hour, minute)
        local = Time.utc(date.year, date.month, date.day, hour, minute)
        TZInfo::Timezone.get(TIME_ZONE).local_to_utc(local) { |periods| periods.first }.utc
      end

      def text(html)
        CGI.unescapeHTML(html.gsub(/<[^>]*>/, ' ')).gsub(/\s+/, ' ').strip
      end
    end
  end
end
