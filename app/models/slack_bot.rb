class SlackBot < ActiveRecord::Base
  belongs_to :slack_team

  def self.from_auth_hash(auth_hash)
    bot_info = auth_hash[:extra][:bot_info]
    bot = find_or_create_by(id: bot_info[:bot_user_id]) do |bot|
      bot.access_token = bot_info[:bot_access_token]
      bot.slack_team_id = auth_hash[:info][:team_id]
    end
    if bot.access_token != bot_info[:bot_access_token]
      bot.access_token = bot_info[:bot_access_token]
    end
    return bot
  end
end
