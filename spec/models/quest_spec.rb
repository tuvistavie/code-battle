require 'spec_helper'

describe Quest do

  let(:creator_guild) { Guild.first }
  let!(:creator)       { create(:user, guilds: [creator_guild]) }
  let!(:quest)         { create(:quest_with_codes, creator: creator) }
  let!(:creator_code)  { create(:code, author: creator, guild: creator_guild, quest: quest) }
  let(:users) { User.all }

  subject { quest }

  it { should respond_to(:codes) }
  it { should respond_to(:votes) }
  it { should respond_to(:codes) }
  it { should respond_to(:quest_total_votes) }
  it { should respond_to(:creator) }
  it { should respond_to(:finalists) }

  it 'should have right number of codes' do
    expect(subject.codes.count).to eq 11
  end

  describe 'guild_codes' do
    it 'should only return guilds codes' do
      codes = subject.guild_codes(creator_guild)
      expect(codes.pluck(:guild_id).uniq).to eq [creator_guild.id]
    end
  end

  describe 'finalists' do
    let(:guild) { Guild.find(2) }
    let(:other_guild) { Guild.where.not(id: guild.id).first }

    subject { quest.finalists.to_a }

    it 'should not return codes not liked' do
      expect(subject.count).to be 0
    end

    context 'should return most liked codes for each guild' do
      let(:random_finalist) { create(:code, author: users[4], guild: other_guild, quest: quest) }
      let(:non_finalist) { create(:code, author: users[3], guild: guild, quest: quest) }
      let(:finalist) { create(:code, author: users[2], guild: guild, quest: quest) }

      before(:each) do
        finalist.update(likes_count: 4)
        non_finalist.update(likes_count: 3)
        random_finalist.update(likes_count: 2)
        quest.finalists.reload
      end

      after(:each) do
        Code.update_all(likes_count: 0)
      end

      it { expect(subject.count).to be 2}
      it { should include(finalist, random_finalist) }
      it { should_not include(non_finalist) }
    end
  end
end
