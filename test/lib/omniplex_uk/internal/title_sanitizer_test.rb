require_relative '../../../test_helper'

class OmniplexUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Avengers: Doomsday', 'Avengers: Doomsday'
  end

  def test_lost_apostrophes
    assert_sanitized "Andre Rieu's 2026 Christmas Concert: Let It Snow", 'Andre Rieu?s 2026 Christmas Concert: Let It Snow'
  end

  def test_seasons_and_screenings
    assert_sanitized 'Scream', 'Scream (1996) (Omniplex Classics)'
    assert_sanitized 'The Hunger Games: Sunrise On The Reaping',
                     'The Hunger Games: Sunrise On The Reaping (Sunrise Screening)'
    assert_sanitized 'Avengers: Endgame', 'Avengers: Endgame Encore'
    assert_sanitized "Pan's Labyrinth", "Pan's Labyrinth (20th Anniversary)"
  end

  def test_language_versions
    assert_sanitized 'Jak zyc, zeby nie zwariowac', 'Jak zyc, zeby nie zwariowac (Poland)'
    assert_sanitized 'Ramayana: Rise of A Legend', 'Ramayana: Rise of A Legend (Hindi)'
  end

  def test_royal_ballet_and_opera_season
    assert_sanitized 'Royal Ballet and Opera: Swan Lake', 'Swan Lake - LIVE - The Royal Ballet 26-27'
    assert_sanitized 'Royal Ballet and Opera: Carmen', 'Carmen - LIVE- The Royal Opera 26-27'
  end

  def test_met_opera_and_national_theatre
    assert_sanitized 'Met Opera: La Fanciulla Del West', 'La Fanciulla Del West - The Met Opera 26-27'
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, OmniplexUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
