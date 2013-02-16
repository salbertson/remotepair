require 'spec_helper'
require 'remotepair_runner'

describe RemotepairRunner do
  describe '#run' do
    context 'with host argument' do
      it 'creates pairing session' do
        runner = RemotepairRunner.new
        gateway = mock(:open_remote)
        Net::SSH::Gateway.stubs(new: gateway)

        runner.run(['host'])

        expect(gateway).to have_received(:open_remote).with(22, 'localhost', 2222)
      end

      it 'shows authentication error' do
        runner = RemotepairRunner.new
        gateway = stub
        gateway.stubs(:open_remote).raises(Net::SSH::AuthenticationFailed)
        Net::SSH::Gateway.stubs(new: gateway)

        expect { runner.run(['host']) }.to raise_error(SystemExit)
      end

      it 'registers a public key' do
        runner = RemotepairRunner.new
        Net::SSH::Gateway.stubs(new: stub(:open_remote))
        net_http = mock(:post_form)
        Net::HTTP = net_http
        uri = URI.parse('http://50.116.19.132')
        File.stubs(read: 'somepublickey')

        runner.run(['host', '-k', '/Users/user/.ssh/id_rsa.pub'])

        expect(File).to have_received(:read).with('/Users/user/.ssh/id_rsa.pub')
        expect(net_http).to have_received(:post_form).with(uri, key: 'somepublickey')
      end
    end

    context 'joins pairing session' do
      it 'joins session' do
        runner = RemotepairRunner.new
        gateway = mock(:open)
        Net::SSH::Gateway.stubs(new: gateway)

        runner.run(['join'])

        expect(gateway).to have_received(:open).with('localhost', 2222, 8000)
      end

      it 'shows authentication error' do
        runner = RemotepairRunner.new
        gateway = stub
        gateway.stubs(:open).raises(Net::SSH::AuthenticationFailed)
        Net::SSH::Gateway.stubs(new: gateway)

        expect { runner.run(['join']) }.to raise_error(SystemExit)
      end

      it 'registers a public key' do
        runner = RemotepairRunner.new
        Net::SSH::Gateway.stubs(new: stub(:open))
        net_http = mock(:post_form)
        Net::HTTP = net_http
        uri = URI.parse('http://50.116.19.132')
        File.stubs(read: 'somepublickey')

        runner.run(['join', '-k', '/Users/user/.ssh/id_rsa.pub'])

        expect(File).to have_received(:read).with('/Users/user/.ssh/id_rsa.pub')
        expect(net_http).to have_received(:post_form).with(uri, key: 'somepublickey')
      end
    end
  end
end
