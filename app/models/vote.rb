# == Schema Information
#
# Table name: votes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  problem_id :integer
#  guild_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class Vote < ActiveRecord::Base
end
