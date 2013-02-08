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
    end
  end
end
