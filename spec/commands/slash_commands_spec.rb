require 'rails_helper'

RSpec.describe SlashCommands do
  let(:slashdeploy) { instance_double(SlashDeploy::Service) }
  let(:handler) { described_class.new slashdeploy }

  describe '#route' do
    it 'routes to the correct handler' do
      a = instance_double(SlackAccount, slack_team: stub_model(SlackTeam, github_organization: 'acme-inc'))

      check_route(a, 'help', HelpCommand, {})

      check_route(a, 'where acme-inc/api', EnvironmentsCommand, 'repository' => 'acme-inc/api')
      check_route(a, 'where api', EnvironmentsCommand, 'repository' => 'acme-inc/api')

      check_route(a, 'lock staging on acme-inc/api: Doing stuff', LockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'message' => ' Doing stuff', 'force' => nil)
      check_route(a, 'lock staging on acme-inc/api', LockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'message' => nil, 'force' => nil)
      check_route(a, 'lock staging on api', LockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'message' => nil, 'force' => nil)
      check_route(a, 'lock staging on api!', LockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'message' => nil, 'force' => '!')
      check_route(a, 'lock staging on api: Doing stuff!', LockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'message' => ' Doing stuff', 'force' => '!')

      check_route(a, 'unlock all', UnlockAllCommand, {})
      check_route(a, 'unlock staging on acme-inc/api', UnlockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging')
      check_route(a, 'unlock staging on api', UnlockCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging')

      check_route(a, 'check production on acme-inc/api', CheckCommand, 'repository' => 'acme-inc/api', 'environment' => 'production')

      check_route(a, 'boom', BoomCommand, {})

      check_route(a, 'acme-inc/api', DeployCommand, 'repository' => 'acme-inc/api', 'force' => nil, 'ref' => nil, 'environment' => nil)
      check_route(a, 'acme-inc/api!', DeployCommand, 'repository' => 'acme-inc/api', 'force' => '!', 'ref' => nil, 'environment' => nil)
      check_route(a, 'acme-inc/api@topic', DeployCommand, 'repository' => 'acme-inc/api', 'ref' => 'topic', 'force' => nil, 'environment' => nil)
      check_route(a, 'acme-inc/api@topic!', DeployCommand, 'repository' => 'acme-inc/api', 'ref' => 'topic', 'force' => '!', 'environment' => nil)
      check_route(a, 'acme-inc/api to staging', DeployCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'force' => nil, 'ref' => nil)
      check_route(a, 'acme-inc/api to staging!', DeployCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'force' => '!', 'ref' => nil)
      check_route(a, 'acme-inc/api to staging', DeployCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'force' => nil, 'ref' => nil)
      check_route(a, 'acme-inc/api to staging!', DeployCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'force' => '!', 'ref' => nil)
      check_route(a, 'acme-inc/api@topic to staging', DeployCommand, 'repository' => 'acme-inc/api', 'ref' => 'topic', 'environment' => 'staging', 'force' => nil)
      check_route(a, 'acme-inc/api@topic to staging!', DeployCommand, 'repository' => 'acme-inc/api', 'ref' => 'topic', 'environment' => 'staging', 'force' => '!')

      check_route(a, 'api to staging', DeployCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging', 'force' => nil, 'ref' => nil)

      check_route(a, 'latest acme-inc/api', LatestCommand, 'repository' => 'acme-inc/api', 'environment' => nil)
      check_route(a, 'latest acme-inc/api to staging', LatestCommand, 'repository' => 'acme-inc/api', 'environment' => 'staging')
    end

    def check_route(account, text, expected_handler, expected_params)
      env = { 'cmd' => Slash::Command.from_params(text: text), 'account' => account }
      router = SlashCommands.route
      route = router.route(env)

      expect(route.match(env)).to eq expected_params
      expect(route.handler).to eq expected_handler
    end
  end
end
