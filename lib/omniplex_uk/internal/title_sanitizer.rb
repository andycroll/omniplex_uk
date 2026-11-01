module OmniplexUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # The website loses some apostrophes, e.g. 'Andre Rieu?s'
      LOST_APOSTROPHE = /(\w)\?(s)\b/

      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [OmniplexUk::Internal::TitleSanitizer]

      # sanitized and standardized title
      # @return [String] sanitised title
      def sanitized
        @restored ||= super.gsub(LOST_APOSTROPHE, "\\1'\\2")
      end

      private

      # strings and regex to be removed
      def remove
        [
          /\s*\(Omniplex Classics\)/i,  # classics season
          /\s*\(Sunrise Screening\)/i,  # early screening
          /\s*\(Poland\)/,              # Polish film
          /\s+Encore\z/i                # encore screening
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(.*?)\s+-\s*LIVE\s*-\s*The Royal (?:Ballet|Opera) \d{2}-\d{2}\z/ => 'Royal Ballet and Opera: ',
          /\A(.*?)\s+-\s+The Met Opera \d{2}-\d{2}\z/                       => 'Met Opera: ',
          /\ANT Live:\s*(.*)/                                                => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
