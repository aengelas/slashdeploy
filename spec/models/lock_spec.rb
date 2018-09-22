require 'rails_helper'

RSpec.describe Lock, type: :model do
  describe '#lock!' do
    fixtures :users
    let(:user) { users(:david) }

    it 'only allows for 1 active lock per environment' do
      repo = Repository.with_name('acme-inc/api')

      # Trying the lock the same environment should result in an error.
      staging = repo.environment('staging')
      expect { staging.lock! user }.to change { staging.locks.count }.by(1)
      expect do
        expect { staging.lock! user }.to raise_error ActiveRecord::RecordNotUnique
      end.to_not change { staging.locks.count }

      # Trying to lock a different environment for the same repo should be fine.
      prod = repo.environment('production')
      expect { prod.lock! user }.to change { prod.locks.count }.by(1)
    end
  end
end
