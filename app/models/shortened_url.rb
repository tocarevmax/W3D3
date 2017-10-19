# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  long_url   :string           not null
#  short_url  :string
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord

  validates :long_url, :user_id, uniqueness: true, presence: true

  belongs_to(
      :submitter,
      class_name: :User,
      foreign_key: :user_id,
      primary_key: :id
  )

  has_many(
    :visits,
    class_name: :Visit,
    foreign_key: :shortened_url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :visitor
  )

  def self.random_code
    code = SecureRandom::urlsafe_base64
    while self.exists?(short_url: code)
      code = SecureRandom::urlsafe_base64
    end
    code
  end

  def self.create!(user_obj, long_url_string)
    new_obj = ShortenedUrl.new(user_id: user_obj.id, long_url: long_url_string, short_url: ShortenedUrl.random_code)
    new_obj.save if new_obj.valid?
  end

  def num_clicks
    self.visits.select(:visitor_id).count
  end

  def num_uniques
    # self.visits.select(:visitor_id).distinct.count
    visitors.count
  end

  def num_recent_uniques
    visits.where("created_at > ?", 10.minutes.ago ).count
  end

end
