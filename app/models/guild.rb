# == Schema Information
#
# Table name: guilds
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  url_safe_name :string(255)
#  users_count   :integer          default(0), not null
#

class Guild < ActiveRecord::Base
  has_many :codes
  has_many :votes
  has_many :quests, through: :votes
  has_many :guild_members_counts

  has_and_belongs_to_many :users,
                          -> { uniq },
                          join_table: 'user_guilds',
                          after_add: -> (g, u) { g.handle_user_add },
                          after_remove: -> (g, u) { g.handle_user_remove }

  has_and_belongs_to_many :recent_users,
                          -> { order(created_at: :desc)
                              .uniq
                              .limit(16)
                              .readonly },
                          join_table: 'user_guilds',
                          class_name: 'User'

  def to_param
    url_safe_name
  end

  def get_guild_coefficient
    1.0 - (self.users_count / User.count)
  end

  def get_total_vote_point
    h = Hash.new
    h.default = 0
    tv_all = TotalVote.all
    tv_all.each do |i|
      h[i.voted_guild_id] += i.vote_num * Guild.find(i.voting_guild_id).get_guild_coefficient
    end
    h
  end

  def get_guild_ranking
    h = get_total_vote_point.sort_by{|_,v| -v }
    ary = Array.new
    h.each{|i| ary << Guild.find_by_id(i[0])}
    ary
  end

  def get_territory_percent
    total = 0
    tvp = get_total_vote_point
    tvp.each{|i| total += i[1]}
    return (tvp.has_key?(self.id) && total != 0)? tvp[self.id] / total : 0
  end

  def get_my_rank
    ary = get_guild_ranking
    ary.each_with_index do |g,i|
      return i+1 if g.id == self.id
    end
    ary.size + 1
  end

  def handle_user_add
    self.increment!(:users_count)
    self.log_users_count!
  end

  def handle_user_remove
    self.decrement!(:users_count)
    self.log_users_count!
  end

  def log_users_count!
    self.guild_members_counts.create!(datetime: Time.now, members_count: self.users_count)
  end

  def territorys
    self.as_json.merge({
        territory: self.get_territory_percent
      })
  end
end
