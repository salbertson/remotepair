require 'net/ssh'
require 'net/ssh/gateway'

# ssh -nvNT -R 2222:localhost:22 desi@50.116.19.132

class Tunnel
  attr_reader :host, :port, :user

  def initialize(host, port)
    @host = host
    @port = port.to_i
  end

  def start
    gateway = Net::SSH::Gateway.new(host, 'desi', password: 'imawesome')
    gateway.open_remote(22, 'localhost', port) do |remote_port, remote_host|
      puts 'Tunnel is open ...'
      Process.spawn(<<-TMUX)
osascript -e 'tell app "Terminal"
  do script "cd #{Dir.pwd} && ruby localjoin.rb"
end tell'
      TMUX
      begin
        sleep 1 while true
      rescue Interrupt
        gateway.close_remote(remote_port, remote_host)
        exit
      end
    end
  rescue Net::SSH::AuthenticationFailed
    puts 'Failed to authenticate'
    exit
  end
end

# http://groups.google.com/group/capistrano/browse_thread/thread/455c0c8a6faa9cc8?pli=1
class Net::SSH::Gateway
  # Opens a SSH tunnel from a port on a remote host to a given host and port
  # on the local side
  # (equivalent to openssh -R parameter)
  def open_remote(port, host, remote_port, remote_host = "127.0.0.1")
    ensure_open!

    @session_mutex.synchronize do
      @session.forward.remote(port, host, remote_port, remote_host)
    end

    if block_given?
      begin
        yield [remote_port, remote_host]
      ensure
        close_remote(remote_port, remote_host)
      end
    else
      return [remote_port, remote_host]
    end
  rescue Errno::EADDRINUSE
    retry
  end

  # Cancels port-forwarding over an open port that was previously opened via
  # #open_remote.
  def close_remote(port, host = "127.0.0.1")
    ensure_open!

    @session_mutex.synchronize do
      @session.forward.cancel_remote(port, host)
    end
  end
end
