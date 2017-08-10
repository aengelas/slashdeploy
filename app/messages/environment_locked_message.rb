class EnvironmentLockedMessage < SlackMessage
  values do
    attribute :environment, Environment
    attribute :lock, Lock
    attribute :message_action, MessageAction
  end

  def to_message
    Slack::Message.new text: text(locker: locker), attachments: [
      Slack::Attachment.new(
        title: 'Steal the lock?',
        callback_id: message_action.callback_id,
        color: '#3AA3E3',
        actions: SlackMessage.confirmation_actions
      )
    ]
  end

  private

  def locker
    slack_account lock.user
  end
end
