# == Schema Information
#
# Table name: battles
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  quest_id    :integer
#  users_count :integer          default(0)
#  started_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Battle < ActiveRecord::Base
  has_many :gladiators,
    after_add:    -> (b, _) { b.increment!(:users_count) },
    after_remove: -> (b, _) { b.decrement!(:users_count) }

  has_many :users, through: :gladiators

  belongs_to :quest

  def as_json(options={})
    g = { include: { user: { only: [:id, :username] } }, methods: :guild_name }
    super({ include: { gladiators: g },  }.merge(options))
  end

end
