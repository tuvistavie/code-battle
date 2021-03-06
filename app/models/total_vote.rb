# == Schema Information
#
# Table name: total_votes
#
#  id              :integer          not null, primary key
#  voting_guild_id :integer
#  voted_guild_id  :integer
#  vote_num        :integer
#

class TotalVote < ActiveRecord::Base
  belongs_to :voting_guild, foreign_key:"voting_guild_id", class_name: "Guild"
  belongs_to :voted_guild, foreign_key:"voted_guild_id", class_name: "Guild"

  def inc_num
    self.vote_num+=1
    self.save!
  end

  def dec_num
    self.vote_num-=1
    self.save!
  end
end
