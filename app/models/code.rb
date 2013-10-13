# == Schema Information
#
# Table name: codes
#
#  id         :integer          not null, primary key
#  source     :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  guild_id   :integer
#  quest_id   :integer
#

class Code < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :quest
  belongs_to :guild
  has_and_belongs_to_many :users, -> { uniq }, join_table: 'user_like_codes'
  has_many :comments

  self.per_page = 10

  validates_presence_of :guild
  validates_presence_of :quest

  def formatted_source
    Pygments.highlight(self.source, lexer: self.guild.url_safe_name)
  end
end
