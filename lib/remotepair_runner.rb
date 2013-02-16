require 'net/ssh/gateway'
require 'net/http'
require 'net_ssh_gateway_patch'

class RemotepairRunner
  def run(args)
    case args[0]
    when 'host'
      register_key(get_key(args))
      create_pairing_session
    when 'join'
      register_key(get_key(args))
      join_pairing_session
    else
      raise
    end
  end

  private

  def get_key(args)
    if args[1] == '-k'
      File.read(args[2])
    end
  end

  def register_key(key)
    if key
      Net::HTTP.post_form(
        URI.parse('http://50.116.19.132'),
        key: key
      )
    end
  end

  def create_pairing_session
    # ssh -nvNT -R 2222:localhost:22 user@50.116.19.132

    gateway = Net::SSH::Gateway.new('50.116.19.132', 'jimtom')
    gateway.open_remote(22, 'localhost', 2222) do |remote_port, remote_host|
      puts 'Pairing ...'
      Process.spawn(<<-TMUX)
osascript -e 'tell app "Terminal"
do script "cd #{Dir.pwd} && localjoin"
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

  def join_pairing_session
    # ssh -nvNT -L 8000:localhost:2222 user@50.116.19.132

    gateway = Net::SSH::Gateway.new('50.116.19.132', 'jimtom')
    gateway.open('localhost', 2222, 8000) do |port|
      puts 'Pairing ...'
      Process.spawn(<<-TMUX)
osascript -e 'tell app "Terminal"
do script "cd #{Dir.pwd} && remotejoin"
end tell'
      TMUX
      begin
        sleep 1 while true
      rescue Interrupt
        gateway.close(port)
        exit
      end
    end
  rescue Net::SSH::AuthenticationFailed
    puts 'Failed to authenticate'
    exit
  end
end
