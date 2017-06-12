# User represents a user of SlashDeploy.
class User < ActiveRecord::Base
  has_many :github_accounts
  has_many :slack_accounts
  has_many :auto_deployments

  # Raised if the user doesn't have a github account.
  MissingGitHubAccount = Class.new(StandardError)

  def self.find_by_github_account_id(id)
    account = GitHubAccount.find_by(id: id)
    account.user if account
  end

  def enable_slack_notifications!
    update_attributes! slack_notifications: true
  end

  def identifier
    "#{id}:#{username}"
  end

  def deployer
    self
  end

  def username
    github_account.login
  end

  def self.find_by_slack(id)
    account = SlackAccount.where(id: id).first
    return unless account
    account.user
  end

  def self.find_by_github(id)
    account = GitHubAccount.where(id: id).first
    return unless account
    account.user
  end

  def slack_account?(slack_account)
    slack_accounts.find do |account|
      account.id == slack_account.id
    end
  end

  def github_account?(github_account)
    github_accounts.find do |account|
      account.id == github_account.id
    end
  end

  def github_account
    github_accounts.first || fail(MissingGitHubAccount)
  end

  def github_token
    account = github_account
    return unless account
    account.token
  end

  def github_login
    account = github_account
    return unless account
    account.login
  end

  def octokit_client
    @client ||= Octokit::Client.new(access_token: github_token)
  end

  # Returns the SlackAccount that should be used when sending direct messages
  # related to the GitHub organization.
  #
  # Returns nil if no matching account is found.
  def slack_account_for_github_organization(organization)
    slack_accounts.find { |account| account.github_organization == organization }
  end
end
