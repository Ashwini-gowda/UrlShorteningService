class UrlShortener < ApplicationRecord
    validates :original, presence: true, format: { with: URI::regexp(%w[http https]) }
    validates :short, uniqueness: true

    before_create :generate_short_url

    private

    def generate_short_url
        self.short = SecureRandom.alphanumeric(6)
    end
end
