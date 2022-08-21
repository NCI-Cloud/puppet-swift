require 'spec_helper'

describe 'swift::internal_client::cache' do
  shared_examples 'swift::internal_client::cache' do

    describe 'without memcached being included' do
      it 'should raise an error' do
        expect { catalogue }.to raise_error(Puppet::Error)
      end
    end

    describe 'with memcached dependency' do
      let :pre_condition do
        'class { "memcached": max_memory => 1 }'
      end

      describe 'with defaults' do
        it 'should have the required classes' do
          is_expected.to contain_class('swift::deps')
          is_expected.to contain_class('swift::internal_client::cache')
        end

        it { is_expected.to contain_swift_internal_client_config('filter:cache/use').with_value('egg:swift#memcache') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/memcache_servers').with_value('127.0.0.1:11211') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/tls_enabled').with_value(false) }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/memcache_max_connections').with_value(2) }
      end

      describe 'with overridden memcache server' do
        let :params do
          {:memcache_servers => '10.0.0.1:1'}
        end

        it { is_expected.to contain_swift_internal_client_config('filter:cache/use').with_value('egg:swift#memcache') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/memcache_servers').with_value('10.0.0.1:1') }
      end

      describe 'with overridden memcache server array' do
        let :params do
          {:memcache_servers => ['10.0.0.1:1', '10.0.0.2:2']}
        end

        it { is_expected.to contain_swift_internal_client_config('filter:cache/use').with_value('egg:swift#memcache') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/memcache_servers').with_value('10.0.0.1:1,10.0.0.2:2') }
      end

      describe 'with overridden cache TLS enabled' do
        let :params do
          {:tls_enabled => true}
        end

        it { is_expected.to contain_swift_internal_client_config('filter:cache/use').with_value('egg:swift#memcache') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/tls_enabled').with_value(true) }
      end

      describe 'with overridden memcache max connections' do
        let :params do
          {:memcache_max_connections => 4}
        end

        it { is_expected.to contain_swift_internal_client_config('filter:cache/use').with_value('egg:swift#memcache') }
        it { is_expected.to contain_swift_internal_client_config('filter:cache/memcache_max_connections').with_value(4) }
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_configures 'swift::internal_client::cache'
    end
  end
end
