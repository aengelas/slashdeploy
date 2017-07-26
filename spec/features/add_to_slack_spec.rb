require 'rails_helper'

RSpec.feature 'Add to Slack' do
  fixtures :all

  after do
    OmniAuth.config.mock_auth[:slack] = nil
  end

  scenario 'clicking the Add to Slack button' do
    OmniAuth.config.mock_auth[:slack] = OmniAuth::AuthHash.new(
      provider: 'slack',
      uid: '123545',
      info: {
        nickname: 'joe',
        team_id: 'XXXXXXXXXX',
        team_domain: 'acme'
      },
      credentials: {
        token: 'xoxt-23984754863-2348975623103'
      },
      extra: {
        bot_info: {
          bot_user_id: 'UTTTTTTTTTTR',
          bot_access_token: 'xoxb-XXXXXXXXXXXX-TTTTTTTTTTTTTT'
        }
      }
    )

    expect do
      visit '/auth/slack/callback'
    end.to change { SlackBot.count }.by(1)
    # expect(page).to have_content 'Success!'
  end
end
